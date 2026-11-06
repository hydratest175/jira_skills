Mission — POC Routing Rules Orq.ai

1. Contexte

Nous travaillons sur l’architecture Engineering Companion / Mock LMC / Orq.ai.

L’architecture actuelle fonctionne :

* Le Mock LMC provisionne les projets Orq.ai.
* Les Identities et budgets sont provisionnés.
* Les configurations de modèles sont provisionnées.
* Les prompts et agents personnels sont provisionnés.
* Chaque utilisateur possède un orchestrateur Engineering Companion et deux sous-agents, Jira Specialist et GitLab Specialist.
* Les spécialistes sont configurés avec leurs outils MCP.
* Engineering Companion récupère les projets, les modèles autorisés et les références exactes des orchestrateurs depuis le Mock LMC.
* Le chat utilise correctement l’orchestrateur personnel provisionné.
* L’exécution Orq.ai fonctionne et les traces sont disponibles.
* La navigation Project-First est opérationnelle.

Tout cela doit être préservé.

Actuellement, le modèle effectivement utilisé par l’agent est celui défini dans son manifeste. Le sélecteur de modèle de l’interface ne permet pas encore un véritable changement de modèle pendant l’exécution.

Nous souhaitons étudier les Routing Rules avant de décider comment implémenter cette fonctionnalité.

2. Objectif du POC

Déterminer expérimentalement si Orq.ai permet de changer dynamiquement le modèle d’inférence d’un agent managé, tout en préservant intégralement son comportement agentique.

Nous voulons tester l’architecture suivante :

Engineering Companion
        |
        | Modèle demandé : GPT ou Mistral
        v
Backend Engineering Companion
        |
        | Autorisation validée
        | Métadonnées de routage contrôlées
        v
Orq.ai
        |
        v
Engineering Companion Agent
        |
        +---- Jira Specialist
        |        |
        |        +---- Outils MCP
        |
        +---- GitLab Specialist
                 |
                 +---- Outils MCP

Hypothèse à vérifier :

Un unique orchestrateur peut rester configuré de manière permanente, tandis que des Routing Rules déterminent le modèle réellement utilisé lors de chaque requête.

Cette hypothèse n’est pas démontrée. Le but du POC est précisément de la confirmer ou de l’infirmer.

3. Question technique principale

Il faut absolument distinguer deux scénarios.

Scénario A — Souhaité

L’appel conserve sa cible agent/<functional_key>.

La Routing Rule agit sur le modèle utilisé pour l’inférence interne de cet agent.

L’agent conserve :

* Son identité et sa clé fonctionnelle.
* Son prompt système.
* Ses instructions.
* Ses outils.
* Ses sous-agents.
* Son équipe d’agents.
* Son comportement d’orchestration.

Seul le modèle d’inférence change.

Scénario B — Non acceptable

La Routing Rule remplace la cible agent/<functional_key> par une référence directe à un modèle.

Le moteur d’exécution de l’agent est alors potentiellement contourné.

Ce scénario ne répondrait pas à notre besoin, même si le modèle final correspond à celui demandé.

Le POC doit démontrer le scénario A, et pas simplement qu’une requête reçoit une réponse provenant de GPT ou de Mistral.

4. Préparation de l’expérimentation

Avant toute modification distante :

1. Examiner le SDK Orq.ai installé et les APIs réellement disponibles sur notre instance Thales.
2. Identifier le mécanisme exact permettant de créer, activer et supprimer des Routing Rules.
3. Vérifier les conditions CEL prises en charge.
4. Vérifier si les métadonnées d’une requête agent/<functional_key> sont disponibles lors des inférences internes.
5. Vérifier la portée des règles : projet, workspace et priorité par rapport aux règles existantes.
6. Identifier les références exactes de deux modèles disponibles pour le test, idéalement GPT et Mistral.
7. Vérifier que les permissions et les clés disponibles permettent un test isolé.

Ne pas inventer de syntaxe CEL, d’endpoint ou de comportement non documenté.

Si nécessaire, créer un script expérimental indépendant des applications existantes.

5. Isolation du POC

Ce test ne doit avoir aucun impact sur les ressources utilisées actuellement par Engineering Companion.

Contraintes impératives :

* Utiliser exclusivement un projet Orq.ai dédié aux tests, explicitement identifiable.
* Ne pas utiliser les projets actuellement exploités par le Mock LMC.
* Ne pas modifier les orchestrateurs personnels existants.
* Ne pas modifier les agents Jira/GitLab existants.
* Ne pas modifier les configurations des modèles existants.
* Ne pas créer de Routing Rule globale au workspace.
* Ne pas modifier les règles déjà présentes.
* Ne pas modifier Engineering Companion ni le Mock LMC.
* Ne pas exposer de secrets, tokens ou clés API dans les logs.

Si aucun environnement de test suffisamment isolé n’est disponible, arrêter avant toute écriture distante et expliquer ce qui manque.

6. Mise en place du test

Créer temporairement, dans le projet de test uniquement :

Agent orchestrateur

Un agent managé Orq.ai disposant :

* D’un prompt système clairement identifiable.
* D’un modèle configuré initialement.
* D’un accès à deux sous-agents fictifs.
* D’au moins un outil de test permettant de prouver que le comportement agentique est conservé.

Sous-agents fictifs

Créer deux sous-agents simulant Jira Specialist et GitLab Specialist.

Ils doivent pouvoir renvoyer des informations fictives et facilement vérifiables.

Ne pas connecter de vrais comptes Jira ou GitLab pour cette expérimentation.

L’objectif est de vérifier que les appels aux sous-agents continuent à fonctionner après application des Routing Rules.

Routing Rules

Créer deux règles temporaires, strictement limitées au projet de test.

Une règle doit sélectionner GPT.

Une autre doit sélectionner Mistral.

Le déclenchement doit dépendre d’une information contrôlée par le backend, par exemple une métadonnée de sélection de modèle, si cette possibilité est effectivement supportée.

Vérifier la syntaxe CEL exacte.

Vérifier le mécanisme d’évaluation et les priorités.

Prévoir des noms uniques et un mécanisme permettant d’identifier précisément les ressources temporaires.

Les règles doivent initialement être désactivées.

Les activer uniquement pendant les tests nécessaires.

7. Tests à réaliser

Test A — Baseline sans Routing Rule

Appeler l’orchestrateur avec son modèle configuré initialement.

Vérifier :

* Le modèle utilisé.
* L’exécution du prompt.
* L’utilisation des outils.
* L’appel aux sous-agents.
* Les traces Orq.ai.

Conserver les identifiants des traces.

Test B — Routage vers GPT

Activer la règle GPT.

Appeler exactement le même orchestrateur.

Vérifier :

* Que sa clé fonctionnelle reste inchangée.
* Que GPT réalise réellement l’inférence attendue.
* Que le prompt est conservé.
* Que les outils fonctionnent.
* Que les sous-agents restent accessibles.
* Que leurs propres modèles sont identifiés.
* Que la règle appliquée est identifiable dans les traces, si la plateforme expose cette information.

Test C — Routage vers Mistral

Répéter le test avec Mistral.

L’orchestrateur doit toujours être le même.

Ne pas modifier son manifeste entre les tests.

Test D — Concurrence

Créer deux conversations distinctes.

Dans la première, sélectionner GPT.

Dans la seconde, sélectionner Mistral.

Lancer les deux requêtes simultanément.

Vérifier que :

* Chaque conversation utilise le modèle demandé.
* Aucune configuration persistante d’agent n’est modifiée.
* Aucun modèle ne fuit d’une conversation à l’autre.
* Les sous-agents restent disponibles.
* Les traces distinguent les exécutions.

Test E — Portée des Routing Rules

Vérifier ce qui se produit lorsqu’un orchestrateur appelle Jira Specialist ou GitLab Specialist.

Questions à résoudre :

* La règle affecte-t-elle uniquement l’orchestrateur ?
* Affecte-t-elle également les sous-agents ?
* Les métadonnées de la requête parent sont-elles propagées ?
* Les sous-agents conservent-ils leur modèle configuré ?
* Une règle peut-elle sélectionner un modèle pour l’orchestrateur sans affecter les spécialistes ?

Ne pas considérer un comportement non observé comme acquis.

Test F — Continuité

Tester deux requêtes successives avec le même orchestrateur et le même modèle.

Puis étudier une transition GPT → Mistral.

Vérifier les limites de previous_response_id.

Ne pas considérer automatiquement qu’un ancien responseId est compatible avec un changement de modèle.

Ce test sert à documenter les comportements et non à implémenter les checkpoints de conversation.

8. Critères de réussite

Le POC est considéré comme réussi uniquement si :

1. Le même orchestrateur conserve sa clé et sa configuration.
2. Deux modèles différents peuvent être sélectionnés dynamiquement.
3. Les traces prouvent quel modèle réalise réellement chaque inférence.
4. Le prompt et les instructions de l’agent restent appliqués.
5. Les outils et les sous-agents restent utilisables.
6. Le comportement des spécialistes est identifié et maîtrisable.
7. Deux conversations concurrentes ne présentent aucune interférence.
8. Aucune ressource extérieure au projet de test n’est affectée.

Si un seul de ces points essentiels échoue, préciser exactement lequel et pourquoi.

9. Nettoyage

Après les tests :

* Désactiver les deux Routing Rules.
* Exporter les informations utiles et références de traces.
* Supprimer uniquement les règles créées pour ce POC.
* Supprimer les ressources temporaires créées pour ce POC, si leur propriété est certaine.
* Vérifier qu’aucune règle temporaire ne reste active.
* Vérifier qu’aucune règle existante n’a été modifiée.

Prévoir ce nettoyage même si un test échoue.

Ne jamais supprimer une ressource préexistante ou dont l’appartenance au POC est incertaine.

10. Livrable attendu

À la fin de l’expérimentation, produire un rapport comprenant :

A. Faisabilité

Conclusion explicite :

* OUI : le scénario A fonctionne.
* NON : les Routing Rules ne permettent pas le comportement souhaité.
* PARTIEL : elles permettent une partie du comportement, avec des limitations.
* INDÉTERMINÉ : les preuves disponibles sont insuffisantes.

B. Résultats

Présenter les tests réalisés, les résultats observés, les références de traces, les modèles effectivement utilisés et les éventuelles erreurs.

C. Comportement des sous-agents

Expliquer précisément comment les règles affectent Jira Specialist et GitLab Specialist.

D. Limites

Distinguer clairement :

* Les comportements démontrés expérimentalement.
* Les comportements documentés.
* Les hypothèses qui restent non vérifiées.

E. Comparaison architecturale

Comparer les deux stratégies :

1. Un orchestrateur personnel utilisant les Routing Rules.
2. Plusieurs orchestrateurs personnels, chacun configuré avec son propre modèle.

Évaluer :

* La complexité du provisioning.
* Le nombre de ressources Orq.ai.
* Les impacts sur les sous-agents.
* Les autorisations LMC.
* La continuité conversationnelle.
* La maintenance.
* L’observabilité.
* La robustesse.
* Les coûts potentiels.

F. Recommandation

Recommander l’architecture la plus adaptée à Engineering Companion sur la base des résultats réels.

Ne pas privilégier artificiellement les Routing Rules si elles ne répondent pas au besoin.

11. Consignes finales

Ce travail est un POC technique isolé, pas une migration d’architecture.

Ne pas modifier les applications existantes.

Ne pas modifier leur provisioning.

Ne pas implémenter la sélection dynamique dans le chat.

Ne pas implémenter les checkpoints pour le moment.

Ne pas annoncer un succès uniquement parce qu’une Routing Rule a sélectionné GPT ou Mistral : il faut impérativement prouver que le comportement agentique est conservé.

Tu es autorisé à créer, activer puis supprimer les ressources temporaires nécessaires dans un projet de test explicitement isolé. Aucune modification hors de ce périmètre n’est autorisée.

À la fin, fournis les résultats, les preuves et une recommandation architecturale.

L’objectif est de pouvoir décider définitivement si notre Engineering Companion doit utiliser les Routing Rules ou conserver des agents distincts par modèle.