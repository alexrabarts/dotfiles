---
description: Add learnings, issues, SOPs, or feature ideas to .agent/ documentation
---

You are helping the user document knowledge about their dotfiles repository. The user wants to add documentation to the appropriate file in the `.agent/` directory structure.

## Available Documentation Files

- **`.agent/sop/learnings.md`** - Insights and lessons learned during development (completed work, what worked/didn't work, debugging techniques)
- **`.agent/sop/issues.md`** - Known issues, in-progress work, and blocked items that need attention
- **`.agent/sop/system-files.md`** - Documentation about system-level configuration files (files requiring root/sudo to install)
- **`.agent/tasks/roadmap.md`** - Long-term vision, planned features, and major initiatives (create if needed)
- **`.agent/tasks/backlog.md`** - Prioritized list of pending work and feature ideas (create if needed)
- **`.agent/system/architecture.md`** - System design, component relationships, and architectural decisions (create if needed)

## Your Task

1. **Identify the documentation type** from the user's input:
   - Is it a learning/insight from completed work? → learnings.md
   - Is it a current issue or blocked item? → issues.md
   - Is it about system files requiring root? → system-files.md
   - Is it a feature idea or backlog item? → backlog.md
   - Is it a long-term roadmap item? → roadmap.md
   - Is it an architectural decision/design? → architecture.md

2. **Read the target file** to understand its current structure and format

3. **Format the new content** to match the existing style:
   - Use appropriate markdown headings
   - Include relevant sections (Problem, Solution, Status, Related Files, etc.)
   - For issues: Use status emojis (🚧 IN PROGRESS, 🛑 BLOCKED, ✅ COMPLETED)
   - For learnings: Include "What Didn't Work" and "What Worked" sections
   - Add dates if relevant

4. **Append the content** using the Edit tool, inserting it at the appropriate location (end of file or under relevant section)

5. **Confirm the update** by briefly describing what was added and where

## Examples

**User input**: "I learned that systemd user services need --user flag for systemctl commands"

**Your response**: Read learnings.md, then append a new section about systemd user services with this insight, formatted consistently with existing entries.

**User input**: "Add issue: Hyprland screen tearing on external monitor with 144Hz refresh rate"

**Your response**: Read issues.md, then append a new 🚧 IN PROGRESS or 🛑 BLOCKED section about the screen tearing issue with standard structure (Issue, Current Status, Next Steps, Related Files).

**User input**: "Feature idea: Add automatic dotfile sync check on login"

**Your response**: Read or create backlog.md, then append the feature idea in a prioritized list format.

## Important Notes

- Always read the target file first to maintain consistent formatting
- Use markdown section headers (##, ###) appropriately
- Include relevant cross-references to other files when applicable
- Keep the tone technical and concise
- Don't remove or modify existing content unless specifically asked
