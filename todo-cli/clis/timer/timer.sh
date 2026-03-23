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
    if [ ! -f "$SESSIONS_FILE" ]; then
        > "$SESSIONS_FILE"
    fi
}

# Log event to sessions file
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

    # First pass: build a simple associative‑like map (label → start time)
    # We'll use plain text records: "start_map $label $timestamp"
    while IFS='|' read -r event label timestamp; do
        case "$event" in
        start)
            if [ "$current" = "$label" ]; then
                active="$label"
            fi
            # Emit a start record: label|start_ts|<timestamp>
            echo "start_record|$label|$timestamp"
            ;;
        stop)
            # Emit a stop record: label|stop_ts|<timestamp>
            echo "stop_record|$label|$timestamp"
            ;;
        esac
    done < "$SESSIONS_FILE"

    # Second pass: build "active" / "stopped" records
    # We'll keep a simple line‑based map instead of eval‑variables
    while IFS='|' read -r kind label timestamp; do
        case "$kind" in
        start_record)
            start_map_label="$label"
            start_map_ts="$timestamp"
            ;;
        stop_record)
            if [ -n "$start_map_label" ] && [ "$start_map_label" = "$label" ]; then
                start_val="$start_map_ts"
                if [ -n "$start_val" ] && [ "$start_val" -gt 0 ] 2>/dev/null; then
                    elapsed=$(compute_elapsed_s "$start_val" "$timestamp")
                    echo "stopped|$label|$start_val|$timestamp|$elapsed"
                fi
            fi
            ;;
        esac
    done < "$SESSIONS_FILE"

    # If there is an active session, emit an active record
    if [ -n "$active" ]; then
        # Re‑read to find latest start for $active
        active_start=""
        while IFS='|' read -r event label timestamp; do
            if [ "$event" = "start" ] && [ "$label" = "$active" ]; then
                active_start="$timestamp"
            fi
        done < "$SESSIONS_FILE"

        if [ -n "$active_start" ] && [ "$active_start" -gt 0 ] 2>/dev/null; then
            now=$(now_s)
            elapsed=$(compute_elapsed_s "$active_start" "$now")
            echo "active|$active|$active_start|$now|$elapsed"
        fi
    fi
}

# status subcommand
cmd_status() {
    echo "--- timer status ---"

    # Ensure sessions file exists and is not empty
    if [ ! -f "$SESSIONS_FILE" ] || [ ! -s "$SESSIONS_FILE" ]; then
        echo "No sessions recorded."
        return
    fi

    # Parse all sessions and print active + completed
    parse_sessions | while IFS='|' read -r state label start_s end_s elapsed_s; do
        start_human=$(date -d "@$start_s" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo "$start_s")
        end_human=$(date -d "@$end_s" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo "$end_s")

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
