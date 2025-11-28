# Developer Templates

Production-ready templates and snippets for common development tasks.

## Overview

This directory contains a curated collection of templates for:

- **Infrastructure** - Docker, Kubernetes, Terraform
- **CI/CD** - GitHub Actions workflows
- **Backend** - Express.js, Flask applications
- **Database** - PostgreSQL initialization and migrations
- **DevOps** - Deployment scripts, Nginx configuration
- **Authentication** - JWT, OAuth2 examples
- **Documentation** - Cheatsheets for Git and Regex

## Templates

### Infrastructure

| File | Description |
|------|-------------|
| `Dockerfile` | Multi-stage Node.js Dockerfile with non-root user |
| `docker-compose.yml` | App + PostgreSQL + Adminer stack |
| `k8s-deployment.yaml` | Kubernetes Deployment, Service, and Ingress |
| `terraform-aws-basic.tf` | Basic AWS infrastructure (VPC, EC2) |
| `nginx.conf` | Secure reverse proxy with HTTPS |

### CI/CD

| File | Description |
|------|-------------|
| `github-workflows-ci.yml` | GitHub Actions CI with test, lint, and Docker build |

### Backend

| File | Description |
|------|-------------|
| `express-jwt-api.js` | Express API with JWT auth and rate limiting |
| `flask-blueprint-app.py` | Flask app with blueprints and config |

### Database

| File | Description |
|------|-------------|
| `postgres-init.sql` | PostgreSQL initialization with roles and schema |
| `sql-migration-template.sql` | SQL migration template with up/down sections |

### DevOps

| File | Description |
|------|-------------|
| `deploy.sh` | Robust deployment script with backups |
| `python-venv-setup.sh` | Python virtual environment setup |

### Authentication

| File | Description |
|------|-------------|
| `jwt-auth-examples.md` | JWT best practices and code examples |
| `oauth2-flow.md` | OAuth2 Authorization Code Flow reference |

### Documentation

| File | Description |
|------|-------------|
| `git-cheatsheet.md` | Common Git commands and workflows |
| `regex-cheatsheet.md` | Regex patterns and examples |

### Project Setup

| File | Description |
|------|-------------|
| `package.json.template` | Node.js package.json template |
| `logging-config.yaml` | Python structured logging configuration |
| `pytest-sample.py` | Pytest example with fixtures |

## Usage

Copy the template you need to your project and customize it:

```bash
# Copy Dockerfile to your project
cp shared/templates/Dockerfile ./

# Copy and rename GitHub workflow
cp shared/templates/github-workflows-ci.yml .github/workflows/ci.yml
```

## Customization

Each template includes comments explaining configuration options. Key customization points:

- **Dockerfile**: Update Node.js version, build commands
- **docker-compose.yml**: Change database credentials (use secrets in production!)
- **terraform-aws-basic.tf**: Update region, key names, and security groups
- **k8s-deployment.yaml**: Update image, replicas, and resource limits

## Security Notes

⚠️ **Important**: These templates contain example credentials for demonstration purposes.

- Never commit real passwords or API keys
- Use environment variables or secret managers
- Review security configurations before production use
- Update default values in all templates

## Contributing

When adding new templates:

1. Include clear comments explaining usage
2. Follow security best practices
3. Add the template to this README
4. Test the template works as expected
