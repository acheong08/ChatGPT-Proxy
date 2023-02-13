# ChatGPT-Proxy
Forward requests and inject CloudFlare cookies

## Installation

### One-click scripts 

- With Docker: `curl https://raw.githubusercontent.com/acheong08/ChatGPT-Proxy/main/scripts/run-with-docker.sh | sh`


### Simple steps

1. Clone the repository
2. Check if Pipenv is installed. If not, run `pip install pipenv -U`.
3. Then, run `pipenv update -d` in this directory, to automatically install the requirements of the proxy.
4. Run `pipenv run proxy` in the base directory, and enjoy it! Uvicorn will provide a high-performance HTTP server for the API service.


### Options

These options can be configured by setting environment variables using `-e KEY="VALUE"` in the `docker run` command.

| Env | Default | Example | Description |
| - | - | - | - |
| `GPT_PROXY` | - | `socks5://127.0.0.1:1080` | The proxy of your server. |
| `GPT_HOST` | `0.0.0.0` | `127.0.0.1` | The hostname of your server. |
| `GPT_PORT` | `5000` | `8080` | The port of your server. |