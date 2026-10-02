# AWS WORM Storage Evaluation — Data Immutability with S3 Object Lock

![AWS](https://img.shields.io/badge/AWS-S3-orange?logo=amazonaws)
![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform)
![GitHub Actions](https://img.shields.io/badge/CI-GitHub%20Actions-2088FF?logo=githubactions)
![Security](https://img.shields.io/badge/Security-Object%20Lock-red)
![Encryption](https://img.shields.io/badge/Encryption-SSE--S3-green)
![Status](https://img.shields.io/badge/Status-Validated-success)

## Project Overview

This project evaluates and implements **Write Once Read Many (WORM) storage** on AWS using **Amazon S3 Object Lock** and Terraform.

The objective is to provide a storage architecture that protects compliance, audit, backup, and regulated data from unauthorized deletion or modification during a defined retention period.

The implementation demonstrates:

* S3 Object Lock
* S3 Versioning
* Governance retention
* Compliance retention
* Legal holds
* Server-side encryption
* Public-access protection
* IAM access controls
* Terraform infrastructure as code
* Automated validation
* GitHub Actions CI
* Object immutability testing
* AWS CLI operational inspection

The project specifically evaluates the difference between **Governance Mode** and **Compliance Mode**, including how retention controls behave when deletion is attempted.

---

# Architecture

```text
                         ┌──────────────────────────┐
                         │        Developer         │
                         │      / DevOps Engineer   │
                         └────────────┬─────────────┘
                                      │
                                      ▼
                         ┌──────────────────────────┐
                         │       GitHub Repository   │
                         │                          │
                         │ Terraform Configuration  │
                         │ Validation Scripts       │
                         │ Documentation            │
                         └────────────┬─────────────┘
                                      │
                                      ▼
                         ┌──────────────────────────┐
                         │      GitHub Actions       │
                         │                          │
                         │ terraform fmt            │
                         │ terraform validate       │
                         │ CI verification          │
                         └────────────┬─────────────┘
                                      │
                                      ▼
                         ┌──────────────────────────┐
                         │        Terraform          │
                         │                          │
                         │ Infrastructure as Code  │
                         └────────────┬─────────────┘
                                      │
                                      ▼
              ┌─────────────────────────────────────────────┐
              │                AWS S3 Bucket                │
              │                                             │
              │  ┌───────────────────────────────────────┐  │
              │  │          S3 Object Lock               │  │
              │  │                                       │  │
              │  │  • Governance Retention              │  │
              │  │  • Compliance Retention              │  │
              │  │  • Legal Holds                        │  │
              │  │  • Immutable Object Versions         │  │
              │  └───────────────────────────────────────┘  │
              │                                             │
              │  Versioning                                  │
              │  SSE-S3 Encryption                           │
              │  Bucket Key                                  │
              │  Public Access Block                         │
              │  IAM Access Control                           │
              └─────────────────────────────────────────────┘
                                      │
                                      ▼
                         ┌──────────────────────────┐
                         │      Validation Layer     │
                         │                          │
                         │ AWS CLI                  │
                         │ inspect-object.sh        │
                         │ test-governance.sh       │
                         │ Delete/retention tests   │
                         └──────────────────────────┘
```

## Data Protection Flow

```text
Object Upload
     │
     ▼
S3 Version Created
     │
     ▼
Retention Policy Applied
     │
     ├───────────────┐
     │               │
     ▼               ▼
Governance       Compliance
Retention        Retention
     │               │
     ▼               ▼
Authorized       Retention
Bypass Possible  Cannot Be Bypassed
     │               │
     └───────┬───────┘
             ▼
      Protected Object
             │
             ▼
      Audit / Inspection
```

---

# Why WORM Storage?

WORM storage is useful when data must remain unchanged for a defined period.

Typical use cases include:

* Compliance records
* Financial records
* Audit evidence
* Security logs
* Backup protection
* Legal evidence
* Regulatory archives
* Records subject to retention policies
* Protection against accidental deletion
* Protection against malicious modification

The key security property is that an object can be protected against deletion or modification until its retention requirements are satisfied.

---

# Core AWS Design

## Amazon S3

The storage layer uses an S3 bucket configured with:

* Object Lock
* Versioning
* Default retention
* Server-side encryption
* Bucket key
* Public-access blocking
* Controlled IAM access

Object Lock is enabled at bucket creation and works together with S3 versioning.

## S3 Object Lock

Object Lock provides the WORM capability.

This project evaluates two retention modes.

### Governance Mode

Governance mode prevents normal users from deleting or modifying protected objects.

Users with the appropriate IAM permission can explicitly bypass governance retention.

The relevant permission is:

```text
s3:BypassGovernanceRetention
```

This makes Governance Mode appropriate when authorized administrators may need controlled retention overrides.

### Compliance Mode

Compliance mode provides stronger immutability.

Once an object is protected by Compliance Mode retention, the protected version cannot be deleted or overwritten until the retention period expires.

Even users with elevated administrative permissions cannot bypass the retention protection during that period.

This provides a stronger control for regulated records and evidence that must remain immutable.

---

# Legal Holds

The project also evaluates S3 Legal Holds.

A legal hold can prevent an object version from being deleted regardless of its normal retention configuration.

Example:

```bash
aws s3api put-object-legal-hold \
  --bucket "$WORM_BUCKET" \
  --key "compliance/compliance-test.txt" \
  --version-id "$COMPLIANCE_VERSION" \
  --legal-hold Status=ON
```

The legal hold can later be removed by an authorized operator when the legal or investigative requirement has ended.

---

# Infrastructure as Code

Terraform manages the AWS infrastructure.

Project configuration:

```text
terraform/
├── main.tf
├── outputs.tf
├── variables.tf
└── versions.tf
```

The Terraform configuration provisions the S3 WORM environment with the required security controls.

Benefits of using Terraform include:

* Reproducible infrastructure
* Version-controlled configuration
* Consistent environments
* Automated validation
* Reviewable infrastructure changes
* Reduced manual configuration
* Easier teardown and redeployment

---

# Repository Structure

```text
worm-storage-evaluation/
│
├── .github/
│   └── workflows/
│       └── terraform.yml
│
├── docs/
│   ├── architecture.md
│   └── evaluation.md
│
├── scripts/
│   ├── inspect-object.sh
│   └── test-governance.sh
│
├── terraform/
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   └── versions.tf
│
├── .gitignore
└── README.md
```

---

# Prerequisites

Install and configure:

* AWS CLI
* Terraform
* Git
* GitHub CLI
* An AWS account with permission to create the required S3 and IAM resources

Verify the tools:

```bash
aws --version
terraform version
git --version
gh --version
```

Verify AWS authentication:

```bash
aws sts get-caller-identity
```

---

# Deployment

## 1. Clone the repository

```bash
git clone https://github.com/georgelolu/worm-storage-evaluation.git
cd worm-storage-evaluation
```

## 2. Configure AWS

Make sure the AWS CLI is authenticated:

```bash
aws sts get-caller-identity
```

The command should return the authenticated AWS identity.

---

## 3. Initialize Terraform

```bash
cd terraform
terraform init
```

---

## 4. Format Terraform

```bash
terraform fmt -recursive
```

---

## 5. Validate the configuration

```bash
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

---

## 6. Review the Terraform plan

```bash
terraform plan
```

Review the resources before deployment.

---

## 7. Deploy the WORM infrastructure

```bash
terraform apply
```

Review the proposed changes and confirm with:

```text
yes
```

---

## 8. Retrieve Terraform outputs

```bash
terraform output
```

The outputs provide information such as the bucket name, ARN, region, and Object Lock status.

---

# AWS S3 Validation

After deployment, retrieve the bucket name:

```bash
terraform output
```

Set the bucket variable:

```bash
export WORM_BUCKET="$(terraform output -raw bucket_name)"
```

Verify versioning:

```bash
aws s3api get-bucket-versioning \
  --bucket "$WORM_BUCKET"
```

Verify Object Lock:

```bash
aws s3api get-object-lock-configuration \
  --bucket "$WORM_BUCKET"
```

---

# Object Inspection

The project includes:

```text
scripts/inspect-object.sh
```

This script provides an operational view of an object and its retention state.

Example:

```bash
./scripts/inspect-object.sh
```

The validation process can inspect:

* Object version
* Retention configuration
* Retention mode
* Retain-until date
* Legal hold state
* Object metadata

---

# Immutability Testing

The project includes:

```text
scripts/test-governance.sh
```

This script is used to validate Governance Mode behavior.

The evaluation tests whether protected objects can be deleted under different authorization conditions.

---

# Governance Mode Test

A protected object is created with Governance retention.

A normal deletion attempt is expected to fail while retention is active.

Example:

```bash
aws s3api delete-object \
  --bucket "$WORM_BUCKET" \
  --key "compliance/compliance-test.txt" \
  --version-id "$COMPLIANCE_VERSION"
```

Expected behavior:

```text
AccessDenied
```

This demonstrates that the protected object version cannot be deleted through a normal deletion request while retention is active.

---

# Governance Bypass Test

Governance Mode supports an explicit bypass mechanism for authorized principals.

The relevant permission is:

```text
s3:BypassGovernanceRetention
```

An authorized operation can explicitly request the bypass:

```bash
aws s3api delete-object \
  --bucket "$WORM_BUCKET" \
  --key "compliance/compliance-test.txt" \
  --version-id "$COMPLIANCE_VERSION" \
  --bypass-governance-retention
```

This demonstrates the fundamental difference between Governance and Compliance retention.

---

# Compliance Mode Test

Compliance Mode provides stronger protection.

A deletion attempt against an actively protected Compliance Mode object is expected to fail.

Example:

```bash
aws s3api delete-object \
  --bucket "$WORM_BUCKET" \
  --key "compliance/compliance-test.txt" \
  --version-id "$COMPLIANCE_VERSION"
```

Expected result:

```text
AccessDenied
```

The previously validated behavior demonstrated that the object remained protected by Object Lock.

This is the core WORM property being evaluated by the project.

---

# Version Preservation

S3 Versioning ensures that object versions are preserved independently.

For example:

```bash
aws s3api list-object-versions \
  --bucket "$WORM_BUCKET" \
  --prefix "compliance/"
```

This allows operators to inspect:

* Current object versions
* Previous versions
* Delete markers
* Retention-protected versions

Versioning is important because WORM protection applies to individual object versions.

---

# Security Controls

The implementation applies multiple layers of protection.

| Control              | Purpose                                         |
| -------------------- | ----------------------------------------------- |
| S3 Object Lock       | Prevents protected object deletion/modification |
| Governance retention | Provides controlled administrative bypass       |
| Compliance retention | Provides stronger immutable retention           |
| Legal Hold           | Prevents deletion while a hold is active        |
| Versioning           | Preserves object versions                       |
| SSE-S3               | Encrypts objects at rest                        |
| S3 Bucket Key        | Reduces encryption request overhead             |
| Public Access Block  | Prevents accidental public exposure             |
| IAM controls         | Restricts administrative operations             |
| Terraform            | Provides repeatable infrastructure              |
| GitHub Actions       | Automates Terraform validation                  |
| CLI validation       | Provides operational verification               |

---

# Security Model

The project follows a layered security model:

```text
                    ┌────────────────────┐
                    │   IAM Permissions  │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │ Public Access      │
                    │ Block              │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │ Encryption         │
                    │ SSE-S3             │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │ Versioning         │
                    └─────────┬──────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │ Object Lock        │
                    └─────────┬──────────┘
                              │
                    ┌─────────┴─────────┐
                    ▼                   ▼
             Governance Mode      Compliance Mode
                    │                   │
                    ▼                   ▼
             Controlled Bypass     No Retention
                                   Bypass
```

---

# CI/CD

Terraform validation is automated using GitHub Actions.

Workflow:

```text
Developer
   │
   ▼
Git Push / Pull Request
   │
   ▼
GitHub Actions
   │
   ├── Terraform Format
   │
   └── Terraform Validate
          │
          ▼
      PASS / FAIL
```

Workflow file:

```text
.github/workflows/terraform.yml
```

This ensures infrastructure configuration is automatically checked before changes are accepted.

---

# Testing Matrix

| Test                 | Expected Result                                  | Status     |
| -------------------- | ------------------------------------------------ | ---------- |
| Terraform formatting | Valid formatting                                 | Validated  |
| Terraform validation | Configuration valid                              | Validated  |
| S3 Versioning        | Enabled                                          | Validated  |
| S3 Object Lock       | Enabled                                          | Validated  |
| Governance retention | Protected object cannot be normally deleted      | Validated  |
| Governance bypass    | Explicit authorized bypass supported             | Evaluated  |
| Compliance retention | Protected object cannot be deleted before expiry | Validated  |
| Legal Hold           | Object remains protected while hold is active    | Evaluated  |
| Object inspection    | Retention metadata visible                       | Validated  |
| Encryption           | SSE-S3 enabled                                   | Configured |
| Public access        | Blocked                                          | Configured |
| IAM control          | Restricted administrative actions                | Configured |

---

# Evidence

The repository includes implementation and evaluation documentation:

* [`docs/architecture.md`](docs/architecture.md)
* [`docs/evaluation.md`](docs/evaluation.md)
* [`scripts/inspect-object.sh`](scripts/inspect-object.sh)
* [`scripts/test-governance.sh`](scripts/test-governance.sh)

These files provide additional technical detail about the architecture, validation methodology, and operational testing.

---

# Important WORM Behavior Demonstrated

One of the key validation results was an attempted deletion of an actively protected object version.

The AWS CLI returned:

```text
AccessDenied
```

because the object was protected by S3 Object Lock.

This demonstrates that the retention policy is enforced by the storage service rather than relying only on application-level controls.

---

# Operational Considerations

WORM storage introduces an important operational requirement:

> Retention policies must be designed carefully because protected data may not be immediately deletable.

Before enabling long retention periods in production, organizations should establish:

* Data classification
* Retention requirements
* Legal hold procedures
* IAM ownership
* Break-glass procedures where applicable
* Cost management
* Lifecycle policies
* Audit requirements
* Recovery procedures
* Compliance requirements

The retention period used in this evaluation is intended for testing and demonstration rather than as a universal production policy.

---

# Cost Considerations

AWS S3 storage and related requests incur AWS charges.

For testing:

* Use small objects.
* Use short retention periods.
* Remove test resources after validation where retention policies permit.
* Monitor S3 storage and request usage.
* Avoid unnecessary replication or large test datasets.

Object Lock can prevent immediate deletion, so cleanup must account for active retention periods and legal holds.

---

# Cleanup

Terraform-managed infrastructure can normally be removed with:

```bash
cd terraform
terraform destroy
```

However, protected objects may prevent deletion while Object Lock retention or legal holds are active.

For this reason, always verify:

```bash
aws s3api get-object-lock-configuration \
  --bucket "$WORM_BUCKET"
```

and inspect protected object versions before attempting cleanup.

---

# Engineering Skills Demonstrated

This project demonstrates practical experience across multiple Cloud and DevOps areas.

### Cloud Engineering

* AWS S3
* S3 Object Lock
* IAM
* Encryption
* Cloud storage security
* Data protection controls

### DevOps

* Terraform
* Infrastructure as Code
* Git
* GitHub
* GitHub Actions
* Automated infrastructure validation

### DevSecOps

* Least-privilege access
* Data immutability
* Encryption at rest
* Public-access prevention
* Retention enforcement
* Security validation
* Controlled administrative access

### Site Reliability / Platform Engineering

* Reproducible infrastructure
* Automated validation
* Operational inspection
* Failure testing
* Infrastructure lifecycle management
* Documented operational procedures

---

# Key Engineering Lessons

## 1. Application controls are not enough

Application-level deletion restrictions can potentially be bypassed if an administrator or compromised service obtains direct storage access.

S3 Object Lock moves the protection boundary into the storage service.

## 2. Governance and Compliance are different

Governance Mode allows an appropriately authorized principal to bypass retention.

Compliance Mode provides stronger immutability because retention cannot be bypassed while active.

## 3. Versioning is fundamental

Object Lock works with S3 versioning, allowing individual versions to remain protected.

## 4. Security requires multiple layers

Encryption alone does not provide immutability.

IAM alone does not provide immutability.

Object Lock, versioning, IAM, encryption, and public-access controls work together to create a stronger storage security model.

## 5. Infrastructure should be reproducible

Terraform allows the storage security architecture to be represented as code and reviewed alongside application code.

---

# Project Outcome

The project successfully demonstrates an AWS S3-based WORM storage environment using Terraform and S3 Object Lock.

The implementation covers:

```text
Infrastructure as Code
        +
S3 Object Lock
        +
Versioning
        +
Retention Controls
        +
Legal Holds
        +
Encryption
        +
IAM
        +
Public Access Protection
        +
Automated Validation
        +
CI
        =
Immutable Cloud Storage Architecture
```

The repository provides both the infrastructure implementation and the operational validation required to understand how AWS enforces object immutability.

---

# Repository

**GitHub:**

https://github.com/georgelolu/worm-storage-evaluation

## Project Status

**Implementation:** Complete
**Terraform:** Implemented
**Object Lock:** Implemented
**Security Controls:** Implemented
**Validation Scripts:** Implemented
**Documentation:** Complete
**GitHub CI:** Configured

