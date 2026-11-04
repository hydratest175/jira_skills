TASK: Mock LMC & Orq.ai Provisioning POC — Architecture Discovery

1. CONTEXT

We are building a standalone Proof of Concept demonstrating automated Orq.ai resource provisioning from a simplified version of LMC (LEA Management Center).

The objective is to analyze the existing enterprise codebases, understand their implementation, and design a minimal application that reproduces the essential LMC workflow.

Technology Stack

* Frontend: React + TypeScript + Vite
* Backend: Python + FastAPI
* Persistence: SQLite
* AI Platform: Orq.ai
* Deployment: Local development, Docker support if appropriate

Keep the architecture minimal and independent of the existing applications.

⸻

2. EXISTING REPOSITORIES — IMPORTANT PATHS

All relevant repositories are located inside:

LEA_Workspace/

A. LMC — LEA Management Center

Exact relative path:

LEA_Workspace/lcc/

This directory contains the existing LMC implementation.

Analyze its code to understand the project, user, membership, permission and model management workflows.

The application currently cannot be launched successfully.

Do not attempt to repair or launch LMC. Only inspect its source code.

B. Existing Orq.ai Provisioning POC

Exact relative path:

LEA_Workspace/use-case-engineering-companion/thales_orq_provisioning/

This project already uses the Orq.ai Python SDK.

This is an important technical reference for our new POC.

Inspect it carefully to identify:

* How the Orq.ai SDK is imported.
* Which SDK package and version are used.
* How the SDK client is initialized.
* How the Orq.ai endpoint is configured.
* How authentication is handled.
* Which provisioning operations are implemented.
* Which API methods are already being used.
* Which existing patterns can be reused.

Do not expose API keys, credentials or other sensitive values.

If your working directory is already LEA_Workspace, use the corresponding relative paths without repeating the workspace directory.

⸻

3. ORQ.AI SDK INVESTIGATION

Inspect the SDK integration already present in:

use-case-engineering-companion/thales_orq_provisioning/

Determine the exact installed SDK package and version.

Inspect its available methods, request models and response models.

Focus on the following capabilities:

1. Creating and retrieving Orq.ai projects.
2. Creating project-specific model configurations.
3. Creating and retrieving Identities.
4. Creating and managing budgets.
5. Creating and configuring agents.
6. Organizing agentic resources using folders or paths.
7. Creating and managing Routing Rules.
8. Executing managed agents.
9. Retrieving monitoring and usage information.

Verify which operations are directly supported by the SDK.

Identify any operations requiring direct HTTP API calls.

Determine which operations require Management Keys or project-scoped API keys.

Do not invent SDK methods or assume capabilities that have not been verified.

Do not install or upgrade dependencies during this phase.

⸻

4. POC FUNCTIONAL SCOPE

The POC focuses exclusively on:

* Project creation.
* User creation and project membership.
* User-specific Orq.ai folders.
* Agentic resource provisioning.
* Project-specific model configurations.
* Dynamic model selection through Routing Rules.
* Persistent Orq.ai Identities.
* Project budgets.
* Identity budgets.

Out of Scope

* EAL and Skills.
* Knowledge Bases.
* Conversation history.
* Jira/GitLab connectors and MCP integration.
* Real SSO authentication.
* Production infrastructure.
* Advanced agent lifecycle management.

⸻

5. ANALYZE THE EXISTING LMC

Inspect:

LEA_Workspace/lcc/

Understand how LMC currently manages:

* Project creation and identifiers.
* User representation.
* Project memberships.
* Roles and permissions.
* Available LLM models.
* Model authorizations.

Identify the relevant backend models, API contracts and source files.

The objective is to reproduce only the essential business logic needed for provisioning.

Do not reproduce unnecessary infrastructure such as Keycloak, SpiceDB or Vault.

⸻

6. TARGET MOCK LMC

Design a minimal standalone application.

Frontend — React + TypeScript

The interface should allow us to:

* Create and view projects.
* Create or select synthetic users.
* Assign users to projects.
* Configure available models for each project.
* Define authorized models for each user.
* Configure project budgets.
* Configure individual user budgets.
* Trigger provisioning through a button.
* Display provisioning status and created resources.

Backend — FastAPI

The backend should:

* Manage Mock LMC data.
* Persist configurations in SQLite.
* Validate user and project configurations.
* Communicate with Orq.ai through the SDK or verified APIs.
* Orchestrate provisioning.
* Track created resource identifiers and provisioning status.

The frontend must never handle Orq.ai API credentials.

⸻

7. TARGET ORQ.AI ARCHITECTURE

Projects

One LMC project corresponds to one Orq.ai project.

User Folders

Each project may contain several users.

Their agentic resources should be organized in user-specific folders or paths.

Example:

Orq.ai — Project A
│
├── Alice/
│   ├── Engineering Companion
│   ├── Jira Specialist
│   └── GitLab Specialist
│
└── Bob/
    ├── Engineering Companion
    ├── Jira Specialist
    └── GitLab Specialist

Investigate how folders are managed through the SDK or API.

Folders must not be treated as security boundaries.

Models

Each Orq.ai project requires project-specific model configurations.

The same underlying LLM may be associated with different project-specific configurations.

This mechanism has already been tested manually.

Investigate how to automate it.

Routing Rules

We want to dynamically select the underlying LLM using request metadata or headers.

The POC must determine whether Routing Rules work for:

* Direct model requests.
* Orq.ai managed agents.
* Delegated sub-agents.
* Concurrent requests selecting different models.

Verify the actual executed model through traces.

Do not assume that Routing Rules affect internal agent calls without testing.

If unsupported, propose the fallback architecture using separate agent configurations per model.

Agents

The initial agentic architecture includes:

* Engineering Companion — Main orchestrator.
* Jira Specialist.
* GitLab Specialist.

Specialists may use simple instructions without real external integrations.

Each user should have personalized agentic resources inside their project.

Identities

Create one persistent Orq.ai Identity per user.

The same Identity should be reusable across projects.

Budgets

Create:

* One budget per Orq.ai project.
* One budget per user Identity.

Investigate budget creation, enforcement and consumption attribution.

⸻

8. TARGET WORKFLOW

The final POC should demonstrate:

MOCK LMC
    │
    ▼
Create Project
    │
    ▼
Assign Users
    │
    ▼
Configure Models
    │
    ▼
Configure Budgets
    │
    ▼
Click "Provision"
    │
    ▼
FASTAPI PROVISIONING SERVICE
    │
    ├── Create Orq.ai Project
    ├── Configure Project Models
    ├── Create User Identities
    ├── Create Project Budget
    ├── Create Identity Budgets
    ├── Organize User Folders
    ├── Create Personal Agents
    └── Configure Routing Rules
    │
    ▼
ORQ.AI RESOURCES READY

Provisioning must eventually be idempotent and avoid creating duplicate resources.

⸻

9. YOUR FIRST TASK — PHASE 1 ONLY

Do not implement anything yet.

Proceed in this order:

1. Inspect LEA_Workspace/lcc/.
2. Understand the existing LMC business logic.
3. Inspect LEA_Workspace/use-case-engineering-companion/thales_orq_provisioning/.
4. Identify the existing Orq.ai SDK integration.
5. Inspect the installed SDK and its supported operations.
6. Identify reusable code and integration patterns.
7. Propose the minimal Mock LMC architecture.
8. Define the SQLite data models.
9. Propose the React interface.
10. Explain the future Orq.ai provisioning workflow.
11. Identify technical uncertainties.
12. Propose a step-by-step implementation roadmap.

Expected Report

A. Existing LMC Architecture

Relevant functionality, data models and source files.

B. Existing Orq.ai SDK Integration

Package, version, available methods and reusable patterns.

C. Minimal Mock LMC Scope

Features to reproduce and exclude.

D. Proposed Architecture

React, FastAPI and SQLite.

E. Proposed Data Models

Projects, users, memberships, authorized models, budgets and Orq.ai resource mappings.

F. Orq.ai Provisioning Design

SDK operations, dependencies, permissions and resource relationships.

G. Technical Risks

Particularly:

* Project-specific model configurations.
* Folder creation.
* Routing Rules compatibility with managed agents.
* Identity propagation.
* Budget enforcement.

H. Implementation Roadmap

Small, independently testable phases.

I. First Implementation Task

The smallest development task recommended after this analysis.

⸻

10. IMPORTANT INSTRUCTIONS

* Do not modify existing repositories.
* Do not create or modify files during this phase.
* Do not launch or repair LMC.
* Do not perform Orq.ai write operations.
* Do not install dependencies.
* Do not expose credentials or secrets.
* Use existing SDK implementations as technical references.
* Do not invent undocumented API functionality.
* Keep the architecture minimal.
* Do not implement EAL, Skills, Knowledge Bases or conversations.
* Clearly distinguish verified behavior from assumptions requiring a POC.

Respond in French.