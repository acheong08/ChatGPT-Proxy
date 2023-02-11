# ChatGPT-Proxy
Forward requests and inject CloudFlare cookies

## Installation

### One-click scripts 

- With Docker: `curl https://raw.githubusercontent.com/acheong08/ChatGPT-Proxy/main/scripts/run-with-docker.sh | sh`


### Simple steps

1. Clone the repository
2. Check if Pipenv is installed. If not, run `pip install pipenv -U`.
3. Then, run `pipenv update -d` in this directory, to automatically install the requirements of the proxy.
4. Copy the `config.example.json` to `config.json`, and edit the `proxy`. If the script is being ran on your VPS, please enable the `virtualdisplay` option.
5. Run `pipenv run proxy` in the base directory, and enjoy it! Uvicorn will provide a high-performance HTTP server for the API service.