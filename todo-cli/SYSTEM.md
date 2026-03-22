# nana‑devops System Design Document (SDD): Baseline

`nana‑devops` is a CLI‑based workflow system for DevOps‑style planning, tracking, billing, and operations, implemented as 12‑fundamental CLI tools under a single Git‑managed repository.

This document is the **baseline systems engineering specification** for the system.
Changes to the system shall be made relative to this baseline.

---

## 1. System Purpose and Scope

### 1.1 Purpose

`nana‑devops` provides:

- A **terminal‑first** environment for:
  - Task planning and tracking (`todo`, `timer`).  
  - Billing and revenue tracking (`revenue`) with UPI‑style semantics.  
  - Notes, secrets, and data operations (`notes`, `crypto`, `password`, `calc`, `qr`, `plot`, `gitops`, `weather`, `todo-list`).

- A **Git‑monitored** source of truth for all CLI logic, with no extra external dependencies in the core workflow.

- A **reset‑able, reproducible** operational environment via Git commands, enabling deterministic recovery and validation.

### 1.2 Scope

In‑scope:

- 12‑fundamental CLI tools under `~/nana-devops/todo-cli/clis/`.  
- Git‑managed configuration, helpers, and documentation.  
- Local execution in a terminal environment (e.g., Termux on Android), with access to internal storage and optional SD‑card backup.

Out‑of‑scope:

- Cloud‑hosted orchestration, distributed CI/CD, or cluster‑scale operations.  
- Any business‑level marketing, monetization‑strategy, or revenue‑forecasting content beyond UPI‑deep‑link templates.

---

## 2. System Architecture

`nana‑devops` is structured as a four‑layer system:

### 2.1 CLI substrate

- `~/bin/<tool>` symlinks to `~/nana-devops/todo-cli/clis/<tool>/bin/<tool>`.  
- Examples: `todo`, `timer`, `notes`, `gitops`, `revenue`.

- Behavior:
  - All CLI operations are performed via these entry‑points.  
  - The shell environment provides the runtime (e.g., `/bin/sh`, `bash`‑compatible syntax).

### 2.2 12‑fundamental CLI tools

Located under `~/nana-devops/todo-cli/clis/`:

- `todo` – task management (add/list)  
- `timer` – time tracking (start/stop)  
- `revenue` – billing / UPI‑link generator  
- `notes` – plain‑text note‑taking  
- `gitops` – Git‑driven workflow helper  
- `crypto` – secrets / encryption operations  
- `password` – password / credential helper  
- `calc` – math / money calculator  
- `qr` – QR code generation  
- `plot` – simple plotting / visualization  
- `weather` – ambient data / information helper  
- `todo-list` – alternate view of tasks

**Core rule**:
- `todo`, `timer`, `revenue` are **pure shell scripts** (no `node`, no `commander`, no `node_modules` in core workflow).

### 2.3 Git system

- Single source of truth:
  `https://github.com/thinkncreateclarity-spec/nana-devops`

- All changes to CLI logic, `SYSTEM.md`, and `README.md` are **committed via Git**.  
- No local‑only Termux‑only scripts; no “magic” outside Git.

### 2.4 Empire / MPC layer

Located under `~/nana-devops/todo-cli/`:

- Files: `mpc-*`, `empire-backup-20260315.tar.gz`, logs, HTML index, etc.  
- Role:
  - Agentic planning, constraints, states, watchdog, and daemon logic for adaptive CLI‑driven empire‑growth semantics.  
  - Backup and state‑capture via `empire-backup-*.tar.gz`.

---

## 3. Requirements (REQ)

This section defines the **baseline requirements** of the system.

### 3.1 REQ‑001: Task management (`todo`)

- The system shall provide a `todo` command with the following subcommands:  
  - `todo add <text>`  
  - `todo list`

- Given: `todo add <text>`  
  - Then: the system shall append `<text>` to `~/nana-devops/todo-cli/clis/todo/data/todos.txt`.  
  - And: print `Added: <text>`.

- Given: `todo list`  
  - Then: the system shall print all tasks in `todos.txt` with line numbers (e.g., using `nl`).

- The implementation of `todo` shall be written as a portable POSIX shell script, with no external dependencies.

### 3.2 REQ‑002: Time tracking (`timer`)

- The system shall provide a `timer` command with the subcommand:  
  - `timer start <task>`

- Given: `timer start <task>`  
  - Then: the system shall print `Timer started: <task>`.  
  - Then: sleep for a configurable duration (initially 5 seconds for validation).  
  - Then: print `Timer finished: <task>`.

- The implementation of `timer` shall be written as a portable POSIX shell script, with no external dependencies.

### 3.3 REQ‑003: Billing / UPI semantics (`revenue`)

- The system shall provide a `revenue` command with the following subcommands:  
  - `revenue upi`  
  - `revenue status`

- Given: `revenue upi`  
  - Then: the system shall print a UPI deep‑link URI, e.g.:
    `upi://pay?pa=ajay@paytm&am=99&tn=CLI-Pro`  
  - The URI content shall be statically defined in the script.

- Given: `revenue status`  
  - Then: the system shall print a status line, e.g.:
    `💎 11/12 Empire → $3M ARR trajectory`  
  - The status line shall be statically defined in the script.

- Given: any other first argument  
  - Then: the system shall print `revenue upi | status | empire`.

- The implementation of `revenue` shall be written as a portable POSIX shell script, with no external dependencies.

### 3.4 REQ‑004: Reset‑able state

- The system shall be bringable to a known‑good state via:
  ```bash
  cd ~/nana-devops
  git fetch origin
  git reset --hard origin/main
  git clean -d --force
  ``` 

### 3.5 REQ‑005: Git‑only truth

- The system shall keep all CLI logic and system documentation (`SYSTEM.md`, `README.md`) under Git version control.
- No critical behavior may depend on Termux‑local‑only files or configuration that are not in the repo.
- All changes to CLI tools, helpers, and documentation shall be recorded in Git before being considered part of the system.
- Any Termux‑local‑only scripts, aliases, or environment‑specific tweaks that are not in the repo shall be treated as non‑standard and invalid in the baseline.

### 3.6 REQ‑006: Real‑time session tracking (`timer`)

- The system shall record start and stop events for each `timer` session in `~/nana-devops/todo-cli/clis/timer/data/sessions.txt`.
- Each start event shall contain:
  - Session label (i.e., the `<task>` given to `timer start`).
  - Start timestamp (in ISO‑8601 or `date +%s`).
- Each stop event shall contain:
  - Session label.
  - Stop timestamp.
- The system shall compute elapsed time (in seconds) for completed sessions.
- The system shall provide a `timer status` command that prints:
  - Current active session (if any), with elapsed time so far.
  - List of completed sessions from `sessions.txt`, each with:
    - Session label.
    - Start time.
    - End time.
    - Elapsed seconds.
- The implementation of `timer` shall be written as a portable POSIX shell script, with no external dependencies.

### 3.7 REQ‑007: Session‑based billing (`revenue`)

- The system shall provide a `revenue session <session_id>` command that:
  - Reads the corresponding timer session from `~/nana-devops/todo-cli/clis/timer/data/sessions.txt`.
  - Computes elapsed time (in seconds) for that session.
  - Maps elapsed time to a monetary value (e.g., 60 minutes → ₹99).
  - Prints a UPI deep‑link URI with that amount and a session‑based label, e.g.:
    `upi://pay?pa=ajay@paytm&am=99&tn=Focus-session`
- The system shall keep `revenue` core behavior (`revenue upi`, `revenue status`) unchanged and treat `revenue session <session_id>` as an extension.
- The implementation of `revenue session` shall be written as a portable POSIX shell script, with no external dependencies.

### 3.8 REQ‑008: Empirical billing trigger (`mpc‑bill`)

- The system shall provide an `mpc‑bill` helper that:
  - Monitors `~/nana-devops/todo-cli/clis/timer/data/sessions.txt`.
  - Detects when a completed session exceeds a configurable threshold (e.g., 60 minutes).
  - For each such session, invokes `revenue session <session_id>` with appropriate parameters.
- The system shall allow the threshold (e.g., `60 minutes`) to be configured via an environment variable or script‑local constant.
- `mpc‑bill` shall be optional and non‑core; the baseline system is valid without running it.
- The implementation of `mpc‑bill` shall be written as a portable POSIX shell script, with no external dependencies.

---

## 4. Validation (VAL)

### 4.1 VAL‑001: Git‑clean state validation

- Preconditions: remote repo exists at `https://github.com/thinkncreateclarity-spec/nana-devops`.
- Steps:
  ```bash
  cd ~/nana-devops
  git fetch origin
  git reset --hard origin/main
  git clean -d --force
  ``` 
- Postconditions:
  - `git status` shall report `nothing to commit, working tree clean`.
  - `~/nana-devops/todo-cli/clis/todo/bin/todo` shall match the version in the repo.
  - Any Termux‑local‑only scripts or untracked helpers that are not in the repo shall be removed and not present in the working tree.

### 4.2 VAL‑002: Core CLI workflow validation

- Preconditions: Git‑clean state.
- Steps:
  ```bash
  cd ~/nana-devops/todo-cli
  todo add "Test task"
  todo list
  timer start "Test task"
  sleep 5
  timer stop
  revenue upi
  ``` 
  - Preconditions: Git‑clean state.
- Expected outputs:
  - `Added: Test task`
  - numbered `todo list`
  - `Timer started: Test task` → `Timer finished: Test task`
  - `upi://pay?pa=ajay@paytm&am=99&tn=CLI-Pro`

  ### 4.3 VAL‑003: Error‑case validation

- Preconditions: Git‑clean state.
- Steps:
  ```bash
  cd ~/nana-devops/todo-cli
  todo
  timer start
  revenue
  ``` 
  - Expected outputs:
  - Each command shall print usage/help or fail with non‑zero exit; no silent success.
- Postconditions:
  - Error‑handling is explicit and consistent across core tools.

### 4.4 VAL‑004: Session‑tracking validation

- Preconditions: Git‑clean state, and `~/nana-devops/todo-cli/clis/timer/data/sessions.txt` exists (can be empty).
- Steps:
  ```bash
  cd ~/nana-devops/todo-cli
  timer start "Session A"
  sleep 建构
  timer stop
  timer start "Session B"
  sleep 5
  timer stop
  timer status
  ``` 
  - Expected outputs:
  - `Timer started: Session A` → `Timer finished: Session A`
  - `Timer started: Session B` → `Timer finished: Session B`
  - `timer status` prints:
    - No active session.
    - Two completed sessions:
      - `Session A` with ~10 seconds elapsed.
      - `Session B` with ~5 seconds elapsed.
- Postconditions:
  - `sessions.txt` contains two start‑stop pairs for `Session A` and `Session B`.
  - Elapsed times match (within small tolerance) the `sleep` durations.

### 4.5 VAL‑005: Session‑billing validation

- Preconditions: Git‑clean state, `timer` sessions recorded and `revenue` command available.
- Steps:
  ```bash
  cd ~/nana-devops/todo-cli
  timer start "Billing session"
  sleep 300
  timer stop
  revenue session "Billing session"
  ``` 
  - Expected outputs:
  - `Timer started: Billing session` → `Timer finished: Billing session`.
  - `revenue session "Billing session"` prints a UPI deep‑link URI, e.g.:
    `upi://pay?pa=ajay@paytm&am=99&tn=Billing-session`.
- Postconditions:
  - The amount in the UPI link corresponds to a reasonable mapping from 300 seconds to a fixed price band (e.g., tiered or flat‑rate).

  ### 4.6 VAL‑006: Billing‑trigger validation

- Preconditions: Git‑clean state, `timer` and `revenue` working, `mpc‑bill` script available.
- Steps:
  ```bash
  cd ~/nana-devops/todo-cli
  timer start "Long session"
  sleep 3600
  timer stop
  mpc‑bill
  ``` 
  - Expected outputs:
  - `Timer started: Long session` → `Timer finished: Long session`.
  - `mpc‑bill` invokes `revenue session "Long session"` and prints a corresponding UPI deep‑link URI.
- Postconditions:
  - `sessions.txt` shows one completed `Long session` of ~3600 seconds.
  - The UPI deep‑link reflects an amount consistent with the configured billing threshold (e.g., 60 minutes → ₹99).

### 4.7 VAL‑007: Monetization‑loop and dashboard validation

- Preconditions: Git‑clean state, `timer` sessions recorded, `revenue` working, and `revenue status` reporting.
- Steps:
  ```bash
  cd ~/nana-devops/todo-cli
  timer start "Monetized session"
  sleep 300
  timer stop
  revenue session "Monetized session"
  revenue status
  ``` 
  - Expected outputs:
  - `Timer started: Monetized session` → `Timer finished: Monetized session`.
  - `revenue session "Monetized session"` prints a UPI deep‑link URI, e.g.:
    `upi://pay?pa=ajay@paytm&am=99&tn=Monetized-session`.
  - `revenue status` prints a status line that includes:
    - The fact that one session has been billed.
    - A running “today / total” indicator or similar summary.
- Postconditions:
  - The status line reflects the billed session and is consistent with `sessions.txt` entries.
  - The UPI‑deep‑link corresponds to the configured monetization rate for the session duration.

## 5. Baseline declaration

- This document corresponds to Git commit `TODO: <SHA>` of the `nana-devops` repository.
- All future changes to the system shall be made relative to this commit.
- To recover the baseline, run:
  ```bash
  cd ~/nana-devops
  git fetch origin
  git reset --hard origin/main
  git clean -d --force
  ``` 
  - The baseline includes:
  - `REQ‑001`–`REQ‑008`
  - `VAL‑001`–`VAL‑007`
  - All core CLI tools and SDD‑related files in `todo-cli`.

