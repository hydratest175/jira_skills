Nous poursuivons le POC mock-lmc-orq-poc.

Le provisioning réel des projets, Identities, budgets et configurations de modèles Orq.ai fonctionne désormais.

Nous voulons maintenant intégrer le provisioning persistant des ressources agentiques, en nous appuyant sur les templates Jira Specialist et GitLab Specialist déjà développés dans les projets LEA.

Avant d’implémenter, prends connaissance de l’architecture et des conventions ci-dessous. Elles constituent les décisions retenues pour cette étape.

1. Objectif architectural

Le Project Manager configure son projet dans le Mock LMC.

Lorsqu’il clique sur « Provisionner tout », le backend crée ou synchronise les ressources Orq.ai correspondantes.

Le workflow devient :

1. Projet Orq.ai.
2. Identities.
3. Budgets.
4. Configurations de modèles.
5. Ressources Prompt.
6. Agents personnels, organisés dans les folders utilisateurs.

Les ressources restent ensuite dans Orq.ai.

Lors d’un nouveau provisioning, les configurations existantes doivent être mises à jour si nécessaire, sans création de doublons.

Nous ne voulons aucun provisioning lié aux connexions ou déconnexions des utilisateurs.

2. Templates existants à réutiliser

Deux projets GitLab contiennent déjà les templates de référence.

GitLab Specialist

Dépôt : lea-gitlab-orq-agent

Fichiers :

* workspace/agents/gitlab-specialist.yaml
* workspace/prompts/gitlab-specialist.yaml
* workspace/prompts/md/gitlab-specialist-system.md

Jira Specialist

Dépôt : lea-jira-orq-agent

Fichiers attendus :

* workspace/agents/jira-specialist.yaml
* workspace/prompts/jira-specialist.yaml
* workspace/prompts/md/jira-specialist-system.md

Attention : vérifie le nom réel du YAML agent Jira, car une capture montre un fichier dont le nom semble être gitlab-specialist.yaml alors que son contenu décrit Jira Specialist.

Ces dépôts sont visibles dans GitLab interne.

Tu n’as pas nécessairement accès à GitLab depuis l’environnement Software Companion.

Commence donc par rechercher les fichiers dans les dépôts déjà présents localement dans LEA_Workspace.

S’ils sont accessibles, lis leurs contenus complets.

S’ils ne le sont pas, n’invente pas les fichiers Markdown à partir de leurs noms ou de suppositions.

Indique-moi simplement quels fichiers doivent être copiés localement.

Tu peux organiser des copies de référence dans mock-lmc-orq-poc, sans modifier les dépôts sources.

Ne réécris pas les prompts spécialisés s’ils sont disponibles.

3. Structure des YAML existants

Les YAML agents Jira et GitLab utilisent globalement cette structure :

key: DEV_Jira_Specialist
display_name: DEV_Jira_Specialist
role: Jira_Specialist
path: DEV Engineering Companion
description: >
  Agent specialized in Jira Tasks
model: thales-poc@openailike/mistral-small-2603
knowledge_base_refs: []
prompt:
  display_name: DEV_Jira_Specialist
skills:
  - display_name: DEV_Test_Skill
  - display_name: DEV_Test_Skill_Other
settings:
  max_iterations: 10
  max_execution_time: 300
  tools:
    - type: current_date
  guardrail_refs: []
instructions: ""

Le YAML GitLab est équivalent, avec les identifiants et descriptions du spécialiste GitLab.

Les YAML des ressources Prompt utilisent cette structure :

key: jira-specialist-prompt
display_name: DEV_Jira_Specialist
path: DEV Engineering Companion
description: System prompt for the Jira specialist agent
system_prompt_file: md/jira-specialist-system.md
prompt:
  messages:
    - role: system
      content: placeholder

Le YAML GitLab référence :

md/gitlab-specialist-system.md

IMPORTANT :

Ces YAML sont des templates provenant des dépôts existants. Ils ne correspondent pas nécessairement directement au schéma des appels API Orq.ai.

Analyse comment ils étaient destinés à être interprétés par les outils de provisioning existants.

Ne transmets pas aveuglément tous leurs champs au SDK.

Le champ system_prompt_file doit être résolu vers le contenu réel du Markdown.

La valeur placeholder ne doit jamais devenir le system prompt final.

4. Contenu attendu des prompts spécialisés

Les deux fichiers Markdown sont des system prompts détaillés.

Ils ne doivent pas être remplacés par de simples descriptions génériques.

Jira Specialist

Le prompt définit :

* Un sous-agent spécialisé dans l’analyse des données Jira.
* Un fonctionnement exclusivement en lecture seule.
* L’analyse des tickets, sprints, epics, commentaires, statuts, dépendances et blockers.
* Une hiérarchie entre instructions système, tâche transmise par l’orchestrateur et données retournées par les outils.
* L’interdiction d’exécuter des instructions trouvées dans des tickets ou commentaires.
* L’interdiction de créer, modifier, supprimer ou faire évoluer des ressources Jira.
* La protection des secrets et données sans rapport avec la demande.
* La gestion des erreurs d’outils, résultats vides et données indisponibles.
* La distinction entre faits, inférences et informations inconnues.
* La limitation des recherches aux projets autorisés.
* L’utilisation de dates explicites, filtres structurés et pagination raisonnable.
* La restitution d’un rapport Markdown compact avec preuves et références.

Le rapport attendu contient notamment :

* Scope.
* Findings.
* Blockers / risks.
* Open loops.
* Metrics.
* Limits.

GitLab Specialist

Le prompt définit :

* Un sous-agent spécialisé dans l’analyse des données GitLab.
* Un fonctionnement exclusivement en lecture seule.
* L’analyse des merge requests, commits, reviews, discussions, issues, pipelines, jobs et événements CI/CD.
* Une hiérarchie d’instructions équivalente.
* La protection contre les instructions malveillantes présentes dans les repositories, commentaires ou logs.
* L’interdiction de modifier des branches, merge requests, pipelines ou autres ressources GitLab.
* La protection des secrets et configurations internes.
* La gestion des erreurs, données manquantes et résultats partiels.
* La limitation des recherches aux projets et groupes autorisés.
* La restitution d’informations vérifiables et dédupliquées.

Le rapport attendu contient les mêmes grandes sections que le rapport Jira.

Ces descriptions permettent de comprendre la finalité des fichiers, mais ne remplacent pas leurs contenus complets.

Utilise les Markdown originaux intégralement.

Si les fichiers originaux sont introuvables, signale ce blocage avant de créer des agents avec des prompts incomplets.

Adaptation de sécurité

Les prompts sources prévoient parfois une recherche élargie lorsque le contexte utilisateur ou projet est manquant.

Pour notre architecture, ne conserve pas un comportement qui élargirait implicitement la recherche à des projets non explicitement autorisés.

Si le périmètre autorisé est absent, le spécialiste doit signaler le contexte manquant sans interroger un périmètre élargi.

Cette adaptation doit rester minimale et identifiable par rapport au template source.

Le contrôle d’autorisation définitif sera assuré par Engineering Companion et ses connecteurs MCP.

5. Convention des clés Orq.ai

Il faut distinguer les clés des agents et les clés des prompts.

Clés des agents

Chaque utilisateur possède ses propres agents dans chaque projet.

La clé doit donc identifier :

* Le projet LMC.
* L’utilisateur.
* Le rôle de l’agent.

Convention proposée :

ec-p-{project_uuid}-u-{user_uuid}-{role}

Rôles :

* engineering-companion
* jira-specialist
* gitlab-specialist

Utilise les identifiants stables des entités SQLite, normalisés dans un format accepté par Orq.ai.

Ne construis jamais une clé fonctionnelle à partir du nom affiché de l’utilisateur ou du projet.

Respecte les contraintes de longueur et de caractères du SDK.

Une même combinaison projet + utilisateur + rôle doit toujours produire exactement la même clé.

Clés des prompts

Les prompts spécialisés sont initialement identiques pour tous les utilisateurs d’un même projet.

Nous préférons donc des ressources Prompt partagées au niveau du projet plutôt que des copies inutiles pour chaque utilisateur.

Convention :

ec-p-{project_uuid}-prompt-jira-specialist

ec-p-{project_uuid}-prompt-gitlab-specialist

L’unicité doit rester garantie même lorsque plusieurs projets utilisent les mêmes templates.

Vérifie si le SDK permet réellement d’associer une ressource Prompt partagée à plusieurs agents.

Si cette association n’est pas supportée, utilise le mécanisme API officiellement disponible pour renseigner le contenu complet du system prompt sur chaque agent.

Dans les deux cas, conserve une seule source de vérité pour chaque template Markdown et évite les duplications de maintenance.

6. Display names et rôles

Les display names peuvent rester simples :

* Engineering Companion
* Jira Specialist
* GitLab Specialist

Ils ne servent pas d’identifiants techniques.

Les rôles des agents doivent correspondre à leur spécialisation.

Une modification de display name ne doit pas provoquer la création d’un nouvel agent.

7. Organisation des folders

Nous avons retenu un projet Orq.ai par projet LMC.

Les agents personnels doivent être organisés dans des folders utilisateurs.

Exemple conceptuel :

Projet Orq.ai : Satellite
|
|-- templates/
|   |-- Jira Specialist Prompt
|   |-- GitLab Specialist Prompt
|
|-- users/
    |-- user-abc123/
    |   |-- Engineering Companion
    |   |-- Jira Specialist
    |   |-- GitLab Specialist
    |
    |-- user-def456/
        |-- Engineering Companion
        |-- Jira Specialist
        |-- GitLab Specialist

Les noms des folders doivent être dérivés d’identifiants stables.

Vérifie le comportement réel du champ path dans le SDK et selon la portée de la clé API.

Attention à ne pas ajouter deux fois le nom du projet dans le path.

Utilise la création implicite des dossiers par les ressources si c’est le mécanisme supporté.

N’invente pas d’API de création ou suppression de folders.

Les folders servent uniquement à organiser les ressources. Ils ne garantissent pas l’isolation entre utilisateurs.

8. Stratégie de modèles

Les modèles ont déjà été provisionnés par notre Mock LMC.

Les nouveaux agents doivent utiliser les configurations réelles existantes dans Orq.ai.

Ne conserve pas le modèle codé en dur dans les YAML sources.

Pour cette étape, nous retenons :

Un ensemble de trois agents persistants par couple projet-utilisateur.

Le Mock LMC doit pouvoir définir un modèle par défaut pour cet utilisateur dans le projet.

Ce modèle doit nécessairement appartenir aux modèles autorisés pour cet utilisateur.

Pour le premier POC, Engineering Companion, Jira Specialist et GitLab Specialist peuvent partager ce même modèle.

Si aucun modèle par défaut valide n’est défini, le provisioning des agents concernés doit être bloqué avec un message explicite.

N’utilise pas arbitrairement le premier modèle trouvé.

Lors d’une modification du modèle par défaut dans le Mock LMC, le provisioning suivant doit mettre à jour les configurations existantes, sans créer de nouveaux agents.

La sélection dynamique d’un modèle pendant une conversation Engineering Companion sera étudiée dans une étape ultérieure.

N’implémente pas encore les Routing Rules.

Ne suppose pas qu’une Routing Rule s’applique automatiquement aux appels internes des agents.

N’utilise pas de mise à jour concurrente d’un agent partagé pour simuler un changement de modèle à chaque requête.

Si cette stratégie de sélection dynamique n’est pas viable, nous étudierons plus tard la création persistante d’un ensemble d’agents par modèle autorisé.

9. Paramètres des agents

Réutilise les paramètres des templates lorsque leur compatibilité SDK est confirmée.

Notamment :

* max_iterations: 10
* max_execution_time: 300

Retire pour cette première version :

* Les Skills de test DEV_Test_Skill et DEV_Test_Skill_Other.
* Les références Knowledge Base.
* Les outils MCP Jira et GitLab.
* Les dépendances à des ressources non encore provisionnées.

Conserve les éventuels outils natifs simples uniquement s’ils sont disponibles et compatibles.

Ne crée pas de faux outils pour remplir les configurations.

Les prompts doivent rester cohérents avec l’absence temporaire d’outils métier : les agents ne doivent jamais inventer des données Jira ou GitLab.

10. Agent Engineering Companion

Nous avons également besoin d’un agent principal Engineering Companion par utilisateur.

Il est destiné à devenir l’orchestrateur des spécialistes Jira et GitLab.

Commence par rechercher un éventuel template Engineering Companion existant dans les dépôts locaux.

S’il existe, examine-le et réutilise sa configuration adaptée.

Sinon, pour ce POC, une configuration minimale explicitement identifiée comme provisoire suffit.

Ne fabrique pas un prompt métier complexe.

Ne configure pas encore les délégations entre agents si cela nécessite des mécanismes supplémentaires.

L’objectif de cette étape est d’abord de provisionner les ressources correctement.

11. Synchronisation et idempotence

Réutilise le système de provisioning et la base SQLite déjà implémentés.

Pour chaque ressource, conserve au minimum les informations nécessaires pour retrouver :

* Le projet LMC.
* Le projet Orq.ai.
* L’utilisateur concerné, si applicable.
* Le type de ressource.
* Son rôle.
* Sa clé fonctionnelle Orq.ai.
* Son identifiant Orq.ai.
* L’empreinte de sa configuration souhaitée.
* Son statut de provisioning.

Le provisioning doit effectuer une réconciliation :

* Ressource inexistante : création.
* Ressource existante et configuration identique : aucune modification.
* Ressource existante et configuration modifiée : mise à jour.
* Erreur après création : tentative de récupération par clé avant toute nouvelle création.
* Collision avec une ressource qui n’appartient pas au POC : ne pas écraser, signaler l’erreur.

Les prompts doivent être synchronisés à partir du contenu complet des fichiers Markdown.

Un changement de prompt doit être détecté et répercuté sur les agents qui l’utilisent.

Ne mets pas systématiquement à jour toutes les ressources à chaque clic.

Ne supprime aucune ressource existante dans cette étape.

Si un utilisateur est retiré du projet, signale ses ressources comme nécessitant une politique de désactivation ou de nettoyage ultérieure, sans suppression automatique.

12. Gestion des modifications des templates

Les fichiers YAML et Markdown constituent les templates de référence.

Les valeurs suivantes doivent être injectées dynamiquement :

* Clé de la ressource.
* Path Orq.ai.
* Référence du modèle.
* Référence du prompt.
* Identifiants projet et utilisateur nécessaires.

Les valeurs suivantes peuvent rester communes :

* Display name.
* Rôle.
* Description métier.
* Instructions spécialisées.
* Paramètres d’exécution compatibles.

Ne modifie jamais les dépôts originaux pour générer les variantes utilisateurs.

Prépare les configurations en mémoire, ou dans des fichiers de travail propres au POC si cela facilite l’implémentation.

Évite de générer des dizaines de YAML permanents simplement pour provisionner plusieurs utilisateurs.

Les mappings durables doivent rester dans SQLite.

13. Intégration au Mock LMC

Conserve le bouton « Provisionner tout ».

Il doit désormais inclure la création/synchronisation des prompts et agents après les modèles.

Il doit permettre de visualiser les ressources créées et les éventuelles erreurs.

N’ajoute pas de simulation de connexion utilisateur.

N’ajoute pas de nouvelle authentification.

Ne refonds pas l’interface existante.

Ajoute uniquement les éléments nécessaires pour choisir explicitement le modèle par défaut d’un utilisateur, afficher les statuts et déclencher le provisioning.

14. Contraintes d’implémentation

Travaille uniquement dans :

LEA_Workspace/mock-lmc-orq-poc

Tu peux lire les autres dépôts du workspace mais tu ne dois pas les modifier.

Réutilise les patterns déjà opérationnels du POC, notamment ceux du SDK Orq.ai.

Si nécessaire, consulte également le POC existant :

LEA_Workspace/use-case-engineering-companion/thales_orq_provisioning

Ne modifie ni le LMC réel dans LEA_Workspace/lcc, ni le backend Engineering Companion.

N’ajoute pas de dépendance ou infrastructure inutile.

N’implémente pas encore :

* EAL.
* Skills.
* Knowledge Bases.
* MCP Jira/GitLab.
* Routing Rules.
* Sessions éphémères.
* Suppression automatique des agents.

Ne journalise jamais les clés API ou autres secrets.

Ne lance aucune opération réelle de création ou modification dans Orq.ai sans mon autorisation.

15. Vérification

Je souhaite effectuer manuellement les validations fonctionnelles dans Orq Studio.

Une fois l’implémentation terminée, je vérifierai :

1. Que les prompts Jira et GitLab ont été correctement intégrés.
2. Que leur contenu correspond aux Markdown de référence.
3. Que les agents sont créés dans le bon projet.
4. Que chaque utilisateur possède ses agents dans son folder.
5. Que les clés restent uniques et stables.
6. Que les agents utilisent le modèle autorisé configuré.
7. Qu’un deuxième provisioning ne crée pas de doublons.
8. Qu’une modification de modèle ou de prompt déclenche une mise à jour correcte.

Ne développe pas de tests automatisés effectuant des appels réels à Orq.ai pour vérifier ces éléments.

Les vérifications automatiques locales doivent rester limitées aux aspects nécessaires au bon fonctionnement du code.

16. Résultat attendu

Je veux pouvoir :

* Configurer mon projet et ses utilisateurs dans le Mock LMC.
* Choisir les modèles autorisés et le modèle par défaut de chaque utilisateur.
* Cliquer sur « Provisionner tout ».
* Retrouver dans Orq.ai les prompts et les agents personnels provisionnés.
* Modifier une configuration dans le Mock LMC.
* Cliquer de nouveau sur « Provisionner tout » pour synchroniser les changements.

Commence par inspecter les sources et les mécanismes du SDK.

Si les templates Jira/GitLab ne sont pas accessibles localement, indique-moi précisément les fichiers manquants avant de provisionner les prompts.

Ensuite, implémente cette étape en respectant les conventions et décisions ci-dessus.

À la fin, présente-moi brièvement les modifications effectuées et la procédure de validation manuelle.

Réponds en français.