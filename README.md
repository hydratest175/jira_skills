Mission — Rétablir l’intégration Jira/GitLab MCP en conservant l’architecture historique d’Engineering Companion

1. Contexte

Nous avons récemment fait évoluer Engineering Companion et le Mock LMC.

Le changement dynamique de modèle fonctionne désormais grâce au versioning des Managed Agents Orq.ai.

Chaque utilisateur possède, pour chaque projet LMC, un orchestrateur personnel ayant plusieurs versions publiées, chacune associée à un modèle autorisé.

Les spécialistes Jira et GitLab sont partagés entre ces versions.

Cependant, nous rencontrons actuellement un problème avec les appels MCP.

Lorsqu’un utilisateur demande à Engineering Companion de récupérer des informations Jira ou GitLab, l’orchestrateur réussit à appeler le spécialiste concerné, le spécialiste se connecte au serveur MCP et découvre ses outils, mais l’exécution de ces outils échoue.

Tu as déjà réalisé une investigation qui a identifié deux problèmes potentiels :

1. Engineering Companion utilise actuellement Redis pour son stockage de connecteurs, tandis que lea-alm-mcp récupère les credentials depuis Vault.
2. La configuration MCP Orq ne transmet pas le header X-LMC-Project-ID, alors que le middleware app/project_authorization.py semble l’exiger.

Je souhaite maintenant corriger cette intégration.

Mais il est absolument essentiel de conserver la logique de fonctionnement initialement prévue dans l’architecture Engineering Companion.

Je vais te décrire cette architecture en détail ci-dessous.

Tu n’as pas besoin d’un diagramme ou d’une image : toutes les informations nécessaires sont dans ce message.

⸻

2. Architecture historique d’Engineering Companion

L’architecture initiale repose sur les composants suivants :

1. Utilisateur
2. Engineering Companion UI
3. Engineering Companion Backend
4. Worker
5. Redis
6. Engineering Companion Agent Orq.ai
7. Jira/GitLab Specialist Orq.ai
8. Orq MCP
9. Serveur lea-alm-mcp
10. Keycloak
11. Vault
12. API Jira/GitLab

Voici la séquence fonctionnelle représentée dans l’architecture historique.

Étape 1 — L’utilisateur interroge Engineering Companion

L’utilisateur ouvre Engineering Companion et envoie une question concernant Jira ou GitLab.

Exemple :

« Liste les projets Jira auxquels j’ai accès. »

L’interface transmet la question au backend Engineering Companion.

L’utilisateur est déjà authentifié via Keycloak.

Le système dispose donc d’une session d’authentification associée à cet utilisateur.

Étape 2 — Le backend transmet la requête au Worker

Dans l’architecture historique, le backend publie un événement à destination d’un Worker.

Cet événement contient notamment :

* La question de l’utilisateur.
* L’identifiant de sa session d’authentification.

Le principe est de permettre au Worker de récupérer le contexte d’authentification de l’utilisateur sans que le frontend transmette directement les credentials Jira ou GitLab.

Attention : cette architecture correspond au fonctionnement historique.

Vérifie si le Worker est encore réellement utilisé dans le code actuel.

Si les changements récents ont déplacé l’exécution Orq directement dans le backend Next.js, il ne faut pas réintroduire artificiellement un Worker.

Ce qui doit être préservé est le mécanisme d’authentification, pas nécessairement l’ancienne organisation des processus.

Étape 3 — Récupération de la session depuis Redis

Dans le diagramme historique, le Worker récupère la session d’authentification dans Redis.

La séquence représentée est :

Worker
   |
   | GET auth:session:{auth_session_id}
   v
 Redis
   |
   | Session payload
   | Keycloak access token
   v
Worker

Le Worker récupère le token Keycloak de l’utilisateur.

Ce token doit ensuite permettre d’authentifier les opérations réalisées pour cet utilisateur.

Le token Keycloak ne doit jamais être remplacé par une API Key Orq ni par un PAT Jira/GitLab.

Ce sont trois types de credentials différents, avec des usages différents.

Vérifie comment ce mécanisme est implémenté dans le code actuel.

Si le token est maintenant récupéré directement depuis la session backend, cette approche peut être conservée.

L’important est de disposer d’un token utilisateur valide, associé à l’identité réellement authentifiée.

Étape 4 — Invocation de l’orchestrateur Orq.ai

Historiquement, le Worker appelait Engineering Companion Agent en transmettant :

* La question utilisateur.
* Le contexte d’authentification Keycloak.

La séquence était conceptuellement :

Worker
   |
   | ask_orq_agent(
   |   question,
   |   keycloak_access_token
   | )
   v
Engineering Companion Agent

Dans notre nouvelle architecture, cette étape a évolué.

Nous devons maintenant résoudre un orchestrateur personnel et une version précise.

Exemple :

Projet LMC : Alpha
Utilisateur : User A
Modèle sélectionné : Mistral Medium
        |
        v
Backend Engineering Companion
        |
        | Vérifie le token Keycloak
        | Vérifie l'appartenance au projet Alpha
        | Vérifie le modèle autorisé
        | Résout l'Agent Key personnelle
        | Résout la version correspondante
        |
        v
Orq.ai
agent/<personal-agent-key>@<published-version>

Ce nouveau mécanisme de versioning doit être conservé intégralement.

Nous ne voulons pas revenir à un orchestrateur global.

Nous ne voulons pas non plus modifier le modèle par PATCH pendant les conversations.

En revanche, l’exécution de cet orchestrateur doit toujours disposer du contexte d’authentification nécessaire aux MCP.

Étape 5 — Délégation vers Jira/GitLab Specialist

Lorsqu’une question nécessite un outil Jira ou GitLab, Engineering Companion délègue au spécialiste correspondant.

Engineering Companion Agent
        |
        | Handoff
        v
Jira Specialist
        |
        | Appel MCP
        v
Orq MCP

Le spécialiste est un Managed Agent Orq.ai.

Il possède ses outils MCP configurés.

Dans notre nouvelle architecture, les spécialistes sont personnels à l’utilisateur et au projet, mais communs à toutes les versions de l’orchestrateur.

Exemple :

User A / Projet Alpha
Engineering Companion
   |
   |-- Version Small
   |-- Version Medium
   |-- Version Gemma
   |
   |-- Jira Specialist
   |
   |-- GitLab Specialist

Les trois versions doivent pouvoir appeler les mêmes spécialistes.

Le changement de modèle de l’orchestrateur ne doit pas changer l’identité utilisateur, le projet LMC ou les droits d’accès utilisés par les MCP.

Étape 6 — Transmission de l’authentification vers le MCP

Dans le diagramme historique, le token Keycloak est transmis depuis l’exécution Orq jusqu’au serveur MCP.

La configuration MCP utilise conceptuellement :

Authorization: Bearer {{access_token}}

Le token est ensuite utilisé lors de la connexion au serveur lea-alm-mcp.

L’objectif est que le serveur MCP puisse vérifier l’identité de l’utilisateur.

Il faut toutefois vérifier comment la variable est réellement fournie et résolue dans la version actuelle d’Orq.

Ne considère pas qu’une variable présente dans la configuration constitue la preuve de sa résolution à l’exécution.

Surtout :

* Ne place jamais le token dans un prompt système.
* Ne l’ajoute pas aux messages de conversation.
* Ne le transmet pas comme argument généré par le LLM.
* Ne l’expose pas dans les traces d’inférence.
* Ne l’enregistre pas dans les logs.

Le token doit être transmis exclusivement par un mécanisme d’authentification approprié et supporté par l’infrastructure MCP/Orq.

Étape 7 — Authentification par Keycloak dans lea-alm-mcp

Lorsque le serveur MCP reçoit une requête, il authentifie le token Keycloak.

Le diagramme historique représente :

lea-alm-mcp
    |
    | JWT validation
    | Keycloak access token
    v
Keycloak
    |
    | Validation
    v
lea-alm-mcp

L’objectif est d’obtenir une identité utilisateur vérifiée.

Cette identité doit ensuite permettre de déterminer quels credentials Jira/GitLab peuvent être utilisés.

Vérifie dans le code réel :

* La validation de la signature du JWT.
* L’issuer.
* L’audience.
* L’expiration.
* Les claims nécessaires.
* L’identifiant utilisateur autoritatif, notamment sub.
* La gestion des tokens expirés ou invalides.

Le serveur MCP doit refuser les requêtes non authentifiées.

Il ne doit jamais utiliser une identité par défaut pour contourner un échec d’authentification.

Étape 8 — Résolution du credential depuis Vault

C’est une partie essentielle du diagramme historique.

Après authentification, le serveur lea-alm-mcp cherche les credentials Jira/GitLab associés à l’utilisateur.

Le diagramme montre un accès Vault reposant notamment sur le chemin de stockage et l’identifiant utilisateur.

La séquence conceptuelle est :

lea-alm-mcp
     |
     | Utilisateur authentifié
     | Identifiant utilisateur (sub)
     |
     v
   Vault
     |
     | Résolution du connecteur
     | Jira/GitLab URL
     | PAT associé
     |
     v
lea-alm-mcp

Le diagramme mentionne un chemin ressemblant à :

/v1/<mount>/metadata/<path>/<user-sub>/alm/...

Ce chemin est indicatif : vérifie le chemin réellement construit dans le code.

Point important : si le moteur Vault utilise KV v2, vérifie la distinction entre les endpoints metadata et data.

Le diagramme n’est pas une preuve que l’endpoint metadata retourne les valeurs des secrets.

Le code réel du MCP doit rester la référence.

Examine notamment :

lea-alm-mcp/app/connector_tokens.py

Détermine précisément :

* Comment le serveur MCP identifie l’utilisateur.
* Comment il construit le chemin Vault.
* Comment il retrouve le connecteur demandé.
* Comment il récupère le PAT.
* Comment il récupère l’URL Jira/GitLab.
* Quelles permissions Vault sont nécessaires.
* Si le contexte du projet LMC intervient dans cette résolution.

Il faut absolument préserver les données déjà présentes dans Vault.

Étape 9 — Appel Jira/GitLab

Une fois le credential correctement résolu, lea-alm-mcp appelle l’API Jira ou GitLab.

Le diagramme représente :

lea-alm-mcp
     |
     | Appel Jira/GitLab
     | Authentification avec le PAT
     v
Jira / GitLab
     |
     | Résultat JSON
     v
lea-alm-mcp

Le résultat revient ensuite au spécialiste, puis à l’orchestrateur.

L’orchestrateur utilise ces informations pour répondre à l’utilisateur.

Le PAT n’a aucune raison d’être renvoyé au modèle.

Seul le résultat métier de l’appel Jira/GitLab doit être exposé.

Étape 10 — Retour vers Engineering Companion

Le résultat suit le chemin inverse :

Jira/GitLab
    |
    v
lea-alm-mcp
    |
    v
Orq MCP
    |
    v
Jira/GitLab Specialist
    |
    v
Engineering Companion Agent
    |
    v
Backend / Worker
    |
    v
Engineering Companion UI
    |
    v
Utilisateur

Dans l’architecture historique, le Worker publie un événement de réponse vers le backend, qui le transmet ensuite à l’UI.

Si notre implémentation actuelle utilise une réponse directe ou du streaming depuis le backend, conserver ce fonctionnement.

Ne change pas inutilement le mécanisme de retour des réponses.

⸻

3. Adaptation indispensable : le contexte projet LMC

L’architecture historique décrit correctement la propagation de l’identité utilisateur.

Cependant, notre nouvelle architecture introduit une dimension supplémentaire : le projet LMC actif.

Un même utilisateur peut maintenant appartenir à plusieurs projets LMC.

Par exemple :

User A
  |
  |-- Projet Alpha
  |     |
  |     |-- Jira Alpha
  |     |-- GitLab Alpha
  |
  |-- Projet Beta
        |
        |-- Jira Beta
        |-- GitLab Beta

Lorsque User A utilise Engineering Companion dans le projet Alpha, les appels MCP doivent être exécutés dans le contexte du projet Alpha.

Ils ne doivent pas récupérer accidentellement un connecteur du projet Beta.

Le contexte d’autorisation nécessaire devient donc :

Identité Keycloak vérifiée
          +
Projet LMC actif et autorisé
          +
Connecteur demandé
          |
          v
Résolution du credential correspondant

Ton investigation précédente a montré que :

app/project_authorization.py

semble exiger le header :

X-LMC-Project-ID

Cependant, la configuration Orq MCP actuelle ne semble pas le transmettre.

Cela doit être corrigé.

Comportement attendu

Le backend Engineering Companion connaît déjà le projet LMC immuable associé à la conversation.

Il doit :

1. Retrouver le projet depuis le thread côté serveur.
2. Vérifier l’appartenance actuelle de l’utilisateur à ce projet.
3. Résoudre le véritable identifiant du projet LMC.
4. Transmettre ce contexte via un mécanisme MCP sécurisé.
5. Permettre au serveur MCP de vérifier à nouveau l’autorisation.
6. Résoudre uniquement les connecteurs autorisés.

Vérifie si Orq.ai permet de transmettre dynamiquement ce header aux appels MCP, y compris lors des handoffs entre orchestrateur et sous-agent.

Ne suppose pas que {{project_id}} est une variable automatiquement disponible.

Si ce n’est pas le cas, examine les mécanismes réellement pris en charge par le SDK et notre version d’Orq.

Ne construis pas une solution qui dépend d’une propagation non démontrée.

Ne place pas le projet dans le prompt comme mécanisme d’autorisation.

Ne permets jamais au LLM de choisir librement le projet.

Et surtout, le serveur MCP doit revérifier que l’identité authentifiée possède les droits nécessaires sur le projet demandé.

Un simple header ne constitue pas une autorisation.

⸻

4. Le rôle respectif de Redis et Vault

Je veux corriger un point de notre investigation précédente.

Nous ne devons pas considérer automatiquement que l’utilisation de Redis et Vault constitue une anomalie.

Dans l’architecture historique, ils remplissent des rôles différents.

Redis

Redis intervient notamment dans :

* La gestion des sessions.
* La récupération du contexte d’authentification.
* Le stockage temporaire des informations nécessaires au backend/Worker.
* Certaines métadonnées applicatives.

Vault

Vault intervient dans :

* Le stockage sécurisé des credentials Jira/GitLab.
* Leur résolution côté serveur MCP.
* Leur mise à disposition des seuls composants autorisés.

Cette séparation peut être parfaitement cohérente.

Notre objectif n’est donc pas de migrer arbitrairement tous les credentials vers un système unique.

Notre objectif est de rétablir le flux permettant à lea-alm-mcp de résoudre les credentials appropriés.

Vérifie comment l’utilisateur est censé enregistrer son PAT.

Vérifie si ce mécanisme historique existe encore.

Vérifie si notre interface actuelle stocke seulement des métadonnées de connecteurs dans Redis, ou si elle était réellement censée enregistrer des PAT dans un backend de secrets.

Détermine si le problème provient :

* D’un credential absent.
* D’un credential enregistré au mauvais endroit.
* D’un chemin Vault incorrect.
* D’un problème de permissions Vault.
* D’une identité utilisateur incorrecte.
* D’un contexte projet absent.
* D’un défaut de propagation des paramètres Orq.
* D’une différence entre le mécanisme historique et le code actuel.

Il faut identifier la cause exacte avant de proposer une modification du stockage.

⸻

5. Protection absolue de Vault

Tu n’as aucune autorisation d’écriture dans Vault pour cette mission.

C’est une contrainte impérative.

Tu ne dois effectuer :

* Aucune suppression.
* Aucune création de secret.
* Aucune mise à jour de secret.
* Aucun écrasement.
* Aucune migration de credentials.
* Aucun changement de chemin.
* Aucune modification d’ACL.
* Aucune modification de politique Vault.
* Aucune rotation de credentials.
* Aucun nettoyage.
* Aucune réinitialisation.

Tu peux examiner le code qui utilise Vault.

Tu peux examiner les configurations non sensibles.

Tu peux vérifier en lecture seule, avec les permissions existantes, l’existence et l’accessibilité des chemins nécessaires.

Tu ne dois pas afficher les valeurs des secrets dans les logs, rapports ou réponses.

Si la lecture d’une valeur sensible n’est pas indispensable au diagnostic, ne l’effectue pas.

Si une écriture dans Vault est nécessaire pour corriger le problème, arrête-toi et demande-moi explicitement l’autorisation avant toute opération.

Précise alors exactement :

* Le chemin Vault concerné.
* Le type d’opération.
* Les ressources affectées.
* Le risque.
* Les conséquences.
* Le mécanisme de retour arrière.

Aucune intervention implicite n’est autorisée.

⸻

6. Analyse comparative : architecture historique et implémentation actuelle

Avant de modifier le code, réalise un audit ciblé.

Compare le fonctionnement historique que je viens de décrire avec notre implémentation actuelle.

Examine notamment :

Engineering Companion

* app/api/chat/route.ts
* lib/orq/responses.ts
* lib/mock-lmc/personal-orchestrator.ts
* lib/orq/project-credentials.ts
* La gestion des sessions.
* Les fonctions liées aux connecteurs.
* Les variables d’exécution envoyées à Orq.

Mock LMC

* Le runtime-context des projets.
* Les memberships utilisateur/projet.
* Les configurations Jira/GitLab.
* Le provisioning des spécialistes.
* Le provisioning des MCP dans Orq.

lea-alm-mcp

* app/connector_tokens.py
* app/project_authorization.py
* Le middleware Keycloak.
* La résolution des connecteurs.
* Les clients Jira/GitLab.
* Le mécanisme d’accès à Vault.

Vérifie les chemins réels dans le workspace avant toute modification.

Je veux que tu identifies précisément :

1. Ce qui correspond encore à l’architecture historique.
2. Ce qui a changé avec nos nouvelles implémentations.
3. Ce qui fonctionne.
4. Ce qui est cassé.
5. Ce qui doit être corrigé.
6. Ce qui ne doit surtout pas être modifié.

Ne propose pas une refonte générale.

⸻

7. Corrections attendues

Une fois la cause identifiée, réalise uniquement les corrections applicatives nécessaires.

A. Propagation de l’authentification

Garantir que l’identité Keycloak de l’utilisateur est correctement transmise jusqu’au serveur MCP.

Vérifier les variables Orq réelles.

Vérifier la transmission aux spécialistes.

Ne jamais exposer le token au LLM.

B. Propagation du projet LMC

Garantir que le serveur MCP reçoit le véritable contexte projet de la conversation.

Vérifier l’autorisation sur ce projet.

Ne pas confondre projet LMC et projet Orq.

C. Résolution des credentials

Faire en sorte que le MCP utilise les credentials déjà disponibles dans le backend de secrets approprié.

Ne déplacer aucun secret automatiquement.

Si un PAT est absent, identifier proprement cette situation.

Si l’ajout d’un PAT nécessite une écriture dans Vault, ne l’effectue pas sans autorisation.

D. Gestion des erreurs

Actuellement, _resolve_connectors() masque potentiellement certaines erreurs derrière CONNECTOR_UNAVAILABLE.

Améliore la journalisation interne pour distinguer :

* Credential absent.
* Erreur Vault.
* Erreur d’autorisation projet.
* Token Keycloak invalide.
* Connecteur introuvable.
* Erreur Jira/GitLab.

Les messages destinés aux utilisateurs ne doivent pas exposer de détails sensibles.

⸻

8. Préserver le versioning des orchestrateurs

Ce point est non négociable.

Nous avons déjà validé et implémenté :

* Un orchestrateur personnel par utilisateur/projet.
* Plusieurs versions correspondant aux modèles autorisés.
* Un mapping SQLite persistant.
* Une sélection du modèle depuis Engineering Companion.
* Une exécution utilisant agent/<key>@<version>.
* Des spécialistes partagés entre les versions.
* Une gestion de la continuité conversationnelle.

Aucun de ces mécanismes ne doit être remplacé ou supprimé.

La correction MCP doit être indépendante du modèle utilisé.

Si l’utilisateur change de Mistral Small à Mistral Medium, le spécialiste Jira doit continuer à recevoir le contexte d’authentification approprié.

Les credentials ne doivent pas être associés artificiellement à une version d’agent.

Ils doivent rester associés à l’utilisateur et au périmètre d’accès autorisé.

⸻

9. Tests obligatoires

Une fois les corrections applicatives terminées, vérifie progressivement la chaîne complète.

Tests d’authentification

* Token Keycloak valide.
* Token expiré.
* Token invalide.
* Utilisateur autorisé sur le projet.
* Utilisateur non autorisé.
* Projet LMC manquant.
* Projet LMC incorrect.

Tests de résolution

* Connecteur présent.
* Connecteur absent.
* Credential existant et accessible.
* Credential absent.
* Erreur de permission Vault.
* Projet différent.
* Utilisateur différent.

Tests MCP

* MCP Connect.
* MCP Discover Tools.
* Exécution de jira_list_projects.
* Exécution d’un outil GitLab en lecture seule.
* Bonne attribution utilisateur/projet.
* Absence de divulgation des tokens.

Tests Engineering Companion

* Orchestrateur version A.
* Orchestrateur version B.
* Jira Specialist avec version A.
* Jira Specialist avec version B.
* GitLab Specialist avec version A.
* GitLab Specialist avec version B.
* Changement de version au cours d’une conversation.
* Maintien du contexte d’authentification après changement de version.
* Absence de régression sur les conversations.
* Absence de modification des mappings de versions.

Utilise des mocks pour tous les scénarios négatifs nécessitant des credentials ou des permissions spécifiques.

Les tests réels doivent rester limités aux comptes et ressources déjà autorisés.

Si aucun credential valide n’est disponible, indique clairement que les tests réels sont bloqués.

Ne contourne jamais Vault ou l’authentification pour faire réussir un test.

⸻

10. Stratégie de travail

Procède dans cet ordre.

Phase 1 — Investigation

Compare le code actuel à l’architecture historique décrite ici.

Identifie les causes exactes des erreurs.

Phase 2 — Correction applicative

Corrige les problèmes de propagation d’identité et de projet.

Corrige les erreurs de résolution qui ne nécessitent pas d’intervention sur Vault.

Préserve le versioning et les fonctionnalités existantes.

Phase 3 — Validation

Exécute les tests applicatifs.

Vérifie les requêtes MCP et les traces Orq.

Confirme le fonctionnement avec plusieurs versions d’orchestrateur.

Phase 4 — Bilan

Présente les résultats et les éventuels blocages restants.

Si une modification de Vault ou d’une ressource partagée devient nécessaire, arrête-toi avant cette opération et demande-moi une validation explicite.

⸻

11. Résultat attendu

Je veux rétablir le fonctionnement suivant :

Utilisateur authentifié
        |
        v
Engineering Companion UI
        |
        v
Engineering Companion Backend
        |
        | Vérification Keycloak
        | Projet LMC actif
        | Modèle autorisé
        |
        v
Résolution de l'orchestrateur personnel
        |
        | Agent Key + version publiée
        |
        v
Managed Agent Orq.ai
        |
        v
Jira/GitLab Specialist
        |
        v
Orq MCP
        |
        | Authentification utilisateur
        | Contexte projet LMC
        |
        v
lea-alm-mcp
        |
        | Vérification JWT
        | Vérification autorisations projet
        |
        v
Vault (lecture des credentials autorisés)
        |
        v
Jira/GitLab API
        |
        v
Résultats vers Engineering Companion

Cette représentation montre le flux logique ; elle ne signifie pas que tous les composants doivent être regroupés dans un même service.

L’implémentation peut conserver les frontières backend, Worker, Redis et Orq réellement présentes dans le code.

Le but est de restaurer le mécanisme d’authentification et de résolution des credentials prévu par l’architecture initiale, tout en conservant notre nouvelle architecture multi-projets et multi-versions.

Je veux une correction réelle lorsque celle-ci peut être effectuée sans opération sensible.

Je ne veux pas une nouvelle architecture.

Je ne veux pas de migration arbitraire.

Je ne veux aucune modification de Vault sans autorisation.

Et je ne veux aucune modification du versioning des agents, des Routing Rules ou des Skills.

À la fin, explique clairement :

* Les causes identifiées.
* Les modifications réalisées.
* Les fichiers modifiés.
* Les tests exécutés.
* Ce qui fonctionne désormais.
* Ce qui reste bloqué.
* Les éventuelles opérations nécessitant mon autorisation.