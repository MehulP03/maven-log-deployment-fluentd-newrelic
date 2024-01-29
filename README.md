# Maven Log Collection with Fluentd and New Relic Integration using Docker

This repository provides a Dockerized solution for collecting Maven logs using Fluentd and forwarding them to New Relic. It includes a sample `fluent.conf` configuration file, a `Dockerfile`, and an `entrypoint.sh` script to set up and run the log collection.

## Prerequisites

- [Docker](https://www.docker.com/get-started) installed on your machine.

## Getting Started

1. Clone this repository:

   ```bash
   git clone https://github.com/MehulP03/maven-log-deployment-fluentd-newrelic.git
   cd maven-log-deployment-fluentd-newrelic
   ```

2. Build the Docker image:

   ```bash
   docker build -t maven-fluentd-newrelic .
   ```

3. Run the Docker container:

   ```bash
   docker run -it maven-fluentd-newrelic
   ```

## Configuration

### Fluentd Configuration (`fluent.conf`)

Components of fluentd file

Created a custom parse to formate the JAVA logs.
```
<parse>
   @type regexp
   expression (?<timestamp>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}.\d{3})\s+(?<logLevel>[A-Z]+)\s+(?<pid>\d+)\s+---\s+\[\s*(?<thread>\S+)\s*\]\s+(?<logger>\S+)\s+:\s+(?<message>.*)
</parse>
```

```conf
<source>
  @type tail
  @log_level info
  <parse>
    @type regexp
    expression (?<timestamp>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}.\d{3})\s+(?<logLevel>[A-Z]+)\s+(?<pid>\d+)\s+---\s+\[\s*(?<thread>\S+)\s*\]\s+(?<logger>\S+)\s+:\s+(?<message>.*)
  </parse>
  path /logs.log
  pos_file /tmp/td-agent/log_file.pos
  tag containers
  read_from_head true
</source>

<match **>
  @type newrelic
  license_key #paste api key of newrelic
  base_url https://log-api.newrelic.com/log/v1
  <buffer>
    @type memory
    flush_interval 5s
  </buffer> 
</match>
```

### Dockerfile

```Dockerfile
FROM maven:3.8.3-openjdk-17-slim

RUN apt update && apt upgrade -y
RUN apt install sudo -y
RUN curl -fsSL https://toolbelt.treasuredata.com/sh/install-ubuntu-focal-td-agent4.sh | sh
RUN apt install systemctl -y
RUN apt install -y gettext
RUN td-agent-gem install fluent-plugin-newrelic
RUN apt install jq -y

COPY fluent.conf /etc/td-agent/td-agent-template.conf
COPY entrypoint.sh .
COPY target/*jar /app.jar
RUN ["chmod", "+x", "entrypoint.sh"]
ENTRYPOINT [ "sh", "entrypoint.sh" ]
```

### Entrypoint Script (`entrypoint.sh`)

```bash
#!/bin/bash
sudo systemctl start td-agent.service
envsubst < /etc/td-agent/td-agent-template.conf > /etc/td-agent/td-agent.conf
sudo systemctl start td-agent.service
java -jar app.jar 2>&1 | tee -a /logs.log
sudo systemctl status td-agent.service
```

## Usage

1. Build and run the Docker container as mentioned in the "Getting Started" section.

2. Replace `#paste api key of newrelic` in `fluent.conf` with your New Relic API key.

3. Customize other configurations as needed.

4. Run the Docker container, and Maven logs will be collected and forwarded to New Relic.

## Notes

- Make sure to replace placeholder values and customize configurations based on your requirements.
- Ensure that your New Relic API key is valid and properly configured.
