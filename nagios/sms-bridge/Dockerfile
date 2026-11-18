FROM python:3.12-slim
RUN pip install flask requests gunicorn
COPY app.py /app/app.py
WORKDIR /app
CMD ["gunicorn", "--workers", "2", "--threads", "4", "--timeout", "60", "-b", "0.0.0.0:8088", "app:app"]
