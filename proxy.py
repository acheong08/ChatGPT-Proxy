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

authentication = {}

context = {"blocked": False}

# Get cloudflare cookies
(
    authentication["cf_clearance"],
    authentication["user_agent"],
) = Cloudflare().get_cf_cookies()


@app.route("/backend-api/conversation", methods=["POST"])
def conversation():
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
        # Get JSON payload from request
        payload = request.get_json()

        # Set user agent
        headers = {
            "Accept": "text/event-stream",
            "Authorization": request.headers.get("Authorization"),
            "User-Agent": authentication["user_agent"],
            "Content-Type": "application/json",
            "X-Openai-Assistant-App-Id": "",
            "Connection": "close",
            "Accept-Language": "en-US,en;q=0.9",
            "Referer": "https://chat.openai.com/chat",
        }

        # Send request to OpenAI
        response = session.post(
            url="https://chat.openai.com/backend-api/conversation",
            headers=headers,
            cookies=cookies,
            data=json.dumps(payload),
            timeout_seconds=360,
        )

        # Check status code
        if response.status_code == 403:
            # Get cf_clearance again
            context["blocked"] = True
            (
                authentication["cf_clearance"],
                authentication["user_agent"],
            ) = Cloudflare().get_cf_cookies()
            context["blocked"] = False
            # return error
            return jsonify(
                {
                    "error": "Cloudflare token expired. Please wait a few minutes while I refresh"
                }
            )
        # Return response
        return response.text
    except Exception as exc:
        return jsonify({"error": str(exc)})


if __name__ == "__main__":
    app.run(debug=True)
