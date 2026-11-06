Mission — Audit technique de la gestion du contexte conversationnel

Contexte

Nous avons terminé et validé la refonte Project-first d’Engineering Companion.

Les conversations sont désormais créées directement dans un projet autorisé.

L’exécution des orchestrateurs personnels provisionnés depuis le Mock LMC fonctionne avec Orq.ai.

Les traces d’exécution sont opérationnelles.

Nous souhaitons maintenant préparer la prochaine fonctionnalité : le changement dynamique de modèle pendant une conversation.

Cependant, avant toute implémentation, je souhaite réaliser un audit approfondi du fonctionnement actuel de l’historique conversationnel.

Cette mission est exclusivement une analyse. Ne modifie aucun code.

1. Analyser le fonctionnement actuel du chat

Étudie la chaîne complète :

Frontend → Backend Engineering Companion → Historique persistant → Orq.ai → Réponse.

Je souhaite comprendre :

* Comment les messages sont stockés.
* Comment ils sont récupérés.
* Comment le contexte est construit avant chaque appel à Orq.ai.
* Comment previous_response_id est utilisé.
* Comment l’orchestrateur est associé à une conversation.
* Comment les messages précédents sont transmis au modèle.
* Comment les résultats des appels aux outils et sous-agents sont conservés.
* Ce qui se passe lorsqu’une conversation est fermée puis rouverte.

Distingue clairement l’historique affiché à l’utilisateur du contexte réellement transmis à l’agent.

2. Étudier un changement de modèle

Imaginons le scénario suivant :

Un utilisateur travaille dans le projet Alpha.

Il commence une conversation avec un orchestrateur utilisant Mistral.

Pendant cette conversation, il échange plusieurs messages et obtient des informations depuis Jira et GitLab.

Il sélectionne ensuite GPT-5.6.

Le système doit utiliser un autre orchestrateur personnel, provisionné dans le même projet pour ce modèle.

Je veux savoir précisément ce qui se passerait aujourd’hui.

Analyse notamment :

* La conservation des messages utilisateur.
* La conservation des réponses précédentes.
* La récupération des informations Jira/GitLab.
* La réutilisation éventuelle de previous_response_id.
* La reconstruction du contexte lorsqu’on change d’orchestrateur.
* Les limitations liées aux formats de messages et aux appels d’outils.
* Les risques de perte de contexte, de duplication ou d’incompatibilité.

Ne suppose pas que la présence de l’historique en base garantit qu’il est correctement transmis au nouvel orchestrateur.

3. Étudier les stratégies possibles

Compare les stratégies techniques envisageables pour assurer la continuité du contexte.

Nous souhaitons conserver notre architecture actuelle :

* Un projet Orq.ai par projet LMC.
* Des orchestrateurs personnels persistants.
* Des agents déjà provisionnés pour les modèles autorisés.
* Aucune modification dynamique de la configuration des agents lors des conversations.
* Une isolation stricte entre projets et utilisateurs.

Étudie notamment la possibilité de sélectionner un orchestrateur différent selon le modèle demandé, puis de reconstruire son contexte depuis l’historique persistant.

Examine également les possibilités et limites de previous_response_id.

Le changement de modèle ne doit pas nécessiter de recréer les agents Orq.ai.

4. Prendre en compte les conversations longues

Analyse les implications pour des conversations contenant beaucoup de messages.

Étudie :

* Les limites de contexte des modèles.
* Le coût et la latence de la retransmission de l’historique.
* Les stratégies de limitation ou de résumé.
* La préservation des informations importantes.
* La conservation des références aux données Jira/GitLab.
* Le risque de perdre des éléments nécessaires à la compréhension de la conversation.

Distingue les fonctionnalités déjà présentes des évolutions envisageables.

5. Vérifier l’isolation des données

Le changement de modèle ne doit jamais entraîner de changement de projet.

Le contexte doit rester rattaché à la conversation existante.

Vérifie que les mécanismes actuels permettent de garantir :

* Le maintien du même threadId.
* Le maintien du même projectId.
* Le respect des autorisations de l’utilisateur.
* L’utilisation de l’orchestrateur personnel correspondant au modèle autorisé.
* L’absence de transmission d’historique provenant d’un autre projet ou utilisateur.

Les vérifications doivent être réalisées côté backend.

6. Livrable attendu

Je souhaite un rapport technique structuré comprenant :

1. Architecture actuelle : comment l’historique conversationnel fonctionne réellement.
2. Analyse de previous_response_id : utilisation, stockage et limites.
3. Changement d’orchestrateur : conséquences exactes sur le contexte.
4. Comparaison des solutions possibles : avantages, inconvénients et complexité.
5. Architecture recommandée : solution la plus adaptée à notre POC.
6. Plan d’implémentation : étapes techniques nécessaires, sans les réaliser.
7. Risques et tests : points à surveiller lors du futur développement.

Appuie tes conclusions sur les fichiers et fonctions réels de la codebase.

Distingue les comportements confirmés des hypothèses.

Contraintes

* Ne modifie aucun fichier applicatif.
* Ne modifie pas le Mock LMC.
* Ne modifie aucun agent Orq.ai.
* N’implémente pas les Routing Rules.
* Ne modifie pas les mécanismes actuels du chat.
* Ne déclenche aucun appel réel vers Orq.ai ou MCP.
* Ne supprime aucune conversation.

À la fin, fournis ton rapport et arrête-toi.

Nous analyserons ensemble tes recommandations avant de décider de l’implémentation.