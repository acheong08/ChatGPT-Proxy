FROM ubuntu:latest

WORKDIR /app

COPY . /app

RUN apt update \
    && apt install git curl python3 python3-pip xvfb -y \
    && cd /app \
    && python3 -m pip install pipenv \
    && pipenv update -d

# Install Chrome
RUN bash /app/scripts/install-chrome.sh

ENTRYPOINT [ "bash", "/app/launch.sh" ]
