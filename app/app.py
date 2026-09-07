"""
Python Flask Calculator App
Endpoints:
  GET  /           — HTML UI
  GET  /health     — ALB health check → {"status": "ok"}
  POST /calculate  — JSON API → {"result": <number>}
"""

from flask import Flask, render_template, request, jsonify

app = Flask(__name__)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _calculate(a, b, op):
    """Return (result, error_message).  error_message is None on success."""
    if op == "add":
        return a + b, None
    elif op == "subtract":
        return a - b, None
    elif op == "multiply":
        return a * b, None
    elif op == "divide":
        if b == 0:
            return None, "division by zero"
        return a / b, None
    else:
        return None, f"unknown operation: {op}"


# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------

@app.route("/health")
def health():
    """ALB health-check endpoint."""
    return jsonify({"status": "ok"}), 200


@app.route("/", methods=["GET"])
def index():
    """Serve the calculator UI."""
    return render_template("index.html")


@app.route("/calculate", methods=["POST"])
def calculate():
    """
    Accept JSON: {"a": <number>, "b": <number>, "op": "add"|"subtract"|"multiply"|"divide"}
    Return:      {"result": <number>}  or  HTTP 400 {"error": "..."}
    """
    data = request.get_json(force=True, silent=True)
    if data is None:
        return jsonify({"error": "invalid JSON body"}), 400

    # Validate required keys
    for key in ("a", "b", "op"):
        if key not in data:
            return jsonify({"error": f"missing field: {key}"}), 400

    try:
        a = float(data["a"])
        b = float(data["b"])
    except (TypeError, ValueError):
        return jsonify({"error": "a and b must be numbers"}), 400

    op = data["op"]
    result, error = _calculate(a, b, op)
    if error:
        return jsonify({"error": error}), 400

    # Return integer when result is whole, float otherwise
    if isinstance(result, float) and result.is_integer():
        result = int(result)

    return jsonify({"result": result}), 200


# ---------------------------------------------------------------------------
# Dev entry-point (gunicorn uses the `app` object directly)
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
