metadata:
  creationTimestamp: null
  name: ${cluster_name}
spec:
  adminAccess:
  - 0.0.0.0/0
  channel: stable
  cloudProvider: aws
  clusterDNSDomain: cluster.local
  configBase: s3://${s3_bucket_id}/${cluster_name}
  configStore: s3://${s3_bucket_id}/${cluster_name}
  dnsZone: ${dns_zone}
  docker:
    bridge: ""
    ipMasq: false
    ipTables: false
    logLevel: warn
    storage: overlay,aufs
  etcdClusters:
  - etcdMembers:
${etc_members}
    name: main
  - etcdMembers:
${etc_members}
    name: events
  keyStore: s3://${s3_bucket_id}/${cluster_name}/pki
  kubeAPIServer:
    address: 127.0.0.1
    admissionControl:
    - NamespaceLifecycle
    - LimitRanger
    - ServiceAccount
    - PersistentVolumeLabel
    - DefaultStorageClass
    - ResourceQuota
    allowPrivileged: true
    apiServerCount: 0
    basicAuthFile: /srv/kubernetes/basic_auth.csv
    clientCAFile: /srv/kubernetes/ca.crt
    cloudProvider: aws
    etcdServers:
    - http://127.0.0.1:4001
    etcdServersOverrides:
    - /events#http://127.0.0.1:4002
    image: gcr.io/google_containers/kube-apiserver:v1.4.3
    logLevel: 2
    pathSrvKubernetes: /srv/kubernetes
    pathSrvSshproxy: /srv/sshproxy
    securePort: 443
    serviceClusterIPRange: 100.64.0.0/13
    tlsCertFile: /srv/kubernetes/server.cert
    tlsPrivateKeyFile: /srv/kubernetes/server.key
    tokenAuthFile: /srv/kubernetes/known_tokens.csv
  kubeControllerManager:
    allocateNodeCIDRs: true
    cloudProvider: aws
    clusterCIDR: 100.96.0.0/11
    clusterName: ${cluster_name}
    configureCloudRoutes: true
    image: gcr.io/google_containers/kube-controller-manager:v1.4.3
    leaderElection:
      leaderElect: true
    logLevel: 2
    master: 127.0.0.1:8080
    pathSrvKubernetes: /srv/kubernetes
    rootCAFile: /srv/kubernetes/ca.crt
    serviceAccountPrivateKeyFile: /srv/kubernetes/server.key
  kubeDNS:
    domain: cluster.local
    image: gcr.io/google_containers/kubedns-amd64:1.3
    replicas: 2
    serverIP: 100.64.0.10
  kubeProxy:
    cpuRequest: 100m
    image: gcr.io/google_containers/kube-proxy:v1.4.3
    logLevel: 2
    master: https://api.internal.${cluster_name}
  kubeScheduler:
    image: gcr.io/google_containers/kube-scheduler:v1.4.3
    leaderElection:
      leaderElect: true
    logLevel: 2
    master: 127.0.0.1:8080
  kubelet:
    allowPrivileged: true
    apiServers: https://api.internal.${cluster_name}
    babysitDaemons: true
    cgroupRoot: docker
    cloudProvider: aws
    clusterDNS: 100.64.0.10
    clusterDomain: cluster.local
    config: /etc/kubernetes/manifests
    configureCbr0: true
    enableDebuggingHandlers: true
    hostnameOverride: '@aws'
    logLevel: 2
    networkPluginMTU: 9001
    networkPluginName: kubenet
    nonMasqueradeCIDR: 100.64.0.0/10
    reconcileCIDR: true
  kubernetesVersion: 1.4.3
  masterInternalName: api.internal.${cluster_name}
  masterKubelet:
    allowPrivileged: true
    apiServers: http://127.0.0.1:8080
    babysitDaemons: true
    cgroupRoot: docker
    cloudProvider: aws
    clusterDNS: 100.64.0.10
    clusterDomain: cluster.local
    config: /etc/kubernetes/manifests
    configureCbr0: true
    enableDebuggingHandlers: true
    hostnameOverride: '@aws'
    logLevel: 2
    networkPluginMTU: 9001
    networkPluginName: kubenet
    nonMasqueradeCIDR: 100.64.0.0/10
    podCIDR: ${pod_cidr}
    reconcileCIDR: true
    registerSchedulable: false
  masterPublicName: api.${cluster_name}
  multizone: true
  networkCIDR: ${vpc_cidr}
  networkID: ${vpc_id}
  networking:
    kubenet: {}
  nonMasqueradeCIDR: 100.64.0.0/10
  secretStore: s3://${s3_bucket_id}/${cluster_name}/secrets
  serviceClusterIPRange: 100.64.0.0/13
  zones:
${subnets}
