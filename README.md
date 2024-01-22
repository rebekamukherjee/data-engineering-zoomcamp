# Data Engineering Zoompcamp 2024

## Important Links

- [GitHub Online Course](https://github.com/DataTalksClub/data-engineering-zoomcamp)
- [YouTube Playlist](https://www.youtube.com/playlist?list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb)
- [2024 Syllabus & Deadlines](https://docs.google.com/spreadsheets/d/e/2PACX-1vQACMLuutV5rvXg5qICuJGL-yZqIV0FBD84CxPdC5eZHf8TfzB-CJT_3Mo7U7oGVTXmSihPgQxuuoku/pubhtml)
- [2024 Homework](https://github.com/DataTalksClub/data-engineering-zoomcamp/tree/main/cohorts/2024)

## Content

### Module 1: Containerization & Infrastructure as Code

- Google Cloud Platform (GCP)
    - Introduction to GCP
    [[video](https://youtu.be/18jIzE41fJ4)]
- Docker + Postgres
[[code](https://github.com/DataTalksClub/data-engineering-zoomcamp/tree/main/01-docker-terraform/2_docker_sql)]
    - Introduction to Docker
    [[video](https://youtu.be/EYNwNlOrpr0),
    [notes](notes/1_docker.md)]
    - Ingesting NY Taxi Data into Postgres
    [[video](https://youtu.be/2JM-ziJt0WI),
    [notes](notes/2_postgresql.md)]
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
- Terraform
    - Introduction to Terraform
    - Terraform Basics: Simple one file Terraform Deployment
    - Deployment with a Variables File
    - Configuring terraform and GCP SDK on Windows