# OpenCode Code Review Plugin

A port of Claude Code's `/code-review` plugin for OpenCode.

Performs automated code review on pull requests using multiple specialized subagents with confidence-based scoring to filter false positives.

## Features

- **Multi-agent review**: 4 parallel subagents independently audit changes
- **Confidence scoring**: Issues scored 0-100, threshold at 80 filters false positives
- **CLAUDE.md compliance**: Checks against project coding guidelines
- **Bug detection**: Focused on changes, not pre-existing issues
- **Git history analysis**: Context from blame and history

## Installation

### 1. Copy agents to your OpenCode config

Copy the `agents/` directory contents to either:
- Per-project: `.opencode/agents/`
- Global: `~/.config/opencode/agents/`

### 2. Copy command to your OpenCode config

Copy `commands/code-review.md` to either:
- Per-project: `.opencode/commands/`
- Global: `~/.config/opencode/commands/`

### 3. (Optional) Install plugin for parallel execution

Copy `plugins/code-review.ts` to either:
- Per-project: `.opencode/plugins/`
- Global: `~/.config/opencode/plugins/`

## Usage

```bash
# In OpenCode TUI, on a PR branch:
/code-review

# Or with arguments:
/code-review --comment
```

## Architecture

### Subagents

| Agent | Model | Purpose |
|-------|-------|---------|
| `cr-gatekeeper` | haiku | Quick check if review needed |
| `cr-guidelines` | haiku | Find relevant CLAUDE.md files |
| `cr-summarizer` | sonnet | Summarize PR changes |
| `cr-compliance` | sonnet | CLAUDE.md compliance audit |
| `cr-bugs` | opus | Bug detection in changes |
| `cr-history` | opus | Git blame/history analysis |
| `cr-validator` | sonnet/opus | Validate individual issues |

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
- `openrouter/anthropic/claude-3-5-haiku-20241022`
- `openrouter/anthropic/claude-sonnet-4-20250514`
- `openrouter/anthropic/claude-opus-4-20250514`

### Confidence Threshold

Edit `commands/code-review.md` to change the threshold:
```
Filter out any issues with a score less than 80.
```

## Credits

Based on [Claude Code's code-review plugin](https://github.com/anthropics/claude-code/tree/main/plugins/code-review) by Boris Cherny (Anthropic).

Ported to OpenCode by [Ren](https://github.com/agent_r3n).
