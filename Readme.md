# Observability Cross-account AWS Infrastructure + EKS opensource S3 backend

Using the stack, Grafana, Prometheus, Loki and Mimir

By relying on in Opensource tool and S3 storage we are achieving a high level of cost-effectiveness and resilience.

Tools applied:

- Grafana: A powerful open-source visualization and analytics tool that enables users to create dashboards and graphs by connecting to various data sources like Prometheus, Elasticsearch, and Loki.
- Prometheus: A CNCF-graduated monitoring and alerting toolkit, widely used for collecting and querying metrics in cloud-native environments, particularly with Kubernetes.
- Loki: A log aggregation system by Grafana Labs, designed to store and query logs efficiently. It integrates seamlessly with Prometheus and Grafana to provide context-rich monitoring.
- Mimir: A scalable metrics storage system by Grafana Labs, designed as an alternative to Cortex, optimized for high availability and storing large volumes of Prometheus metrics.
- PromTail: A lightweight agent for collecting logs and forwarding them to Loki. It acts as a bridge between log-producing systems and Loki, attaching metadata for easier log querying.
- S3: Amazon’s Simple Storage Service, an object storage platform widely used for scalable, durable, and secure data storage. It serves as a common backend for storing application data, logs, and metrics.
- Kubernetes: An open-source container orchestration platform that automates deployment, scaling, and management of containerized applications, forming the backbone of many cloud-native architectures.
- Helm Charts: A package manager for Kubernetes that simplifies the deployment and management of applications by bundling configuration files and templates into reusable, versioned packages.
- A lightweight Grafana Agent integration that collects metrics from Amazon CloudWatch and exposes them in a Prometheus-compatible format. It simplifies bridging AWS CloudWatch metrics with Prometheus, enabling Kubernetes-native observability and easy integration with tools like Grafana for visualization.


## Landscape

By implementing a cross-account observability environment, we can achieve a high level of infrastructure monitoring and visibility. This is accomplished by leveraging an open-source, cost-effective toolkit designed to efficiently collect logs from multiple AWS accounts and consolidate them into a central account for analysis.

Key features include:
•	Promtail Lambda Function: A customized Lambda function is deployed to handle log collection and forwarding.
•	The function includes enhancements to support retry mechanisms for both same-account and cross-account scenarios, ensuring reliable log ingestion and transport.

This solution provides a scalable and efficient approach to cross-account observability, leveraging lightweight, open-source tools for seamless integration.


![img.png](Observability-landscape.drawio.png)

## Requirements to deploy

This solution involves deploying two key modules:
1.	Central Observability Module:
This module serves as the core observability layer. It is responsible for aggregating and centralizing monitoring data from multiple sources.
2.	Origin Observability Module:
This module is deployed in one or more origin environments to collect and forward observability data from those specific accounts or regions.

Multi-Origin Deployment:

The solution supports deployment across multiple origins, enabling observability data collection from numerous AWS accounts. This setup facilitates centralized monitoring and analysis for multi-account environments.

Cross-Account Configuration:

To enable cross-account observability:
•	A Cross-Account IAM Role must be created and assigned to the Origin Observability providers.
•	The corresponding policy should grant the necessary permissions for data collection and sharing.

Configuration in Central Observability:

•	The variable monitored_accounts in the Central Observability module must be configured with the list of AWS accounts to be monitored. This ensures proper integration and data flow from the origin modules to the central observability layer.


## Deploy using

```terraform plan -var-file="test.tfvars"```

```terraform apply -var-file="test.tfvars"```

## Lint

`terraform fmt -recursive ../../ `

## Destroy using

```terraform destroy -var-file="test.tfvars"```


## Update eks config locally

`aws eks --region eu-central-1 update-kubeconfig --name gustavo-cluster-1`


