

[![GitHub](https://img.shields.io/badge/GitHub-Repository-blue?logo=github)](https://github.com/BaharakQaderi/docker-continuous-integration-webapp-python)
[![Docker](https://img.shields.io/badge/Docker-Containerized-blue?logo=docker)](https://github.com/BaharakQaderi/docker-continuous-integration-webapp-python)
[![Flask](https://img.shields.io/badge/Flask-Backend-lightgrey?logo=flask)](https://github.com/BaharakQaderi/docker-continuous-integration-webapp-python)
[![Redis](https://img.shields.io/badge/Redis-Database-red?logo=redis)](https://github.com/BaharakQaderi/docker-continuous-integration-webapp-python)
[![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI-blue?logo=githubactions)](https://github.com/BaharakQaderi/docker-continuous-integration-webapp-python/actions)

# Build Robust Continuous Integration With Docker (Educational Resource)

## About This Resource

This repository is an educational resource designed to help you understand and implement the following DevOps and cloud-native concepts:

- Run a Redis server locally in a Docker container
- Dockerize a Python web application written in Flask
- Build Docker images and push them to the Docker Hub registry
- Orchestrate multi-container applications with Docker Compose
- Replicate a production-like infrastructure anywhere
- Define a continuous integration workflow using GitHub Actions

### Application Architecture

You’ll build a Flask web application for tracking page views, with data stored persistently in a Redis data store. The application is a multi-container setup orchestrated by Docker Compose, allowing you to build and test locally or in the cloud, paving the way for continuous integration.

**Architecture Overview:**



```
Browser (outside Docker)
    │
    │ 1. GET http://localhost
    | 7. This page has been seen 10 times!
    ▼
┌─────────────────────────────────────────────────────────────┐
│                        docker-compose                       │
│                                                             │
│   ┌─────────────┐           ┌───────────────┐               │
│   │ web-service │           │ redis-service │               │
│   │ ┌─────────┐ │           │               │               │
│   │ │Gunicorn | |           │               │               |
│   │ └─────────┘ │           │               │               │
│   │     │ ▲     │           │               │               │
│   │ 2.  │ │ 6.  │           │               │               │
│   │     ▼ │     │           │               │               │
│   │ ┌─────────┐ │     3&5   │ ┌───────────┐ │               │
│   │ │ Flask   │ ◄────────────►│    Redis  │ |               | 
│   │ └─────────┘ |           | └───────────┘ |               │
│   └─────┬───────┘           └───────┬───────┘               │
│                                     │ 4.                    │
│                                     ▼                       │
│                            ┌──────────────┐                 │
│                            │  /redis-data │ (persistent)    │
│                            └──────────────┘                 │
└─────────────────────────────────────────────────────────────┘
```
Flow:
1. Browser sends GET request to Gunicorn (web-service)
2. Gunicorn forwards request to Flask
3. Flask sends INCR page_views to Redis (redis-service)
4. Redis persists data to /redis-data
5. Redis  returns the new count to Flask
6. Flask returns the count to Gunicorn, which responds to the browser with the page view count

Request flow:
- The browser sends a GET request to http://localhost
- Gunicorn (web-service) serves the Flask app, which increments page_views in Redis (redis-service)
- Redis stores the count persistently in /redis-data

The application consists of two Docker containers:

- **Flask App Container:** Runs a Flask application on top of Gunicorn, responding to HTTP requests and updating the number of page views.
- **Redis Container:** Runs a Redis instance for storing page view data persistently in a local volume on the host machine.

---

## Running

To start the application in the background, run the following command:

```shell
$ docker compose up -d
```

Then, navigate your web browser to <http://localhost>, and keep refreshing the page to update the number of page views.

## Testing

You can run the end-to-end tests by enabling another service using a special profile and then browse the logs:

```shell
$ docker compose --profile testing up -d
$ docker compose logs test-service
```

## Development & Debugging

### Local Development Setup

This project supports both traditional `venv` and modern `uv` package managers:

- **Docker containers** use Python's built-in `venv`
- **Local development** can use `uv` for faster dependency management

To set up local development:

```shell
# Using uv (recommended for speed)
$ uv venv
$ source .venv/bin/activate
$ uv pip install -e ".[dev]"

# Or using traditional venv
$ python -m venv .venv
$ source .venv/bin/activate
$ pip install -e ".[dev]"
```

### Debugging Docker Build Failures

When `docker compose --profile testing up -d` fails, use the provided debug scripts:

```shell
# Quick check - runs exact Docker command chain
$ ./web/debug_docker_checks.sh

# Detailed check - shows which specific step fails
$ ./web/debug_checks.sh
```

The Docker build runs these quality checks:
- **pytest** - Unit tests
- **flake8** - Code style linting
- **isort** - Import sorting
- **black** - Code formatting
- **pylint** - Code quality analysis
- **bandit** - Security vulnerability scanning

### Fixing Common Issues

**Black formatting errors:**
```shell
$ source .venv/bin/activate
$ python -m black src/
```

**Import sorting errors:**
```shell
$ python -m isort src/
```

**Code style issues:**
```shell
$ python -m flake8 src/
```
