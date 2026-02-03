# OpenCode Code Review Plugin

A port of Claude Code's `/code-review` plugin for OpenCode.

Performs automated code review on pull requests using multiple specialized subagents with confidence-based scoring to filter false positives.

## Features

- **Multi-agent review**: 4 parallel subagents independently audit changes
- **Confidence scoring**: Issues scored 0-100, threshold at 80 filters false positives
- **CLAUDE.md compliance**: Checks against project coding guidelines
- **Bug detection**: Focused on changes, not pre-existing issues
- **Git history analysis**: Context from blame and history

## Installation (Automatic)

Run the install script to install globally:

```bash
./install.sh
```

This copies agents, commands, and plugins to `~/.config/opencode/`.

## Installation (Manual)

If you prefer to install manually or want per-project installation:

### Option A: Markdown Files (Recommended)

1. **Copy agents** to either:
   - Per-project: `.opencode/agents/`
   - Global: `~/.config/opencode/agents/`

2. **Copy command** (`commands/code-review.md`) to either:
   - Per-project: `.opencode/commands/`
   - Global: `~/.config/opencode/commands/`

3. **(Optional) Copy plugin** (`plugins/code-review.ts`) to either:
   - Per-project: `.opencode/plugins/`
   - Global: `~/.config/opencode/plugins/`
   
   The plugin sends desktop notifications when a code review completes (supports macOS and Linux).

### Option B: JSON Config

Alternatively, merge the contents of `opencode.example.json` into your existing `opencode.json` config file. This defines all agents and the command in a single file.

You'll still need to copy `commands/code-review.md` since the JSON references it via `{file:./commands/code-review.md}`.

> **Note**: Don't use both options together. If you copy the markdown agent files AND merge the JSON config, you'll have duplicate agent definitions.

## Usage

```bash
# In OpenCode TUI, on a PR branch:
/code-review

# Or with arguments:
/code-review --comment
```

## Architecture

### How It Works

When you run `/code-review`, the command template is sent to your primary agent (typically `build`). The primary agent reads the workflow instructions and uses the `Task` tool to invoke each subagent. The `@agent-name` mentions in the command prompt tell the primary agent which subagents to spawn.

Subagents are configured with `hidden: true` so they don't clutter your `@` autocomplete menu, but the primary agent can still invoke them via the Task tool.

### Subagents

| Agent | Model | Purpose |
|-------|-------|---------|
| `cr-gatekeeper` | haiku | Quick check if review needed |
| `cr-guidelines` | haiku | Find relevant CLAUDE.md files |
| `cr-summarizer` | sonnet | Summarize PR changes |
| `cr-compliance` | opus | CLAUDE.md compliance audit |
| `cr-bugs` | opus | Bug detection in changes |
| `cr-history` | opus | Git blame/history analysis |
| `cr-validator` | opus | Validate individual issues |

### Confidence Scoring

- **0**: Not confident, false positive
- **25**: Somewhat confident, might be real
- **50**: Moderately confident, real but minor
- **75**: Highly confident, real and important
- **100**: Absolutely certain, definitely real

Only issues scoring ≥80 are reported.

### False Positives Filtered

- Pre-existing issues not introduced in PR
- Code that looks buggy but isn't
- Pedantic nitpicks
- Issues linters will catch
- General quality issues (unless in CLAUDE.md)

## Configuration

### Models (via OpenRouter)

Default models assume OpenRouter. Adjust in agent files if needed:
- `openrouter/anthropic/claude-haiku-4.5`
- `openrouter/anthropic/claude-sonnet-4.5`
- `openrouter/anthropic/claude-opus-4.5`

### Confidence Threshold

Edit `commands/code-review.md` to change the threshold:
```
Filter out any issues with a score less than 80.
```

## Credits

Based on [Claude Code's code-review plugin](https://github.com/anthropics/claude-code/tree/main/plugins/code-review) by Boris Cherny (Anthropic).

Ported to OpenCode by [Ren](https://github.com/agent-r3n).
