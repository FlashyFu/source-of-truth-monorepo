# CLAUDE.md - AI Assistant Guide for FlashFusion SoT Monorepo

> **Purpose**: This file provides comprehensive guidance for AI assistants (Claude, GPT, Gemini, etc.) working with the FlashFusion Source-of-Truth monorepo. It explains codebase structure, development workflows, key patterns, and conventions to follow.

**Last Updated**: 2025-11-27
**Repository**: FlashFusion Source-of-Truth Monorepo
**Total Projects**: 53 repositories consolidated into one monorepo

---

## Table of Contents

1. [Repository Overview](#repository-overview)
2. [Critical Context](#critical-context)
3. [Directory Structure](#directory-structure)
4. [Technology Stack](#technology-stack)
5. [Development Workflows](#development-workflows)
6. [Key Patterns & Conventions](#key-patterns--conventions)
7. [Testing Strategy](#testing-strategy)
8. [Common Tasks](#common-tasks)
9. [Code Style Guidelines](#code-style-guidelines)
10. [Important Files & Configuration](#important-files--configuration)
11. [Git Workflow](#git-workflow)
12. [Troubleshooting](#troubleshooting)
13. [AI Assistant Guidelines](#ai-assistant-guidelines)

---

## Repository Overview

### What is This?

This is a **pnpm workspace monorepo** consolidating 53 previously separate repositories into a unified codebase. It uses a **SoT (Source-of-Truth) Canonical Model** where all development happens in this repository, and changes are pushed to downstream "mirror" repositories.

### Key Statistics

- **Package Manager**: pnpm 9.0.0 (enforced)
- **Build System**: Turborepo 2.1.0
- **Node Version**: 20+ (required)
- **TypeScript**: 5.4+
- **Total Repositories**: 53 (3 imported, 50 pending)
- **Workspace Pattern**: `agents/*`, `projects/**/*`, `shared/*`

### Repository Status

**Imported (3 repos)**:
- `projects/local/flashfusion-consolidated/` - Main FlashFusion consolidated monorepo
- `projects/local/harvestflow/` - HarvestFlow data pipeline
- `projects/local/int-smart-triage-ai-2.0/` - Smart Triage AI system

**Pending Import (50 repos)**:
- Krosebrook org: 34 repos
- flashfusionv1 org: 8 repos
- ChaosClubCo org: 8 repos

---

## Critical Context

### SoT Canonical Model

**IMPORTANT**: This is the source of truth. All changes must be made here, not in mirror repositories.

```
┌─────────────────────────────────┐
│  Source-of-Truth Monorepo       │  ← All development happens here
│  (this repository)              │
└────────────┬────────────────────┘
             │
             │ git subtree split (automated)
             │
    ┌────────┼────────┐
    ▼        ▼        ▼
 Mirror1  Mirror2  Mirror3  ... (50 mirrors)
```

**Rules**:
- ✅ Make all changes in this SoT repository
- ✅ Push changes to mirrors via automated CI/CD
- ❌ NEVER commit directly to mirror repositories
- ❌ NEVER pull from mirrors back to SoT

### Workspace Dependencies

Projects reference each other using the `workspace:*` protocol:

```json
{
  "dependencies": {
    "@flashfusion/logging": "workspace:*",
    "@flashfusion/contracts": "workspace:*"
  }
}
```

### Build Caching

**Turbo caching** significantly speeds up builds:
- First build: 10-20 minutes
- Cached builds: <1 minute
- Only changed projects + dependencies rebuild

---

## Directory Structure

```
source-of-truth-monorepo/
├── projects/                     # All 53 project repositories
│   ├── local/                    # Local-only repositories (3)
│   │   ├── flashfusion-consolidated/
│   │   │   ├── apps/             # Applications (web, api)
│   │   │   ├── packages/         # Shared packages (ai-core, shared)
│   │   │   └── database/         # Database scripts and migrations
│   │   ├── harvestflow/          # Data pipeline + dashboard
│   │   └── int-smart-triage-ai-2.0/  # Triage AI system
│   ├── krosebrook/               # Krosebrook org (34 repos, pending)
│   │   ├── core/                 # Core FlashFusion projects
│   │   ├── apps/                 # Applications
│   │   └── tools/                # Development tools
│   ├── flashfusionv1/            # FlashFusionv1 org (8 repos, pending)
│   └── chaosclubco/              # ChaosClubCo org (8 repos, pending)
├── agents/                       # AI agent implementations (4)
│   ├── claude-agent/             # Anthropic Claude integration
│   ├── codex-agent/              # OpenAI Codex integration
│   ├── gemini-agent/             # Google Gemini integration
│   └── github-agent/             # GitHub Copilot integration
├── shared/                       # Shared utilities across all projects
│   ├── contracts/                # Agent output schemas (JSON Schema)
│   ├── logging/                  # Structured JSON logging (OTEL)
│   ├── otel/                     # OpenTelemetry observability
│   ├── test-utils/               # Testing utilities
│   └── workflows/                # CI/CD shared utilities
├── scripts/                      # Automation scripts
│   ├── import-github-repos.sh    # Import remaining 50 repos
│   ├── generate-deploy-keys.sh   # Deploy key generation
│   └── validate-setup.sh         # Setup validation
├── docs/                         # Documentation (Diátaxis framework)
│   ├── tutorials/                # Learning-oriented guides
│   ├── how-to/                   # Goal-oriented recipes
│   ├── reference/                # Technical specifications
│   ├── explanation/              # Conceptual understanding
│   ├── adr/                      # Architecture Decision Records
│   └── security/                 # Security audits and guides
├── .github/                      # GitHub Actions workflows
│   └── workflows/
│       ├── ci.yml                # CI pipeline (lint, build, test)
│       ├── security.yml          # Security scanning (gitleaks, audit)
│       └── subtree-push.yml      # Push to mirror repos
├── package.json                  # Root workspace configuration
├── pnpm-workspace.yaml           # Workspace definitions
├── turbo.json                    # Turbo build configuration
├── tsconfig.base.json            # Base TypeScript config
└── .llms.txt                     # LLM discovery index (197 lines)
```

### Key Directories Explained

**`projects/`**: Contains all 53 project repositories. Each project maintains its own `package.json`, dependencies, and configuration.

**`agents/`**: AI agent stubs following a unified contract model. All agents must accept the same CLI flags and output the same JSON schema.

**`shared/`**: Utilities shared across the entire monorepo (logging, contracts, observability, testing).

**`docs/`**: Comprehensive documentation following the [Diátaxis framework](https://diataxis.fr/) (tutorials, how-tos, reference, explanations).

**`scripts/`**: Automation for importing repos, generating keys, and validating setup.

---

## Technology Stack

### Core Technologies

**Package Management**:
- pnpm 9.0.0 (enforced via `packageManager` field)
- Workspace protocol for internal dependencies

**Build System**:
- Turborepo 2.1.0 with intelligent caching
- Parallel task execution
- Remote caching ready

**Languages**:
- TypeScript 5.4+ (primary)
- JavaScript (ES2022 modules)
- Node.js 20+ (required)

### Frontend Stack

**React Ecosystem**:
- React 19.2.0 (latest)
- Next.js 14 (SSR/SSG)
- Vite 7.x (build tool for SPAs)
- Wouter (lightweight routing)
- Zustand (state management)

**UI Libraries**:
- Radix UI (accessible primitives)
- TailwindCSS 4.x (utility-first CSS)
- Lucide React (icons)
- shadcn/ui patterns

### Backend Stack

**Server Frameworks**:
- Express 4.18-5.1 (REST APIs)
- Socket.io 4.8 (WebSockets)
- Node-cron (scheduling)

**API Tools**:
- Swagger UI Express (API docs)
- Express Validator (validation)
- Helmet (security headers)
- CORS middleware

### Database Technologies

**ORMs/Query Builders**:
- Drizzle ORM 0.44.4 with Drizzle Kit 0.31.4
- Drizzle Zod (schema validation)

**Databases**:
- PostgreSQL (via Neon serverless)
- Supabase (BaaS with Postgres)
- Redis 5.6 (caching)

### AI/ML Integrations

**AI SDKs**:
- @anthropic-ai/sdk 0.20.0 (Claude)
- OpenAI 4.0 (GPT/Codex)
- @supabase/supabase-js 2.38-2.39

**AI Tools**:
- Playwright 1.54 (browser automation)
- @mendable/firecrawl-js (web scraping)

### Testing Frameworks

**Test Runners**:
- Node.js built-in test runner (`node --test`) - Primary
- Jest 29.x (legacy, ai-core package)
- c8 (coverage tool)

**Coverage Requirements**:
- Lines: 70% minimum
- Functions: 70% minimum
- Branches: 70% minimum

### DevOps & Infrastructure

**Deployment**:
- Vercel (serverless functions, frontend hosting)
- Docker (compose files present)
- PM2 (process management)

**CI/CD**:
- GitHub Actions (9 workflows)
- Changesets (versioning)
- Husky (git hooks)
- lint-staged (pre-commit)

**Security**:
- Gitleaks (secret scanning)
- Renovate (dependency updates)
- pnpm audit (vulnerability scanning)

### Additional Libraries

**Payment Processing**: Stripe 19.3.1
**Communication**: Twilio 5.8 (SMS/voice)
**Utilities**: Axios, Zod 3.25-4.1, Winston 3.17, Chalk, Inquirer

---

## Development Workflows

### Initial Setup

```bash
# 1. Clone repository
git clone git@github.com:Krosebrook/source-of-truth-monorepo.git
cd source-of-truth-monorepo

# 2. Ensure correct Node version
node --version  # Should be 20+

# 3. Ensure pnpm is installed
npm install -g pnpm@9

# 4. Install all dependencies
pnpm install

# 5. Build all projects
pnpm build

# 6. Run tests
pnpm test

# 7. Validate setup
./scripts/validate-setup.sh
```

### Daily Development

```bash
# Start specific project in dev mode
pnpm --filter @flashfusion/web dev

# Build only changed projects since last commit
pnpm build --filter=...[HEAD^]

# Run linting
pnpm lint

# Run type checking
pnpm type-check

# Format code
pnpm format
```

### Working on a Feature

```bash
# 1. Create feature branch
git checkout -b feature/your-feature-name

# 2. Make changes to relevant projects

# 3. Run local checks
pnpm lint
pnpm type-check
pnpm build
pnpm test

# 4. Commit with conventional commits
git commit -m "feat(scope): add new feature"

# 5. Push to your branch
git push origin feature/your-feature-name

# 6. Create PR (CI runs automatically)
```

### Adding a New Project

```bash
# 1. Create project directory in appropriate location
mkdir -p projects/krosebrook/apps/new-app

# 2. Initialize package.json
cd projects/krosebrook/apps/new-app
pnpm init

# 3. Update package.json with @flashfusion scope
{
  "name": "@flashfusion/new-app",
  "version": "0.1.0",
  "private": true
}

# 4. Add dependencies (use workspace:* for internal deps)
{
  "dependencies": {
    "@flashfusion/logging": "workspace:*"
  }
}

# 5. Install from root
cd /path/to/root
pnpm install

# 6. Add build task to package.json
{
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "test": "node --test"
  }
}

# 7. Test the project
pnpm --filter @flashfusion/new-app build
```

### Publishing Packages

```bash
# 1. Create a changeset
pnpm changeset
# Follow prompts to select packages and describe changes

# 2. Version packages (creates version bump commits)
pnpm changeset version

# 3. Install updated versions
pnpm install

# 4. Commit changeset and version updates
git add .
git commit -m "chore: version packages"

# 5. Publish (when ready)
pnpm release
```

---

## Key Patterns & Conventions

### 1. Structured Logging

All projects should use the shared logging utility:

```typescript
// From /shared/logging/json-logger.ts
import { createLogger } from '@flashfusion/logging';

const logger = createLogger({
  service: 'my-service',
  level: 'info'
});

// Structured JSON output (OTEL compatible)
logger.info('User authenticated', {
  userId: '123',
  traceId: 'abc-def-ghi',
  workflowId: 'auth-flow'
});

// Output:
// {"ts":"2025-11-15T12:00:00.000Z","level":"info","msg":"User authenticated","service":"my-service","userId":"123","traceId":"abc-def-ghi","workflowId":"auth-flow"}
```

**Log Levels**: `debug`, `info`, `warn`, `error`, `fatal`

### 2. Agent Contracts

All AI agents must follow the unified contract:

**CLI Interface**:
```bash
agent-cli \
  --prompt path/to/prompt.txt \
  --context path/to/context.json \
  --output-schema path/to/schema.json \
  --out output/directory
```

**Output Schema**: `/shared/contracts/agent-output.schema.json`

**Example Output**:
```json
{
  "agent": "claude",
  "version": "1.0.0",
  "timestamp": "2025-11-15T12:00:00Z",
  "result": {
    "success": true,
    "data": {...}
  }
}
```

### 3. Package Naming

All packages use the `@flashfusion` scope:

```
@flashfusion/web
@flashfusion/api
@flashfusion/logging
@flashfusion/contracts
@flashfusion/claude-agent
```

### 4. Workspace Dependencies

Always use `workspace:*` for internal dependencies:

```json
{
  "dependencies": {
    "@flashfusion/logging": "workspace:*",
    "@flashfusion/contracts": "workspace:*",
    "external-package": "^1.0.0"
  }
}
```

### 5. TypeScript Configuration

All projects extend the base config:

```json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "dist",
    "rootDir": "src"
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist"]
}
```

### 6. Test Naming & Location

**Test Files**:
- Location: `tests/*.test.js` or `test/*.test.js`
- Smoke tests: `tests/smoke.test.js`
- Unit tests: `tests/unit/*.test.js`
- Integration: `tests/integration/*.test.js`

**Example**:
```javascript
// tests/user-service.test.js
import { describe, it } from 'node:test';
import assert from 'node:assert';
import { getUserById } from '../src/user-service.js';

describe('getUserById', () => {
  it('should return user when valid ID is provided', async () => {
    const user = await getUserById('123');
    assert.strictEqual(typeof user, 'object');
    assert.strictEqual(user.id, '123');
  });

  it('should throw error when ID is missing', async () => {
    await assert.rejects(
      async () => getUserById(null),
      { message: 'User ID is required' }
    );
  });
});
```

### 7. Environment Variables

**Never commit `.env` files**. Always provide `.env.example`:

```bash
# .env.example
DATABASE_URL=postgresql://user:password@localhost:5432/dbname
ANTHROPIC_API_KEY=your_api_key_here
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key
```

### 8. Error Handling

Use consistent error handling patterns:

```typescript
// Good: Typed errors with context
class ValidationError extends Error {
  constructor(message: string, public field: string) {
    super(message);
    this.name = 'ValidationError';
  }
}

async function createUser(data: UserData) {
  if (!data.email) {
    throw new ValidationError('Email is required', 'email');
  }

  try {
    return await db.users.create(data);
  } catch (error) {
    logger.error('Failed to create user', { error, data });
    throw error;
  }
}
```

### 9. API Response Format

Consistent API responses:

```typescript
// Success
{
  "success": true,
  "data": {...},
  "meta": {
    "timestamp": "2025-11-15T12:00:00Z",
    "requestId": "req_123"
  }
}

// Error
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email is required",
    "field": "email"
  },
  "meta": {
    "timestamp": "2025-11-15T12:00:00Z",
    "requestId": "req_123"
  }
}
```

### 10. Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `ci`, `build`

**Examples**:
```
feat(api): add user authentication endpoint
fix(logging): correct JSON output format
docs: update getting started guide
chore(deps): update dependencies
```

---

## Testing Strategy

### Test Framework Distribution

1. **Node.js Native Test Runner** (Primary)
   - Used in: int-smart-triage-ai-2.0, flashfusion-consolidated
   - Command: `node --test tests/*.test.js`
   - Benefits: No dependencies, fast, built-in

2. **Jest** (Legacy/AI Core)
   - Used in: ai-core package
   - Coverage: Configured with c8

### Running Tests

```bash
# Run all tests
pnpm test

# Run tests for specific project
pnpm --filter @flashfusion/web test

# Run with coverage
pnpm --filter @flashfusion/web test --coverage

# Run in watch mode
pnpm --filter @flashfusion/web test --watch
```

### Coverage Thresholds

Enforced via c8 configuration:

```json
{
  "c8": {
    "check-coverage": true,
    "lines": 70,
    "functions": 70,
    "branches": 70,
    "statements": 70,
    "reporter": ["text", "html", "lcov"]
  }
}
```

### Testing Best Practices

1. **Write tests first** (TDD when appropriate)
2. **Test behavior, not implementation**
3. **Use descriptive test names**
4. **Follow AAA pattern**: Arrange, Act, Assert
5. **Mock external dependencies**
6. **Test edge cases and error conditions**
7. **Keep tests independent and isolated**

---

## Common Tasks

### Building

```bash
# Build all projects
pnpm build

# Build only changed projects
pnpm build --filter=...[HEAD^]

# Build specific project
pnpm --filter @flashfusion/web build

# Build with no cache (force rebuild)
pnpm build --force

# Clean build artifacts
pnpm clean
```

### Linting & Formatting

```bash
# Lint all code
pnpm lint

# Lint with auto-fix
pnpm lint --fix

# Format all code
pnpm format

# Check formatting
pnpm format:check

# Lint specific project
pnpm --filter @flashfusion/web lint
```

### Type Checking

```bash
# Type check all projects
pnpm type-check

# Type check specific project
pnpm --filter @flashfusion/web type-check
```

### Security

```bash
# Run security audit
pnpm security:audit

# Check for moderate+ vulnerabilities (fails on findings)
pnpm security:audit:check

# Get JSON audit results
pnpm security:audit:json
```

### Documentation

```bash
# Check documentation status
pnpm docs:status

# Resume documentation work (shows last 30 lines of session log)
pnpm docs:resume

# Lint markdown files
pnpm docs:lint

# Validate documentation
pnpm docs:validate
```

### Development

```bash
# Start all dev servers (resource-intensive!)
pnpm dev

# Start specific project
pnpm --filter @flashfusion/web dev

# Start multiple specific projects
pnpm --filter @flashfusion/web --filter @flashfusion/api dev
```

---

## Code Style Guidelines

### TypeScript/JavaScript

**General Principles**:
- Use TypeScript by default
- Prefer `const` over `let`, avoid `var`
- Use arrow functions for callbacks
- Use async/await over promises
- Use template literals over string concatenation
- Destructure objects and arrays

**Example**:
```typescript
// Good
const getUserData = async (userId: string): Promise<User> => {
  if (!userId) {
    throw new ValidationError('User ID is required', 'userId');
  }

  const user = await db.users.findById(userId);
  if (!user) {
    throw new NotFoundError(`User ${userId} not found`);
  }

  return user;
};

// Bad
async function getUserData(userId) {
  var user = await db.users.find({ id: userId });
  return user;
}
```

### Naming Conventions

**Files**:
- Components: `PascalCase.tsx` (e.g., `UserProfile.tsx`)
- Utilities: `kebab-case.ts` (e.g., `user-service.ts`)
- Tests: `*.test.ts` or `*.test.js`
- Config: `kebab-case.config.ts`

**Variables & Functions**:
- Variables: `camelCase`
- Functions: `camelCase`
- Classes: `PascalCase`
- Constants: `UPPER_SNAKE_CASE`
- Private fields: `_camelCase` or `#camelCase`

**Example**:
```typescript
const MAX_RETRY_ATTEMPTS = 3;

class UserService {
  private _cache: Map<string, User>;

  async getUserById(userId: string): Promise<User> {
    // ...
  }
}

const createUserService = () => new UserService();
```

### Import Order

1. Node.js built-ins
2. External dependencies
3. Workspace dependencies
4. Relative imports

```typescript
// 1. Node.js built-ins
import { readFile } from 'node:fs/promises';
import path from 'node:path';

// 2. External dependencies
import express from 'express';
import { z } from 'zod';

// 3. Workspace dependencies
import { createLogger } from '@flashfusion/logging';
import type { AgentOutput } from '@flashfusion/contracts';

// 4. Relative imports
import { getUserById } from './services/user-service.js';
import type { User } from './types.js';
```

### Comments & Documentation

**JSDoc for public APIs**:
```typescript
/**
 * Retrieves a user by their unique identifier
 * @param userId - The unique user identifier
 * @returns Promise resolving to the user object
 * @throws {ValidationError} If userId is missing
 * @throws {NotFoundError} If user doesn't exist
 */
async function getUserById(userId: string): Promise<User> {
  // Implementation
}
```

**Inline comments for complex logic**:
```typescript
// Calculate exponential backoff: 2^attempt * 1000ms
const delayMs = Math.pow(2, attempt) * 1000;
```

### File Structure

**Standard file structure for services**:
```
src/
├── index.ts              # Public API exports
├── types.ts              # Type definitions
├── config.ts             # Configuration
├── services/             # Business logic
│   ├── user-service.ts
│   └── auth-service.ts
├── utils/                # Utility functions
│   └── validators.ts
├── middleware/           # Express middleware (if applicable)
│   └── auth.ts
└── routes/               # API routes (if applicable)
    └── users.ts
```

---

## Important Files & Configuration

### Root Configuration Files

**`package.json`**:
- Root workspace configuration
- Scripts for building, testing, linting
- DevDependencies for tooling

**`pnpm-workspace.yaml`**:
- Defines workspace packages
- Pattern: `agents/*`, `projects/**/*`, `shared/*`

**`turbo.json`**:
- Build task configuration
- Dependency graph
- Cache settings
- Output directories

**`tsconfig.base.json`**:
- Base TypeScript configuration
- Extended by all projects
- Target: ES2022
- Module: ESNext with bundler resolution

### Linting & Formatting

**`eslint.config.js`**:
- ESLint rules for JavaScript/TypeScript
- Shared across all projects

**`.prettierrc.json`**:
- Prettier formatting rules
- Auto-formats on commit via lint-staged

**`.editorconfig`**:
- Editor settings (indent, line endings, etc.)

### Git & CI/CD

**`.gitignore`**:
- Ignores node_modules, dist, .env, etc.

**`.github/CODEOWNERS`**:
- Defines code ownership for PR reviews

**`commitlint.config.js`**:
- Enforces conventional commits

**`.github/workflows/ci.yml`**:
- CI pipeline: lint, build, test

**`.github/workflows/security.yml`**:
- Security scanning: gitleaks, pnpm audit

**`.github/workflows/subtree-push.yml`**:
- Automated push to mirror repositories

### Security

**`renovate.json`**:
- Automated dependency updates
- Runs Mondays @ 6 AM UTC
- Groups updates by package type

**`.cspell.json`**:
- Spell checking configuration

**`.markdown-link-check.json`**:
- Link validation for markdown

### AI/Documentation

**`.llms.txt`**:
- LLM discovery index (197 lines)
- Provides context for AI assistants

**`docs/mcp.json`**:
- Model Context Protocol configuration

### Environment Examples

**Key `.env.example` files**:
- `/projects/local/flashfusion-consolidated/packages/ai-core/.env.example`
- `/projects/local/flashfusion-consolidated/packages/shared/.env.example`
- `/projects/local/int-smart-triage-ai-2.0/.env.example`

---

## Git Workflow

### Branch Strategy

**Main Branches**:
- `main` - Production-ready code
- `develop` - Development branch (if using GitFlow)

**Feature Branches**:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation
- `refactor/` - Code refactoring
- `test/` - Test additions
- `chore/` - Maintenance

### Commit Process

```bash
# 1. Stage changes
git add .

# 2. Commit with conventional message
git commit -m "feat(api): add user authentication"

# Note: Husky runs pre-commit hooks:
#   - lint-staged (formats code)
#   - commitlint (validates commit message)

# 3. Push to remote
git push origin feature/your-branch
```

### Pull Request Process

1. **Create PR** on GitHub
2. **Fill out PR template**:
   - Description
   - Type of change
   - Related issues
   - Changes made
   - Testing performed
3. **Wait for CI** to pass:
   - Lint
   - Build
   - Test
   - Security scan
4. **Address review comments**
5. **Maintainer merges** (usually squash merge)

### SoT Workflow (Important!)

**Development in SoT**:
```bash
# 1. Make changes in SoT repository
git checkout -b feature/new-feature
# ... make changes ...
git commit -m "feat: add new feature"
git push origin feature/new-feature

# 2. Create PR and merge to main

# 3. CI automatically runs subtree-push.yml
#    which pushes changes to mirror repositories
```

**NEVER do this** in mirror repos:
```bash
# ❌ DO NOT commit directly to mirrors
cd mirror-repo
git commit -m "fix: something"
git push
```

---

## Troubleshooting

### Build Failures

**Problem**: Build fails with "cannot find module"

**Solution**:
```bash
# 1. Clean build artifacts
pnpm clean

# 2. Remove node_modules
rm -rf node_modules

# 3. Reinstall dependencies
pnpm install

# 4. Rebuild
pnpm build
```

**Problem**: Turbo cache issues

**Solution**:
```bash
# Clear Turbo cache
rm -rf .turbo

# Force rebuild (no cache)
pnpm build --force
```

### Import Errors

**Problem**: "Cannot find workspace dependency"

**Solution**:
```bash
# 1. Check pnpm-workspace.yaml includes the project
# 2. Verify package.json uses workspace:* protocol
{
  "dependencies": {
    "@flashfusion/logging": "workspace:*"  // ✅ Correct
  }
}

# 3. Reinstall
pnpm install
```

**Problem**: Circular dependency detected

**Solution**:
- Review dependency graph
- Refactor to remove circular dependency
- Consider extracting shared code to new package

### Type Checking Errors

**Problem**: TypeScript errors in dependent projects

**Solution**:
```bash
# Build dependencies first
pnpm build

# Then type check
pnpm type-check
```

### Test Failures

**Problem**: Tests fail in CI but pass locally

**Solution**:
- Check Node version matches (20+)
- Check environment variables
- Review CI logs for specific errors
- Run tests with same conditions as CI:
  ```bash
  NODE_ENV=test pnpm test
  ```

### Security Audit Failures

**Problem**: `pnpm audit` reports vulnerabilities

**Solution**:
```bash
# 1. Review vulnerabilities
pnpm security:audit

# 2. Update dependencies
pnpm update

# 3. Check Renovate PRs for automated updates

# 4. If unfixable, document and create override
# (Only after security review!)
```

### Git Issues

**Problem**: Merge conflicts in `pnpm-lock.yaml`

**Solution**:
```bash
# 1. Accept either version
git checkout --theirs pnpm-lock.yaml  # or --ours

# 2. Regenerate lockfile
pnpm install

# 3. Commit resolved lockfile
git add pnpm-lock.yaml
git commit -m "chore: resolve lockfile conflicts"
```

---

## AI Assistant Guidelines

### When Working with This Codebase

**DO**:
- ✅ Always check existing documentation first (`/docs/`)
- ✅ Use workspace dependencies (`workspace:*`)
- ✅ Follow conventional commits
- ✅ Write tests for new features
- ✅ Use TypeScript by default
- ✅ Reference the shared logging utility
- ✅ Follow existing patterns in the codebase
- ✅ Check `.llms.txt` for high-level context
- ✅ Make changes in SoT repository only
- ✅ Use pnpm (not npm or yarn)

**DON'T**:
- ❌ Commit directly to mirror repositories
- ❌ Use npm or yarn (use pnpm)
- ❌ Commit .env files
- ❌ Skip tests for new features
- ❌ Use `any` type in TypeScript
- ❌ Create new documentation without checking existing docs
- ❌ Ignore ESLint/Prettier errors
- ❌ Push untested code

### Understanding the Codebase

**To understand structure**:
1. Start with `/README.md`
2. Review `/REPO_MAP.md` for repository index
3. Check `/.llms.txt` for LLM-specific context
4. Read relevant `/docs/` sections

**To understand a specific feature**:
1. Search code with grep/ripgrep
2. Check related tests
3. Review related ADRs in `/docs/adr/`
4. Look for similar implementations

### Making Changes

**Before making changes**:
1. Understand the existing pattern
2. Check if similar code exists elsewhere
3. Review related tests
4. Check documentation for guidelines

**When adding features**:
1. Follow existing patterns
2. Write tests first (or alongside)
3. Update documentation
4. Add JSDoc comments for public APIs
5. Consider backward compatibility

**When fixing bugs**:
1. Write failing test first
2. Fix the bug
3. Verify test passes
4. Check for similar bugs elsewhere
5. Update documentation if needed

### Code Review Checklist

Before submitting PR, verify:

- [ ] Code follows style guidelines
- [ ] Tests added and passing
- [ ] Documentation updated
- [ ] Commit messages follow conventions
- [ ] No hardcoded secrets
- [ ] TypeScript types are specific (no `any`)
- [ ] Error handling implemented
- [ ] Logging added for important events
- [ ] Build succeeds locally
- [ ] Linting passes
- [ ] Security audit passes

### Common Patterns to Follow

**Logging**:
```typescript
import { createLogger } from '@flashfusion/logging';

const logger = createLogger({ service: 'my-service' });
logger.info('Operation completed', { userId, duration });
```

**Error Handling**:
```typescript
try {
  const result = await riskyOperation();
  return result;
} catch (error) {
  logger.error('Operation failed', { error, context });
  throw new ServiceError('Failed to complete operation', { cause: error });
}
```

**Validation**:
```typescript
import { z } from 'zod';

const userSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1)
});

const validatedData = userSchema.parse(input);
```

**API Responses**:
```typescript
return {
  success: true,
  data: user,
  meta: {
    timestamp: new Date().toISOString(),
    requestId: req.id
  }
};
```

### Terminology to Use

**Correct Terms**:
- "SoT" (not "source of truth" or "source-of-truth")
- "mirror" (not "downstream repo" or "fork")
- "workspace" (not "monorepo packages")
- "Turbo" (not "TurboRepo" or "turborepo")
- "Diátaxis" (with accent)
- "pnpm" (lowercase)

### File Paths

Always use absolute paths from repo root:
- ✅ `/projects/local/flashfusion-consolidated/apps/web/src/index.ts`
- ❌ `apps/web/src/index.ts`

---

## Quick Reference

### Essential Commands

```bash
# Setup
pnpm install
pnpm build

# Development
pnpm dev
pnpm --filter <package> dev

# Quality
pnpm lint
pnpm type-check
pnpm test

# Security
pnpm security:audit:check

# Documentation
pnpm docs:status

# Clean
pnpm clean
rm -rf node_modules .turbo
```

### Essential Files

- `/README.md` - Project overview
- `/REPO_MAP.md` - Repository index
- `/CONTRIBUTING.md` - Contribution guidelines
- `/.llms.txt` - LLM context
- `/docs/index.md` - Documentation home
- `/turbo.json` - Build configuration
- `/pnpm-workspace.yaml` - Workspace definition

### Essential Links

- **Issues**: https://github.com/Krosebrook/source-of-truth-monorepo/issues
- **Documentation**: https://flashfusion.co
- **Diátaxis Framework**: https://diataxis.fr/
- **Conventional Commits**: https://www.conventionalcommits.org/
- **pnpm Workspaces**: https://pnpm.io/workspaces

---

## Conclusion

This monorepo is a production-ready, enterprise-scale codebase with:
- **53 repositories** consolidated
- **Comprehensive tooling** (Turbo, pnpm, TypeScript)
- **Automated CI/CD** (GitHub Actions)
- **Security scanning** (gitleaks, audit)
- **Extensive documentation** (Diátaxis framework)
- **AI-friendly** (LLMs.txt, MCP)

When working with this codebase:
1. **Follow patterns** - consistency is key
2. **Test thoroughly** - quality matters
3. **Document changes** - help future developers
4. **Ask questions** - better to clarify than assume

For more information, consult:
- `/README.md` - Quick start
- `/GETTING_STARTED.md` - Detailed onboarding
- `/docs/` - Comprehensive documentation
- `/.llms.txt` - AI assistant context

**Happy coding! 🚀**

---

**Last Updated**: 2025-11-27
**Maintainer**: @Krosebrook
**Version**: 1.0.0
