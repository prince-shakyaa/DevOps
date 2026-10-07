"""Campus Lost & Found API: report lost/found items, mark them returned."""
import os
import time

import psycopg
from psycopg.rows import dict_row
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

DB_DSN = (
    f"host={os.getenv('DB_HOST', 'localhost')} port={os.getenv('DB_PORT', '5432')} "
    f"dbname={os.getenv('DB_NAME', 'lostfound')} user={os.getenv('DB_USER', 'lostfound')} "
    f"password={os.getenv('DB_PASSWORD', 'lostfound')}"
)

app = FastAPI(title="Campus Lost & Found")


class ItemIn(BaseModel):
    title: str
    location: str
    kind: str = "lost"          # lost | found


class ItemPatch(BaseModel):
    status: str                 # open | returned


def conn():
    return psycopg.connect(DB_DSN, row_factory=dict_row, connect_timeout=3)


@app.on_event("startup")
def init_db():
    # fail fast: a few short retries, then crash so the problem is visible
    for attempt in range(1, int(os.getenv("DB_RETRIES", "5")) + 1):
        try:
            with conn() as c:
                c.execute("""
                    CREATE TABLE IF NOT EXISTS items (
                        id SERIAL PRIMARY KEY,
                        title TEXT NOT NULL,
                        location TEXT NOT NULL,
                        kind TEXT NOT NULL DEFAULT 'lost',
                        status TEXT NOT NULL DEFAULT 'open',
                        created_at TIMESTAMPTZ NOT NULL DEFAULT now()
                    )""")
            print(f"database ready on attempt {attempt}", flush=True)
            return
        except psycopg.OperationalError as e:
            print(f"database not ready (attempt {attempt}): {str(e).strip().splitlines()[0]}", flush=True)
            time.sleep(1)
    raise RuntimeError("could not reach the database")


@app.get("/api/health")
def health():
    with conn() as c:
        c.execute("SELECT 1")
    return {"status": "ok", "db": "up"}


@app.get("/api/items")
def list_items():
    with conn() as c:
        return c.execute(
            "SELECT id, title, location, kind, status FROM items ORDER BY id").fetchall()


@app.post("/api/items", status_code=201)
def create_item(item: ItemIn):
    if item.kind not in ("lost", "found"):
        raise HTTPException(422, "kind must be 'lost' or 'found'")
    with conn() as c:
        return c.execute(
            "INSERT INTO items (title, location, kind) VALUES (%s, %s, %s) "
            "RETURNING id, title, location, kind, status",
            (item.title, item.location, item.kind)).fetchone()


@app.patch("/api/items/{item_id}")
def update_item(item_id: int, patch: ItemPatch):
    with conn() as c:
        row = c.execute(
            "UPDATE items SET status = %s WHERE id = %s "
            "RETURNING id, title, location, kind, status",
            (patch.status, item_id)).fetchone()
    if not row:
        raise HTTPException(404, "item not found")
    return row


@app.delete("/api/items/{item_id}", status_code=204)
def delete_item(item_id: int):
    with conn() as c:
        if c.execute("DELETE FROM items WHERE id = %s", (item_id,)).rowcount == 0:
            raise HTTPException(404, "item not found")
