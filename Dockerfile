FROM python:3.14-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.14-slim
WORKDIR /app
COPY --from=builder /install /usr/local
RUN useradd -m -u 1000 appuser
USER 1000
COPY src/ src/
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')"]
CMD ["uvicorn", "src.app:app", "--host", "0.0.0.0", "--port", "8080"]
