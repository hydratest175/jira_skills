Nous avons maintenant les résultats de ton investigation de phase 1.

Je souhaite que tu passes aux corrections applicatives, mais progressivement, en conservant l’architecture historique Engineering Companion et notre nouveau versioning Orq.ai.

Objectif : faire fonctionner Jira/GitLab Specialist → lea-alm-mcp → Vault → Jira/GitLab, avec l’identité Keycloak et le projet LMC appropriés.

1. Contraintes impératives

* Aucun changement du versioning des orchestrateurs.
* Aucun changement de la logique de conversation.
* Aucune modification des ressources Orq partagées sans accord.
* Aucune écriture, suppression, création ou modification dans Vault.
* Aucune modification des politiques ou permissions Vault.
* Aucun contournement TLS ni de l’authentification.
* Aucun PAT ou token affiché dans les logs ou rapports.
* Pas de Skills ni de Routing Rules.

Ne crée pas une nouvelle architecture d’authentification : conserve le mécanisme Keycloak existant.

2. Corriger le contexte projet LMC

Le backend connaît déjà le projet LMC immuable de chaque thread.

Il doit transmettre le vrai LMC Project ID à Orq sous forme de variable serveur, distincte du projet Orq.

Étudie le mécanisme de variables MCP réellement supporté par notre SDK et notre déploiement Orq.ai.

La configuration MCP doit pouvoir transmettre X-LMC-Project-ID avec une valeur dérivée exclusivement du backend, jamais du LLM.

Vérifie que le header est effectivement transmis lors d’un handoff vers Jira/GitLab Specialist.

N’inclus ni token ni valeur sensible dans les traces de test.

Attention : ajouter ce header ne suffit pas à autoriser la requête.

3. Rétablir le contrat de vérification du projet

lea-alm-mcp/app/project_authorization.py appelle un endpoint de type :

GET /projects/{project_id}/backends

Notre Mock LMC actuel ne fournit pas ce contrat.

Examine précisément les attentes du MCP : schéma de réponse, authentification du service, validation de l’utilisateur, projets et connecteurs autorisés.

Compare ces attentes avec les endpoints déjà disponibles dans Mock LMC.

Propose puis implémente une compatibilité minimale et sécurisée, dans le code local uniquement, en réutilisant les données LMC existantes.

Ne retourne jamais tous les backends sans filtrage.

Ne considère jamais un Project ID fourni dans un header comme une autorisation suffisante.

L’accès aux connecteurs doit être limité au projet actif et à l’utilisateur authentifié, avec vérification serveur des droits. Si le contrat MCP nécessite une authentification service-à-service, conserve ce contrôle.

Ne modifie aucune configuration de production ou Kubernetes sans validation.

4. Corriger le problème de configuration CA locale

Tu as identifié que REQUESTS_CA_BUNDLE pointe vers un répertoire au lieu d’un fichier CA.

Corrige la configuration locale applicative pour qu’elle utilise le bundle CA approprié déjà disponible, après vérification de son existence et de sa chaîne de confiance.

Ne désactive jamais la validation TLS.

Distingue ensuite clairement :

* Erreur de configuration CA.
* Erreur réseau ou proxy.
* Erreur TLS de confiance.
* Erreur d’authentification Vault.
* Erreur de permission Vault.
* Credential absent.

Le fait qu’une connexion échoue après correction du CA ne signifie pas automatiquement que le credential est absent.

5. Préserver Redis et Vault

Nous conservons la séparation suivante :

* Redis : sessions, métadonnées des connecteurs et autres états applicatifs existants.
* Vault : credentials Jira/GitLab.

Le code UI possède déjà un backend de secrets Vault, actuellement désactivé.

Analyse ce mécanisme pour comprendre comment restaurer le flux historique d’enregistrement d’un PAT, mais ne l’active pas automatiquement tant que les paramètres, permissions et impacts ne sont pas validés.

Ne synchronise pas arbitrairement les secrets entre Redis et Vault.

Ne crée aucun secret de test dans Vault.

Ne change aucune donnée existante dans Vault.

Si le serveur MCP distant possède une configuration Vault différente de notre environnement local, privilégie l’inspection en lecture seule de ses configurations et logs Kubernetes, dans la limite des accès disponibles.

Ne déduis pas l’état du Vault distant à partir du seul échec du client local.

6. Validation progressive

Commence par corriger et tester localement :

1. La transmission du projet LMC.
2. L’autorisation du couple utilisateur/projet.
3. Le filtrage des connecteurs autorisés.
4. Les configurations CA.
5. La distinction des erreurs internes.
6. La conservation de l’authentification pendant les handoffs.
7. La compatibilité avec les différentes versions d’orchestrateur.

Utilise des mocks pour tester le contrat LMC, Vault et les appels Jira/GitLab sans utiliser de véritables PAT.

Ne lance un appel Jira/GitLab réel que si le chemin d’authentification est opérationnel et qu’un credential déjà autorisé est disponible.

Si une modification du serveur MCP distant, d’une configuration Orq partagée ou une écriture dans Vault devient indispensable, présente-moi les changements précis et arrête-toi avant de les appliquer.

7. Résultat attendu

Je veux une correction réelle du code local autorisé, pas simplement un nouveau rapport.

Présente :

* Les corrections effectuées.
* Les fichiers modifiés.
* Les tests et leurs résultats.
* Le schéma exact de propagation du contexte utilisateur/projet.
* Le résultat des vérifications de connexion Vault.
* Les blocages restant sur l’environnement distant.
* Les éventuelles actions nécessitant mon autorisation.

Priorité : rétablir la chaîne d’intégration MCP sans toucher aux données Vault, sans affaiblir l’autorisation projet et sans casser le fonctionnement des orchestrateurs versionnés.