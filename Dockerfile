FROM python:3.11

MAINTAINER Marie Salm "marie.salm@iaas.uni-stuttgart.de"

WORKDIR /app
RUN apt-get update
RUN apt-get install -y gcc python3-dev curl
RUN pip install poetry gunicorn

COPY ./pyproject.toml /app/pyproject.toml
COPY ./poetry.lock /app/poetry.lock
RUN python -m poetry export --without-hashes --format=requirements.txt -o requirements.txt && python -m pip install -r requirements.txt

COPY . /app

EXPOSE 5013/tcp

ENV FLASK_APP=qiskit-service.py
ENV FLASK_ENV=development
ENV FLASK_DEBUG=0
RUN echo "python -m flask db upgrade" > /app/startup.sh
RUN echo "gunicorn qiskit-service:app -b 0.0.0.0:5013 -w 4 --timeout 500 --log-level info" >> /app/startup.sh
CMD [ "sh", "/app/startup.sh" ]
