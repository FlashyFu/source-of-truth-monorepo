# FlashFusion SoT Documentation

> Comprehensive documentation for the Source-of-Truth monorepo following the [Diátaxis](https://diataxis.fr/) framework

**Last Updated**: 2025-11-27
**Framework**: Diátaxis
**Optimization**: LLM-ready (LLMs.txt + MCP)

---

## Welcome

This documentation covers all aspects of the FlashFusion Source-of-Truth monorepo, a unified consolidation of
53 repositories across the FlashFusion ecosystem.

**New here?** Start with [Getting Started](/GETTING_STARTED.md) or the [Quickstart Tutorial](/docs/tutorials/01-quickstart.md).

---

## Documentation Structure

We follow the **[Diátaxis Framework](https://diataxis.fr/)**, organizing docs into four categories based on user needs:

### 📚 [Tutorials](/docs/tutorials/) - Learning

**Purpose**: Step-by-step lessons for beginners
**User Need**: "Teach me how this works"

- [Quickstart (15 min)](/docs/tutorials/01-quickstart.md)
- [Importing Repositories](/docs/tutorials/02-importing-repos.md)
- [Building Your First Agent](/docs/tutorials/03-building-your-first-agent.md)
- [Publishing Packages](/docs/tutorials/04-publishing-packages.md)

### 🔧 [How-To Guides](/docs/how-to/) - Goals

**Purpose**: Practical recipes for specific problems
**User Need**: "Help me solve this task"

- [How to Add a New Repository](/docs/how-to/add-new-repository.md)
- [How to Configure CI/CD](/docs/how-to/configure-ci-cd.md)
- [How to Debug Build Failures](/docs/how-to/debug-build-failures.md)
- [How to Publish with Changesets](/docs/how-to/publish-with-changesets.md)

### 📖 [Reference](/docs/reference/) - Information

**Purpose**: Technical specifications and facts
**User Need**: "Tell me the details"

- [Workspace Structure](/docs/reference/workspace-structure.md)
- [CLI Reference](/docs/reference/cli-reference.md)
- [Subtree Synchronization](/docs/reference/subtree-sync.md)
- [Configuration Reference](/docs/reference/configuration-reference.md)
- [API Documentation](/docs/reference/api/)
- [Repository Map](/REPO_MAP.md)

### 💡 [Explanation](/docs/explanation/) - Understanding

**Purpose**: Conceptual background and rationale
**User Need**: "Explain why this exists"

- [SoT Canonical Model](/docs/explanation/sot-canonical-model.md)
- [Git Subtree Explained](/docs/explanation/git-subtree-explained.md)
- [Monorepo vs Polyrepo](/docs/explanation/monorepo-vs-polyrepo.md)
- [Turbo Caching Internals](/docs/explanation/turbo-caching-internals.md)

---

## Additional Resources

### 📋 [Architecture Decision Records (ADRs)](/docs/adr/)

Documenting significant architectural decisions and their rationale.

- [ADR-0001: SoT Canonical Model](/docs/adr/0001-sot-canonical.md)
- [ADR-0002: pnpm Package Manager](/docs/adr/0002-pnpm-package-manager.md)
- [ADR-0003: Turborepo Build System](/docs/adr/0003-turborepo-build-system.md)

### 📗 [Runbooks](/docs/runbooks/)

Operational procedures for on-call engineers and daily operations.

- [Daily Operations](/docs/runbooks/daily-operations.md)
- [Incident Response](/docs/runbooks/incident-response.md)
- [Disaster Recovery](/docs/runbooks/disaster-recovery.md)

### 📕 [Deep-Dive Guides](/docs/guides/)

Comprehensive guides on specific topics.

- **Agent Integration**: [Claude](/docs/guides/agent-integration/claude-agent.md),
  [Codex](/docs/guides/agent-integration/codex-agent.md), [Gemini](/docs/guides/agent-integration/gemini-agent.md),
  [GitHub](/docs/guides/agent-integration/github-agent.md)
- **Security**: [Secret Management](/docs/guides/security/secret-management.md), [Vulnerability Reporting](/docs/guides/security/vulnerability-reporting.md)
- **Contribution**: [Code Review Guidelines](/docs/guides/contribution/code-review-guidelines.md), [Release Process](/docs/guides/contribution/release-process.md)

---

## Quick Navigation

### For New Contributors

1. [Getting Started](/GETTING_STARTED.md)
2. [Quickstart Tutorial](/docs/tutorials/01-quickstart.md)
3. [Contributing Guidelines](/CONTRIBUTING.md)

### For Developers

1. [Workspace Structure](/docs/reference/workspace-structure.md)
2. [Build System (Turbo)](/docs/explanation/turbo-caching-internals.md)
3. [CLI Reference](/docs/reference/cli-reference.md)

### For Operators

1. [Daily Operations Runbook](/docs/runbooks/daily-operations.md)
2. [Troubleshooting Guide](/docs/how-to/debug-build-failures.md)
3. [Incident Response](/docs/runbooks/incident-response.md)

### For Architects

1. [SoT Canonical Model](/docs/explanation/sot-canonical-model.md)
2. [Architecture Decision Records](/docs/adr/)
3. [System Design](/docs/explanation/)

---

## AI-Optimized Documentation

This documentation is optimized for LLMs and AI assistants:

- **LLMs.txt**: AI discovery index at [`/.llms.txt`](/.llms.txt)
- **MCP Config**: Model Context Protocol at [`/docs/mcp.json`](/docs/mcp.json)
- **Structured**: Consistent terminology, clear headings, short paragraphs
- **Validated**: CI pipeline ensures quality (markdownlint, link checking)

---

## Documentation Meta

- [Style Guide](/docs/STYLE_GUIDE.md) - Writing standards
- [Progress Tracker](/docs/.progress.yaml) - Implementation status
- [Session Log](/docs/SESSION_LOG.md) - Work continuation tracker
- [Roadmap](/docs/meta/documentation-roadmap.md) - Full 6-chunk plan
- [Best Practices](/docs/meta/best-practices.md) - Sources of truth

---

## Contributing to Docs

Documentation is code! Follow these guidelines:

1. **Framework**: Place docs in correct Diátaxis category
2. **Style**: Follow [Style Guide](/docs/STYLE_GUIDE.md)
3. **Review**: Docs reviewed like code (PRs required)
4. **Testing**: Test all code examples before committing
5. **AI-Readable**: Short paragraphs, clear headings, consistent terms

See [CONTRIBUTING.md](/CONTRIBUTING.md) for full guidelines.

---

## Support

**Questions?** Check the [FAQ](/docs/how-to/faq.md) or [open an issue](https://github.com/Krosebrook/source-of-truth-monorepo/issues)

**Found an error?** Submit a PR or report it in [Issues](https://github.com/Krosebrook/source-of-truth-monorepo/issues)

---

_Documentation built with ❤️ following [Diátaxis](https://diataxis.fr/)_
