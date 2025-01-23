FROM python:3.9-slim

COPY . /api

WORKDIR /api

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 80

ENTRYPOINT ["python3", "api.py"]