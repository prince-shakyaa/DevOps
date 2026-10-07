"""Campus grade API: a small Flask service used to demonstrate a CI/CD pipeline."""
import hmac
import os
import socket

from flask import Flask, jsonify, request

from app.grading import is_pass, letter_grade, sgpa

APP_VERSION = "1.0.0"

app = Flask(__name__)


@app.get("/")
def index():
    return jsonify(
        service="campus-grade-api",
        version=APP_VERSION,
        git_sha=os.environ.get("GIT_SHA", "dev"),
        hostname=socket.gethostname(),
        endpoints=["/health", "/api/grade?marks=<n>", "POST /api/sgpa", "/api/secure/report"],
    )


@app.get("/health")
def health():
    return jsonify(status="ok")


@app.get("/api/grade")
def grade():
    try:
        marks = float(request.args["marks"])
        letter, points = letter_grade(marks)
    except KeyError:
        return jsonify(error="query parameter 'marks' is required"), 400
    except (TypeError, ValueError) as exc:
        return jsonify(error=str(exc)), 400
    return jsonify(marks=marks, grade=letter, points=points, passed=is_pass(marks))


@app.post("/api/sgpa")
def compute_sgpa():
    body = request.get_json(silent=True) or {}
    try:
        result = sgpa(body.get("courses", []))
    except (TypeError, ValueError) as exc:
        return jsonify(error=str(exc)), 400
    return jsonify(sgpa=result, courses=len(body["courses"]))


@app.get("/api/secure/report")
def secure_report():
    expected = os.environ.get("API_KEY", "")
    supplied = request.headers.get("X-API-Key", "")
    if not expected or not hmac.compare_digest(supplied, expected):
        return jsonify(error="unauthorized"), 401
    return jsonify(status="authorized", report="semester results unlocked")


if __name__ == "__main__":  # pragma: no cover
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", "8000")))
