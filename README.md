# Data Engineering Zoompcamp 2024

## Important Links

- [GitHub Online Course](https://github.com/DataTalksClub/data-engineering-zoomcamp)
- [YouTube Playlist](https://www.youtube.com/playlist?list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb)
- [2024 Syllabus & Deadlines](https://docs.google.com/spreadsheets/d/e/2PACX-1vQACMLuutV5rvXg5qICuJGL-yZqIV0FBD84CxPdC5eZHf8TfzB-CJT_3Mo7U7oGVTXmSihPgQxuuoku/pubhtml)
- [2024 Homework](https://github.com/DataTalksClub/data-engineering-zoomcamp/tree/main/cohorts/2024)

## Content

### Module 1: Containerization & Infrastructure as Code

- Docker + Postgres
[[code](./code/1_docker/)]
    - Introduction to Docker
    [[video](https://youtu.be/EYNwNlOrpr0),
    [notes](notes/1_docker.md)]
    - Ingesting NY Taxi Data into Postgres
    [[video](https://youtu.be/2JM-ziJt0WI),
    [notes](notes/2_postgres.md)]
    - Connecting pgAdmin and Postgres
    [[video](https://youtu.be/hCAIVe9N0ow),
    [notes](notes/3_pgadmin.md)]
    - Putting the ingestion script into Docker
    [[video](https://youtu.be/B1WwATwf-vY),
    [notes](notes/4_data-ingestion.md)]
    - Running Postgres and pgAdmin with Docker-Compose
    [[video](https://youtu.be/hKI6PkPhpa0),
    [notes](notes/5_docker-compose.md)]
    - SQL refresher
    [[video](https://youtu.be/QEcps_iskgg)]
- Google Cloud Platform (GCP)
    - Introduction to GCP
    [[video](https://youtu.be/18jIzE41fJ4)]
- Terraform
[[code](./code/2_terraform/)]
    - Introduction to Terraform
    [[video](https://youtu.be/s2bOYDCKl_M),
    [notes](notes/6_terraform.md)]
    - Simple one file Terraform Deployment
    [[video](https://youtu.be/Y2ux7gq3Z0o),
    [notes](notes/6_terraform.md)]
    - Deployment with a Variables File
    [[video](https://youtu.be/PBi0hHjLftk),
    [notes](notes/6_terraform.md)]

### Module 2: Workflow Orchestration

- Data Lake
[[video](https://youtu.be/W3Zm6rjOq70),
[notes](notes/7_data-lake.md)]
- Introduction to Orchestration
[[video 1](https://youtu.be/0yK7LXwYeD0),
[video 2](https://youtu.be/Li8-MWHhTbo),
[notes](notes/8_workflow-orchestration.md)]
- Mage
[[code](./code/3_mage/),
[notes](notes/9_mage.md)]
    - Introduction to Mage
       - What is Mage?
       [[video](https://youtu.be/AicKRcK3pa4)]
       - Configuring Mage
       [[video](https://youtu.be/2SV-av3L3-k)]
       - A Simple Pipeline
       [[video](https://youtu.be/stI-gg4QBnI)]
    - ETL: API to Postgres
        - Configuring Postgres
        [[video](https://youtu.be/pmhI-ezd3BE)]
        - Writing an ETL Pipeline
        [[video](https://youtu.be/pmhI-ezd3BE)]
    - ETL: API to GCS
        - Configuring GCP
        [[video](https://youtu.be/00LP360iYvE)]
        - Writing an ETL Pipeline
        [[video](https://youtu.be/w0XmcASRUnc)]
    - ETL: GCS to BigQuery
        - Writing an ETL Pipeline
        [[video](https://youtu.be/JKp_uzM-XsM)]
    - Parameterized Execution
    [[video](https://youtu.be/H0hWjWxB-rg)]
    - Backfills
    [[video](https://youtu.be/ZoeC6Ag5gQc)]
    - Deployment
    [[code](./code/4_gcp/)]
        - Deployment Prerequisites
        [[video](https://youtu.be/zAwAX5sxqsg)]
        - Google Cloud Permissions
        [[video](https://youtu.be/O_H7DCmq2rA)]
        - Deploying to Google Cloud
        [[video 1](https://youtu.be/9A872B5hb_0),
        [video 2](https://youtu.be/0YExsb2HgLI)]

### Module 3: Data Warehouse

- BigQuery
[[code](),
[notes]()]
    - Data Warehouse
    [[video]()]
    - Partitioning and Clustering
    [[video]()]
    - BigQuery Best Practices
    [[video]()]
    - Internals of BigQuery
    [[video]()]
    - Machine Learning in BigQuery
    [[video]()]
    - Machine Learning Deployment in BigQuery
    [[video]()]