# Agent Library Manifest

This directory contains ALL agents - both universal and specialized - in a flat structure. Each agent filename starts with their name for easy identification.

**Universal agents** (Karen, Paige, Wigsy) are symlinked from here into `~/.claude/agents/` so they're always available. All other agents are opt-in via `/setup-agents`.

## Categories

### Universal (Always Available)
- **karen-manager.md** (Karen) - "Call the manager" - stern feedback when Claude is being lazy or cutting corners
- **paige-technical-docs-writer.md** (Paige) - Technical documentation and guides
- **wigsy-code-reviewer.md** (Wigsy) - Code review, quality analysis, Git/JJ expertise, merge and release management

### Backend
- **shane-go-backend-dev.md** - Go service development with DuckDB/PostgreSQL; cynical and snarky
- **dba-dan-database-expert.md** - Database design, optimization, and query tuning; very friendly and helpful

### Frontend
- **oliver-shadcn-ui-builder.md** - React/Next.js with shadcn/ui components

### Mobile
- **andy-android-kotlin-expert.md** - Native Android development
- **iris-ios-expert-reviewer.md** - Native iOS development

### Infrastructure
- **scott-sysadmin-expert.md** - System administration (Linux/macOS), systemd, Homebrew, chezmoi; cynical but educational
- **lee-network-infrastructure-expert.md** - Network configuration and troubleshooting

### Planning
- **eric-strategic-architect.md** - System architecture design; cynical and intellectually above everyone
- **david-product-requirements-architect.md** - PRD creation and feature planning
- **agent-orchestrator.md** - Agent coordination and routing (no personality yet)

### Data
- **sarah-q-lewis-data-analyst.md** - Database queries and data analysis; SQL expert (S.Q.L.)

### Automation
- **winston-autonomous-executor.md** - Long-running autonomous tasks; reliable and methodical

### Specialized
- **jacob-music-theory-expert.md** (Jacob) - Music theory and composition
- **mark-geo-aeo-strategist.md** (Mark) - AI content optimization (GEO/AEO)
- **proompty-mc-proomptface-prompt-engineer.md** (Proompty Mc Proomptface) - AI prompt engineering and optimization
- **guy-classic-web-dev.md** (Guy) - Classic web development (jQuery, PHP, FTP deployments); legacy code maintenance and educational anti-patterns
