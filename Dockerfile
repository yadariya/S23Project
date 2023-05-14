FROM node:20 as frontend-build

WORKDIR /app
COPY ./smart-access-frontend/package.json ./smart-access-frontend/package-lock.json ./

RUN npm install

COPY ./smart-access-frontend/ ./

RUN npm run build

FROM python:3.11

ENV PYTHONFAULTHANDLER=1 \
  PYTHONUNBUFFERED=1 \
  PYTHONHASHSEED=random \
  PIP_NO_CACHE_DIR=off \
  PIP_DISABLE_PIP_VERSION_CHECK=on \
  PIP_DEFAULT_TIMEOUT=100

RUN pip install --upgrade pip setuptools wheel
RUN pip install poetry

RUN apt-get update && apt-get install -y swig zbar-tools

RUN pip install m2crypto==0.38.0 --no-use-pep517

WORKDIR /app
COPY ./SmartAccess/poetry.lock ./SmartAccess/pyproject.toml ./

RUN poetry config virtualenvs.create false \
  && poetry install --no-interaction --no-ansi

COPY ./SmartAccess/ ./
COPY --from=frontend-build /app/dist ./static/

CMD [ "poetry", "run", "run" ]