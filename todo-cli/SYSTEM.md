# nana‑devops System Description

`nana‑devops` is a **terminal‑first, CLI‑only system** for DevOps‑in‑a‑terminal workflow, built on 12‑fundamental CLI tools, Git‑only truth, and UPI‑first monetization.

---

## 1. System Purpose

`nana‑devops` enables:

- Ubiquitous planning, tracking, and billing via the terminal.  
- Git‑driven evolution of CLI tools, with no extra dependencies outside the repo.  
- UPI‑based invoicing and revenue tracking for CLI‑driven services.

**Target user**: CLI‑native indie developer / DevOps practitioner using Termux on Android.

---

## 2. System Architecture

The system is composed of **four layers**:

1. **CLI substrate**  
   - `~/bin/<tool>` symlinks to `~/nana-devops/todo-cli/clis/<tool>/bin/<tool>`.  
   - Example tools: `todo`, `timer`, `notes`, `gitops`, `revenue`, etc.

2. **12‑fundamental CLI tools**  
   - 12 independent CLI modules under `~/nana-devops/todo-cli/clis/`:
     - `todo` – task management  
     - `timer` – time tracking  
     - `revenue` – UPI billing and status  
     - `notes` – plain‑text note‑taking  
     - `gitops` – Git‑driven workflow helper  
     - `crypto` – secrets / encryption helpers  
     - `password` – password / credential helper  
     - `calc` – math / money calculator  
     - `qr` – QR code creation  
     - `plot` – simple plotting  
     - `weather` – ambient info  
     - `todo-list` – alternate view of tasks  

   - Core rule: **`todo`, `timer`, `revenue` are pure shell scripts** (no `node`, no `commander`, no `node_modules` in core workflow).

3. **Git system**  
   - Single source of truth:  
     `https://github.com/thinkncreateclarity-spec/nana-devops`  
   - All changes flow through Git; no local‑only Termux‑only scripts.

4. **Empire / MPC layer**  
   - Files: `mpc-*`, `empire-backup-20260315.tar.gz`, logs, HTML index, etc.  
   - Role: agentic planning, constraints, states, watchdog, and daemon logic for adaptive CLI empire growth.

---

## 3. Key Interfaces

### 3.1 `todo` interface

- Command pattern:
  - `todo add <text>`  
  - `todo list`  
- Behaviors:
  - Stores tasks in `~/nana-devops/todo-cli/clis/todo/data/todos.txt`.  
  - Prints `Added: <text>` on `add`, task list on `list`.

### 3.2 `timer` interface

- Command pattern:
  - `timer start <task>`  
- Behaviors:
  - Prints `Timer started: <task>`.  
  - Sleeps 5 seconds (or real‑time duration later).  
  - Prints `Timer finished: <task>`.

### 3.3 `revenue` interface

- Command pattern:
  - `revenue upi`  
  - `revenue status`  
- Behaviors:
  - `revenue upi` → prints UPI deep‑link:  
    `upi://pay?pa=ajay@paytm&am=99&tn=CLI-Pro`  
  - `revenue status` → prints:  
    `💎 11/12 Empire → $3M ARR trajectory`  
  - else → `revenue upi | status | empire`

---

## 4. Storage and Environment

- **Runtime location**:  
  - `~/nana-devops` lives in Termux internal storage.  
  - `~/bin` symlinks point into `~/nana-devops/todo-cli/clis/<tool>/bin/<tool>`.

- **Backup / SD role**:  
  - `~/storage/external-1` is SD‑card mount, used for:
    - `empire-backup-*.tar.gz`  
    - large logs, artifacts  
  - Production repo is always on internal Termux storage.

---

## 5. System Validation

The system is valid when:

1. **Git‑clean reset works**  
   ```bash
   cd ~/nana-devops
   git fetch origin
   git reset --hard origin/main
   git clean -d --force
