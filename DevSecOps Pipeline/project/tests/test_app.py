import pytest

from app import app as app_module
from app.app import app


@pytest.fixture
def client():
    app.config["TESTING"] = True
    saved = list(app_module.NOTICES)
    with app.test_client() as c:
        yield c
    app_module.NOTICES[:] = saved


def test_index_renders_notices(client):
    resp = client.get("/")
    assert resp.status_code == 200
    assert b"Mid-semester exams" in resp.data


def test_index_escapes_html(client):
    client.post("/api/notices", json={"title": "<script>alert(1)</script>", "body": "x", "category": "event"})
    assert b"<script>alert(1)</script>" not in client.get("/").data


def test_health(client):
    assert client.get("/health").get_json()["status"] == "healthy"


def test_version_reports_git_sha(client, monkeypatch):
    monkeypatch.setenv("GIT_SHA", "abc1234")
    assert client.get("/api/version").get_json()["git_sha"] == "abc1234"


def test_list_and_filter(client):
    assert client.get("/api/notices").get_json()["count"] == 2
    exams = client.get("/api/notices?category=exam").get_json()
    assert exams["count"] == 1 and exams["notices"][0]["category"] == "exam"
    assert client.get("/api/notices?category=parties").status_code == 400


def test_get_one_and_404(client):
    assert client.get("/api/notices/1").get_json()["id"] == 1
    assert client.get("/api/notices/999").status_code == 404


def test_create_notice(client):
    resp = client.post("/api/notices", json={"title": "Library hours", "body": "Open till 11pm.", "category": "academic"})
    assert resp.status_code == 201
    body = resp.get_json()
    assert body["id"] == 3 and body["posted_at"].endswith("+00:00")


@pytest.mark.parametrize("payload", [
    None,
    ["not", "a", "dict"],
    {"title": "", "body": "b", "category": "exam"},
    {"title": "t" * 81, "body": "b", "category": "exam"},
    {"title": "t", "body": "   ", "category": "exam"},
    {"title": "t", "body": "b" * 501, "category": "exam"},
    {"title": "t", "body": "b", "category": "parties"},
])
def test_create_rejects_bad_input(client, payload):
    assert client.post("/api/notices", json=payload).status_code == 400
