# ─────────────────────────────────────────────────────────────────────────────
# Python Calculator App — container image
# Base:  python:3.11-slim
# Serve: gunicorn on 0.0.0.0:5000
# ─────────────────────────────────────────────────────────────────────────────

FROM python:3.11-slim

# Non-root user for security
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

# Set working directory
WORKDIR /app

# Install dependencies first (layer-cache friendly)
COPY app/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source
COPY app/ /app/

# Own files by the non-root user
RUN chown -R appuser:appgroup /app

USER appuser

# Flask / gunicorn port
EXPOSE 5000

# Health check so `docker run` and orchestrators know when the app is ready
HEALTHCHECK --interval=15s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')"

# gunicorn: bind all interfaces, 2 workers, app object from app.py
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--timeout", "30", "app:app"]
