"""
Fetches cookies from chat.openai.com and returns them (Flask)
"""
import json

import tls_client
from flask import Flask
from flask import jsonify
from flask import request
from OpenAIAuth.Cloudflare import Cloudflare

app = Flask(__name__)

session = tls_client.Session(
    client_identifier="chrome_108",
)

session.proxies.update(
    {
        "http": "http://185.199.229.156:7492",
        "https": "https://185.199.229.156:7492",
    }
)

authentication = {}

context = {"blocked": False}

# Get cloudflare cookies
(
    authentication["cf_clearance"],
    authentication["user_agent"],
) = Cloudflare(proxy="socks5://185.199.229.156:7492").get_cf_cookies()


@app.route("/<path:subpath>", methods=["POST", "GET"])
def conversation(subpath: str):
    try:
        if context.get("blocked"):
            return jsonify({"error": "Blocking operation in progress"})
        # Get cookies from request
        cookies = {
            "cf_clearance": authentication["cf_clearance"],
            "__Secure-next-auth.session-token": request.cookies.get(
                "__Secure-next-auth.session-token"
            ),
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

        print(response.text)

        # Check status code
        if response.status_code == 403:
            # Get cf_clearance again
            context["blocked"] = True
            (
                authentication["cf_clearance"],
                authentication["user_agent"],
            ) = Cloudflare(proxy="socks5://185.199.229.156:7492").get_cf_cookies()
            context["blocked"] = False
            # return error
            return jsonify(
                {
                    "error": "Cloudflare token expired. Please wait a few minutes while I refresh"
                }
            )
        # Return response
        print(response.text)
        return response.text
    except Exception as exc:
        return jsonify({"error": str(exc)})


if __name__ == "__main__":
    app.run(debug=False)
