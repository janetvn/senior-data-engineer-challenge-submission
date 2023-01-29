# SECTION 3: DESIGN

The design for the use case includes three (3) parts:
- General architecture for image processing services 
- CI/CD deployment architecture for the applications 
- Business Intelligence Resource Architecture 

Assumptions:
- The web application which allows users to upload images to the cloud using an API is running in a Docker container 
- Go serverless as much as possible to reduce overhead for management and taking advantage of cloud scaling 

## Part 1: General architecture for image processing services

![Image Process](image_processing_architecture.png?raw=true "Title")

- Image Processing API takes care of the images uploaded by users and directly pushes it to a S3 bucket 
- Amazon Kinesis Firehose consumer will reliably extract and load images and its metadata from the Kafka streams to the same S3 bucket that Image Processing API in near real-time. 
- In the S3 that hosts the uploaded images, one-time setup for Lifecycle configuration will help to expire and delete the objects from the cloud environment automatically. Furthermore, storage costs will be managed effectively as well. S3 Lifecycle configuration is a set of rules that define actions that Amazon S3 applies to a group of objects, such as transitioning an object to another storage class or expire objects and delete it from S3.
- As images are hosted on S3, temporary access can be granted to users with S3 link. 

## Part 2: CI/CD Deployment

![CICD](cicd_deployment.png?raw=true "Title")
- For web application API, codes and Docker image file are pushed to Github with version control. Github Actions are used to build docker images and pushed to Amazon ECR (Elastic Container Registry). The containerised application is later deployed and launched via the serverless service - Amazon ECS - which will take care of the management and autoscaling overhead. 
- Similarly, for Kinesis Firehose consumer application, its codes and stack are stored in Github for version control and later hosted in S3 and later deployed via CloudFormation. 

## Part 3: Business Intelligence Resource

![CI/CD](business_intelligence_resource.png?raw=true "Title")
- The main data resources in this architecture are the data warehouse Redshift. There will be different ETL/ ELT/ Streaming pipelines that loads data into Redshift for structured data.
- Amazon Athena acts the central query engine that data analysts used to query data and connect to many and different data sources. 
- Athena Federated Query are used to run SQL queries across data stored in relational, non-relational, object, and custom data sources using different data source connectors run on AWS Lambda to run federated queries. 
- Other semi-structured data will be loaded to S3 and directly accessed via Athena as well without any data source connectors. 

## Key considerations by stakeholders
**Securing access to the environment and its resources as the company expands**
- Enable SAML 2.0 federated users to access the AWS Management Console.
- Set up IAM role with the least privileges that will grant to do the job.
- Data access are controlled to column-level, not only just table-level 
- All applications are deployed in the company VPC and not available to the public, unless it is a customer-facing applications. 
- Deploy solutions like CloudFlare and VPN for company resource access.

**Security of data at rest and in transit**

For protecting data at rest in S3: 
- Server-Side Encryption – Request Amazon S3 to encrypt the object before saving it on disks in its data centers and then decrypt it when downloading the objects.
- Client-Side Encryption – Encrypt data client-side and upload the encrypted data to Amazon S3.
Data transferring over the network:
- Encrypting data when sending in into the network, 
- Applying firewalls and network access control will help secure the networks used to transmit data against malware attacks or intrusions.

**Scaling to meet user demand while keeping costs low**
- Use serverless solutions to scale according the user demand. 
- All applications are deployed in a single region to keep egress charges low.

**Maintenance of the environment and assets (including processing scripts)**
- Using serverless solutions to reduce overhead for maintenance and management. 
- Github with version controlled for rolling back. etc 
