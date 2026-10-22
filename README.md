ADR-001: User-Specific Orq Agents for Skills Management

Status: Proposed
Date: 2026-10-22
Project: Engineering Companion
Decision scope: EAL Skills integration

1. Context

Engineering Companion must allow users to discover and install Skills from the Engineering Agentic Library (EAL) marketplace.

Each user should be able to select their own Skills and use them in Engineering Companion without affecting other users.

The solution must integrate with the existing architecture:

* Orq.ai for agent management and execution.
* EAL as the Skills marketplace.
* Keycloak for user authentication.
* LMC for project and connector permissions.
* FastAPI as the Engineering Companion backend.

2. Proposed Solution

Create and maintain a dedicated Orq.ai agent for each Engineering Companion user.

Each agent has its own configuration and list of attached Skills.

When a user installs or removes a Skill from the EAL, Engineering Companion updates that user’s Orq agent using the Orq API.

The solution relies on Orq’s native Skills attachment mechanism.

Architecture

                   EAL Marketplace
                         |
                   Install Skill
                         |
                         v
                Engineering Companion
                   FastAPI Backend
                         |
              Keycloak + LMC Checks
                         |
                         v
                  Orq Agents API
                         |
              +----------+----------+
              |          |          |
              v          v          v
            Agent A    Agent B    Agent C
              |          |          |
            Skills     Skills     Skills
            1, 2       2, 3       1, 4

Each user is mapped to one dedicated Orq agent.

3. Technical Implementation

3.1 Agent provisioning

When a user first accesses Engineering Companion:

1. Authenticate the user using Keycloak.
2. Check whether a dedicated Orq agent already exists.
3. If not, create a new agent from a predefined Engineering Companion configuration.
4. Store the mapping between the user’s Keycloak ID and their Orq agent key.

The agent inherits the standard Engineering Companion configuration, including the model, instructions, approved tools and guardrails.

Relevant Orq API:

POST /v2/agents

3.2 Skill installation

When a user selects a Skill from the EAL marketplace:

1. Engineering Companion receives the selected EAL Skill ID.
2. The backend validates that the user can access the Skill.
3. The backend resolves the EAL Skill to a corresponding native Orq Skill. If it does not exist, it must first be imported or registered in Orq.
4. The backend retrieves the user’s dedicated agent configuration.
5. It updates the agent’s attached Skills.
6. The Skill becomes available to the user.

Relevant Orq APIs:

* POST /v2/skills — Create or register a Skill.
* PATCH /v2/agents/{agent_key} — Update the user’s agent, including its skills field.
* POST /v3/router/responses — Execute the dedicated agent using model: "agent/{agent_key}".

The backend must preserve the other attached Skills when updating the list.

3.3 Skill execution

When a user sends a message:

1. The backend identifies the authenticated user.
2. It retrieves their dedicated Orq agent key.
3. It invokes that specific agent through the Responses API.
4. Orq makes the attached Skills available for on-demand use.
5. The agent executes the task using the permitted MCP tools.

3.4 Permissions and isolation

User-to-agent mapping is managed by Engineering Companion.

LMC permissions must still be enforced for every connector or MCP tool request, regardless of which agent is executing the task.

A dedicated Orq agent does not automatically provide a security boundary between users. Agent invocation, credentials and data access must remain controlled by the backend.

3.5 Lifecycle management

Engineering Companion must also manage:

* Agent creation and deletion.
* Skill installation and removal.
* Synchronization of updates to the common agent template.
* Synchronization of updated EAL Skills.
* Handling concurrent Skill modifications.
* Cleanup of unused agents.

4. Advantages

* Direct integration with Orq’s native Skills functionality.
* Each user has an independently configurable agent.
* Skill attachment is persistent in the agent configuration.
* Orq manages the on-demand invocation of attached Skills.
* Personal configurations can evolve independently.

5. Disadvantages

* The number of agents increases with the number of users.
* Agent provisioning and configuration synchronization require additional backend logic.
* Changes to the common agent configuration may need to be propagated to all user agents.
* Skill installation requires modifying the user’s Orq agent configuration.
* Large-scale agent management can create operational overhead.
* The approach may be unsuitable for the potential Engineering Companion user population.

6. Consequences

This solution mainly relies on existing Orq agent and Skill management APIs, but introduces a significant agent lifecycle management responsibility.

The number of agent configurations is proportional to the number of users.

The solution is feasible from an API perspective, subject to validation of Orq platform limits, quotas, and performance at the expected scale.

7. Validation Criteria

The architecture should be validated by checking that:

* A user can install and remove an EAL Skill without affecting another user.
* The backend invokes only the correct user’s agent.
* LMC permissions cannot be bypassed through an attached Skill.
* Updates to the common agent template can be propagated reliably.
* Agent creation and update operations remain manageable under expected load.

8. Documentation

* Orq — Create Agent API
* Orq — Update Agent API
* Orq — Skills
* Orq — Run Agents






ADR-002: Shared Orq Agent with Dynamic User Skills

Status: Proposed
Date: 2026-10-22
Project: Engineering Companion
Decision scope: EAL Skills integration

1. Context

Engineering Companion must allow users to discover, install and use Skills from the Engineering Agentic Library (EAL).

Each user should have a personalized set of available Skills, without requiring a dedicated Orq agent.

The architecture must support multiple users, integrate with LMC permissions and remain scalable.

2. Proposed Solution

Use one shared Orq.ai agent for Engineering Companion, with a different set of Skills supplied dynamically for each user.

Instead of permanently attaching each user’s Skills to a dedicated agent, Engineering Companion manages Skill ownership and availability in its backend.

At execution time, the backend retrieves the user’s selected Skills from the EAL and provides their instructions to the shared agent using Orq’s runtime variables.

The agent configuration remains unchanged across users.

Architecture

                    EAL Marketplace
                          |
                    Install Skill
                          |
                          v
                 Engineering Companion
                    FastAPI Backend
                          |
               +----------+----------+
               |                     |
               v                     v
          User Skills DB       Keycloak / LMC
               |                     |
               +----------+----------+
                          |
                 Load User Skills
                          |
                          v
                   Shared Orq Agent
                          |
                 Dynamic Instructions
                          |
                          v
                   MCP Jira / GitLab

All users share the same agent, but only their authorized Skills are made available during execution.

3. Technical Implementation

3.1 Skill installation

When a user selects a Skill from the EAL marketplace:

1. The frontend sends the selected Skill ID to the FastAPI backend.
2. The backend authenticates the user through Keycloak.
3. It validates access to the selected Skill.
4. It stores the relationship between the user and the installed Skill.
5. The Skill becomes available in Engineering Companion.

The Skill does not need to be permanently attached to an Orq agent.

A database record can contain:

Field	Description
user_id	Keycloak user identifier
skill_id	EAL Skill identifier
skill_version	Selected Skill version
enabled	Whether the Skill is active
project_id	Optional LMC project scope

The EAL remains the primary source of published Skills.

3.2 Dynamic Skill loading

When a user sends a message:

1. The backend identifies the authenticated user and active LMC project.
2. It retrieves the user’s enabled Skills.
3. It verifies their availability and permissions.
4. It retrieves the relevant Skill instructions from the EAL.
5. It sends the selected instructions to the shared Orq agent through runtime variables.
6. The agent processes the request using the supplied instructions and permitted MCP tools.

The selected Skills may be chosen explicitly by the user or selected by a backend relevance mechanism.

3.3 Orq runtime variables

Orq.ai supports dynamic variables in agent instructions.

The shared agent can be configured with:

You are Engineering Companion.

Available user skills: {{user_skills}}

The FastAPI backend supplies the variable when invoking the agent through the Orq Responses API.

Relevant Orq API:

POST /v3/router/responses

Example request structure:

{
  "model": "agent/engineering-companion",
  "input": "Generate my sprint report",
  "variables": {
    "user_skills": "Sprint Reporter: Retrieve Jira issues, identify blockers and generate a structured sprint report."
  }
}

The same agent can be invoked with different Skill instructions for different users.

This uses Orq’s template variable mechanism, not dynamic attachment of native Orq Skills.

3.4 Future optimization: On-demand Skill retrieval

Injecting multiple complete Skills into every execution can increase token consumption and context complexity.

To avoid this, a dedicated Skill retrieval mechanism can be introduced through MCP.

The shared Orq agent would have access to two tools:

* list_my_skills: Retrieve names, descriptions and IDs of Skills available to the authenticated user.
* get_skill: Retrieve the full instructions of an authorized Skill when needed.

With this approach:

1. The agent discovers the user’s available Skills.
2. It identifies a relevant Skill.
3. It calls get_skill to retrieve its instructions.
4. It applies the Skill to the current request.

This provides lazy loading without requiring agent-specific configurations.

The mechanism must be implemented in Engineering Companion and validated with Orq MCP integration. It is not an automatic capability of the Orq runtime variables API.

3.5 Permissions and isolation

Skills must not grant additional connector permissions.

The backend and MCP authorization layer must enforce LMC project permissions independently of Skill instructions.

Key requirements:

* User identity must be established server-side.
* Skill retrieval must be scoped to the authenticated user.
* MCP operations must validate the user’s project and connector permissions.
* Conversations and retrieved data must remain isolated between users.
* Skill content must be validated to reduce prompt injection risks.
* Executable scripts or arbitrary code contained in Skills must not be executed by default.

For the initial implementation, Skills are assumed to be instruction-based Markdown content.

4. Advantages

* A single shared Orq agent can support multiple users.
* No per-user agent provisioning or synchronization is required.
* Users can install or remove Skills without modifying Orq agent configurations.
* User-specific Skills are managed independently by Engineering Companion.
* The architecture supports growth in users without a corresponding increase in Orq agent configurations.
* Integration with EAL and LMC can be handled centrally.
* On-demand Skill retrieval can reduce unnecessary context usage.

5. Disadvantages

* Engineering Companion must implement a dedicated Skill management layer.
* Native Orq Skill attachment is not used directly for user-specific selections.
* Dynamic instruction injection may increase token consumption.
* Poorly selected or conflicting Skills can affect agent behavior.
* Backend and MCP authorization need careful design.
* Skill retrieval latency and EAL availability must be managed.
* More implementation and testing are required for automatic Skill discovery.

6. Consequences

This solution keeps agent configuration centralized while moving Skill selection and personalization into Engineering Companion.

The number of Orq agent configurations does not depend on the number of users.

The architecture introduces a backend dependency for retrieving, validating and delivering Skills during execution.

An initial implementation can rely on runtime variables. A subsequent version can introduce MCP-based on-demand retrieval.

Both mechanisms must be evaluated for latency, security and Skill execution accuracy.

7. Validation Criteria

The architecture should be validated by checking that:

* Multiple users can invoke the same Orq agent with different Skills.
* Installing or removing a Skill does not modify the shared agent.
* Users cannot retrieve unauthorized Skills.
* LMC connector permissions are always enforced.
* Skill selection remains accurate when many Skills are installed.
* Token consumption and response latency remain acceptable.
* On-demand retrieval works reliably if the MCP extension is adopted.

8. Documentation

* Orq — Build Agents: Variables and Templates
* Orq — Run Agents: Pass Variables
* Orq — Skills
