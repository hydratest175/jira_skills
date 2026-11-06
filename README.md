Mission 1 — Stabilisation technique d’Engineering Companion

Contexte

Nous avons intégré Engineering Companion à notre Mock LMC.

Le système permet désormais de récupérer les projets, les modèles autorisés, les Identities et les orchestrateurs personnels provisionnés dans Orq.ai.

Cependant, mes premiers tests manuels ont révélé plusieurs dysfonctionnements.

Je souhaite que tu identifies leurs causes exactes et que tu les corriges avant de poursuivre le développement.

Cette mission concerne exclusivement les bugs techniques. Ne réalise pas encore de refonte UX globale.

1. Corriger l’erreur Orq.ai HTTP 403

Lorsque j’envoie un message à un orchestrateur personnel provisionné par le Mock LMC, j’obtiens :

HTTP 403: Project out of scope for this API key

Le problème apparaît sur plusieurs projets, indépendamment du modèle sélectionné.

Analyse attendue

Examine la chaîne complète d’exécution :

* Authentification Keycloak.
* Récupération du projet LMC.
* Résolution du projet Orq.ai.
* Résolution de l’orchestrateur personnel.
* Récupération de sa functional key.
* Sélection des credentials Orq.ai.
* Construction de la requête vers Orq.ai.

Identifie précisément quelle clé API est actuellement utilisée lors de l’exécution et pourquoi elle ne permet pas d’accéder au projet concerné.

Examine la configuration Docker, les variables d’environnement et les mécanismes existants de gestion des secrets.

Point architectural important

Le Mock LMC peut provisionner plusieurs projets Orq.ai.

Engineering Companion doit pouvoir exécuter les agents présents dans les projets auxquels les utilisateurs sont autorisés.

Nous devons donc disposer d’une stratégie de credentials compatible avec plusieurs projets.

Étudie les solutions adaptées, notamment :

* Des clés d’exécution spécifiques aux projets.
* Une clé de service ayant explicitement accès aux projets nécessaires, si la plateforme le permet.

Privilégie une solution respectant le principe du moindre privilège.

La Management Key doit rester réservée aux opérations d’administration et de provisioning. Ne l’utilise pas pour exécuter les agents.

Correction attendue

Identifie la cause réelle avant d’implémenter une correction.

Réutilise les mécanismes de gestion des secrets déjà présents lorsque c’est possible.

Si des clés doivent être créées ou configurées manuellement dans Orq Studio, explique-moi précisément la procédure.

Ne crée pas automatiquement de nouvelles clés API sans mon accord.

Ne contourne aucun contrôle d’autorisation.

Ne modifie pas les orchestrateurs, leurs prompts ou leurs modèles.

Diagnostic

Améliore les logs backend afin de distinguer clairement :

* Une clé API absente.
* Une clé invalide.
* Une clé non autorisée sur le projet Orq.ai.
* Un agent introuvable.
* Une configuration non synchronisée.
* Une erreur réseau ou une indisponibilité d’Orq.ai.

N’affiche jamais les credentials dans les logs ou les réponses API.

L’utilisateur doit recevoir un message compréhensible plutôt qu’une erreur technique brute.

2. Corriger les dysfonctionnements des conversations

Plusieurs opérations ne fonctionnent pas correctement.

Renommage

Il arrive que je ne puisse pas renommer une conversation.

Analyse le frontend et le backend pour identifier pourquoi.

Vérifie :

* Le déclenchement de l’action depuis l’interface.
* Les requêtes API.
* Les contrôles d’autorisation.
* La persistance des modifications.
* L’actualisation de l’interface après renommage.

Corrige les dysfonctionnements.

Le renommage ne doit jamais modifier les messages, le projet ou l’orchestrateur d’une conversation.

Affectation d’une conversation à un projet

Lorsqu’une conversation ne possède aucun projet et que j’essaie de l’affecter à un projet existant, l’opération semble parfois ne rien faire.

Analyse précisément ce comportement.

Vérifie si le blocage provient :

* Du frontend.
* Des endpoints backend.
* Des contrôles d’autorisation.
* De la persistance.
* Des modifications récentes apportées au système de conversations.

Corrige les dysfonctionnements identifiés.

Pour cette première mission, conserve cette fonctionnalité afin de pouvoir récupérer les anciennes conversations sans projet.

L’affectation doit être autorisée uniquement si l’utilisateur possède les permissions nécessaires sur le projet de destination.

Une conversation déjà rattachée à un projet ne doit pas pouvoir être déplacée librement vers un autre projet : notre future architecture prévoit une appartenance stable au projet.

Si une opération échoue, affiche une erreur explicite.

Intégrité des conversations

Vérifie que les corrections ne provoquent pas :

* De perte de messages.
* De duplication de conversations.
* De modification involontaire du projet.
* De changement d’orchestrateur non souhaité.
* De mélange de données entre utilisateurs ou projets.

Ne supprime aucune conversation existante.

3. Préparer la future navigation par projet

Nous allons prochainement modifier l’organisation des conversations dans Engineering Companion.

La future logique sera :

Sélection du projet → Création d’une conversation dans ce projet → Exécution de l’orchestrateur personnel.

Une conversation devra appartenir à un projet dès sa création.

Pour cette première mission, ne développe pas cette nouvelle navigation.

Cependant, identifie les composants et endpoints qui devront évoluer.

Signale les dépendances éventuelles au fonctionnement actuel des conversations sans projet.

4. Contraintes

* Ne modifie pas le provisioning du Mock LMC.
* Ne modifie pas les agents Orq.ai existants.
* Ne modifie pas les prompts.
* Ne modifie pas les connecteurs MCP.
* Ne développe pas les Routing Rules.
* Ne modifie pas la sélection dynamique des modèles.
* Ne supprime aucune donnée existante.
* Ne réalise pas de refonte globale de l’interface.
* Ne compromets pas l’authentification Keycloak.

Réutilise les services existants autant que possible.

N’introduis pas de nouvelle infrastructure sans nécessité.

5. Vérifications

Effectue les vérifications locales nécessaires.

Tu peux utiliser des mocks pour tester la résolution des credentials et les erreurs HTTP.

Vérifie également les opérations de renommage et d’affectation des conversations.

Ne déclenche pas automatiquement de conversations réelles vers Orq.ai ou d’appels MCP.

Je réaliserai moi-même les tests fonctionnels et vérifierai les traces dans Orq Studio.

6. Résultat attendu

À la fin de cette mission, je veux :

1. Comprendre pourquoi les appels Orq.ai renvoyaient une erreur HTTP 403.
2. Disposer d’une solution correcte pour exécuter les agents des projets autorisés.
3. Pouvoir renommer mes conversations.
4. Pouvoir rattacher les anciennes conversations sans projet à un projet autorisé.
5. Obtenir des messages d’erreur compréhensibles lorsqu’une opération échoue.
6. Connaître les fichiers modifiés et les éventuelles interventions manuelles nécessaires.

Relance Engineering Companion en local après les corrections.

Fournis-moi une procédure de validation manuelle simple.

Arrête-toi ensuite. Je veux vérifier que le chat fonctionne réellement avant d’entamer la refonte UX.