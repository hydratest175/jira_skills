1. Requirements & Technical Constraints

Engineering Companion × LMC × Orq.ai

1.1. Contexte et objectifs

L’intégration entre LMC (Landing Management Console), Engineering Companion (EC), Orq.ai et l’Engineering Agentic Library (EAL) vise à fournir une plateforme d’assistants IA personnalisables, sécurisés et accessibles dans le contexte des projets d’ingénierie.

LMC constitue la source de vérité pour la gestion des projets, des utilisateurs, des permissions et des connecteurs autorisés.

Engineering Companion fournit l’interface utilisateur et assure l’application des règles d’autorisation, tandis qu’Orq.ai prend en charge l’orchestration et l’exécution des agents IA.

L’EAL permet aux utilisateurs de sélectionner des Skills pour personnaliser les capacités de leurs assistants.

L’architecture doit répondre à plusieurs objectifs :

* Personnalisation : permettre à chaque utilisateur de disposer d’un environnement adapté à ses projets, modèles autorisés, Skills et documents.
* Sécurité : garantir l’isolation des utilisateurs et des projets, ainsi que le respect des autorisations définies dans LMC.
* Maintenabilité : faciliter les évolutions des templates d’agents, des Skills et des configurations, sans nécessiter de mises à jour massives et complexes.
* Scalabilité : permettre le déploiement à grande échelle pour plusieurs milliers d’utilisateurs.
* Observabilité : assurer un suivi précis des consommations, coûts, performances et erreurs.
* Gouvernance financière : appliquer des budgets au niveau des projets et des utilisateurs.
* Automatisation : limiter les opérations manuelles de provisioning, de synchronisation et de nettoyage.

Les exigences ci-dessous sont classées selon leur statut :

* Mandatory : besoin ou contrainte déjà exprimé comme obligatoire.
* Current direction : orientation technique actuellement privilégiée, mais susceptible d’évoluer.
* POC : hypothèse retenue pour les premiers tests.
* To define : exigence ou comportement nécessitant une décision complémentaire.

⸻

1.2. Functional Requirements

Ces exigences décrivent les fonctionnalités attendues du point de vue des managers et des utilisateurs d’Engineering Companion.

ID	Requirement	Description	Status
FR-01	Project creation	Un manager doit pouvoir créer un projet dans LMC.	Mandatory
FR-02	User assignment	Un manager doit pouvoir associer plusieurs utilisateurs à un projet LMC.	Mandatory
FR-03	User permissions	LMC doit définir les permissions des utilisateurs dans chaque projet.	Mandatory
FR-04	Connector assignment	Un projet LMC doit pouvoir être associé à des connecteurs autorisés, notamment Jira et GitLab.	Mandatory
FR-05	Model authorization	LMC doit permettre de définir les modèles LLM accessibles à chaque utilisateur dans son contexte projet.	Mandatory
FR-06	Project visibility	Un utilisateur doit uniquement voir les projets LMC auxquels il est autorisé à accéder.	Mandatory
FR-07	Project selection	Un utilisateur doit pouvoir sélectionner son projet actif dans Engineering Companion.	Mandatory
FR-08	Project-scoped execution	Toutes les opérations des agents doivent s’effectuer dans le contexte du projet LMC sélectionné.	Mandatory
FR-09	Model selection	Un utilisateur doit pouvoir sélectionner un modèle LLM parmi ceux autorisés dans son projet.	Mandatory
FR-10	Model switching	Un utilisateur doit pouvoir changer de modèle depuis l’interface Engineering Companion.	Mandatory
FR-11	Skills marketplace	Un utilisateur doit pouvoir parcourir l’EAL et sélectionner des Skills pour personnaliser son assistant.	Mandatory
FR-12	Personalized Skills	Les Skills sélectionnés doivent être disponibles pour l’utilisateur dans le contexte du projet concerné.	Mandatory
FR-13	Skills persistence	Les préférences de Skills doivent être conservées entre les sessions utilisateur.	Mandatory
FR-14	Personal Knowledge Base	Un utilisateur doit pouvoir ajouter des documents personnels pour enrichir les connaissances de son assistant.	Mandatory
FR-15	Document persistence	Les documents personnels doivent rester disponibles après déconnexion et reconnexion.	Mandatory
FR-16	Conversation history	Les conversations doivent être conservées entre les sessions.	Mandatory
FR-17	Conversation continuity	Un utilisateur doit pouvoir retrouver et poursuivre une conversation précédente, même après renouvellement de son environnement agentique.	Mandatory
FR-18	Project switching	Un utilisateur doit pouvoir changer de projet sans mélanger les ressources, permissions ou conversations des différents projets.	Mandatory
FR-19	Access revocation	Lorsqu’un utilisateur perd ses permissions LMC, il doit immédiatement perdre la possibilité d’effectuer de nouvelles opérations non autorisées.	Mandatory
FR-20	Workspace preparation	Engineering Companion doit pouvoir afficher un état de chargement lorsque l’environnement agentique de l’utilisateur est en cours de préparation.	Current direction

⸻

1.3. Architecture & Orq.ai Requirements

Ces exigences concernent les composants techniques et leur organisation dans Orq.ai.

ID	Requirement	Description	Status
AR-01	Orq.ai orchestration	L’orchestration des agents doit être réalisée uniquement à travers les agents Orq.ai, sans orchestrateur Deep Agent externe.	Mandatory
AR-02	Project mapping	Un projet Orq.ai doit correspondre à un projet LMC.	Current direction
AR-03	Orq.ai abstraction	Les utilisateurs finaux ne doivent jamais accéder directement à Orq.ai. La plateforme doit rester entièrement masquée derrière Engineering Companion.	Mandatory
AR-04	Backend orchestration	Le backend Engineering Companion doit assurer la communication avec les API Orq.ai et sélectionner les ressources autorisées.	Mandatory
AR-05	User resource organization	Les ressources agentiques personnelles doivent pouvoir être organisées par utilisateur, notamment à l’aide de folders Orq.ai.	Current direction
AR-06	Personal agent configuration	Chaque utilisateur doit pouvoir disposer de configurations d’agents personnalisées dans chaque projet auquel il appartient.	Mandatory
AR-07	Multi-agent architecture	L’architecture initiale comprend un orchestrateur Engineering Companion et deux sous-agents spécialisés : Jira Specialist et GitLab Specialist.	Current direction
AR-08	Preconfigured model agents	Les modèles doivent être sélectionnés à travers des configurations d’agents préconfigurées, plutôt que par modification du modèle via PATCH à chaque changement.	Current direction
AR-09	Project-specific model IDs	Des configurations de modèles spécifiques aux projets doivent être créées dans Orq.ai, conformément aux exigences de l’équipe IT, même lorsqu’elles utilisent un même LLM sous-jacent.	Mandatory
AR-10	Sub-agent model configuration	Pour le POC, l’orchestrateur et ses sous-agents doivent utiliser le même modèle LLM.	POC
AR-11	Independent model configuration	À terme, l’architecture doit permettre d’étudier des modèles différents pour l’orchestrateur et les sous-agents.	To define
AR-12	Agent configuration management	Les configurations d’agents doivent être définies et administrées de manière centralisée.	Mandatory
AR-13	Automated resource management	La création, la mise à jour et la suppression des ressources Orq.ai doivent pouvoir être automatisées via API.	Mandatory

Important : les folders Orq.ai sont considérés comme des mécanismes d’organisation des ressources, et non comme des frontières de sécurité individuelles.

⸻

1.4. Security & Access Control Requirements

L’isolation des utilisateurs et des projets représente une exigence fondamentale.

Étant donné que plusieurs utilisateurs peuvent partager un même projet Orq.ai, les contrôles d’autorisation doivent être assurés par Engineering Companion et les services externes concernés.

ID	Requirement	Description	Status
SR-01	Authentication	L’authentification des utilisateurs doit s’appuyer sur le SSO Keycloak.	Mandatory
SR-02	LMC as source of truth	LMC doit constituer la référence pour les autorisations des utilisateurs, projets et connecteurs.	Mandatory
SR-03	Backend authorization	Le backend doit vérifier les permissions utilisateur/projet avant toute opération sensible.	Mandatory
SR-04	Project isolation	Un utilisateur ne doit jamais pouvoir accéder aux ressources ou données d’un projet LMC non autorisé.	Mandatory
SR-05	User isolation	Un utilisateur ne doit pas pouvoir accéder aux agents, documents, conversations ou ressources personnelles d’un autre utilisateur sans autorisation explicite.	Mandatory
SR-06	Model access control	Le backend doit empêcher l’utilisation de modèles non autorisés dans LMC.	Mandatory
SR-07	Skills access control	Les Skills EAL doivent être disponibles uniquement selon les permissions de l’utilisateur et du projet actif.	Mandatory
SR-08	MCP authorization	Les serveurs MCP doivent appliquer les permissions LMC lors de l’accès aux ressources Jira, GitLab et aux autres systèmes connectés.	Mandatory
SR-09	User credentials	Les credentials personnels des connecteurs, notamment les PAT Jira/GitLab, doivent être stockés et utilisés de manière sécurisée.	Mandatory
SR-10	API key protection	Les clés API Orq.ai et les clés d’administration ne doivent jamais être exposées au frontend ou aux utilisateurs finaux.	Mandatory
SR-11	Least privilege	Les clés API et comptes techniques doivent disposer des permissions minimales nécessaires à leur fonction.	Mandatory
SR-12	Knowledge isolation	Les documents personnels et les Knowledge Bases doivent être protégés par des contrôles d’autorisation indépendants de leur organisation en folders.	Mandatory
SR-13	Revocation enforcement	Les changements de permissions LMC doivent être pris en compte sans attendre une reconnexion ou une opération de provisioning.	Mandatory
SR-14	Secret protection	Les tokens, clés API, PAT et autres secrets ne doivent pas apparaître dans les prompts, réponses ou logs applicatifs.	Mandatory

⸻

1.5. Resource Provisioning & Lifecycle Requirements

Le provisioning constitue l’un des enjeux principaux de l’architecture.

L’objectif est de disposer d’un mécanisme automatisé capable de provisionner les ressources, de gérer leurs évolutions et de limiter les opérations de maintenance.

ID	Requirement	Description	Status
PR-01	Project provisioning	La création d’un projet LMC doit permettre la création automatique du projet Orq.ai correspondant.	Mandatory
PR-02	Project resource initialization	Les ressources communes nécessaires au projet, notamment les configurations de modèles, doivent être initialisées automatiquement.	Mandatory
PR-03	User identity provisioning	Une Identity Orq.ai doit être créée ou retrouvée pour chaque utilisateur concerné.	Mandatory
PR-04	On-demand agent provisioning	Les agents personnels doivent pouvoir être provisionnés lors de la première utilisation du projet par l’utilisateur.	Current direction
PR-05	Model-based provisioning	Le provisioning doit prendre en compte les modèles autorisés à l’utilisateur et créer les configurations d’agents nécessaires.	Mandatory
PR-06	Skills provisioning	Le provisioning doit récupérer les Skills sélectionnés dans l’EAL et les associer aux agents appropriés.	Mandatory
PR-07	Template synchronization	Les agents doivent pouvoir bénéficier des dernières versions validées de leurs templates sans nécessiter de maintenance manuelle massive.	Mandatory
PR-08	Skills synchronization	Les évolutions des Skills EAL doivent pouvoir être répercutées sur les configurations agentiques concernées.	Mandatory
PR-09	Persistent user data	Les conversations, documents et préférences utilisateur doivent survivre aux opérations de renouvellement ou de suppression des agents.	Mandatory
PR-10	Resource cleanup	Les ressources personnelles devenues inutiles doivent pouvoir être supprimées sans affecter celles des autres utilisateurs.	Mandatory
PR-11	Provisioning idempotency	Une opération de provisioning répétée ne doit pas créer de ressources dupliquées ou incohérentes.	Mandatory
PR-12	Concurrent sessions	Le système doit gérer correctement plusieurs connexions ou opérations simultanées pour un même utilisateur et projet.	Mandatory
PR-13	Failure recovery	Les échecs partiels de provisioning ou de suppression doivent être détectés et récupérables.	Mandatory
PR-14	Session lifecycle	Une politique de gestion de la fin de session doit couvrir le logout, le changement de projet et l’inactivité.	Current direction
PR-15	Environment lifecycle strategy	Le choix entre agents entièrement éphémères et agents persistants avec réconciliation reste à finaliser.	To define
PR-16	Resource retention	Les règles de conservation et de suppression des agents, conversations, documents et Knowledge Bases doivent être définies.	To define

Objectif de maintenabilité

Le système doit éviter qu’une modification d’un template ou d’un Skill nécessite une intervention manuelle sur l’ensemble des agents personnels existants.

Les ressources doivent pouvoir être créées ou synchronisées automatiquement à partir de configurations centralisées et versionnées.

La manière d’atteindre cet objectif reste ouverte :

* Provisioning entièrement éphémère à chaque session.
* Provisioning à la demande avec réconciliation des configurations existantes.
* Approche hybride avec nettoyage des ressources après une période d’inactivité.

Ces possibilités seront comparées dans l’analyse architecturale.

⸻

1.6. Monitoring, Observability & Budget Requirements

Le monitoring et la gouvernance financière sont des exigences obligatoires.

L’objectif est de permettre un suivi individuel et par projet, indépendamment de la manière dont les agents sont provisionnés.

ID	Requirement	Description	Status
MR-01	User Identity	Chaque utilisateur doit posséder une Identity Orq.ai identifiable de manière stable.	Mandatory
MR-02	Identity persistence	Une Identity doit pouvoir être réutilisée entre plusieurs sessions et projets.	Mandatory
MR-03	User budget	Un budget doit être créé pour chaque Identity utilisateur.	Mandatory
MR-04	Project budget	Un budget doit être créé pour chaque projet Orq.ai correspondant à un projet LMC.	Mandatory
MR-05	Budget enforcement	Les budgets applicables doivent être pris en compte lors des exécutions afin de contrôler les consommations.	Mandatory
MR-06	User cost tracking	Le système doit permettre de suivre les consommations et les coûts de chaque utilisateur.	Mandatory
MR-07	Project cost tracking	Le système doit permettre de suivre les consommations et les coûts globaux de chaque projet LMC.	Mandatory
MR-08	User-project cost tracking	Il doit être possible de connaître la consommation d’un utilisateur dans un projet spécifique.	Mandatory
MR-09	Model usage tracking	Le système doit permettre de mesurer la consommation par modèle LLM réellement utilisé.	Mandatory
MR-10	Agent usage tracking	Le système doit distinguer les consommations de l’orchestrateur et des sous-agents.	Mandatory
MR-11	Multi-agent cost attribution	Les coûts des sous-agents doivent pouvoir être rattachés à l’utilisateur et au projet ayant initié l’exécution.	Mandatory
MR-12	Execution observability	Les exécutions doivent être observables à travers des traces, métriques et informations de diagnostic.	Mandatory
MR-13	Performance monitoring	Le système doit permettre de suivre les latences, erreurs et performances des agents et outils.	Mandatory
MR-14	Cost reporting	Les données de consommation doivent pouvoir être consolidées pour produire des rapports et tableaux de bord.	Mandatory
MR-15	Historical monitoring	L’historique nécessaire au reporting doit rester exploitable après la mise à jour ou la suppression de ressources agentiques.	Mandatory
MR-16	Budget configuration	Les montants, périodes, devises et responsabilités de définition des budgets doivent être précisés.	To define

Granularité de monitoring attendue

Le système doit au minimum permettre les analyses suivantes :

Dimension	Exemple
Project	Coût total du projet Satellite
User	Coût total d’Alice
User + Project	Coût d’Alice dans Satellite
Model	Consommation de Model A
Agent	Consommation de Jira Specialist
User + Model	Modèles utilisés par Alice
Project + Model	Répartition des modèles utilisés dans Satellite
Agent + Project	Coût des sous-agents Jira/GitLab pour Satellite

Point de validation technique : la bonne propagation des informations d’identité et de projet aux sous-agents ainsi que l’absence de double comptabilisation doivent être vérifiées lors du POC.

⸻

1.7. Maintainability, Scalability & Reliability Requirements

Ces exigences concernent les qualités attendues de la solution à grande échelle.

ID	Requirement	Description	Status
NFR-01	Centralized configuration	Les templates, configurations des agents et versions approuvées doivent être gérés de manière centralisée.	Mandatory
NFR-02	Automated updates	Les mises à jour doivent pouvoir être déployées sans intervention manuelle sur chaque agent.	Mandatory
NFR-03	Version management	Les versions des templates et des Skills doivent pouvoir être identifiées et contrôlées.	Mandatory
NFR-04	Scalability	L’architecture doit pouvoir évoluer vers plusieurs milliers d’utilisateurs et un grand nombre de projets.	Mandatory
NFR-05	Controlled provisioning latency	Les temps de provisioning doivent rester compatibles avec une expérience utilisateur acceptable.	Mandatory
NFR-06	Fault tolerance	Une erreur de provisioning ou d’exécution ne doit pas entraîner d’incohérences durables dans les ressources.	Mandatory
NFR-07	Safe updates	Les évolutions de configurations doivent éviter d’interrompre ou de modifier de manière imprévisible les exécutions actives.	Mandatory
NFR-08	Auditability	Les opérations importantes de provisioning, modification, révocation et suppression doivent être traçables.	Mandatory
NFR-09	Environment separation	Les configurations et déploiements doivent prendre en compte les environnements de développement, staging et production.	Mandatory
NFR-10	Operational simplicity	L’architecture doit limiter autant que possible les duplications, opérations administratives et composants supplémentaires à maintenir.	Mandatory
NFR-11	Resource limits	Les quotas et limites de l’environnement Orq.ai doivent être compatibles avec la volumétrie attendue.	To validate
NFR-12	Monitoring reliability	Les métriques nécessaires au suivi métier doivent rester cohérentes et exploitables même en cas de changement de version ou de cycle de vie des agents.	Mandatory

⸻

1.8. Current Architectural Directions

Les orientations suivantes reflètent les choix actuellement privilégiés par l’équipe.

Elles ne constituent pas toutes des contraintes définitives et pourront évoluer à la suite des analyses ou des POC.

Sujet	Orientation actuelle	Statut
Orq.ai project structure	Un projet Orq.ai par projet LMC	Current direction
User organization	Un folder par utilisateur au sein du projet Orq.ai	Current direction
User access	Aucun accès direct des utilisateurs à Orq.ai	Mandatory
Agent architecture	Un orchestrateur Engineering Companion avec des sous-agents Jira et GitLab	Current direction
Agent personalization	Agents personnels par couple utilisateur/projet	Current direction
Model selection	Agents préconfigurés par modèle autorisé	Current direction
POC model configuration	Même modèle pour l’orchestrateur et les sous-agents	POC
Project-specific models	Création de configurations de modèles distinctes selon les exigences IT	Mandatory
Identity management	Une Identity Orq.ai stable par utilisateur	Mandatory
Budget management	Budget par projet et budget par Identity	Mandatory
Skills management	Personnalisation individuelle via l’EAL	Mandatory
Provisioning	Création automatisée des ressources à la demande	Current direction
Agent lifecycle	Suppression par session ou conservation avec réconciliation	To define
Knowledge management	Documents personnels persistants	Mandatory
Conversation management	Historique persistant entre les sessions	Mandatory
Access control	Contrôles effectués par Engineering Companion et les services MCP	Mandatory
Monitoring	Suivi par projet, utilisateur, modèle et agent	Mandatory

⸻

1.9. Open Requirements & Points to Clarify

Plusieurs décisions restent nécessaires pour finaliser les exigences techniques.

ID	Sujet	Question à résoudre
OR-01	Agent lifecycle	Faut-il supprimer les agents après chaque session ou les conserver et synchroniser leurs configurations ?
OR-02	Provisioning strategy	Faut-il provisionner tous les modèles autorisés dès la connexion ou uniquement le modèle sélectionné ?
OR-03	Session expiration	Quelle durée d’inactivité doit déclencher la fermeture de l’environnement ?
OR-04	Concurrent sessions	Un utilisateur peut-il maintenir plusieurs sessions ou onglets actifs sur un même projet ?
OR-05	API key lifecycle	Faut-il créer une clé API temporaire par session utilisateur ou utiliser des clés de service limitées aux projets ?
OR-06	Knowledge Base architecture	Les Knowledge Bases personnelles doivent-elles être conservées dans Orq.ai ou dans une infrastructure externe ?
OR-07	Conversation continuity	Quel mécanisme garantit la reprise des conversations après suppression ou mise à jour des agents ?
OR-08	Template updates	Les nouvelles versions doivent-elles être appliquées immédiatement ou lors de la prochaine utilisation ?
OR-09	Skills synchronization	Comment synchroniser les versions EAL avec les Skills natifs Orq.ai et leurs associations aux agents ?
OR-10	Sub-agent models	Le modèle choisi doit-il s’appliquer à tous les agents ou seulement à l’orchestrateur ?
OR-11	Budget policies	Qui définit les budgets, leurs montants, leurs périodes et les règles de dépassement ?
OR-12	Resource retention	Combien de temps conserver les agents inutilisés, les conversations et les documents personnels ?
OR-13	Expected scale	Combien de projets, d’utilisateurs, de sessions simultanées et de modèles doivent être supportés ?
OR-14	Performance targets	Quel temps maximal de préparation d’environnement est acceptable pour l’utilisateur ?
OR-15	LMC synchronization	Comment Engineering Companion est-il informé des créations, modifications et suppressions de projets et permissions dans LMC ?

⸻

1.10. Requirements Summary

Les exigences peuvent être regroupées autour de six piliers architecturaux.

Pilier	Objectif principal
Project & Access Management	Garantir que chaque utilisateur travaille uniquement dans ses projets LMC autorisés.
Agent & Model Management	Fournir des agents personnalisés utilisant les modèles autorisés, avec des configurations maintenables.
Skills & Knowledge Management	Permettre la personnalisation via l’EAL et la conservation des connaissances personnelles.
Provisioning & Lifecycle Management	Automatiser la création, la synchronisation et le nettoyage des ressources.
Monitoring & Budget Management	Suivre les coûts et appliquer des budgets par projet et utilisateur.
Security, Scalability & Reliability	Garantir une architecture sécurisée, robuste et adaptée à un déploiement à grande échelle.

Conclusion

L’architecture cible doit permettre de fournir à chaque utilisateur un environnement Engineering Companion personnalisé, limité aux permissions de son projet LMC et capable d’évoluer automatiquement avec les configurations et les Skills validés.

Elle doit également assurer la persistance des données utilisateur, l’isolation des ressources, la traçabilité des exécutions ainsi qu’un contrôle financier à travers les budgets Orq.ai par projet et par Identity.

Le principal enjeu architectural reste de déterminer comment gérer le cycle de vie et la synchronisation des agents personnels de manière à maximiser la maintenabilité, sans introduire une complexité excessive dans le provisioning et l’exploitation.

Les différentes solutions techniques devront être évaluées par rapport à ces exigences.