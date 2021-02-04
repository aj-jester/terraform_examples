#!/bin/bash

# Variables set by TF
ENI_ID=${eni_id}
VPC_DNS=${vpc_dns}

describe_eni () {
  aws ec2 describe-network-interfaces \
    --network-interface-ids $${ENI_ID} \
    --region $${REGION} \
    --query 'NetworkInterfaces[0]'
}

attach_eni () {
  aws ec2 attach-network-interface \
    --network-interface-id $${ENI_ID} \
    --instance-id $${INSTANCE_ID} \
    --device-index 1 \
    --region $${REGION}
}

detach_eni () {
  aws ec2 detach-network-interface \
    --attachment-id $${ATTACHMENT_ID} \
    --force \
    --region $${REGION}
}

echo_strip () {
  content=$$1
  content="$${content%\"}"
  content="$${content#\"}"
  echo "$${content}"
}

override_resolv_conf () {
  [ -f /etc/resolv.conf ] && mv /etc/resolv.conf /etc/resolv.conf.old
cat > /etc/resolv.conf << RESOLV_CONF
nameserver $${VPC_DNS}
RESOLV_CONF
}

install_deps () {
  while ! ping -c 1 -W 1 google.com; do
    echo "Waiting for connectivity -  might not be up just yet..."
    sleep 1
  done

  yum -y install epel-release
  yum -y install python-pip jq unbound
  pip install awscli
}

attempt_to_attach_eni () {
for i in {1..6}
do
  ENI_DATA=describe_eni
  ATTACHMENT_STATUS=$$(echo_strip $$($$ENI_DATA | jq .Attachment.Status))

  if [ "$${ATTACHMENT_STATUS}" == "null" ]; then
    echo "Attaching $${ENI_ID} to $${INSTANCE_ID}."

    ATTACHMENT_ID=$$(echo_strip $$(attach_eni | jq .AttachmentId))

    if [[ $${ATTACHMENT_ID} =~ ^eni-attach- ]]; then
      echo "Successfuly attached $${ATTACHMENT_ID}."

      echo "Waiting for eth1 to initialize."
      sleep 10
      break

    else
      echo "Failed to attach $${ENI_ID}."
      exit 1
    fi

  elif [ "$${ATTACHMENT_STATUS}" == "attached" ]; then
    ATTACHMENT_ID=$$(echo_strip $$($$ENI_DATA | jq .Attachment.AttachmentId))
    ATTACHED_INSTANCE=$$(echo_strip $$($$ENI_DATA | jq .Attachment.InstanceId))

    echo "Detaching $${ENI_ID} from $${ATTACHED_INSTANCE}."

    detach_eni

  else
    ATTACHED_INSTANCE=$$(echo_strip $$($$ENI_DATA | jq .Attachment.InstanceId))
    echo "Unable to attach, retrying. Status: $${ATTACHMENT_STATUS}; Instance: $${ATTACHED_INSTANCE}."
  fi

  if [ "$$i" -ge 6 ]; then
    echo "Failed all attempts to attach $${ENI_ID}, aborting."
    exit 1
  fi

  sleep 10
done
}

configure_eth1 () {

cat > /etc/sysconfig/network << SYS_NET
NETWORKING=yes
NOZEROCONF=yes
GATEWAYDEV=eth0
SYS_NET

cat > /etc/sysconfig/network-scripts/ifcfg-eth1 << IFCFG_ETH1
DEVICE="eth1"
BOOTPROTO="dhcp"
ONBOOT="yes"
TYPE="Ethernet"
USERCTL="yes"
PEERDNS="yes"
IPV6INIT="no"
PERSISTENT_DHCLIENT="1"
IFCFG_ETH1

cat > /etc/sysconfig/network-scripts/route-eth1 << ROUTE_ETH1
default via $${GATEWAY} dev eth1 table 2
$${NETWORK} dev eth1 src $${ETH1_IP} table 2
ROUTE_ETH1

cat > /etc/sysconfig/network-scripts/rule-eth1 << RULE_ETH1
from $${ETH1_IP}/32 table 2
RULE_ETH1

ifdown eth1 >/dev/null 2>&1
ifup eth1 >/dev/null

ip rule | grep "$${ETH1_IP} lookup 2" >/dev/null

if [ "$$?" -eq 0 ]; then
  echo "Configured eth1 successfully."
else
  echo "Failed to configure eth1."
  exit 1
fi

}

configure_unbound () {

cat > /etc/unbound/unbound.conf << UNBOUND_CONF
server:
        interface: $${ETH0_IP}
        interface: $${ETH1_IP}
        access-control: 10.0.0.0/8 allow
forward-zone:
        name: "."
        forward-addr: $${VPC_DNS}
${forward_zones}
UNBOUND_CONF

  systemctl start unbound.service

  total_procs=$$(netstat -tulpn | grep /unbound | wc -l)

  # Ensure 4 procs are running, ETH0 and ETH1 interfaces and TCP and UDP protocols.
  if [ "$${total_procs}" -eq 4 ]; then
    echo "Unbound started successfully."
  else
    echo "Failed to start Unbound."
    exit 1
  fi

}



override_resolv_conf

install_deps

INSTANCE_DATA=$$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document)

REGION=$$(echo_strip $$(echo $${INSTANCE_DATA} | jq .region))
INSTANCE_ID=$$(echo_strip $$(echo $${INSTANCE_DATA} | jq .instanceId))

NETWORK=$$(ip route show default | sed -n 2p | cut -d " " -f1)
GATEWAY=$$(ip route show default | sed -n 1p | cut -d " " -f3)
ETH0_IP=$$(echo_strip $$(echo $${INSTANCE_DATA} | jq .privateIp))
ETH1_IP=$$(echo_strip $$(describe_eni | jq .PrivateIpAddress))

attempt_to_attach_eni
configure_eth1
configure_unbound
