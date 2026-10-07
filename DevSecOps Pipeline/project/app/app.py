"""Campus notice board: a deliberately small Flask app that the DevSecOps pipeline guards."""
import os
import socket
from datetime import datetime, timezone

from flask import Flask, abort, jsonify, render_template, request

APP_VERSION = "1.2.0"
CATEGORIES = {"academic", "exam", "event", "hostel", "placement"}
MAX_TITLE = 80
MAX_BODY = 500

app = Flask(__name__)

# in-memory store; a real deployment would use a database
NOTICES = [
    {"id": 1, "title": "Mid-semester exams", "body": "Timetable is on the portal.", "category": "exam",
     "posted_at": "2026-09-28T09:00:00+00:00"},
    {"id": 2, "title": "Hackathon registrations open", "body": "Teams of up to four.", "category": "event",
     "posted_at": "2026-10-01T12:30:00+00:00"},
]


def _validate(payload):
    """Return (clean_notice, None) or (None, error message)."""
    if not isinstance(payload, dict):
        return None, "JSON object expected"
    title = payload.get("title")
    body = payload.get("body")
    category = payload.get("category")
    if not isinstance(title, str) or not title.strip() or len(title) > MAX_TITLE:
        return None, f"title must be 1-{MAX_TITLE} characters"
    if not isinstance(body, str) or not body.strip() or len(body) > MAX_BODY:
        return None, f"body must be 1-{MAX_BODY} characters"
    if category not in CATEGORIES:
        return None, f"category must be one of {sorted(CATEGORIES)}"
    return {"title": title.strip(), "body": body.strip(), "category": category}, None


@app.get("/")
def index():
    return render_template("index.html", notices=NOTICES, version=APP_VERSION)


@app.get("/health")
def health():
    return jsonify(status="healthy", version=APP_VERSION)


@app.get("/api/version")
def version():
    return jsonify(version=APP_VERSION, git_sha=os.environ.get("GIT_SHA", "dev"), hostname=socket.gethostname())


@app.get("/api/notices")
def list_notices():
    category = request.args.get("category")
    if category is not None and category not in CATEGORIES:
        return jsonify(error="unknown category"), 400
    items = [n for n in NOTICES if category is None or n["category"] == category]
    return jsonify(count=len(items), notices=items)


@app.get("/api/notices/<int:notice_id>")
def get_notice(notice_id):
    for notice in NOTICES:
        if notice["id"] == notice_id:
            return jsonify(notice)
    abort(404)


@app.post("/api/notices")
def create_notice():
    clean, error = _validate(request.get_json(silent=True))
    if error:
        return jsonify(error=error), 400
    clean["id"] = max((n["id"] for n in NOTICES), default=0) + 1
    clean["posted_at"] = datetime.now(timezone.utc).isoformat(timespec="seconds")
    NOTICES.append(clean)
    return jsonify(clean), 201


@app.errorhandler(404)
def not_found(_):
    return jsonify(error="not found"), 404

