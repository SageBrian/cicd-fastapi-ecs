# ---- build stage ----
FROM python:3.12-slim AS build

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --target=/install -r requirements.txt

# ---- runtime stage ----
FROM python:3.12-slim

# Run as non-root
RUN useradd --create-home --uid 1000 appuser
WORKDIR /app

COPY --from=build /install /usr/local/lib/python3.12/site-packages
COPY main.py .

USER appuser
EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
