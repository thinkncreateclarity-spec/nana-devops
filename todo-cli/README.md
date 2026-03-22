
This `README.md` is **marketing‑neutral**, **onboarding‑only**, and **engineer‑friendly**.

***

### 2. `SYSTEM.md` (spacecraft‑systems‑style)

Replace `~/nana-devops/todo-cli/SYSTEM.md` with this **systems‑engineering‑grade** spec:

```markdown
# nana‑devops System Design Document (SDD)

`nana‑devops` is a CLI‑based workflow system for DevOps‑style planning, tracking, and billing, implemented as a set of 12‑fundamental CLI tools under a single Git‑managed repository.

This document serves as the **top‑level systems engineering specification** for:

- Purpose, scope, and constraints  
- Architecture and layers  
- Interfaces and contracts  
- Storage, environment, and configuration  
- Validation and baselines  
- Evolution and change control  

It is intended to satisfy the roles of:

- **System architect**  
- **Developer / maintainer**  
- **Verification engineer**  
- **User / operator**

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

## 3. Interfaces and Contracts

### 3.1 `todo` interface

**Command patterns**:
- `todo add <text>`  
- `todo list`

**Semantics**:

- Input:
  - First argument: command (`add`, `list`).  
  - Subsequent arguments: task text (for `add`).

- Output:
  - `Added: <text>` when `add` succeeds.  
  - Task list via `nl` when `list` is called.

- State:
  - Tasks stored in:  
    `~/nana-devops/todo-cli/clis/todo/data/todos.txt`.  
  - Implementation must append to and read from this file; no extra external state.

**Constraints**:
- No external dependencies (no `node` / no `npm` calls).
- Implementation must be portable POSIX shell.

### 3.2 `timer` interface

**Command pattern**:
- `timer start <task>`

**Semantics**:

- Input:
  - First argument: `start`.  
  - Remaining arguments: task description.

- Output:
  - `Timer started: <task>` during start.  
  - `Timer finished: <task>` after sleep duration.

- Time model:
  - Initially: `sleep 5` (for quick validation).  
  - Extended model: configurable duration via numeric minutes (e.g., `timer start 25 "Work session"`).

**Constraints**:
- No external dependencies.  
- Portable POSIX shell.

### 3.3 `revenue` interface

**Command patterns**:
- `revenue upi`  
- `revenue status`  

**Semantics**:

- `revenue upi`:
  - Output: UPI deep‑link URI for payment, e.g.:  
    `upi://pay?pa=ajay@paytm&am=99&tn=CLI-Pro`  
  - This URI is **statically defined** in the script; no runtime configuration.

- `revenue status`:
  - Output: status line, e.g.:  
    `💎 11/12 Empire → $3M ARR trajectory`  
  - This line is **statically defined** in the script; no runtime configuration.

- Default:
  - If first argument is not `upi` or `status`, print:  
    `revenue upi | status | empire`.

**Constraints**:
- No external dependencies.  
- Portable POSIX shell.

---

## 4. Storage, Environment, and Configuration

### 4.1 Runtime location

- `~/nana-devops` lives in **local terminal‑environment storage** (e.g., Termux internal storage).  
- `~/bin` symlinks point into `~/nana-devops/todo-cli/clis/<tool>/bin/<tool>`.

### 4.2 Backup and SD‑card usage

- `~/storage/external-1` is SD‑card mount (if available), used for:
  - `empire-backup-*.tar.gz`  
  - Large logs and artifacts  

- Product‑repo:
  - Remains on **internal storage**; no symbolic‑link‑into‑SD‑volume for `nana‑devops` itself.

### 4.3 Configuration model

- No external configuration files for `todo`, `timer`, `revenue` in their core mode.  
- Any configuration is introduced explicitly via:
  - Additional CLI arguments,  
  - Configuration under `~/nana-devops/todo-cli/` in Git,  
  - or via `mpc-*` constraint / state files.

---

## 5. Validation and Operational Baselines

### 5.1 System validation procedure

The system is considered valid when:

1. **Git‑clean reset succeeds**  
   ```bash
   cd ~/nana-devops
   git fetch origin
   git reset --hard origin/main
   git clean -d --force
