import pytest

from app.main import app


@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as c:
        yield c


def test_index(client):
    body = client.get("/").get_json()
    assert body["service"] == "campus-grade-api"
    assert "git_sha" in body


def test_health(client):
    assert client.get("/health").get_json() == {"status": "ok"}


def test_grade_ok(client):
    body = client.get("/api/grade?marks=84").get_json()
    assert body == {"marks": 84.0, "grade": "A+", "points": 9, "passed": True}


def test_grade_missing_param(client):
    assert client.get("/api/grade").status_code == 400


def test_grade_bad_values(client):
    assert client.get("/api/grade?marks=abc").status_code == 400
    assert client.get("/api/grade?marks=101").status_code == 400


def test_sgpa_endpoint(client):
    resp = client.post("/api/sgpa", json={"courses": [{"marks": 95, "credits": 3}, {"marks": 65, "credits": 3}]})
    assert resp.status_code == 200
    assert resp.get_json() == {"sgpa": 8.5, "courses": 2}


def test_sgpa_endpoint_rejects_empty(client):
    assert client.post("/api/sgpa", json={}).status_code == 400


def test_secure_report_requires_key(client, monkeypatch):
    monkeypatch.setenv("API_KEY", "unit-test-key")
    assert client.get("/api/secure/report").status_code == 401
    assert client.get("/api/secure/report", headers={"X-API-Key": "wrong"}).status_code == 401
    ok = client.get("/api/secure/report", headers={"X-API-Key": "unit-test-key"})
    assert ok.status_code == 200 and ok.get_json()["status"] == "authorized"


def test_secure_report_locked_without_configured_key(client, monkeypatch):
    monkeypatch.delenv("API_KEY", raising=False)
    assert client.get("/api/secure/report", headers={"X-API-Key": ""}).status_code == 401
