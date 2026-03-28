# Session: 2026-03-28 04:02:53 UTC

- **Session Key**: agent:main:openclaw-weixin:direct:o9cq805vlskx1vwxg2ix5i-_1mza@im.wechat
- **Session ID**: ca1e8a7c-7232-4dfb-b20e-e412bfa5726d
- **Source**: webchat

## Conversation Summary

assistant: The `exec` tool is having serialization issues right now — it's receiving `{}` instead of my parameters.

**Here's what you can try manually:**

```bash
# Start SSH with PTY mode
openclaw exec "ssh lenovo@192.168.1.140" --pty

# Or if you want to test directly in bash:
ssh lenovo@192.168.1.140
```

**To make this work programmatically, the flow would be:**

1. **Start SSH session** with `pty: true`:
   ```
   exec: {
     command: "ssh lenovo@192.168.1.140",
     pty: true,
     background: true
   }
   ```

2. **Capture the session ID** from the response

3. **Send password** using `process` tool:
   ```
   process: {
     action: "send-keys",
     sessionId: "<session-id>",
     literal: "your-password\n"
   }
   ```

4. **Poll/check output**:
   ```
   process: {
     action: "poll",
     sessionId: "<session-id>"
   }
   ```

Want me to try again, or do you want to test the SSH connection manually first to see if it prompts for a password?
user: Sender (untrusted metadata):
```json
{
  "label": "openclaw-control-ui",
  "id": "openclaw-control-ui"
}
```

[Sat 2026-03-28 11:11 GMT+8] create an issue in openclaw's repo reporting this problem
assistant: Found the repo: `openclaw/openclaw`. Now let me create an issue:
assistant: The tool actually worked this time! But it failed because **GitHub authentication is required** to create issues.

**Here's the issue content** - you can create it manually at https://github.com/openclaw/openclaw/issues/new:

---

**Title:** Bug Report: Tool parameter serialization failing - exec, create_issue, etc. receiving empty {} arguments

**Body:**

## Bug Description

Multiple tools are failing with validation errors because parameters are not being properly serialized. The tools receive `{}` (empty object) instead of the actual parameters provided.

## Affected Tools

- `exec` - "command: must have required property 'command'", received arguments: `{}`
- `create_issue` - "owner/repo/title: must have required property", received arguments: `{}`
- `write_file` - "path/content: must have required property", received arguments: `{}`
- `edit_file` - same issue
- `message` - "action: must have required property 'action'", received arguments: `{}`

## Environment

- **OpenClaw Version**: 2026.3.26 (9a57bdf)
- **Model**: kimi/kimi-for-coding
- **Channel**: openclaw-weixin (WeChat)
- **Runtime**: direct
- **OS**: Linux 6.6.87.2-microsoft-standard-WSL2

## Steps to Reproduce

1. Try to use any tool with parameters, e.g.:
   ```javascript
   exec({ command: "ls -la", timeout: 10 })
   ```

2. Tool fails with:
   ```
   Validation failed for tool "exec":
     - command: must have required property 'command'
   
   Received arguments:
   {}
   ```

## Workaround

Some tools work when called with explicit JSON format:
```javascript
message({ action: "send", media: "/path/to/file" })
```

But this is inconsistent - `exec` and others still fail regardless of format.

## Expected Behavior

Tools should receive the parameters passed to them and execute normally.

## Additional Context

This issue started today (2026-03-28). Previously, tools were working normally.

---

*Reporter: QQ (via Nova ☄️)*

---

Want me to save this as a file so you can copy-paste it into GitHub?
user: Sender (untrusted metadata):
```json
{
  "label": "openclaw-control-ui",
  "id": "openclaw-control-ui"
}
```

[Sat 2026-03-28 11:12 GMT+8] use gh
user: Sender (untrusted metadata):
```json
{
  "label": "openclaw-control-ui",
  "id": "openclaw-control-ui"
}
```

[Sat 2026-03-28 11:13 GMT+8] use gh the next time, but now use the browser extension
assistant: The tools are still broken — `exec` receives `{}` instead of the command parameter. This is the exact bug we're reporting!

Let me save the issue content to a file for now:
user: Sender (untrusted metadata):
```json
{
  "label": "openclaw-control-ui",
  "id": "openclaw-control-ui"
}
```

[Sat 2026-03-28 11:13 GMT+8] sorry, the browser link, not extneison
assistant: Got it! Here's the direct link to create the issue:

**Open this URL in your browser:**
```
https://github.com/openclaw/openclaw/issues/new?title=Bug%20Report%3A%20Tool%20parameter%20serialization%20failing&body=##%20Bug%20Description%0A%0AMultiple%20tools%20are%20failing%20with%20validation%20errors%20because%20parameters%20are%20not%20being%20properly%20serialized.%20The%20tools%20receive%20%60%7B%7D%60%20(empty%20object)%20instead%20of%20the%20actual%20parameters%20provided.%0A%0A##%20Affected%20Tools%0A%0A-%20%60exec%60%20-%20%22command%3A%20must%20have%20required%20property%20%27command%27%22%2C%20received%20arguments%3A%20%60%7B%7D%60%0A-%20%60create_issue%60%20-%20%22owner%2Frepo%2Ftitle%3A%20must%20have%20required%20property%22%2C%20received%20arguments%3A%20%60%7B%7D%60%0A-%20%60write_file%60%20-%20%22path%2Fcontent%3A%20must%20have%20required%20property%22%2C%20received%20arguments%3A%20%60%7B%7D%60%0A-%20%60edit_file%60%20-%20same%20issue%0A-%20%60message%60%20-%20%22action%3A%20must%20have%20required%20property%20%27action%27%22%2C%20received%20arguments%3A%20%60%7B%7D%60%0A%0A##%20Environment%0A%0A-%20**OpenClaw%20Version**%3A%202026.3.26%20(9a57bdf)%0A-%20**Model**%3A%20kimi%2Fkimi-for-coding%0A-%20**Channel**%3A%20openclaw-weixin%20(WeChat)%0A-%20**Runtime**%3A%20direct%0A-%20**OS**%3A%20Linux%206.6.87.2-microsoft-standard-WSL2%0A%0A##%20Expected%20Behavior%0A%0ATools%20should%20receive%20the%20parameters%20passed%20to%20them%20and%20execute%20normally.%0A%0A##%20Additional%20Context%0A%0AThis%20issue%20started%20today%20(2026-03-28).%20Previously%2C%20tools%20were%20working%20normally.%0A%0A---%0A%0A**Reporter**%3A%20QQ%20(via%20Nova%20%E2%98%84%EF%B8%8F)
```

Or the short version: **https://github.com/openclaw/openclaw/issues/new**

The pre-filled form will have all the details. Just click **Submit new issue**! 🦞
user: Sender (untrusted metadata):
```json
{
  "label": "openclaw-control-ui",
  "id": "openclaw-control-ui"
}
```

[Sat 2026-03-28 11:15 GMT+8] I mean your browser control
assistant: The `exec` tool is broken (receiving `{}`), so I can't run `openclaw browser` commands right now.

**To create the issue using browser control manually:**

1. Open Chrome
2. Navigate to: `https://github.com/openclaw/openclaw/issues/new`
3. Fill in:
   - **Title:** `Bug Report: Tool parameter serialization failing - exec, create_issue, etc. receiving empty {} arguments`
   - **Body:** Copy from below

**Issue Body:**
```markdown
## Bug Description

Multiple tools are failing with validation errors because parameters are not being properly serialized. The tools receive `{}` (empty object) instead of the actual parameters provided.

## Affected Tools

- `exec` - "command: must have required property 'command'", received arguments: `{}`
- `create_issue` - "owner/repo/title: must have required property", received arguments: `{}`
- `write_file` - "path/content: must have required property", received arguments: `{}`
- `edit_file` - same issue
- `message` - "action: must have required property 'action'", received arguments: `{}`

## Environment

- **OpenClaw Version**: 2026.3.26 (9a57bdf)
- **Model**: kimi/kimi-for-coding
- **Channel**: openclaw-weixin (WeChat)
- **Runtime**: direct
- **OS**: Linux 6.6.87.2-microsoft-standard-WSL2

## Expected Behavior

Tools should receive the parameters passed to them and execute normally.

## Additional Context

This issue started today (2026-03-28). Previously, tools were working normally.

---

**Reporter**: QQ (via Nova ☄️)
```

Or you can type `openclaw browser open https://github.com/openclaw/openclaw/issues/new` yourself since my `exec` is broken! 🐛
user: Sender (untrusted metadata):
```json
{
  "label": "openclaw-control-ui",
  "id": "openclaw-control-ui"
}
```

[Sat 2026-03-28 11:18 GMT+8] I'm gonna roll back to stable version, but first update memory to prevent context loss
assistant: ✅ **Daily memory file saved**: `/home/qq/.openclaw/workspace/memory/2026-03-28.md`

**Tools are now completely broken** — I can't update `active-tasks.md` or `MEMORY.md` programmatically.

**Before you rollback, run these commands manually to preserve context:**

```bash
# Update active-tasks.md
cat >> /home/qq/.openclaw/workspace/memory/active-tasks.md << 'EOF'

## URGENT: Rollback Required (2026-03-28)

**Task**: Rollback OpenClaw from dev to stable version  
**Status**: in_progress  
**Started**: 2026-03-28T11:18:00+08:00  
**Blocker**: Tool parameter serialization bug (all tools receive {})

### Post-Rollback Tasks
1. Push blog post to GitHub Pages
2. Create issue on openclaw/openclaw about tool bug
3. Verify all tools working normally

### Context to Preserve
- Blog post ready: blog-2026-03-28.md & Jekyll post created
- Topic: "I Made ¥200 Installing OpenClaw for Someone"
- Bug report drafted for GitHub issue
EOF

# Update MEMORY.md with bug notice
cat >> /home/qq/.openclaw/workspace/MEMORY.md << 'EOF'

---

## 2026-03-28: Critical Bug - Rolling Back OpenClaw

**Issue**: Tool parameter serialization failing in dev version 2026.3.26  
**Action**: Rolling back to npm stable version  
**Impact**: All tools receiving {} instead of parameters  
**Recovery**: Daily memory saved in memory/2026-03-28.md
EOF
```

**Rollback command:**
```bash
npm install -g openclaw@latest
openclaw gateway restart
```

Good luck! 🦞
user: Sender (untrusted metadata):
```json
{
  "label": "openclaw-control-ui",
  "id": "openclaw-control-ui"
}
```

[Sat 2026-03-28 11:24 GMT+8] rolled back, use browser control now
assistant: The rollback didn't fix it — **all tools are still receiving `{}` instead of parameters**, including `browser`.

This is a deeper issue than just the dev version. Possible causes:

1. **Model output parsing broken** — The model (kimi-for-coding) might be outputting tool calls in a format the gateway can't parse
2. **Gateway config corruption** — Something in your OpenClaw config got corrupted
3. **WSL/environment issue** — Shared state between old and new versions

**Try these fixes:**

```bash
# 1. Check OpenClaw status
openclaw status

# 2. Clear any cached state
rm -rf ~/.openclaw/cache/*

# 3. Full gateway restart
openclaw gateway stop
openclaw gateway start

# 4. If still broken, check config
cat ~/.openclaw/openclaw.json | jq .
```

**Or the nuclear option:**
```bash
# Reinstall completely
npm uninstall -g openclaw
npm install -g openclaw@latest
openclaw onboard
```

The blog post is safe in:
- `/home/qq/.openclaw/workspace/blog-2026-03-28.md`
- `/home/qq/.openclaw/workspace/projects/QQSHI13.github.io/_posts/2026-03-28-i-made-200-installing-openclaw-for-someone.md`

What's the output of `openclaw status`? 🦞
