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
   - `wigsy-code-reviewer` (Wigsy) - Code review, quality analysis, Git/JJ expertise, merge and release management
   - `paige-technical-docs-writer` (Paige) - Technical documentation and guides
   - `karen-manager` (Karen) - "Call the manager" - stern feedback when Claude is being lazy or cutting corners

2. **Agent Library** (`~/.claude/agents-library/`) - Activated per-project:
   - Flat structure with names at the beginning of filenames for easy identification
   - See `MANIFEST.md` for categorization and organization
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

All agents are in `~/.claude/agents-library/` with a flat structure. See `MANIFEST.md` for categories.

**Backend:**
- `shane-go-backend-dev` (Shane) - Go service development with DuckDB/PostgreSQL; cynical and snarky
- `dba-dan-database-expert` (DBA Dan) - Database design, optimization, and query tuning; very friendly and helpful

**Frontend:**
- `oliver-shadcn-ui-builder` (Oliver) - React/Next.js with shadcn/ui components

**Mobile:**
- `andy-android-kotlin-expert` (Andy) - Native Android development
- `iris-ios-expert-reviewer` (Iris) - Native iOS development

**Infrastructure:**
- `scott-sysadmin-expert` (Scott) - System administration (Linux/macOS), systemd, Homebrew, chezmoi; cynical but educational
- `lee-network-infrastructure-expert` (Lee) - Network configuration and troubleshooting

**Planning:**
- `david-product-requirements-architect` (David) - PRD creation and feature planning
- `eric-strategic-architect` (Eric) - System architecture design; cynical and intellectually above everyone
- `agent-orchestrator` - Agent coordination and routing

**Data:**
- `sarah-q-lewis-data-analyst` (Sarah Q. Lewis) - Database queries and data analysis; SQL expert

**Automation:**
- `winston-autonomous-executor` (Winston) - Long-running autonomous tasks; reliable and methodical

**Specialized:**
- `jacob-music-theory-expert` (Jacob) - Music theory and composition
- `mark-geo-aeo-strategist` (Mark) - AI content optimization (GEO/AEO)
- `proompty-mc-proomptface-prompt-engineer` (Proompty Mc Proomptface) - AI prompt engineering and optimization

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
