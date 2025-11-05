# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) and other AI agents when working in this environment.

## Development Workflow

### Git Operations
- NEVER push to remote repositories automatically
- Always wait for explicit user instruction to push
- Commit locally as work progresses, but only push when user says "push" or "git push"
- Use conventional commit messages that focus on "why" rather than "what"

### Planning Before Execution
- For non-trivial tasks, discuss approach before implementing
- Break complex features into phases
- Identify dependencies and potential issues upfront
- Provide options when multiple valid approaches exist

### Iterative Development
- Deliver working increments frequently
- Test after each significant change
- Gather feedback before proceeding to next phase
- Be prepared to adjust based on feedback

### UI Work Deferral
- UI implementation can be deferred to a different machine with emulators
- Focus on backend logic and APIs first when on server environments
- Provide clear API contracts for frontend integration

## Architecture Preferences

### Technology Stack

**Backend Services:**
- Go with lightweight interfaces
  - Basic Go http server, not heavy frameworks
  - Use external libraries sparingly
- Databases:
  - **DuckDB** for embedded/analytics (NOT SQLite - they are different engines)
    - Use `duckdb` CLI to query DuckDB files, never `sqlite3`
    - DuckDB is single-writer: stop services before running scripts that write
  - **PostgreSQL** for production services requiring multi-user access
    - Use for web services, APIs with concurrent writes
    - Prefer connection pooling for high-traffic services
- systemd for process management on Linux
- LaunchAgent for process management on macOS

**Frontend:**
- Next.js for complex web applications
- shadcn/ui for component library
- TypeScript for type safety

**Mobile:**
- Native Android (Kotlin)
- Native iOS (Swift)

**Terminal UIs:**
- Bubbletea for interactive CLI applications
- Use for tools requiring user interaction, progress displays, forms
- Prefer simple CLI flags/args for non-interactive tools

**AI/LLM Integration:**
- Hybrid approach: Try Ollama (local/free) first, fallback to Claude API
- Queue heavy AI tasks asynchronously (embeddings, vision analysis)
- Cache AI results to reduce costs

### Database Practices

**DuckDB (for embedded/analytics):**
- Single file, portable, fast
- Excellent for analytics and read-heavy workloads
- Remember: single-writer limitation
- Use proper indexes for performance

**PostgreSQL (for production services):**
- Use for multi-user web services and APIs
- Leverage JSONB for semi-structured data
- Use connection pooling (pgbouncer or application-level)
- Consider `pg` utility script for quick connections

**Schema Management:**
- Migrations in code (not external tools)
- Always use `IF NOT EXISTS` / `IF EXISTS` for idempotency
- Document schema in CLAUDE.md with comments
- Include indexes in schema documentation

### Code Organization

**Go Projects:**
- `cmd/` for executable entry points
- `internal/` for private application code
- `pkg/` for reusable library code (rare, prefer internal)
- Keep packages focused and loosely coupled

**Configuration:**
- YAML for structured config
- `.env` for secrets (never commit)
- Environment variables namespaced (e.g., `APPNAME_*`)
- Provide `.example` files for both

### Package Naming Conventions
- Reverse domain notation: `com.rabarts.*` (not `com.alexrabarts.*`)
- Go modules: `github.com/alexrabarts/<project>`
- Consistent naming across LaunchAgents, systemd units, and config directories

## Project Structure Standards

### .agent/ Directory
Every project should maintain an `.agent/` directory for AI agent documentation and knowledge.

**Directory structure:**
- **sop/** - Standard Operating Procedures (issues, learnings, debugging, deployment)
- **system/** - System Documentation (architecture, database, dependencies, API)
- **tasks/** - Project Planning (roadmap, PRD, backlog)

Each `.agent/` directory should include a `README.md` that:
- Explains the directory structure
- Links to existing documentation files
- Describes how to update documentation (e.g., via `/update-doc` command)

**Updating documentation:**
Use the `/update-doc` slash command to add content to .agent/ files:
```
/update-doc I learned that X requires Y
/update-doc Issue: Z is broken when W happens
/update-doc Feature idea: implement ABC
```

See the [dotfiles .agent/README.md](https://github.com/alexrabarts/dotfiles/tree/master/.agent) for a reference implementation.

### Development Commands
Common Makefile targets across projects:
- `make build` - Compile binary
- `make run` - Run locally for testing
- `make test` - Run test suite
- `make deps` - Install/update dependencies
- `make install` - Install to standard location
- `make deploy` - Deploy to production
- `make logs` - View service logs

## Agent Specialization

### Agent Management Philosophy

To minimize context usage, agents are organized into:

1. **Universal Agents** (`~/.claude/agents/`) - Always available:
   - `code-reviewer` - Code review and quality analysis
   - `technical-docs-writer` - Technical documentation and guides

2. **Agent Library** (`~/.claude/agents-library/`) - Activated per-project:
   - Organized by category (backend, frontend, mobile, infrastructure, planning, etc.)
   - Not loaded unless explicitly activated for a project

3. **Project-Specific Agents** (`.claude/agents/`) - Active for current project:
   - Copied from library using `/setup-agents` command
   - Override global agents when present

### Setting Up Project Agents

Use the `/setup-agents` slash command to activate relevant agents:

```bash
# Auto-detect project type and activate appropriate agents
/setup-agents auto

# Interactive mode with questions
/setup-agents

# Manually select specific agents
/setup-agents go-backend-dev database-expert

# List all available agents
/setup-agents list

# Sync project agents with library (update to latest)
/setup-agents sync
```

### Available Specialized Agents

**Backend** (`~/.claude/agents-library/backend/`):
- `go-backend-dev` - Go service development
- `database-expert` - Database design and optimization

**Frontend** (`~/.claude/agents-library/frontend/`):
- `shadcn-ui-builder` - React/Next.js with shadcn/ui components

**Mobile** (`~/.claude/agents-library/mobile/`):
- `android-kotlin-expert` - Android app development
- `ios-expert-reviewer` - iOS app code review

**Infrastructure** (`~/.claude/agents-library/infrastructure/`):
- `network-infrastructure-expert` - Network and infrastructure
- `sysadmin-expert` - System administration and DevOps

**Planning** (`~/.claude/agents-library/planning/`):
- `product-requirements-architect` - PRD creation and feature planning
- `strategic-architect` - System architecture design
- `agent-orchestrator` - Agent coordination and routing

**Data** (`~/.claude/agents-library/data/`):
- `data-analyst` - Database queries and data analysis

**Automation** (`~/.claude/agents-library/automation/`):
- `autonomous-executor` - Long-running autonomous tasks

**Specialized** (`~/.claude/agents-library/specialized/`):
- `music-theory-expert` - Music theory and composition
- `geo-aeo-strategist` - AI content optimization (GEO/AEO)
- `prompt-engineer` - AI prompt engineering and optimization

## Service Management

### Linux (systemd)
```bash
sudo systemctl status <service>     # Check status
sudo systemctl restart <service>    # Restart
sudo journalctl -u <service> -f     # View logs
sudo systemctl enable <service>     # Enable on boot
```

### macOS (LaunchAgent)
```bash
launchctl load ~/Library/LaunchAgents/<plist>      # Start
launchctl unload ~/Library/LaunchAgents/<plist>    # Stop
launchctl list | grep <name>                       # Check status
tail -f ~/.<service>/log/*.log                     # View logs
```

## Development Best Practices

### Error Handling
- Return errors, don't log and ignore
- Wrap errors with context: `fmt.Errorf("operation failed: %w", err)`
- Handle errors at appropriate level
- Provide actionable error messages

### Testing Strategy
- Unit tests for business logic
- Integration tests for external dependencies
- Use fixtures and mocks appropriately
- Test edge cases and error paths

### Code Quality
- Clear, descriptive names over comments
- Comments explain "why" not "what"
- Keep functions focused and small
- Avoid premature optimization

### Security Considerations
- Never commit secrets (use .env files)
- Validate all external input
- Use principle of least privilege
- Keep dependencies updated

### Performance Patterns
- Profile before optimizing
- Cache expensive operations
- Use appropriate data structures
- Consider memory vs. speed tradeoffs

## Communication Style

### When Providing Updates
- Be concise but complete
- Focus on actionable information
- Explain trade-offs when making decisions
- Surface potential issues early

### When Asking Questions
- Be specific about what's unclear
- Provide context for why it matters
- Offer options when appropriate
- Make recommendations based on project patterns

### When Something Goes Wrong
- Describe what happened clearly
- Explain the impact
- Provide debugging steps taken
- Suggest fixes or workarounds

### General Communication Preferences
- Be concise but thorough
- No emojis unless explicitly requested
- Focus on technical accuracy
- Ask clarifying questions when requirements are ambiguous

## Common Pitfalls

### Database
- Remember DuckDB single-writer limitation
- Stop services before running migration scripts
- Use `duckdb` CLI not `sqlite3` for DuckDB files
- Always backup before schema changes

### Service Deployment
- Test locally before deploying
- Check logs after deployment
- Verify health endpoints
- Have rollback plan ready

### Configuration
- Validate config on startup
- Provide clear error messages for missing config
- Document all environment variables
- Use sensible defaults where possible

### Dependencies
- Keep Go modules tidy (`go mod tidy`)
- Review dependency licenses
- Monitor for security advisories
- Minimize external dependencies

## Project-Specific Notes

Each project may have additional guidelines in its own CLAUDE.md file. Always check for project-specific documentation that supersedes or extends these global guidelines.

When in doubt:
1. Check project's CLAUDE.md
2. Look for similar patterns in existing code
3. Ask the user for clarification
4. Prefer simplicity over cleverness
