#!/bin/bash
# peon-ping adapter for Windsurf IDE (Cascade hooks)
# Translates Windsurf hook events into peon.sh stdin JSON
#
# Setup: Add to ~/.codeium/windsurf/hooks.json (see README for full hooks.json):
#   {
#     "hooks": {
#       "post_cascade_response": [
#         { "command": "bash ~/.claude/hooks/peon-ping/adapters/windsurf.sh post_cascade_response", "show_output": false }
#       ],
#       "pre_user_prompt": [
#         { "command": "bash ~/.claude/hooks/peon-ping/adapters/windsurf.sh pre_user_prompt", "show_output": false }
#       ]
#     }
#   }

set -euo pipefail

PEON_DIR="${CLAUDE_PEON_DIR:-${CLAUDE_CONFIG_DIR:-$HOME/.claude}/hooks/peon-ping}"

WINDSURF_EVENT="${1:-post_cascade_response}"

# Drain stdin (Windsurf sends JSON context we don't need)
cat > /dev/null

# Map Windsurf hook events to peon.sh PascalCase events
case "$WINDSURF_EVENT" in
  post_cascade_response)
    EVENT="Stop"
    ;;
  pre_user_prompt)
    EVENT="UserPromptSubmit"
    ;;
  post_write_code)
    EVENT="Stop"
    ;;
  post_run_command)
    EVENT="Stop"
    ;;
  *)
    # Unknown event — skip
    exit 0
    ;;
esac

SESSION_ID="windsurf-${PPID:-$$}"
CWD="${PWD}"

echo "{\"hook_event_name\":\"$EVENT\",\"notification_type\":\"\",\"cwd\":\"$CWD\",\"session_id\":\"$SESSION_ID\",\"permission_mode\":\"\"}" \
  | bash "$PEON_DIR/peon.sh"
