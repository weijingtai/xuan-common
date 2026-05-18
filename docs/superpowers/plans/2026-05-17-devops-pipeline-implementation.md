# xuan-common Flash DevOps Pipeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a hybrid parallel DevOps pipeline for xuan-common involving Super-linter, Trivy, and Playwright, with ZenTao and GitNexus integration.

**Architecture:** Use Gitea Actions on 192.168.0.165. Parallelize Lint and Security jobs. Make Playwright E2E dependent on both. Finalize with automated feedback to ZenTao and indexing in GitNexus.

**Tech Stack:** Gitea Actions, Super-linter Slim, Trivy, Playwright, Flutter/Dart, ZenTao CLI.

---

### Task 1: Initialize Gitea Actions Workflow Folder

**Files:**
- Create: `.gitea/workflows/devops.yaml`

- [ ] **Step 1: Create directory structure**

Run: `mkdir -p .gitea/workflows`

- [ ] **Step 2: Initialize YAML file with basic trigger**

```yaml
name: xuan-common Flash DevOps
on: [push, pull_request]

jobs:
  ping:
    runs-on: ubuntu-latest
    steps:
      - name: Ping
        run: echo "Pipeline Initialized"
```

- [ ] **Step 3: Commit**

```bash
git add .gitea/workflows/devops.yaml
git commit -m "ci: initialize Gitea Actions workflow folder"
```

---

### Task 2: Implement Parallel Lint and Security Jobs

**Files:**
- Modify: `.gitea/workflows/devops.yaml`

- [ ] **Step 1: Add Super-linter Slim job**

```yaml
  lint:
    name: Lint Code Base
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: Run Super-Linter
        uses: github/super-linter/slim@v5
        env:
          VALIDATE_ALL_CODEBASE: false
          DEFAULT_BRANCH: main
          VALIDATE_DART: true
          VALIDATE_MARKDOWN: true
          VALIDATE_YAML: true
```

- [ ] **Step 2: Add Trivy Security job**

```yaml
  security:
    name: Security Scan
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          ignore-unfixed: true
          format: 'table'
          exit-code: '1'
          severity: 'CRITICAL,HIGH'
```

- [ ] **Step 3: Commit**

```bash
git add .gitea/workflows/devops.yaml
git commit -m "ci: add parallel lint and security jobs"
```

---

### Task 3: Implement Playwright E2E Job with Dependency

**Files:**
- Modify: `.gitea/workflows/devops.yaml`

- [ ] **Step 1: Add Playwright E2E job**

```yaml
  e2e-test:
    name: Playwright E2E Tests
    needs: [lint, security]
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 18
      - name: Install dependencies
        run: npm install
      - name: Install Playwright Browsers
        run: npx playwright install --with-deps chromium
      - name: Run Playwright tests
        run: npx playwright test
```

- [ ] **Step 2: Commit**

```bash
git add .gitea/workflows/devops.yaml
git commit -m "ci: add playwright e2e job dependent on lint and security"
```

---

### Task 4: ZenTao and GitNexus Feedback Integration

**Files:**
- Modify: `.gitea/workflows/devops.yaml`

- [ ] **Step 1: Add Success/Failure feedback step**

```yaml
      - name: Notify GitNexus
        if: always()
        run: |
          curl -X POST http://192.168.0.165:4747/api/analyze -d '{"path": "/gitea-repos/xuan/xuan-common.git"}'
      
      - name: ZenTao Feedback on Failure
        if: failure()
        run: |
          echo "Triggering zentao-cli to create bug..."
          # Placeholder for zentao-cli command since specific ID needs sync
          # zentao bug create --title "CI Failure in xuan-common" --product 1
```

- [ ] **Step 2: Commit and Push**

```bash
git add .gitea/workflows/devops.yaml
git commit -m "ci: add gitnexus and zentao integration placeholders"
git push gitea main
```
