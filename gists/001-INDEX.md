# Top 20 Essential Gists — Index and Purpose

> **Purpose**: This collection contains 20 ready-to-use gists for common developer needs. Each entry below is provided as a separate file/gist in this directory.

## List of Included Gists

| # | File | Description |
|---|------|-------------|
| 002 | [Dockerfile-node](002-Dockerfile-node) | Production-ready Node.js Dockerfile with multi-stage build and security notes |
| 003 | [docker-compose.yml](003-docker-compose.yml) | Compose file for app + Postgres + adminer, env examples |
| 004 | [github-actions-ci.yml](004-github-actions-ci.yml) | CI workflow for Node.js + tests + Docker build + semantic-release notes |
| 005 | [express-jwt-api.js](005-express-jwt-api.js) | Minimal Express REST API with JWT auth, rate limiting, validation |
| 006 | [flask-blueprint-app.py](006-flask-blueprint-app.py) | Flask app with blueprint layout, config, and simple migration hooks |
| 007 | [nginx.conf](007-nginx.conf) | Secure reverse-proxy config with HTTP -> HTTPS redirect and headers |
| 008 | [terraform-aws-basic.tf](008-terraform-aws-basic.tf) | Minimal reproducible Terraform for VPC + subnet + EC2 example |
| 009 | [k8s-deployment.yaml](009-k8s-deployment.yaml) | Deployment + Service + Ingress example for stateless apps with liveness/readiness |
| 010 | [postgres-init.sql](010-postgres-init.sql) | Secure DB init script with roles, schemas, migrations guidance |
| 011 | [sql-migration-template.sql](011-sql-migration-template.sql) | Example up/down SQL migration template and instructions |
| 012 | [deploy.sh](012-deploy.sh) | Robust bash deployment script (validate, backup, deploy, rollback) |
| 013 | [git-cheatsheet.md](013-git-cheatsheet.md) | Practical Git commands and tips for daily workflows |
| 014 | [regex-cheatsheet.md](014-regex-cheatsheet.md) | Common regex patterns and examples |
| 015 | [python-venv-setup.sh](015-python-venv-setup.sh) | Reproducible Python venv & pip-tools setup script with per-project notes |
| 016 | [package.json.template](016-package.json.template) | Opinionated package.json template for Node projects |
| 017 | [jwt-auth-examples.md](017-jwt-auth-examples.md) | JWT best practices, token storage, rotation, and code snippets |
| 018 | [oauth2-flow.md](018-oauth2-flow.md) | OAuth2 authorization code flow, PKCE, and integration checklist |
| 019 | [pytest-sample.py](019-pytest-sample.py) | Pytest layout, fixtures, parametrization, and coverage example |
| 020 | [logging-config.yaml](020-logging-config.yaml) | Structured logging example for Python (dictConfig) and tips |

## Usage

1. Copy any file into a new gist at [gist.github.com](https://gist.github.com) or into your repo.
2. Each file includes comments and a quick "how to use" block.

## Notes

- **Security**: Sensitive values should be injected via environment variables or secrets managers.
- **Infrastructure**: For production infra snippets, adapt region/account/IDs accordingly.
- **Customization**: These are starting points — customize for your specific needs.

## Categories

### Infrastructure & DevOps
- Docker: 002, 003
- CI/CD: 004, 012
- Nginx: 007
- Terraform: 008
- Kubernetes: 009

### Database
- PostgreSQL: 010, 011

### Backend
- Node.js/Express: 005
- Flask/Python: 006, 019

### Authentication
- JWT: 005, 017
- OAuth2: 018

### Developer Tools
- Git: 013
- Regex: 014
- Python Environment: 015
- Node.js Setup: 016
- Logging: 020

---

**Last Updated**: 2024-01-15  
**Maintainer**: FlashFusion Team
