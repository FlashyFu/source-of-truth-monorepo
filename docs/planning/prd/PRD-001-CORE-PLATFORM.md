# PRD-001: Core Platform Foundation

**PRD Version:** 1.0.0  
**Created:** 2025-11-27  
**Owner:** Platform Team  
**Status:** Active  
**Phase:** 1 of 5  
**Timeline:** Weeks 1-4

---

## 1. Overview

### 1.1 Purpose

This Product Requirements Document defines the specifications for FlashFusion's Core Platform Foundation - the fundamental infrastructure layer that enables all subsequent features, agents, and business automation capabilities.

### 1.2 Background

FlashFusion's Source-of-Truth monorepo consolidates 53 repositories into a unified development environment. The Core Platform Foundation establishes the architectural patterns, shared packages, security infrastructure, and deployment pipelines required for a production-grade AI business operating system.

### 1.3 Goals

1. **Unified Development Experience:** Single monorepo with consistent tooling and conventions
2. **Production-Ready Infrastructure:** CI/CD, security scanning, and deployment automation
3. **Scalable Architecture:** Patterns that support 100+ microservices and agents
4. **Security First:** Authentication, authorization, and compliance from day one
5. **Developer Productivity:** <30 minute onboarding, <5 minute builds

### 1.4 Non-Goals (Out of Scope for Phase 1)

- Agent implementation (Phase 2)
- Business workflow automation (Phase 3)
- Analytics dashboards (Phase 4)
- Production scaling (Phase 5)

---

## 2. Requirements

### 2.1 Functional Requirements

#### FR-001: Monorepo Structure

**Priority:** P0 (Critical)  
**Status:** ✓ Complete

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-001.1 | pnpm workspace configuration | `pnpm-workspace.yaml` defines all workspace patterns |
| FR-001.2 | Turborepo build system | `turbo.json` with caching and parallel builds |
| FR-001.3 | Workspace organization | `/projects`, `/agents`, `/shared` directory structure |
| FR-001.4 | TypeScript base configuration | `tsconfig.base.json` extended by all packages |
| FR-001.5 | Package naming convention | All packages use `@flashfusion/*` scope |

#### FR-002: Shared Packages

**Priority:** P0 (Critical)  
**Status:** ✓ Complete

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-002.1 | Structured logging package | `@flashfusion/logging` with JSON output, log levels |
| FR-002.2 | Agent contracts package | `@flashfusion/contracts` with JSON Schema validation |
| FR-002.3 | OpenTelemetry package | `@flashfusion/otel` with tracing, metrics, logs |
| FR-002.4 | Test utilities package | `@flashfusion/test-utils` with common testing helpers |
| FR-002.5 | Workflow utilities | `@flashfusion/workflows` for CI/CD shared code |

#### FR-003: Authentication & Authorization

**Priority:** P0 (Critical)  
**Status:** ○ Planned

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-003.1 | Supabase Auth integration | SSO, email/password, magic links supported |
| FR-003.2 | JWT token management | Access/refresh token flow with secure storage |
| FR-003.3 | Role-based access control | Roles: admin, developer, viewer, agent |
| FR-003.4 | API key management | Service-to-service authentication |
| FR-003.5 | Session management | Secure session handling with timeout policies |

#### FR-004: CI/CD Pipeline

**Priority:** P0 (Critical)  
**Status:** ✓ Complete

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-004.1 | Lint workflow | ESLint + Prettier on all PRs |
| FR-004.2 | Build workflow | Turborepo build with caching |
| FR-004.3 | Test workflow | Node.js test runner with coverage |
| FR-004.4 | Security scanning | Gitleaks for secrets, pnpm audit for deps |
| FR-004.5 | Deployment automation | Staging deploy on merge, production on release |

#### FR-005: Development Environment

**Priority:** P1 (High)  
**Status:** ○ Planned

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-005.1 | Docker Compose setup | Single command to start all services |
| FR-005.2 | Environment configuration | `.env.example` files, validated env vars |
| FR-005.3 | Database provisioning | PostgreSQL via Supabase or Docker |
| FR-005.4 | Redis provisioning | Redis for caching and sessions |
| FR-005.5 | Hot reload support | File watch with instant reload |

### 2.2 Non-Functional Requirements

#### NFR-001: Performance

| ID | Requirement | Target | Measurement |
|----|-------------|--------|-------------|
| NFR-001.1 | Build time (full) | <5 minutes | Turborepo build duration |
| NFR-001.2 | Build time (incremental) | <30 seconds | Changed packages only |
| NFR-001.3 | Test execution | <10 minutes | Full test suite duration |
| NFR-001.4 | CI pipeline | <15 minutes | PR check total time |

#### NFR-002: Reliability

| ID | Requirement | Target | Measurement |
|----|-------------|--------|-------------|
| NFR-002.1 | CI pipeline success rate | >99% | GitHub Actions pass rate |
| NFR-002.2 | Build reproducibility | 100% | Identical outputs on same inputs |
| NFR-002.3 | Dependency resolution | 100% | No unresolved workspace deps |

#### NFR-003: Security

| ID | Requirement | Target | Measurement |
|----|-------------|--------|-------------|
| NFR-003.1 | Secret scanning | 0 secrets in commits | Gitleaks findings |
| NFR-003.2 | Dependency vulnerabilities | 0 critical/high | pnpm audit output |
| NFR-003.3 | Auth token expiry | 15 min access, 7 day refresh | Token configuration |
| NFR-003.4 | HTTPS enforcement | 100% | All endpoints TLS |

#### NFR-004: Maintainability

| ID | Requirement | Target | Measurement |
|----|-------------|--------|-------------|
| NFR-004.1 | Code coverage | >70% | c8/nyc coverage report |
| NFR-004.2 | Documentation coverage | 100% public APIs | JSDoc/TypeDoc generation |
| NFR-004.3 | Linting compliance | 0 errors | ESLint report |
| NFR-004.4 | Type safety | 100% TypeScript | No `any` types in new code |

---

## 3. Technical Design

### 3.1 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           MONOREPO STRUCTURE                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐                │
│  │    projects/   │  │    agents/     │  │    shared/     │                │
│  ├────────────────┤  ├────────────────┤  ├────────────────┤                │
│  │ local/         │  │ claude-agent/  │  │ contracts/     │                │
│  │ krosebrook/    │  │ codex-agent/   │  │ logging/       │                │
│  │ flashfusionv1/ │  │ gemini-agent/  │  │ otel/          │                │
│  │ chaosclubco/   │  │ github-agent/  │  │ test-utils/    │                │
│  └────────────────┘  └────────────────┘  └────────────────┘                │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                           BUILD & TOOLING                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │
│  │  Turborepo  │  │    pnpm     │  │  TypeScript │  │   ESLint    │       │
│  │  (Build)    │  │  (Packages) │  │  (Language) │  │  (Linting)  │       │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘       │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                           CI/CD PIPELINE                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │
│  │    Lint     │──│    Build    │──│    Test     │──│   Deploy    │       │
│  │  + Format   │  │  + Cache    │  │  + Coverage │  │  + Release  │       │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘       │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                           SECURITY LAYER                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐       │
│  │  Gitleaks   │  │  pnpm audit │  │  Renovate   │  │  Supabase   │       │
│  │  (Secrets)  │  │  (Deps)     │  │  (Updates)  │  │  Auth       │       │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Package Dependency Graph

```
@flashfusion/contracts
    │
    ├──► @flashfusion/logging
    │        │
    │        └──► @flashfusion/otel
    │
    └──► @flashfusion/test-utils

projects/local/flashfusion-consolidated
    │
    ├──► @flashfusion/logging
    ├──► @flashfusion/contracts
    └──► @flashfusion/otel

agents/*
    │
    ├──► @flashfusion/logging
    └──► @flashfusion/contracts
```

### 3.3 Technology Stack

| Component | Technology | Version | Justification |
|-----------|------------|---------|---------------|
| Package Manager | pnpm | 9.x | Fast, disk-efficient, workspace support |
| Build System | Turborepo | 2.x | Intelligent caching, parallel execution |
| Language | TypeScript | 5.4+ | Type safety, better DX, refactoring |
| Runtime | Node.js | 20+ | LTS, native test runner, ESM support |
| Linting | ESLint | 9.x | Flat config, modern rules |
| Formatting | Prettier | 3.x | Consistent code style |
| Testing | Node.js Test Runner | Native | Zero dependencies, fast |
| Coverage | c8 | 10.x | Native V8 coverage |
| Auth | Supabase Auth | 2.x | Managed, secure, feature-rich |
| CI/CD | GitHub Actions | N/A | Native integration, free tier |

### 3.4 Configuration Files

#### Root `package.json`

```json
{
  "name": "@flashfusion/source-of-truth-monorepo",
  "private": true,
  "packageManager": "pnpm@9.0.0",
  "scripts": {
    "build": "turbo build",
    "dev": "turbo dev",
    "lint": "turbo lint",
    "test": "turbo test",
    "test:coverage": "turbo test:coverage",
    "type-check": "turbo type-check",
    "format": "prettier --write \"**/*.{ts,tsx,js,jsx,json,md}\"",
    "format:check": "prettier --check \"**/*.{ts,tsx,js,jsx,json,md}\"",
    "security:audit": "pnpm audit --audit-level moderate",
    "clean": "turbo clean && rm -rf node_modules"
  },
  "devDependencies": {
    "turbo": "^2.1.0",
    "typescript": "^5.4.0",
    "eslint": "^9.0.0",
    "prettier": "^3.0.0"
  }
}
```

#### `turbo.json`

```json
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": ["**/.env.*local"],
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**"]
    },
    "lint": {},
    "test": {
      "dependsOn": ["build"],
      "outputs": []
    },
    "type-check": {
      "dependsOn": ["^build"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "clean": {
      "cache": false
    }
  }
}
```

---

## 4. User Stories

### 4.1 Developer Stories

#### US-001: New Developer Onboarding

**As a** new developer joining the FlashFusion team  
**I want to** set up my development environment quickly  
**So that** I can start contributing within 30 minutes

**Acceptance Criteria:**
- [ ] Clone repository completes in <2 minutes
- [ ] `pnpm install` completes in <5 minutes
- [ ] `pnpm build` completes in <5 minutes
- [ ] Development server starts with single command
- [ ] GETTING_STARTED.md provides clear instructions

#### US-002: Code Contribution

**As a** developer  
**I want to** make changes and get feedback quickly  
**So that** I can iterate efficiently

**Acceptance Criteria:**
- [ ] Hot reload reflects changes in <1 second
- [ ] `pnpm lint` catches issues before commit
- [ ] CI provides feedback within 15 minutes
- [ ] Type checking catches errors at compile time

#### US-003: Package Development

**As a** developer creating a new shared package  
**I want to** follow established patterns  
**So that** my package integrates seamlessly

**Acceptance Criteria:**
- [ ] Package template available
- [ ] Workspace dependencies resolve automatically
- [ ] Build includes package in dependency graph
- [ ] Tests run as part of CI pipeline

### 4.2 DevOps Stories

#### US-004: CI Pipeline Maintenance

**As a** DevOps engineer  
**I want to** monitor and maintain CI pipelines  
**So that** builds remain fast and reliable

**Acceptance Criteria:**
- [ ] Pipeline duration visible in GitHub Actions
- [ ] Cache hit rates tracked
- [ ] Failure alerts sent to Slack/email
- [ ] Easy rollback for pipeline changes

#### US-005: Security Monitoring

**As a** security engineer  
**I want to** be alerted to security issues  
**So that** I can respond quickly

**Acceptance Criteria:**
- [ ] Gitleaks blocks commits with secrets
- [ ] pnpm audit runs on every PR
- [ ] Renovate creates PRs for security updates
- [ ] Weekly security audit reports generated

---

## 5. API Specifications

### 5.1 Logging API (`@flashfusion/logging`)

```typescript
interface LoggerConfig {
  service: string;
  level?: 'debug' | 'info' | 'warn' | 'error' | 'fatal';
  format?: 'json' | 'pretty';
}

interface Logger {
  debug(message: string, context?: Record<string, unknown>): void;
  info(message: string, context?: Record<string, unknown>): void;
  warn(message: string, context?: Record<string, unknown>): void;
  error(message: string, context?: Record<string, unknown>): void;
  fatal(message: string, context?: Record<string, unknown>): void;
  child(context: Record<string, unknown>): Logger;
}

function createLogger(config: LoggerConfig): Logger;
```

### 5.2 Contracts API (`@flashfusion/contracts`)

```typescript
interface AgentOutput {
  agent: string;
  version: string;
  timestamp: string;
  result: {
    success: boolean;
    data?: unknown;
    error?: {
      code: string;
      message: string;
    };
  };
  metadata?: Record<string, unknown>;
}

function validateAgentOutput(output: unknown): AgentOutput;
function createAgentOutput(params: Partial<AgentOutput>): AgentOutput;
```

### 5.3 OpenTelemetry API (`@flashfusion/otel`)

```typescript
interface OTelConfig {
  serviceName: string;
  serviceVersion: string;
  environment: 'development' | 'staging' | 'production';
  exporterEndpoint?: string;
}

interface Tracer {
  startSpan(name: string, attributes?: Record<string, string>): Span;
  withSpan<T>(name: string, fn: () => T): T;
}

function initializeTracing(config: OTelConfig): Tracer;
function getTracer(): Tracer;
function shutdownTracing(): Promise<void>;
```

---

## 6. Testing Strategy

### 6.1 Test Levels

| Level | Tool | Coverage Target | Location |
|-------|------|-----------------|----------|
| Unit | Node.js Test Runner | 80% | `tests/unit/` |
| Integration | Node.js Test Runner | 70% | `tests/integration/` |
| E2E | Playwright | 50% | `tests/e2e/` |
| Smoke | Node.js Test Runner | 100% critical paths | `tests/smoke.test.js` |

### 6.2 Test Patterns

```typescript
// tests/unit/logger.test.ts
import { describe, it, beforeEach } from 'node:test';
import assert from 'node:assert';
import { createLogger } from '@flashfusion/logging';

describe('createLogger', () => {
  let logger: Logger;

  beforeEach(() => {
    logger = createLogger({ service: 'test-service' });
  });

  it('should create logger with default level info', () => {
    assert.strictEqual(logger.level, 'info');
  });

  it('should output JSON format by default', () => {
    const output = captureOutput(() => logger.info('test message'));
    assert.doesNotThrow(() => JSON.parse(output));
  });

  it('should include service name in output', () => {
    const output = captureOutput(() => logger.info('test'));
    const parsed = JSON.parse(output);
    assert.strictEqual(parsed.service, 'test-service');
  });
});
```

### 6.3 CI Test Configuration

```yaml
# .github/workflows/ci.yml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'
      - run: pnpm install --frozen-lockfile
      - run: pnpm test:coverage
      - uses: codecov/codecov-action@v4
        with:
          files: ./coverage/lcov.info
```

---

## 7. Security Considerations

### 7.1 Authentication Flow

```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│  Client  │────►│  Auth    │────►│ Supabase │────►│  Database│
│          │◄────│  Service │◄────│   Auth   │◄────│          │
└──────────┘     └──────────┘     └──────────┘     └──────────┘
     │                │                │
     │   1. Login     │   2. Verify    │
     │   Request      │   Credentials  │
     │◄───────────────┤                │
     │   3. JWT       │                │
     │   Tokens       │                │
     │                │                │
     │   4. API Call  │                │
     │   + JWT        │                │
     │────────────────►                │
     │   5. Validate  │                │
     │   Token        │                │
     │◄───────────────┤                │
     │   6. Response  │                │
```

### 7.2 Secret Management

| Secret Type | Storage | Rotation | Access |
|-------------|---------|----------|--------|
| API Keys | GitHub Secrets | 90 days | CI only |
| Database Credentials | Supabase Vault | 30 days | Server-side only |
| JWT Signing Keys | Environment Vars | 7 days | Auth service only |
| Deploy Keys | GitHub Deploy Keys | Annual | Repository-specific |

### 7.3 Security Checklist

- [x] Gitleaks pre-commit hook
- [x] pnpm audit in CI
- [x] Renovate for dependency updates
- [ ] HTTPS enforcement
- [ ] Rate limiting
- [ ] Input validation (Zod)
- [ ] CORS configuration
- [ ] Security headers (Helmet)

---

## 8. Deployment Strategy

### 8.1 Environment Configuration

| Environment | Trigger | Infrastructure | URL |
|-------------|---------|----------------|-----|
| Development | Local | Docker Compose | localhost:3000 |
| Preview | PR open | Vercel Preview | pr-{number}.flashfusion.co |
| Staging | Merge to main | Vercel + K8s | staging.flashfusion.co |
| Production | Release tag | K8s Production | app.flashfusion.co |

### 8.2 Deployment Workflow

```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]
  release:
    types: [published]

jobs:
  deploy-staging:
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: pnpm install
      - run: pnpm build
      - run: vercel deploy --prebuilt --token=${{ secrets.VERCEL_TOKEN }}

  deploy-production:
    if: github.event_name == 'release'
    runs-on: ubuntu-latest
    needs: [deploy-staging]
    steps:
      - uses: actions/checkout@v4
      - run: pnpm install
      - run: pnpm build
      - run: vercel deploy --prebuilt --prod --token=${{ secrets.VERCEL_TOKEN }}
```

---

## 9. Monitoring & Observability

### 9.1 Key Metrics

| Metric | Target | Alert Threshold |
|--------|--------|-----------------|
| Build duration | <5 min | >10 min |
| CI pass rate | >99% | <95% |
| Deployment time | <5 min | >15 min |
| Error rate | <0.1% | >1% |

### 9.2 Logging Standards

```json
{
  "ts": "2025-11-27T12:00:00.000Z",
  "level": "info",
  "msg": "Request processed",
  "service": "api-gateway",
  "traceId": "abc-123-def",
  "spanId": "span-456",
  "duration": 42,
  "status": 200
}
```

---

## 10. Rollout Plan

### 10.1 Week 1: Monorepo Setup

- [x] Initialize pnpm workspace
- [x] Configure Turborepo
- [x] Set up shared packages structure
- [x] Create TypeScript configuration
- [x] Implement basic CI workflow

### 10.2 Week 2: Shared Packages

- [x] Implement @flashfusion/logging
- [x] Implement @flashfusion/contracts
- [x] Implement @flashfusion/otel
- [x] Implement @flashfusion/test-utils
- [x] Add comprehensive tests

### 10.3 Week 3: Security & Auth

- [ ] Integrate Supabase Auth
- [ ] Implement RBAC system
- [ ] Configure API key management
- [ ] Set up session handling
- [ ] Security audit

### 10.4 Week 4: Environments

- [ ] Docker Compose development setup
- [ ] Staging environment (Vercel)
- [ ] Production environment (K8s)
- [ ] Monitoring configuration
- [ ] Documentation complete

---

## 11. Success Criteria

### 11.1 Definition of Done

- [ ] All functional requirements implemented
- [ ] Test coverage >70%
- [ ] Zero critical security vulnerabilities
- [ ] Documentation complete
- [ ] Stakeholder sign-off

### 11.2 Acceptance Metrics

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Build time | <5 min | TBD | ○ |
| Test coverage | >70% | TBD | ○ |
| CI pass rate | >99% | TBD | ○ |
| Security issues | 0 critical | TBD | ○ |
| Documentation | 100% | TBD | ○ |

---

## 12. Appendix

### 12.1 Glossary

| Term | Definition |
|------|------------|
| Monorepo | Single repository containing multiple projects |
| Turborepo | Build system for JavaScript/TypeScript monorepos |
| pnpm | Fast, disk-efficient package manager |
| Workspace | Collection of packages in a monorepo |

### 12.2 References

- [Turborepo Documentation](https://turbo.build/repo/docs)
- [pnpm Workspaces](https://pnpm.io/workspaces)
- [Supabase Auth](https://supabase.com/docs/guides/auth)
- [GitHub Actions](https://docs.github.com/actions)

### 12.3 Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | 2025-11-27 | Platform Team | Initial PRD |

---

**Document Owner:** Platform Team  
**Next Review:** 2025-12-11  
**Approval Status:** Pending
