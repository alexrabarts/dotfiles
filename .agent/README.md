# Agent Documentation

This directory contains documentation and knowledge for AI agents (like Claude Code) working on this dotfiles repository.

## Directory Structure

### 📋 sop/ - Standard Operating Procedures

Operational knowledge, troubleshooting guides, and known issues.

- **[learnings.md](sop/learnings.md)** - Insights and lessons learned during development
  - What worked and what didn't
  - Debugging techniques
  - Best practices discovered through experience

- **[issues.md](sop/issues.md)** - Known issues and in-progress work
  - Current problems and their status (🚧 IN PROGRESS, 🛑 BLOCKED, ✅ COMPLETED)
  - Workarounds and solutions
  - Items requiring attention

- **[system-files.md](sop/system-files.md)** - System-level configuration documentation
  - Files requiring root/sudo to install
  - Installation procedures for system configs
  - Service management instructions

### 🏗️ system/ - System Documentation

*Currently empty - Reserved for architecture and design documentation*

Intended for:
- `architecture.md` - System design and component relationships
- `database.md` - Schema documentation and query patterns
- `dependencies.md` - External services and libraries
- `api.md` - API contracts and integration points

### 📝 tasks/ - Project Planning

*Currently empty - Reserved for roadmap and backlog*

Intended for:
- `roadmap.md` - Long-term vision and planned features
- `backlog.md` - Prioritized list of pending work
- `prd.md` - Product requirements and feature specs

## Quick Links

### Current Documentation

- [Keyboard Remapping Learnings](sop/learnings.md) - keyd vs userspace tools
- [T2 Keyboard Resume Issue](sop/issues.md) - In-progress suspend/resume fix
- [System Files Documentation](sop/system-files.md) - Root-level config installation

## How to Update This Documentation

Use the `/update-doc` slash command to add new content:

```
/update-doc I learned that chezmoi templates use Go syntax
/update-doc Issue: screen tearing on external monitor
/update-doc Feature idea: automated backup system
```

The command will automatically:
- Determine the appropriate file (learnings.md, issues.md, backlog.md, etc.)
- Format content to match existing structure
- Add proper status emojis and sections

## Documentation Conventions

### For Learnings
- Include "What Didn't Work" and "What Worked" sections
- Add debugging techniques and tools used
- Document key insights and gotchas

### For Issues
- Use status emojis: 🚧 IN PROGRESS, 🛑 BLOCKED, ✅ COMPLETED
- Include sections: Issue, Root Cause, Current Solution, Testing, Next Steps
- Add relevant file paths and cross-references

### For System Files
- Document installation procedures
- Include command examples
- Explain purpose and key settings
- Note any prerequisites

---

*This .agent/ structure is based on the conventions defined in `~/.claude/CLAUDE.md`*
