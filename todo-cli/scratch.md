#!/bin/sh
# timer – CLI time tracker for nana‑devops
# REQ‑006: records start/stop events, computes elapsed time, implements `timer status`.

set -e

PROGNAME=$(basename "$0")
SESSIONS_DIR="$HOME/nana-devops/todo-cli/clis/timer/data"
SESSIONS_FILE="$SESSIONS_DIR/sessions.txt"
LOCK_FILE="$SESSIONS_DIR/.timer.lock"

# Ensure directories and files exist
ensure_dirs() {
        mkdir -p "$SESSIONS_DIR"
        > "$SESSIONS_FILE"
}

log_event() {  # $1: type, $2: session label, $3: timestamp
        echo "$1|$2|$3" >> "$SESSIONS_FILE"
}

# Get current session ID (label) from lock file
current_session() {
        if [ -f "$LOCK_FILE" ]; then
                cat "$LOCK_FILE"
        else
                echo ""
        fi
}

# Start a new session
cmd_start() {
        if [ -z "$2" ]; then
                echo "Usage: $PROGNAME start <task>" >&2
                return 1
        fi

        session="$2"
        now=$(date +%s)

        # If there is already an active session, fail
        current=$(current_session)
        if [ -n "$current" ]; then
                echo "Active session already running: $current (stop it first)" >&2
                return 1
        fi

        echo "$session" > "$LOCK_FILE"

        log_event "start" "$session" "$now"
        echo "Timer started: $session"
}

# Stop current session
cmd_stop() {
        current=$(current_session)
        if [ -z "$current" ]; then
                echo "No active session to stop." >&2
                return 1
        fi

        now=$(date +%s)
        log_event "stop" "$current" "$now"
        rm -f "$LOCK_FILE"

        echo "Timer finished: $current"
}

# Current time (in seconds since epoch)
now_s() {
        date +%s
}

# Convert seconds to human‑readable hh:mm:ss
seconds_to_hms() {
        sec="$1"
        h=$(($sec / 3600))
        m=$((($sec % 3600) / 60))
        s=$(($sec % 60))

        printf "%02d:%02d:%02d" "$h" "$m" "$s"
}

# Compute elapsed time between two timestamps
compute_elapsed_s() {
        start="$1"
        end="$2"
        echo $(($end - $start))
}

# Parse sessions and assemble records
parse_sessions() {
        active=""
        current=$(current_session)

        # Print header: state | label | start | end | elapsed
        while IFS='|' read -r event label timestamp; do
                case "$event" in
                start)
                        if [ "$current" = "$label" ]; then
                                # If this label is current, mark it active
                                active="$label"
                        fi
                        # Store start time for this label
                        eval "start_${label}=$timestamp"
                        ;;
                stop)
                        # If this label has a start time, compute elapsed
                        start_var=start_${label}
                        start_val=$(eval echo $${start_var})
                        if [ -n "$start_val" ]; then
                                elapsed=$(compute_elapsed_s "$start_val" "$timestamp")
                                # Emit line: "stopped|label|start|stop|elapsed"
                                echo "stopped|$label|$start_val|$timestamp|$elapsed"
                        fi
                        ;;
                esac
        done < "$SESSIONS_FILE"

        # If there is an active session, emit an active record
        if [ -n "$active" ]; then
                active_start=$(eval echo $start_${active})
                if [ -n "$active_start" ]; then
                        now=$(now_s)
                        elapsed=$(compute_elapsed_s "$active_start" "$now")
                        echo "active|$active|$active_start|$(now_s)|$elapsed"
                fi
        fi
}

# status subcommand
cmd_status() {
        echo "--- timer status ---"

        # If no sessions file, create it
        if [ ! -s "$SESSIONS_FILE" ]; then
                echo "No sessions recorded."
                return
        fi

        # Parse all sessions and print active + completed
        parse_sessions | while IFS='|' read -r state label start_s end_s elapsed_s; do
                start_human=$(date -d "@$start_s" '+%Y‑%m‑%d %H:%M:%S' 2>/dev/null || echo "$start_s")
                end_human=$(date -d "@$end_s" '+%Y‑%m‑%d %H:%M:%S' 2>/dev/null || echo "$end_s")

                case "$state" in
                active)
                        hms=$(seconds_to_hms "$elapsed_s")
                        echo " ACTIVE: $label"
                        echo "   Start: $start_human"
                        echo "   Elapsed: $hms ($elapsed_s s)"
                        ;;
                stopped)
                        hms=$(seconds_to_hms "$elapsed_s")
                        echo "COMPLETED: $label"
                        echo "   Start: $start_human"
                        echo "   End: $end_human"
                        echo "   Elapsed: $hms ($elapsed_s s)"
                        ;;
                esac
        done
}

# Main dispatch
main() {
        ensure_dirs

        case "$1" in
        start)
                cmd_start "$@"
                ;;
        stop)
                cmd_stop
                ;;
        status)
                cmd_status
                ;;
        "")
                echo "Usage: $PROGNAME start <task>" >&2
                echo "       $PROGNAME stop" >&2
                echo "       $PROGNAME status" >&2
                return 1
                ;;
        *)
                echo "Unknown command: $1" >&2
                echo "Expected: start, stop, status" >&2
                return 1
                ;;
        esac
}

# Run main with all arguments
main "$@"
