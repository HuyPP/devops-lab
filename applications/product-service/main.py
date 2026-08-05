from fastapi import FastAPI, Response
from prometheus_client import generate_latest, CONTENT_TYPE_LATEST, Counter

app = FastAPI()

# Khởi tạo Metric đếm số lượng HTTP Request
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP Requests', ['method', 'endpoint'])

@app.get("/health")
def health_check():
    return {"status": "Healthy"}

@app.get("/metrics")
def get_metrics():
    # Phơi bày metric cho Prometheus
    return Response(content=generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.get("/products")
def get_products():
    # Tăng biến đếm mỗi khi có người gọi API này
    REQUEST_COUNT.labels(method='GET', endpoint='/products').inc()
    return {
        "data": [
            {"id": "p1", "name": "Deluxe Steering Wheel Toy", "price": 45.00, "stock": 150},
            {"id": "p2", "name": "Ear Cleaner Pro", "price": 12.99, "stock": 300}
        ]
    }