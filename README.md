# Tripare.ai DevOps Assessment

This repository contains the implementation and validation work completed for the Tripare.ai DevOps assessment.

The assessment covers:

- AWS infrastructure design using Terraform
- Development and production environment configurations
- VPC networking
- ECS/Fargate application infrastructure
- Amazon RDS database infrastructure
- Local PostgreSQL setup using Docker Compose
- Database schema and seed data
- Query optimization
- PostgreSQL backup and restore
- Infrastructure validation

---

## Table of Contents

- [Project Overview](#project-overview)
- [Repository Structure](#repository-structure)
- [Technology Stack](#technology-stack)
- [Architecture Overview](#architecture-overview)
- [Local PostgreSQL Setup](#local-postgresql-setup)
- [Database Schema](#database-schema)
- [Seed Data](#seed-data)
- [Query Optimization](#query-optimization)
- [Database Backup and Restore](#database-backup-and-restore)
- [Terraform Infrastructure](#terraform-infrastructure)
- [Terraform Validation](#terraform-validation)
- [AWS Deployment Status](#aws-deployment-status)
- [Environment Configuration](#environment-configuration)
- [Security Considerations](#security-considerations)
- [Final Review Checklist](#final-review-checklist)
- [Completion Summary](#completion-summary)

---

## Project Overview

The objective of this assessment was to design and validate a DevOps solution for a containerized application running on AWS.

The proposed AWS infrastructure follows this architecture:

```text
                    Internet
                       |
                       v
                Application Load
                   Balancer
                       |
                       v
                 ECS / Fargate
                 Application
                       |
                       v
                  Amazon RDS
                 PostgreSQL
```

The infrastructure is organized into reusable Terraform modules and separate environment configurations for development and production.

A local PostgreSQL environment was also created using Docker Compose to support database schema creation, test data generation, query optimization, and backup/restore verification.

---

## Repository Structure

```text
tripare-devops-assessment/
│
├── docker-compose.yml
│
├── db/
│   ├── migrations/
│   │   └── *.sql
│   │
│   └── seeds/
│       └── seed.sql
│
├── backups/
│   └── tripare_*.dump
│
├── scripts/
│   ├── backup.sh
│   └── restore.sh
│
├── infra/
│   ├── envs/
│   │   ├── dev/
│   │   │   ├── backend.tf
│   │   │   └── main.tf
│   │   │
│   │   └── prod/
│   │       ├── backend.tf
│   │       └── main.tf
│   │
│   └── modules/
│       ├── ecs/
│       │   └── main.tf
│       │
│       ├── network/
│       │   └── main.tf
│       │
│       └── rds/
│           └── main.tf
│
└── README.md
```

> The exact file list may vary depending on the final repository contents.

---

## Technology Stack

| Technology | Purpose |
|---|---|
| Terraform | Infrastructure as Code |
| AWS VPC | Network isolation |
| AWS ALB | Application traffic distribution |
| Amazon ECS/Fargate | Containerized application deployment |
| Amazon RDS | Managed PostgreSQL database |
| Docker Compose | Local database environment |
| PostgreSQL | Relational database |
| PowerShell | Local Windows command execution |
| Bash | Backup and restore scripts |
| Git | Version control |

---

## Architecture Overview

The proposed AWS architecture consists of the following components.

### 1. VPC

A dedicated VPC is used to isolate the application infrastructure.

The VPC design includes:

- Public subnets
- Private subnets
- Internet Gateway
- Route tables
- Network segmentation

### 2. Application Load Balancer

The Application Load Balancer is intended to:

- Receive incoming application traffic
- Distribute traffic across ECS tasks
- Provide a public entry point for the application
- Perform health checks on application targets

### 3. ECS/Fargate

Amazon ECS with Fargate is used as the container execution platform.

The ECS configuration is intended to include:

- ECS cluster
- ECS task definition
- ECS service
- Container configuration
- CPU and memory allocation
- Desired task count
- Load balancer integration
- Health check configuration

### 4. Amazon RDS

Amazon RDS is used as the managed PostgreSQL database.

The database is intended to run in private subnets and be accessible only from the ECS application security group.

### 5. Security Groups

The security group design follows the principle of least privilege.

Expected traffic flow:

```text
Internet
   |
   v
ALB Security Group
   |
   v
ECS Security Group
   |
   v
RDS Security Group
```

The database should not be directly accessible from the public internet.

---

## Local PostgreSQL Setup

The local PostgreSQL environment was configured using Docker Compose.

### PostgreSQL Configuration

| Setting | Value |
|---|---|
| PostgreSQL Image | `postgres:16-alpine` |
| Container Name | `tripare-postgres` |
| Database Name | `tripare` |
| Username | `tripare` |
| Password | `tripare` |
| Host Port | `5432` |

### Start PostgreSQL

Run the following command from the project root:

```powershell
docker compose up -d
```

### Check Container Status

```powershell
docker compose ps
```

### Access PostgreSQL

```powershell
docker compose exec postgres psql -U tripare -d tripare
```

### Stop PostgreSQL

```powershell
docker compose down
```

> The PostgreSQL volume is retained unless the `-v` option is used.

To remove the containers and associated volumes:

```powershell
docker compose down -v
```

---

## Database Schema

The local database contains the following tables:

### `hotel_bookings`

This table stores hotel booking information, including:

- Organization ID
- Hotel ID
- City
- Check-in date
- Check-out date
- Booking amount
- Booking status
- Creation timestamp

### `booking_events`

This table stores booking-related events.

The event table includes:

- Booking ID
- Event type
- Event payload
- Event creation timestamp

The database migration files are located in:

```text
db/migrations
```

---

## Seed Data

The seed script is located at:

```text
db/seeds/seed.sql
```

The seed data was successfully loaded and verified.

### Seed Data Summary

| Data Type | Count |
|---|---:|
| Hotel bookings | 100 |
| Booking events | 25 |

The dataset includes multiple:

- Cities
- Organizations
- Booking statuses
- Booking dates
- Booking records

### Execute the Seed Script

```powershell
docker compose exec -T postgres psql -U tripare -d tripare -f /seeds/seed.sql
```

### Verify Booking Count

```powershell
docker compose exec postgres psql -U tripare -d tripare -c "SELECT COUNT(*) FROM hotel_bookings;"
```

### Verify Event Count

```powershell
docker compose exec postgres psql -U tripare -d tripare -c "SELECT COUNT(*) FROM booking_events;"
```

Expected result:

```text
hotel_bookings: 100
booking_events: 25
```

---

## Query Optimization

The booking search query was analyzed using PostgreSQL's `EXPLAIN (ANALYZE, BUFFERS)` command.

### Query Under Test

```sql
SELECT *
FROM hotel_bookings
WHERE city = 'delhi'
  AND created_at >= NOW() - INTERVAL '30 days'
ORDER BY created_at DESC;
```

### Query Execution Command

```powershell
docker compose exec postgres psql -U tripare -d tripare -c "EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM hotel_bookings WHERE city = 'delhi' AND created_at >= NOW() - INTERVAL '30 days' ORDER BY created_at DESC;"
```

### Composite Index

The following composite index was verified:

```sql
CREATE INDEX idx_hotel_bookings_city_created_org_status
ON public.hotel_bookings
USING btree (city, created_at, org_id, status);
```

The index supports filtering by:

- `city`
- `created_at`

### Verify Indexes

```powershell
docker compose exec postgres psql -U tripare -d tripare -c "SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'hotel_bookings';"
```

### Update Table Statistics

```powershell
docker compose exec postgres psql -U tripare -d tripare -c "ANALYZE hotel_bookings;"
```

### Verification Result

The query initially used a sequential scan because the test table contained only 100 rows. PostgreSQL may prefer a sequential scan for small datasets because it can be cheaper than using an index.

For index verification, sequential scans were temporarily disabled for the session:

```powershell
docker compose exec postgres psql -U tripare -d tripare -c "SET enable_seqscan = off; EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM hotel_bookings WHERE city = 'delhi' AND created_at >= NOW() - INTERVAL '30 days' ORDER BY created_at DESC;"
```

The resulting execution plan confirmed:

```text
Bitmap Index Scan on idx_hotel_bookings_city_created_org_status
```

The query returned:

```text
14 rows
```

> Disabling sequential scans was used only for testing and verification. It is not intended as a permanent production configuration.

---

## Database Backup and Restore

A PostgreSQL custom-format backup was successfully created inside the PostgreSQL container.

The backup was copied to the local `backups` directory.

### Example Backup File

```text
backups/tripare_20260917_134710.dump
```

### Create a Backup Inside the Container

```powershell
docker compose exec -T postgres pg_dump -U tripare -d tripare -Fc -f /tmp/tripare_backup.dump
```

### Copy the Backup to the Local Machine

```powershell
docker cp tripare-postgres:/tmp/tripare_backup.dump .\backups\tripare_backup.dump
```

### Validate the Backup Archive

```powershell
docker cp .\backups\tripare_backup.dump tripare-postgres:/tmp/final_verify.dump
```

```powershell
docker compose exec postgres pg_restore -l /tmp/final_verify.dump
```

The archive validation confirmed the presence of:

- `hotel_bookings`
- `booking_events`
- Primary key definitions
- Foreign key definitions
- Composite index
- Seeded data

### Restore into a Fresh Database

A fresh database named `tripare_restore` was used for restore verification.

Example restore workflow:

```powershell
docker compose exec postgres psql -U tripare -d postgres -c "CREATE DATABASE tripare_restore;"
```

```powershell
docker compose exec -T postgres pg_restore -U tripare -d tripare_restore /tmp/tripare_backup.dump
```

### Verify Restored Data

```powershell
docker compose exec postgres psql -U tripare -d tripare_restore -c "SELECT COUNT(*) FROM hotel_bookings;"
```

```powershell
docker compose exec postgres psql -U tripare -d tripare_restore -c "SELECT COUNT(*) FROM booking_events;"
```

Restore verification confirmed:

- **100 hotel bookings**
- **25 booking events**

---

## Terraform Infrastructure

Terraform configurations are organized into separate development and production environments.

### Environment Directories

```text
infra/envs/dev
infra/envs/prod
```

### Terraform Modules

```text
infra/modules/ecs
infra/modules/network
infra/modules/rds
```

The modular structure is intended to support reuse and separation of infrastructure responsibilities.

### Development Environment

The development environment is located at:

```text
infra/envs/dev
```

### Production Environment

The production environment is located at:

```text
infra/envs/prod
```

---

## Terraform Validation

Terraform formatting and validation were completed successfully.

### Format Terraform Files

Run from the project root:

```powershell
terraform fmt -recursive
```

### Initialize Development Environment Without Remote Backend

```powershell
terraform -chdir=infra/envs/dev init -backend=false
```

### Validate Development Environment

```powershell
terraform -chdir=infra/envs/dev validate
```

Expected result:

```text
Success! The configuration is valid.
```

### Initialize Production Environment Without Remote Backend

```powershell
terraform -chdir=infra/envs/prod init -backend=false
```

### Validate Production Environment

```powershell
terraform -chdir=infra/envs/prod validate
```

Expected result:

```text
Success! The configuration is valid.
```

### Terraform Validation Results

| Environment | Initialization | Validation |
|---|---|---|
| Development | Successful | Passed |
| Production | Successful | Passed |

The AWS provider was initialized successfully using the existing Terraform dependency lock file.

---

## AWS Deployment Status

No AWS infrastructure was deployed as part of this assessment.

Terraform validation was performed using:

```powershell
terraform init -backend=false
```

Disabling backend initialization allowed the Terraform configuration to be initialized and validated without connecting to the configured remote AWS backend.

The following activities were completed locally:

- Terraform formatting
- Terraform module initialization
- Development environment validation
- Production environment validation
- PostgreSQL setup
- Database seeding
- Query optimization verification
- Backup archive validation
- Database restore verification

No AWS resources were created or modified.

---

## Environment Configuration

The repository contains separate Terraform configurations for development and production.

When reviewing the environment configurations, verify the following differences:

- Resource sizing
- ECS task CPU and memory
- Desired task count
- Database instance sizing
- Backup retention
- Deletion protection
- Environment-specific naming
- Environment-specific networking
- Environment-specific variables
- Remote state configuration

Development and production resources should remain logically separated.

---

## Security Considerations

The following security practices should be followed when deploying the infrastructure:

- Do not commit AWS credentials to the repository.
- Do not commit passwords or other secrets.
- Use AWS IAM roles instead of long-lived access keys where possible.
- Keep the RDS database in private subnets.
- Restrict RDS access to the ECS security group.
- Avoid exposing PostgreSQL directly to the internet.
- Use least-privilege security group rules.
- Store sensitive configuration values in a secure secrets-management system.
- Review Terraform state files before committing them.
- Add sensitive files to `.gitignore` where appropriate.

Before submission, verify that no credentials or sensitive information are included in the repository.

---




---

## Completion Summary

| Area | Status |
|---|---|
| Docker Compose PostgreSQL setup | Completed |
| Database schema and migrations | Completed |
| Seed data generation | Completed |
| 100 booking records | Verified |
| 25 booking events | Verified |
| Query optimization verification | Completed |
| Composite index verification | Completed |
| PostgreSQL backup creation | Completed |
| Backup archive validation | Completed |
| Restore into a fresh database | Completed |
| Terraform formatting | Completed |
| Development Terraform initialization | Successful |
| Development Terraform validation | Passed |
| Production Terraform initialization | Successful |
| Production Terraform validation | Passed |
| AWS infrastructure deployment | Not performed |

---

## Conclusion

The local PostgreSQL environment, database seed data, query optimization checks, backup/restore workflow, and Terraform configuration validation were completed successfully.

Both development and production Terraform configurations passed validation.

No AWS resources were deployed during the assessment.
