from fastapi.testclient import TestClient

from main import app

client = TestClient(app)


def test_health():
    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.json()["status"] == "ok"


def test_root():
    resp = client.get("/")
    assert resp.status_code == 200


def test_create_and_get_item():
    resp = client.post("/items", json={"name": "widget", "description": "a test widget"})
    assert resp.status_code == 201
    item_id = resp.json()["id"]

    resp = client.get(f"/items/{item_id}")
    assert resp.status_code == 200
    assert resp.json()["name"] == "widget"


def test_get_missing_item():
    resp = client.get("/items/9999")
    assert resp.status_code == 404
