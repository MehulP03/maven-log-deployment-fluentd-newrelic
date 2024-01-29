FROM maven:3.8.3-openjdk-17-slim

RUN apt update && apt upgrade -y
RUN apt install sudo -y
RUN curl -fsSL https://toolbelt.treasuredata.com/sh/install-ubuntu-focal-td-agent4.sh | sh
RUN apt install systemctl -y
RUN apt install -y gettext
RUN td-agent-gem install fluent-plugin-newrelic
# RUN td-agent-gem install fluent-plugin-newrelic
RUN apt install jq -y
# RUN curl -L https://toolbelt.treasuredata.com/sh/install-debian-buster-td-agent4.sh | sh

COPY fluent.conf /etc/td-agent/td-agent-template.conf
COPY entrypoint.sh .
COPY target/*jar /app.jar
RUN ["chmod", "+x", "entrypoint.sh"]
ENTRYPOINT [ "sh", "entrypoint.sh" ]
