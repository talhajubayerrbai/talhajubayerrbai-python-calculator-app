"""
Pytest test suite for the Flask Calculator App.
Run from the repo root with:  python -m pytest app/tests/ -v
"""

import sys
import os

# Make sure `app/` is importable regardless of working directory
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

import json
import pytest
from app import app as flask_app


@pytest.fixture
def client():
    """Create a Flask test client with testing mode enabled."""
    flask_app.config["TESTING"] = True
    with flask_app.test_client() as client:
        yield client


# ---------------------------------------------------------------------------
# Helper
# ---------------------------------------------------------------------------

def post_calculate(client, a, b, op):
    return client.post(
        "/calculate",
        data=json.dumps({"a": a, "b": b, "op": op}),
        content_type="application/json",
    )


# ---------------------------------------------------------------------------
# Health check
# ---------------------------------------------------------------------------

def test_health_returns_200(client):
    """GET /health must respond 200 with {"status": "ok"}."""
    resp = client.get("/health")
    assert resp.status_code == 200
    body = resp.get_json()
    assert body == {"status": "ok"}


# ---------------------------------------------------------------------------
# HTML UI
# ---------------------------------------------------------------------------

def test_index_returns_html(client):
    """GET / must return 200 and HTML content."""
    resp = client.get("/")
    assert resp.status_code == 200
    assert b"Calculator" in resp.data


# ---------------------------------------------------------------------------
# Arithmetic — happy paths
# ---------------------------------------------------------------------------

def test_add(client):
    """3 + 4 = 7."""
    resp = post_calculate(client, 3, 4, "add")
    assert resp.status_code == 200
    assert resp.get_json() == {"result": 7}


def test_subtract(client):
    """10 - 3 = 7."""
    resp = post_calculate(client, 10, 3, "subtract")
    assert resp.status_code == 200
    assert resp.get_json() == {"result": 7}


def test_multiply(client):
    """6 × 7 = 42."""
    resp = post_calculate(client, 6, 7, "multiply")
    assert resp.status_code == 200
    assert resp.get_json() == {"result": 42}


def test_divide(client):
    """20 ÷ 4 = 5."""
    resp = post_calculate(client, 20, 4, "divide")
    assert resp.status_code == 200
    assert resp.get_json() == {"result": 5}


def test_divide_non_whole(client):
    """7 ÷ 2 = 3.5 (float result)."""
    resp = post_calculate(client, 7, 2, "divide")
    assert resp.status_code == 200
    assert resp.get_json() == {"result": 3.5}


# ---------------------------------------------------------------------------
# Arithmetic — error paths
# ---------------------------------------------------------------------------

def test_divide_by_zero(client):
    """Division by zero must return HTTP 400 with {"error": "division by zero"}."""
    resp = post_calculate(client, 9, 0, "divide")
    assert resp.status_code == 400
    body = resp.get_json()
    assert "error" in body
    assert body["error"] == "division by zero"


def test_unknown_operation(client):
    """An unknown op name must return HTTP 400."""
    resp = post_calculate(client, 1, 1, "modulo")
    assert resp.status_code == 400
    body = resp.get_json()
    assert "error" in body


def test_missing_field(client):
    """A request missing the 'b' field must return HTTP 400."""
    resp = client.post(
        "/calculate",
        data=json.dumps({"a": 5, "op": "add"}),
        content_type="application/json",
    )
    assert resp.status_code == 400
    assert "error" in resp.get_json()


def test_non_numeric_values(client):
    """Non-numeric a/b must return HTTP 400."""
    resp = post_calculate(client, "foo", "bar", "add")
    assert resp.status_code == 400
    assert "error" in resp.get_json()


def test_negative_numbers(client):
    """-5 + -3 = -8."""
    resp = post_calculate(client, -5, -3, "add")
    assert resp.status_code == 200
    assert resp.get_json() == {"result": -8}


def test_float_inputs(client):
    """0.1 + 0.2 ≈ 0.3 (floating-point result accepted)."""
    resp = post_calculate(client, 0.1, 0.2, "add")
    assert resp.status_code == 200
    result = resp.get_json()["result"]
    assert abs(result - 0.3) < 1e-9
