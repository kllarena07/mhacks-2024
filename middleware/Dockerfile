FROM python:3.9-slim

WORKDIR /app

COPY . /app

RUN apt-get update && apt-get install -y \
  build-essential \
  libffi-dev \
  libssl-dev \
  python3-dev \
  && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

ENV FLASK_APP=server.py
ENV FLASK_RUN_HOST=0.0.0.0

CMD ["flask", "run"]
