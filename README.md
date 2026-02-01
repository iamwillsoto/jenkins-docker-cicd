# Jenkins CI/CD in Docker with Persistent Volumes

This project implements Jenkins in Docker with persistent state and a controlled runtime lifecycle.
Jenkins is deployed using containerized infrastructure, validated for state persistence across rebuilds,
extended through a custom image, and fully torn down to confirm correct resource ownership.

The goal is to demonstrate operationally sound CI/CD infrastructure patterns rather than a one-off Jenkins install.

---

## Overview

Jenkins is executed as a Dockerized service with its state externalized to a named volume.
This allows Jenkins containers to be replaced, upgraded, or rebuilt without loss of configuration,
credentials, or build history.

The runtime is then extended via a Dockerfile to demonstrate how Jenkins environments can be versioned
and standardized across teams. Finally, all resources are explicitly removed to validate a clean lifecycle.

---

## Design Decisions

- **Containerized Jenkins runtime**  
  Eliminates host configuration drift and enables repeatable provisioning.

- **Named Docker volume mounted to `/var/jenkins_home`**  
  Ensures Jenkins state survives container replacement.

- **Explicit container recreation**  
  Confirms Jenkins persistence behaves correctly under rebuild scenarios.

- **Custom Jenkins image**  
  Allows runtime dependencies to be installed and version-controlled.

- **Explicit teardown**  
  Prevents orphaned volumes and ensures full cleanup of CI infrastructure.

---

## Repository Structure

```bash
├── docker-compose.yml
├── Dockerfile
├── validation-screenshots/
└── README.md
```

---

## Jenkins Deployment (Docker Compose)

Jenkins is launched using the official Jenkins LTS image with a persistent volume mapped to
`/var/jenkins_home`.

```bash
docker compose up -d
docker ps
```

Initial administrator credentials are retrieved directly from the container:

```bash
docker exec -it jenkins-lts \
  cat /var/jenkins_home/secrets/initialAdminPassword
```

Jenkins is then initialized via the web UI at:
```bash
http://localhost:8080
```

## Persistence Validation
The Jenkins container is removed and recreated while retaining the same data volume:

```bash
docker compose down
docker compose up -d
```

Result:

Jenkins does not reinitialize

Previously created users and configuration remain intact

This confirms Jenkins state is decoupled from the container lifecycle.

## Runtime Customization (Dockerfile)

A custom Jenkins image is built on top of Jenkins LTS with additional tooling commonly required in CI environments.

```bash
docker build -t jenkins-custom:lts .
docker images | grep jenkins-custom
```

The custom image is launched with a separate volume and alternate port mapping:
```bash
docker volume create jenkins_custom_home

docker run -d \
  --name jenkins-custom \
  -p 8081:8080 \
  -p 50001:50000 \
  -v jenkins_custom_home:/var/jenkins_home \
  jenkins-custom:lts

docker ps
```

Administrator credentials are retrieved in the same manner:
```bash
docker exec -it jenkins-custom \
  cat /var/jenkins_home/secrets/initialAdminPassword
```

Jenkins is accessible at:
```bash
http://localhost:8081
```

## Teardown & Verification
All Jenkins resources are explicity removed to confirm clean lifecycle management.
```bash
docker rm -f jenkins-custom
docker volume rm jenkins_custom_home
docker rmi jenkins-custom:lts
```

Compose resources are removed along with their volume:
```bash
docker compose down -v
```

Verification
```bash
docker ps -a | grep jenkins || echo "No Jenkins containers found"
docker volume ls | grep jenkins || echo "No Jenkins volumes found"
docker images | grep jenkins-custom || echo "No custom Jenkins image found"
```

## Evidence

Command output and UI verification screenshots are stored in the validation-screenshots/ directory and
demonstrate successful deployment, persistence, customization, and teardown.