Solution 1 — Shared Agents (Agents mutualisés)

Cette solution repose sur une architecture dans laquelle les agents Orq.ai sont partagés entre les utilisateurs d’un même projet LMC, plutôt que de créer des agents dédiés à chaque utilisateur.

Chaque projet créé dans LMC correspond à un projet Orq.ai dans lequel sont provisionnées les ressources agentiques nécessaires : un agent principal Engineering Companion et ses deux sous-agents spécialisés, Jira Specialist et GitLab Specialist.

Afin de permettre aux utilisateurs de sélectionner différents modèles d’IA, plusieurs configurations d’agents peuvent être provisionnées par projet, chacune associée à un modèle spécifique. Lorsqu’un utilisateur sélectionne un modèle dans Engineering Companion, le backend vérifie ses autorisations LMC puis invoque l’agent correspondant.

La personnalisation des Skills est gérée dynamiquement via l’EAL (Engineering Agentic Library). Chaque utilisateur peut sélectionner ses propres Skills depuis la marketplace, sans modifier la configuration des agents partagés.

Pour permettre cette personnalisation, il serait nécessaire de développer un serveur MCP dédié à l’EAL, exposant notamment des outils comme list_available_skills et get_skill. Ce serveur permettrait aux agents Orq.ai de découvrir et de récupérer dynamiquement les Skills associés à l’utilisateur, en fonction de son identité et du projet actif. Les vérifications d’autorisation seraient effectuées côté serveur afin de garantir qu’un utilisateur ne puisse accéder qu’aux Skills auxquels il a droit.

Cette approche présente plusieurs avantages :

* Scalabilité : le nombre d’agents dépend du nombre de projets et de modèles disponibles, et non du nombre d’utilisateurs.
* Maintenabilité : les mises à jour des agents et des sous-agents sont centralisées.
* Flexibilité : les utilisateurs peuvent choisir leurs modèles autorisés et personnaliser leurs Skills.
* Monitoring : les fonctionnalités Orq.ai permettent de suivre les consommations et les coûts par projet, utilisateur, modèle et agent.
* Provisioning simplifié : aucune création d’agent supplémentaire n’est nécessaire lorsqu’un nouvel utilisateur rejoint un projet.

Cette solution présente néanmoins plusieurs limitations :

* Développement supplémentaire : contrairement à l’approche avec agents personnels, qui exploite directement l’association native des Skills aux agents Orq.ai, cette architecture nécessite de développer et maintenir une couche de gestion dynamique des Skills.
* Serveur MCP dédié : la mise en place du serveur MCP EAL implique de développer les outils de découverte et de récupération des Skills, leur intégration aux agents Orq.ai et les contrôles d’autorisation associés. Il faudra également garantir la transmission sécurisée du contexte utilisateur et projet.
* Complexité à l’exécution : les agents doivent identifier et charger les Skills pertinents pendant les conversations, ce qui introduit des appels supplémentaires, une latence potentielle et davantage de scénarios d’erreur.
* Sécurité et isolation : les agents étant mutualisés, il est indispensable de garantir qu’aucun utilisateur ne puisse accéder aux Skills, aux credentials ou aux ressources d’un autre utilisateur ou d’un autre projet.

En conclusion, cette architecture réduit considérablement le nombre d’agents à provisionner et simplifie leur maintenance, mais nécessite davantage de développement spécifique côté Engineering Companion et EAL. Elle privilégie la mutualisation des ressources au prix d’une complexité applicative plus importante.