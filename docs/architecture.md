# WORM Storage Architecture

## Objective

Evaluate AWS S3 Object Lock as a WORM storage mechanism for
protecting data from unauthorized modification and deletion.

## Components

- Amazon S3
- S3 Versioning
- S3 Object Lock
- Governance Retention
- Compliance Retention
- Legal Holds
- Terraform
- AWS CLI
- IAM
- GitHub Actions
- CloudTrail

## Data Flow

Application
    |
    v
S3 Bucket
    |
    +--> Versioning
    |
    +--> Object Lock
            |
            +--> Governance
            |
            +--> Compliance
            |
            +--> Legal Hold

## Security Controls

- Public access blocked
- Object versioning enabled
- Object Lock enabled
- Server-side encryption enabled
- Retention controls
- IAM authorization
- Audit logging
