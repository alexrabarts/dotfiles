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
- `go-backend-dev` - Go service development with DuckDB/PostgreSQL
- `database-expert` - Database design, optimization, and query tuning

**Frontend** (`~/.claude/agents-library/frontend/`):
- `shadcn-ui-builder` - React/Next.js with shadcn/ui components

**Mobile** (`~/.claude/agents-library/mobile/`):
- `android-kotlin-expert` - Native Android development
- `ios-expert-reviewer` - Native iOS development

**Infrastructure** (`~/.claude/agents-library/infrastructure/`):
- `network-infrastructure-expert` - Network configuration and troubleshooting
- `sysadmin-expert` - System administration (Linux/macOS), systemd, Homebrew, chezmoi

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

## Development Best Practices

### Code Quality
- Clear, descriptive names over comments
- Comments explain "why" not "what"
- Keep functions focused and small
- Avoid premature optimization

### Testing Strategy
- Unit tests for business logic
- Integration tests for external dependencies
- Use fixtures and mocks appropriately
- Test edge cases and error paths

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

### Configuration
- Validate config on startup
- Provide clear error messages for missing config
- Document all environment variables
- Use sensible defaults where possible

### Dependencies
- Review dependency licenses
- Monitor for security advisories
- Minimize external dependencies
- Keep dependencies updated

### Deployment
- Test locally before deploying
- Check logs after deployment
- Verify health endpoints
- Have rollback plan ready

## Project-Specific Notes

Each project may have additional guidelines in its own CLAUDE.md file. Always check for project-specific documentation that supersedes or extends these global guidelines.

**Technology-specific guidance lives in specialized agents:**
- Go project structure and patterns → `go-backend-dev` agent
- Database design and queries → `database-expert` agent
- React/Next.js UI development → `shadcn-ui-builder` agent
- System administration → `sysadmin-expert` agent
- Mobile development → `android-kotlin-expert` or `ios-expert-reviewer` agents

When in doubt:
1. Check project's CLAUDE.md
2. Use `/setup-agents` to activate appropriate specialized agents
3. Look for similar patterns in existing code
4. Ask the user for clarification
5. Prefer simplicity over cleverness
