# Code Analysis Methodology

When analyzing code, use structured parsing instead of grep hunting.

## 1. Read the Full File First

```
read file_path:/path/to/file
```

Start with the complete context. Don't grep blindly.

## 2. Use Offset/Limit for Large Files

```
read file_path:/path/to/file limit:100 offset:1      # First 100 lines
read file_path:/path/to/file limit:50 offset:200     # Lines 200-250
```

## 3. Identify Entry Points

For HTML/JS apps, find:

- Event listeners (`addEventListener`, `onclick`)
- DOM element IDs
- Function definitions
- State initialization

## 4. Trace Execution Flow

Follow the call chain:

1. User action (click, submit)
2. Event handler
3. Core function
4. State update / API call
5. UI update

## 5. Document Findings

When you find bugs or patterns, document them:

- **Location**: file + line number
- **Issue**: what's wrong
- **Fix**: what changed
- **Why**: root cause

## Code Parsing Checklist

| Step | Action                          | Tool         |
| ---- | ------------------------------- | ------------ |
| 1    | Read file(s) completely         | `read`       |
| 2    | Identify key functions/handlers | Visual scan  |
| 3    | Trace execution flow            | Mental model |
| 4    | Locate the bug                  | Line numbers |
| 5    | Fix with precise edit           | `edit`       |
| 6    | Verify the fix                  | Re-read      |

## Anti-Patterns to Avoid

- ❌ `grep -n "keyword"` without context
- ❌ Editing without reading surrounding code
- ❌ Assuming variable names match functionality
- ❌ Fixing symptoms instead of root causes

## Sub-Agent Code Analysis

When spawning sub-agents for code tasks, give them:

```
Task: Analyze and fix bugs in [project]

Process:
1. Read the main entry file (index.html, main.js, etc.)
2. Map out the component/module structure
3. Identify all event handlers and their callbacks
4. Look for console errors, broken state, or missing cleanup
5. Fix issues at the root cause, not symptoms
6. Verify fixes don't break other functionality

Report: What you found, what you fixed, and why.
```
