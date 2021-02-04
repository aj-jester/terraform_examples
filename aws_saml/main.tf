# Module: aws_saml
resource "aws_iam_saml_provider" "main" {
  name                   = "${var.provider_name}"
  saml_metadata_document = "${file("${var.metadata_file}")}"
}
