POC technique — Routing Rules Orq.ai et changement dynamique de modèle

1. Contexte

Nous travaillons sur l’intégration de l’Engineering Companion avec notre Mock LMC et Orq.ai.

L’architecture actuellement implémentée fonctionne :

* Un projet LMC correspond à un projet Orq.ai.
* Le LMC provisionne les projets, Identities, budgets, modèles, prompts et agents.
* Chaque utilisateur dispose de son orchestrateur Engineering Companion personnel, accompagné de ses spécialistes Jira et GitLab.
* Les spécialistes sont configurés avec leurs outils MCP.
* Les ressources sont persistantes et synchronisées par updates.
* Engineering Companion récupère depuis le Mock LMC les projets, modèles autorisés, Identities et références des agents.
* Le chat peut exécuter l’orchestrateur personnel associé au projet de l’utilisateur.
* Le fonctionnement Project-first est opérationnel.

Il reste néanmoins un point architectural majeur à résoudre : le changement dynamique de modèle pendant une conversation.

Actuellement, le sélecteur de modèle existe dans Engineering Companion, mais il ne permet pas encore de changer réellement le modèle utilisé par l’orchestrateur.

Un audit précédent a proposé de provisionner un orchestrateur distinct par modèle autorisé, avec une stratégie de checkpoints pour préserver la continuité des conversations.

Avant d’implémenter cette solution, je souhaite réexaminer une architecture potentiellement plus simple : utiliser les Routing Rules natives d’Orq.ai pour changer le modèle sans multiplier les agents.

2. Architecture que nous souhaitons étudier

L’objectif serait de conserver un seul ensemble d’agents par utilisateur et par projet :

Projet LMC Alpha
    |
    |-- Projet Orq.ai Alpha
          |
          |-- User A
          |     |-- Engineering Companion
          |     |     |-- Jira Specialist
          |     |     └-- GitLab Specialist
          |     |
          |     └-- Modèles autorisés :
          |           |-- GPT
          |           └-- Mistral
          |
          └-- User B
                |-- Engineering Companion
                |     |-- Jira Specialist
                |     └-- GitLab Specialist
                |
                └-- Modèles autorisés :
                      └-- Mistral

Le modèle effectivement utilisé serait sélectionné dynamiquement.

Exemple :

1. User A ouvre Engineering Companion dans le projet Alpha.
2. Le backend récupère ses modèles autorisés auprès du LMC.
3. User A sélectionne GPT.
4. Le backend valide cette sélection.
5. Il appelle son orchestrateur personnel Orq.ai.
6. Une Routing Rule permettrait de sélectionner GPT pour l’inférence.
7. User A sélectionne ensuite Mistral.
8. Le même orchestrateur serait conservé, mais Mistral serait utilisé.

L’objectif est d’éviter de créer plusieurs orchestrateurs et plusieurs spécialistes simplement parce qu’un utilisateur peut choisir différents modèles.

Attention : il s’agit d’une hypothèse architecturale à valider, pas d’un fonctionnement déjà démontré.

3. Première étape — Investigation technique approfondie

Avant de modifier quoi que ce soit, étudie les fonctionnalités d’Orq.ai réellement disponibles dans notre environnement Thales.

Examine notamment :

* Le fonctionnement des Routing Rules.
* Leurs conditions : modèle, metadata, headers, Identity, projet.
* Leur périmètre d’application.
* Leur ordre de priorité.
* L’API Gateway et la Responses API.
* L’exécution des agents via agent/<functional_key>.
* La manière dont les agents managés effectuent leurs propres appels d’inférence.
* Le fonctionnement des sous-agents.
* Les possibilités de transmission de paramètres ou de métadonnées à l’exécution.
* Les limites éventuelles de notre SDK Orq.ai et de notre instance Thales.

Documentation officielle à consulter :

https://docs.orq.ai/ai-gateway/configuration/routing-rules

https://docs.orq.ai/ai-studio/ai-engineering/run-agents

Inspecte également le code existant d’Engineering Companion, du Mock LMC et les intégrations Orq.ai.

Question technique fondamentale

Une Routing Rule peut-elle modifier le modèle d’inférence interne d’un agent managé tout en conservant l’exécution de cet agent, ses instructions, ses spécialistes et ses outils ?

Il faut impérativement distinguer deux scénarios.

Scénario A — Fonctionnement souhaité

Nous appelons agent/engineering-companion, et l’agent conserve son fonctionnement habituel, mais son inférence utilise dynamiquement GPT ou Mistral.

Scénario B — Fonctionnement non souhaité

Nous appelons agent/engineering-companion, mais une Routing Rule remplace simplement le modèle demandé à l’AI Gateway par un modèle GPT ou Mistral.

Dans ce cas, nous risquons de ne plus exécuter l’agent Engineering Companion lui-même.

Ce scénario ne répondrait pas à notre besoin.

Ne considère donc pas qu’une Routing Rule est compatible avec notre architecture simplement parce qu’elle fonctionne avec une requête AI Gateway classique.

4. Deuxième étape — POC minimal et isolé

Si l’investigation montre une possibilité crédible, prépare un POC ciblé.

Je souhaite vérifier deux comportements :

Test 1 :

Un orchestrateur personnel existant est invoqué avec GPT comme modèle souhaité.

Test 2 :

Le même orchestrateur personnel, avec exactement la même functional key, est invoqué avec Mistral comme modèle souhaité.

Nous devons vérifier :

1. Que l’orchestrateur exécuté est bien le même.
2. Que le modèle d’inférence réellement utilisé change.
3. Que les instructions de l’orchestrateur restent appliquées.
4. Que les spécialistes Jira et GitLab restent disponibles.
5. Que les Routing Rules ne remplacent pas l’agent lui-même par un simple modèle.
6. Que les traces Orq.ai permettent d’identifier le modèle effectivement utilisé.
7. Que deux conversations simultanées peuvent utiliser des modèles différents sans interférence.

Concernant Jira et GitLab, examine aussi si les sous-agents héritent automatiquement de la sélection du modèle principal ou s’ils conservent leur propre modèle configuré.

Ce dernier comportement doit être clairement documenté : nous pourrions accepter que les spécialistes utilisent un modèle fixe, si cela correspond à une décision explicite.

Ne suppose pas que les métadonnées transmises à l’orchestrateur sont automatiquement transmises à ses sous-agents.

5. Sécurité et isolation

Le Mock LMC reste la source de vérité des autorisations.

Les utilisateurs finaux n’accèdent jamais directement à Orq.ai.

Le backend Engineering Companion doit vérifier :

* L’identité de l’utilisateur depuis Keycloak.
* Son appartenance au projet LMC.
* Les modèles qu’il est autorisé à utiliser.
* Le projet Orq.ai associé.
* L’orchestrateur personnel correspondant.

Les paramètres de routage ne doivent jamais permettre de contourner ces validations.

Par exemple, User B ne doit pas pouvoir obtenir GPT si son projet ne l’autorise qu’à utiliser Mistral, même en manipulant une requête HTTP.

Par ailleurs, les Routing Rules peuvent avoir un périmètre plus large que celui d’un seul agent.

Il ne faut donc surtout pas créer une règle globale susceptible de modifier les requêtes des autres projets ou utilisateurs.

Si le POC nécessite la création d’une Routing Rule réelle, elle doit être strictement isolée, désactivée par défaut et limitée à des conditions de test spécifiques.

Ne modifie aucune règle de production.

6. Continuité des conversations

Je souhaite également que tu analyses les conséquences sur previous_response_id.

L’objectif n’est pas nécessairement de résoudre tout de suite cette question, mais de déterminer ce qui se passe dans les cas suivants :

* GPT → GPT.
* GPT → Mistral.
* Mistral → GPT.
* GPT → Mistral → GPT.

Un changement de modèle ne doit pas provoquer de perte silencieuse de contexte ni réutiliser un previous_response_id incompatible.

Notre historique reste persisté côté Engineering Companion.

Les checkpoints et la reconstruction du contexte restent des solutions envisageables, indépendamment du choix des Routing Rules.

Il faut également envisager la continuité après une mise à jour des prompts, des outils ou des configurations d’agent.

7. Contraintes importantes

Nous avons déjà beaucoup avancé sur le provisioning et l’intégration Engineering Companion.

Je veux préserver ce qui fonctionne actuellement.

Par conséquent :

* Ne refonds pas le provisioning existant.
* Ne crée pas de nouveaux orchestrateurs par modèle.
* Ne modifie pas les agents actuellement provisionnés.
* Ne change pas la logique de sélection de modèle dans Engineering Companion.
* Ne modifie pas les historiques ni les conversations existantes.
* Ne supprime aucune ressource.
* Ne change pas les Routing Rules existantes.
* Ne touche pas aux credentials ou aux Management Keys.
* Ne lance aucun appel susceptible de modifier notre environnement distant sans accord explicite.

Tu peux analyser la codebase, consulter les documentations, créer des tests locaux et préparer un script de POC isolé.

Si un test réel nécessite une création ou modification de ressource dans Orq.ai, explique précisément ce qui sera créé ou modifié et demande mon accord avant son exécution.

Les secrets doivent rester dans les variables d’environnement ou mécanismes de secrets déjà prévus. Ne les affiche jamais dans les logs ou dans ton compte rendu.

8. Résultat attendu

À l’issue de ton travail, je veux un compte rendu technique permettant de prendre une décision architecturale.

Présente :

A. Faisabilité

Les Routing Rules permettent-elles réellement de changer le modèle utilisé à l’intérieur d’un agent Orq.ai managé ?

Réponse : OUI / NON / NON DÉMONTRÉ.

B. Fonctionnement

Si oui, explique précisément comment le routage doit être effectué.

Identifie les paramètres de requête, headers, metadata ou configurations nécessaires.

C. Sous-agents

Explique le comportement de Jira Specialist et GitLab Specialist lors d’un changement de modèle.

D. Continuité

Explique les conséquences sur previous_response_id et sur la conservation du contexte.

E. Sécurité

Identifie les risques liés aux règles partagées, aux autorisations LMC et à l’isolation entre projets et utilisateurs.

F. Comparaison architecturale

Compare :

Solution 1 : un orchestrateur personnel avec sélection dynamique du modèle via Routing Rules.

Solution 2 : un orchestrateur personnel distinct pour chaque modèle autorisé, avec checkpoints lors des changements.

Évalue les deux solutions selon la faisabilité, la complexité, les ressources Orq.ai, la maintenance, la sécurité, la performance, la continuité des conversations et la future intégration de Skills EAL.

G. Recommandation

Propose la solution que tu recommandes pour notre architecture.

Appuie-toi sur les éléments réellement vérifiés.

Distingue clairement les comportements documentés, les observations faites pendant le POC et les hypothèses non validées.

9. Consigne finale

Je ne te demande pas encore d’implémenter une nouvelle architecture.

Je veux d’abord confirmer ou infirmer la faisabilité des Routing Rules dans notre contexte exact.

Ne pars pas du principe que la solution avec plusieurs orchestrateurs par modèle est nécessaire.

Mais ne pars pas non plus du principe que les Routing Rules résoudront automatiquement le problème.

Investigue, prépare les tests nécessaires, réalise uniquement ceux autorisés et présente-moi les conclusions.

Nous déciderons ensuite ensemble quelle architecture implémenter.