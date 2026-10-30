TASK: Engineering Companion — Architecture Discovery & Prototype Preparation

YOUR ROLE

You are acting as a Senior Software Architect and AI Engineer working on the Engineering Companion project.

Your objective is to analyze the existing codebases and identify the best way to implement a new architecture integrating:

* Engineering Companion (EC)
* LEA Management Center (LMC)
* Orq.ai
* Engineering Agentic Library (EAL)
* MCP servers for Jira and GitLab

Your analysis must be based on the actual implementation, existing dependencies, documentation and available API specifications.

IMPORTANT: THIS IS A READ-ONLY ANALYSIS PHASE.

Do not modify code, create files, update dependencies, execute migrations, commit changes or perform write operations against external systems.

Do not execute commands that modify the environment.

Ask clarification questions whenever important information cannot be determined from the repositories.

⸻

1. PROJECT CONTEXT

Engineering Companion is an enterprise AI assistant platform.

Its orchestration relies exclusively on Orq.ai managed agents.

The current multi-agent architecture includes:

* Engineering Companion: main orchestrator.
* Jira Specialist: specialized Jira agent.
* GitLab Specialist: specialized GitLab agent.

The platform integrates with LMC (LEA Management Center), which manages enterprise projects, users, permissions and connectors.

Users authenticate through the enterprise SSO infrastructure.

The EAL is a marketplace of reusable Skills that users can select to personalize their assistants.

The objective is to provide personalized AI environments while keeping provisioning, maintenance, security and monitoring manageable at enterprise scale.

⸻

2. TARGET ARCHITECTURE

2.1. Project organization

The current architectural decision is:

One LMC project corresponds to one Orq.ai project.

Example:

LMC Project A → Orq.ai Project A.

Several users may belong to the same project.

Personal agent resources should be organized using user-specific folders or resource paths inside the Orq.ai project.

Users must never access Orq.ai directly.

All authorization is enforced through the Engineering Companion backend and the appropriate downstream services.

Orq.ai folders must not be treated as individual security boundaries.

2.2. Personal agents

Each user should be able to have personalized agents within each LMC project.

The personalized configuration may contain:

* A common versioned agent template.
* User-specific Skills from EAL.
* Authorized tools and connectors.
* Personal Knowledge Base references.
* Project-specific configuration.

The initial agent team contains:

* Engineering Companion.
* Jira Specialist.
* GitLab Specialist.

2.3. Model management

The IT team requires project-specific model configurations/identifiers in Orq.ai.

The underlying LLM may be reused across different project-specific configurations.

This mechanism has already been tested manually in Orq.ai.

Users must be able to select an authorized model from Engineering Companion.

We are currently investigating dynamic model selection using Orq.ai AI Gateway Routing Rules.

The idea is to use request metadata or headers to select the underlying LLM without modifying the agent configuration.

This capability has not yet been validated for managed agents.

A critical POC must determine whether Routing Rules can affect:

1. The internal LLM calls of an Orq.ai managed agent.
2. The internal LLM calls of its delegated sub-agents.
3. Concurrent requests selecting different models.

The implementation must not assume this behavior without evidence.

For the initial POC, all agents involved in a workflow should use the same selected model, if technically possible.

If dynamic routing is unsupported, the fallback is to provision separate agent configurations per authorized model.

2.4. Skills personalization

EAL is the source of truth for available Skills and their approved versions.

Users can select Skills individually.

Their selections must persist independently of Orq.ai agent configurations.

Personal agents must be built using the relevant common templates and the user’s authorized Skills.

Investigate how the current project represents, creates, references and updates Orq.ai Skills.

2.5. Provisioning and lifecycle management

Resources must be provisioned automatically through APIs.

The current preferred lifecycle strategy is:

Provision on Demand + Replace on Change.

When a user enters an LMC project in Engineering Companion:

1. Verify authorization.
2. Resolve the corresponding Orq.ai project.
3. Retrieve the user’s desired configuration.
4. Check whether personalized agents already exist.
5. Create them if missing.
6. Reuse them if up to date.
7. Create a new generation if their configuration is outdated.
8. Switch new executions to the updated generation.
9. Clean up obsolete generations safely.

This lifecycle remains a recommendation and may change after POC results.

The alternative strategy, involving agent creation at session start and deletion at session end, is still under consideration.

All provisioning operations must be idempotent and recoverable.

2.6. Identities and budgets

The following requirements are mandatory:

* One stable Orq.ai Identity per user.
* One Orq.ai budget per Identity.
* One Orq.ai budget per LMC/Orq.ai project.

The solution must support cost attribution by:

* User.
* Project.
* User and project.
* Model.
* Agent.
* Multi-agent execution.

Verify whether Identity and project information are correctly propagated to delegated sub-agents.

Investigate existing budget management capabilities and how budgets can be provisioned automatically.

2.7. Knowledge and conversations

Personal documents and conversations must persist between user sessions.

The lifecycle of agents must be independent from the lifecycle of user documents and conversation history.

Investigate the existing conversation storage and the available Orq.ai conversation continuation mechanisms.

Do not assume that deleting or replacing an Orq.ai agent preserves the ability to resume its previous conversations.

2.8. Security

LMC is the source of truth for project membership and permissions.

Engineering Companion must enforce authorization for every sensitive operation.

MCP servers must enforce the authorized user/project/connector scope.

Jira and GitLab credentials must remain protected.

Investigate the current Keycloak, LMC, SpiceDB, Vault, connector and MCP integrations where present.

Do not expose credentials or sensitive configuration values in your report.

⸻

3. CODEBASE INVESTIGATION

Analyze the repositories available in the workspace.

Identify:

A. Engineering Companion

* Frontend architecture and routing.
* Backend framework and module structure.
* Authentication and authorization.
* Project selection and conversation management.
* Existing Orq.ai integration.
* Current agent invocation and streaming.
* Existing database models.
* Existing tests.

B. LMC — LEA Management Center

* Project creation and lifecycle.
* User/project membership management.
* Permissions.
* Connector configuration.
* Model authorization.
* Available API contracts.
* Events, callbacks or synchronization mechanisms.
* Existing mechanisms for notifying Engineering Companion.

C. Orq.ai integration

* Installed SDK versions.
* API clients and wrappers.
* Agents and templates.
* Skills.
* Model configuration.
* Routing Rules.
* Identities.
* Budgets.
* Tracing and monitoring.
* Authentication and API key management.

Determine which capabilities are already implemented and which need development.

D. MCP

* Existing Jira and GitLab tools.
* Authentication mechanism.
* User credential resolution.
* Project context propagation.
* Server-side authorization.
* Connector restrictions.
* Existing tests.

E. EAL

* Whether an EAL repository or API is available.
* How Skills are represented.
* How versions are managed.
* How users select Skills.
* How Skills can be synchronized with Orq.ai.

⸻

4. TECHNICAL VALIDATION

Use the following sources to investigate the implementation:

1. Existing repository code and tests.
2. Project documentation.
3. Installed SDKs and type definitions.
4. Available API specifications.
5. Existing Orq.ai clients and examples.
6. Official Orq.ai documentation.

Do not guess undocumented API behavior.

Clearly distinguish:

* VERIFIED IN CODE
* VERIFIED IN DOCUMENTATION
* REQUIRES POC
* UNKNOWN

Whenever possible, reference the exact repository paths and relevant files supporting your findings.

Do not expose secrets, tokens, PATs or sensitive environment variables.

⸻

5. EXPECTED OUTPUT

Provide a structured architecture investigation report.

Section 1 — Existing architecture

Explain the current implementation and component responsibilities.

Include relevant repository paths and filenames.

Section 2 — Existing reusable components

Identify functionality that can be reused without significant changes.

Section 3 — Missing capabilities

Identify what must be added for the target architecture.

Section 4 — Integration gaps and risks

Pay particular attention to:

* LMC/EC API compatibility.
* User/project authorization.
* Orq.ai project and agent provisioning.
* Skill personalization.
* Dynamic model selection through Routing Rules.
* Identity propagation.
* Budget creation and enforcement.
* MCP project scoping.
* Conversation persistence.
* Knowledge Base isolation.
* Agent lifecycle and configuration updates.

Section 5 — Proposed implementation architecture

Recommend the minimum set of backend components needed to implement the POC.

Reuse the existing architecture wherever possible.

Do not propose unnecessary microservices.

Section 6 — Recommended implementation plan

Divide the work into small, testable phases.

For each phase, identify:

* Objective.
* Existing components to reuse.
* New components required.
* Dependencies.
* Acceptance criteria.
* Main technical risks.

Section 7 — First POC recommendation

Identify the smallest experiment that can validate dynamic model routing for Orq.ai managed agents and sub-agents.

Describe how to observe the actual model used and verify that agent behavior, Skills and tool access are preserved.

Do not implement the POC yet.

⸻

6. FINAL INSTRUCTIONS

Do not change any code during this phase.

Do not fabricate API endpoints, implementation details or test results.

Ground technical findings in actual source files or available documentation.

If a repository is missing, explicitly state that it is unavailable.

Distinguish mandatory requirements from provisional architecture choices.

Prioritize existing implementations over rebuilding functionality.

At the end, summarize:

1. What already exists.
2. What is missing.
3. What is uncertain.
4. The most important architectural risks.
5. The exact first implementation task you recommend.

Respond in French, keeping technical identifiers and code terminology in English.