# Design Spec: xuan-common Flash DevOps Pipeline

**Date:** 2026-05-17
**Status:** Approved
**Project:** xuan-common (Flutter/Dart)

## 1. Executive Summary
This document defines the automated DevOps pipeline and agent collaboration model for the `xuan-common` project. The goal is to achieve high velocity through parallelism at both the infrastructure (CI/CD) and the human-AI (Agent) levels, while maintaining strict code quality and security standards.

## 2. Infrastructure Architecture (Gitea Actions)
We implement a **Hybrid Parallel Pipeline** on Gitea Actions, hosted on the local Nomad/Podman cluster (192.168.0.165).

### 2.1 Workflow Topology
The pipeline is triggered on every `push` and `pull_request` to the `main` branch.

1.  **Stage 1: Fast Feedback (Parallel)**
    *   **Job: `lint`**: Uses `github/super-linter:slim`. Validates Dart, Markdown, and YAML. Focuses on low resource footprint.
    *   **Job: `security`**: Uses `aquasec/trivy`. Scans `pubspec.yaml` for vulnerable dependencies and checks for leaked secrets.
2.  **Stage 2: Behavioral Validation (Conditional)**
    *   **Job: `e2e-test`**: Depends on `lint` and `security`.
    *   **Execution**: Launches a Flutter Web host container and runs Playwright E2E tests against it.
3.  **Stage 3: Feedback Loop**
    *   **Success**: Updates ZenTao task to "Closed".
    *   **Failure**: Creates a ZenTao Bug with logs/screenshots.
    *   **GitNexus**: Triggers `analyze` on 192.168.0.165 to update the knowledge graph.

## 3. Agent Collaboration Model (Superpowers + G-Stack)
We utilize `@subagent` concurrency to mimic a full engineering team.

### 3.1 Parallel Tasking
*   **Design Phase**: `plan-eng-review` defines the interface.
*   **Implementation Phase (Concurrent)**:
    *   `@coder`: Implements the feature logic in Dart.
    *   `@tester`: Writes Playwright BDD specs in the `test/e2e` folder.
*   **Verification Phase (Concurrent)**:
    *   `gstack-cso`: Security audit.
    *   `gstack-review`: Logic and architecture review.

## 4. Integration Details

### 4.1 ZenTao Sync
*   **Single Source of Truth**: Requirements must exist in ZenTao.
*   **Automation**: Use `zentao-cli` to sync status.

### 4.2 GitNexus Processing
*   The pipeline will include a final step to notify GitNexus:
    ```bash
    curl -X POST http://192.168.0.165:4747/api/analyze -d '{"path": "/gitea-repos/xuan/xuan-common.git"}'
    ```

## 5. Definition of Done
- [ ] Gitea Actions YAML configured and committed.
- [ ] First successful run with parallel Lint and Security jobs.
- [ ] Playwright test successfully executes in the remote container.
- [ ] ZenTao Bug automatically created on a forced failure test.

## 6. Constraints & Risks
*   **Resource Management**: Super-linter Slim must be monitored for memory usage on the Nomad node.
*   **Network**: 192.168.0.164 (Master) must have reliable connectivity to 192.168.0.165 (Gitea/Runner/Nexus).
