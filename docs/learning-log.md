# Learning Log

## 2026-10-07: Terraform fundamentals and first build

**Studied:** HashiCorp "Get Started – AWS": What is IaC; Build infrastructure.

**Takeaways (in my own words):**
- Infrastructure as code: Infrastructure-as-Code (IaC) is a practice that automates the setup and management of computing infrastructure through human-readable configuration files instead of through an error-prone manual process.
- init / plan / apply / destroy: "init", which is short for "initialize", tells Terraform to install the necessary specified plugins that it needs to manage the infrastructure; "plan" tells Terraform to allow you to preview the changes that it will execute to match your configuration; "apply" tells Terraform to make the planned changes; and "destroy" tells Terraform to destroy the infrastructure it's managing and all of the resources managed by my configuration
- State: This command lets you safely view and update the digital inventory file that tracks which real-world cloud resources your code is currently managing.

**Built:** One EC2 instance (Amazon Linux 2023, t3.micro) in us-west-2 using a
data source to look up the latest AMI. Applied, inspected with `state list` and
`show`, then destroyed.

**What surprised me / questions:**
- I'm suprised how easy these concepts are
