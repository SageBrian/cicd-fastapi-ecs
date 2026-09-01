import os
import time
from datetime import datetime

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

APP_VERSION = os.getenv("APP_VERSION", "0.1.0")
START_TIME = time.time()

app = FastAPI(title="devops-demo-api", version=APP_VERSION)

# ---- in-memory "database" so the app runs with zero external deps ----
_items: dict[int, "Item"] = {}
_next_id = 1


class Item(BaseModel):
    id: int | None = None
    name: str
    description: str | None = None


@app.get("/health")
def health():
    """Used by ALB target group health checks and CI smoke tests."""
    return {
        "status": "ok",
        "version": APP_VERSION,
        "uptime_seconds": round(time.time() - START_TIME, 2),
        "timestamp": datetime.utcnow().isoformat(),
    }


@app.get("/")
def root():
    return {"message": "devops-demo-api is running", "version": APP_VERSION}


@app.get("/items")
def list_items():
    return list(_items.values())


@app.post("/items", status_code=201)
def create_item(item: Item):
    global _next_id
    item.id = _next_id
    _items[_next_id] = item
    _next_id += 1
    return item


@app.get("/items/{item_id}")
def get_item(item_id: int):
    if item_id not in _items:
        raise HTTPException(status_code=404, detail="Item not found")
    return _items[item_id]
