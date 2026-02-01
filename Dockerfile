FROM jenkins/jenkins:lts

# Switch to root to install packages (optional, but shows "custom build" capability)
USER root

# Minimal example: add basic tools you commonly want in CI environments
RUN apt-get update \
  && apt-get install -y --no-install-recommends curl git \
  && rm -rf /var/lib/apt/lists/*

# Back to the jenkins user for runtime
USER jenkins
