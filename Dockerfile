FROM ubuntu:latest

WORKDIR /

ADD ./ /app
RUN apt update && apt install git curl python3 python3-pip wget xvfb -y && cd /app && python3 -m pip install pipenv && pipenv update -d

# Install Chrome
ADD ./scripts/install-chrome.sh /
RUN bash /install-chrome.sh

WORKDIR /app
ENTRYPOINT [ "bash", "/app/launch.sh" ]
