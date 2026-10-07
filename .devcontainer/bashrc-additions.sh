# Save command history immediately
PROMPT_COMMAND="history -a; ${PROMPT_COMMAND}"

# Default AWS profile
export AWS_PROFILE=aaron-admin

# Daily terminal logging (one file per day; flushes every line)
LOG_DIR="/workspaces/aws-platform-terraform/.terminal-logs"
if [ -z "$TERMINAL_LOGGING" ] && [ -t 1 ]; then
  export TERMINAL_LOGGING=1
  mkdir -p "$LOG_DIR"
  exec script -q -f -a "$LOG_DIR/$(date +%F).log"
fi
