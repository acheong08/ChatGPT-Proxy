"""
Fetches cookies from chat.openai.com and returns them (Flask)
"""
import json
import os
import tls_client
import uvicorn

from asgiref.wsgi import WsgiToAsgi
from flask import Flask
from flask import jsonify
from flask import request
from OpenAIAuth.Cloudflare import Cloudflare

GPT_PROXY = os.getenv('GPT_PROXY')
GPT_HOST = os.getenv('GPT_HOST', '0.0.0.0')
GPT_PORT = int(os.getenv('GPT_PORT', 5000))

app = Flask(__name__)

session = tls_client.Session(client_identifier="chrome_108", )
if GPT_PROXY:
    session.proxies.update(http=GPT_PROXY, https=GPT_PROXY)

authentication = {}

context = {"blocked": False}

# Get cloudflare cookies
(
    authentication["cf_clearance"],
    authentication["user_agent"],
) = Cloudflare(proxy=GPT_PROXY).get_cf_cookies()


@app.route("/<path:subpath>", methods=["POST", "GET"])
def conversation(subpath: str):
    if request.headers.get("Authorization") is None:
        return jsonify({"error": "Missing Authorization header"})
    try:
        if context.get("blocked"):
            return jsonify({"error": "Blocking operation in progress"})
        # Get cookies from request
        cookies = {
            "cf_clearance":
            authentication["cf_clearance"],
            "__Secure-next-auth.session-token":
            request.cookies.get("__Secure-next-auth.session-token"),
        }

        # Set user agent
        headers = {
            "Accept": "text/event-stream",
            "Authorization": request.headers.get("Authorization"),
            "User-Agent": authentication["user_agent"],
            "Content-Type": "application/json",
            "X-Openai-Assistant-App-Id": "",
            "Connection": "close",
            "Accept-Language": "en-US,en;q=0.9",
            "Referer": "https://chat.openai.com/" + "chat",
        }

        # Send request to OpenAI
        if request.method == "POST":
            response = session.post(
                url="https://chat.openai.com/" + subpath,
                headers=headers,
                cookies=cookies,
                data=json.dumps(request.get_json()),
                timeout_seconds=360,
            )
        elif request.method == "GET":
            response = session.get(
                url="https://chat.openai.com/" + subpath,
                headers=headers,
                cookies=cookies,
                timeout_seconds=360,
            )

        # Check status code
        if response.status_code == 403:
            # Get cf_clearance again
            context["blocked"] = True
            (
                authentication["cf_clearance"],
                authentication["user_agent"],
            ) = Cloudflare(proxy=GPT_PROXY).get_cf_cookies()
            context["blocked"] = False
            # return error
            return jsonify({
                "error":
                "Cloudflare token expired. Please wait a few minutes while I refresh"
            })
        # Return response
        return response.text
    except Exception as exc:
        return jsonify({"error": str(exc)})


if __name__ == "__main__":
    uvicorn.run(
        WsgiToAsgi(app),
        host=GPT_HOST,
        port=GPT_PORT,
        server_header=False)  # start a high-performance server with Uvicorn
