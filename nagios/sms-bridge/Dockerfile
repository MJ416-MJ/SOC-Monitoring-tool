FROM python:3.12-slim
RUN pip install flask requests gunicorn
COPY app.py /app/app.py
WORKDIR /app
CMD ["gunicorn", "-b", "0.0.0.0:8088", "app:app"]
