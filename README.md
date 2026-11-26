Je valide les conclusions de l’analyse documentaire C7a ainsi que la nouvelle orientation concernant le Repair.

Notre priorité est désormais la récupération automatique sécurisée, avec une intégration minimale au mécanisme de debug et de support existant.

Attention : C7a n’a finalement introduit aucun code applicatif. L’endpoint de provisioning, le suivi des opérations Orq et l’intégration à operation-progress restent donc à implémenter. Assure-toi qu’ils figurent explicitement dans la roadmap avant C8.

Nous pouvons commencer C7b — Automatic LOCAL_PERSISTENCE Recovery During Active Workflow.

1. Espace de travail

Utilise comme base applicative cumulative :

/workspace/LEA_Workspace/lcc-c6-temporal-outbox-dispatcher

Crée un nouvel espace isolé :

/workspace/LEA_Workspace/lcc-c7b-active-workflow-recovery

C7a constitue une référence documentaire, et non une nouvelle base applicative.

Préserve intégralement tous les espaces précédents.

2. Documentation et références

Relis notamment :

* C7A_ORQ_RECOVERY_AND_REPAIR_ANALYSIS.md
* LMC_SAGA_REPAIR_CONVERGENCE_ANALYSIS.md
* C3C_PROVISIONING_WORKFLOW_V2.md
* C3D_POSTGRESQL_STATE_STORE.md
* C3E_PROVISIONING_ACTIVITIES_V2.md
* C4Q_TEMPORAL_REAL_QUALIFICATION.md
* C6_TEMPORAL_OUTBOX_DISPATCHER.md
* C6Q_TEMPORAL_REAL_QUALIFICATION.md
* LMC_WORKSPACE_INDEX.md
* La roadmap canonique.

Inspecte les preuves réellement conservées lors de C4-Q.

Identifie précisément la cause du Workflow FAILED après redémarrage, malgré la conservation de LOCAL_PERSISTENCE et l’absence de deuxième POST.

Ne suppose pas que la cause est uniquement liée à la configuration des retries Temporal.

3. Objectif de C7b

Permettre au Workflow actif de récupérer automatiquement les échecs de persistance locale lorsque les preuves nécessaires existent déjà.

L’objectif est notamment d’éviter qu’une ressource Orq correctement créée et identifiée conduise inutilement à une opération métier en échec.

La récupération doit être intégrée à la chaîne existante.

Ne développe pas un second orchestrateur, un système de support parallèle ou un nouveau moteur de Saga.

4. Séparation des responsabilités

Conserve les responsabilités suivantes :

* Temporal orchestre l’exécution et les reprises contrôlées.
* Les Activities exécutent les opérations métier.
* Le Store PostgreSQL contrôle les transitions durables et les CAS.
* ProjectOrqSaga représente l’état métier autoritatif.
* orq_project_mappings représente l’identité distante autoritative.
* L’outbox représente la livraison à Temporal.
* Le Repair existant reste un outil résiduel de diagnostic et d’intervention manuelle.

Ne déplace pas vers le Repair une récupération qui peut être effectuée automatiquement et de manière sûre pendant le Workflow.

5. Scénarios à récupérer

Inspecte les possibilités de convergence automatique pour :

* Identité Orq confirmée mais mapping non persisté.
* Mapping persisté mais acquittement perdu.
* Mapping confirmé mais finalisation incomplète.
* Perte d’acquittement après persistance du résultat distant.
* Erreur PostgreSQL transitoire.
* Interruption du Worker pendant une étape exclusivement locale.
* Redélivrance d’une Activity de persistance ou de finalisation.

Pour chaque scénario, identifie les preuves durables nécessaires et les préconditions exactes.

Une récupération ne doit être effectuée que lorsque l’identité et la cohérence de l’opération peuvent être établies.

Distingue les opérations encore actives des opérations déjà terminales. Ne contourne pas les contraintes d’immuabilité ou les CAS existants.

6. Préservation des protections contre les doublons

Toutes les garanties précédemment développées restent impératives :

* Réservation durable avant mutation.
* mutation_attempted irréversible.
* Aucun verrou SQL pendant les appels réseau.
* Aucun retry aveugle d’une mutation Orq.
* Aucun deuxième POST après une mutation potentiellement effectuée.
* Aucun DELETE automatique.
* Aucun changement arbitraire de génération.
* Aucune nouvelle Saga pour masquer une opération existante.
* Aucun écrasement des preuves persistées.
* Aucun contournement des protections CAS.

Ne confonds jamais une identité candidate avec une identité distante confirmée.

Une erreur PostgreSQL après création Orq ne doit pas provoquer une nouvelle création Orq.

7. Utilisation des retries Temporal

Inspecte les politiques de retry actuelles du Workflow V2 et de ses Activities.

Identifie les étapes purement locales pouvant bénéficier de retries bornés et idempotents.

Privilégie les mécanismes natifs de Temporal lorsque cela permet une récupération plus simple et plus robuste.

Cependant :

* Ne rends pas automatiquement retryable l’Activity mutative de réconciliation.
* Ne modifie pas globalement maximum_attempts sans analyser les conséquences.
* Ne relance pas le Workflow complet pour corriger une erreur de persistance.
* Ne répète pas une étape distante déjà effectuée.
* Ne crée pas de boucle de récupération infinie.

Si nécessaire, sépare explicitement la récupération locale de la logique de mutation distante.

Réutilise au maximum les méthodes du Store C3d.

Justifie chaque changement de politique de retry.

8. Préservation du déterminisme Temporal

Toute modification du Workflow V2 doit être évaluée au regard de sa compatibilité avec les historiques existants.

Utilise les historiques sûrs conservés pendant C4-Q et C6-Q.

Vérifie si les modifications nécessitent un mécanisme de versioning ou de patching Temporal.

Ne modifie pas silencieusement les contrats ou le comportement déterministe du Workflow.

Exécute les replays hors ligne pertinents.

Si une incompatibilité subsiste, documente-la et propose une stratégie de compatibilité avant toute qualification distante.

Ne prétends pas avoir rejoué l’historique du redémarrage C4-Q : celui-ci n’a pas été conservé pour des raisons de sécurité.

9. Résultat attendu

Lorsque les preuves durables sont suffisantes et que les conditions métier restent valides, le Workflow doit pouvoir reprendre la persistance locale et terminer correctement l’opération.

Dans le scénario cible :

* Une seule mutation Orq a été effectuée.
* L’identité distante confirmée est conservée.
* Le Worker rencontre une erreur de persistance ou une interruption.
* Le Workflow reprend les étapes locales autorisées.
* Le mapping est correctement persisté ou retrouvé.
* ProjectOrqSaga est finalisée conformément aux preuves.
* Aucun deuxième POST n’est effectué.

Lorsque les preuves sont insuffisantes, le système doit conserver une classification honnête et exploitable.

Ne transforme pas artificiellement une situation incertaine en SUCCEEDED.

10. Qualification locale

Utilise PostgreSQL 18.4 réel et isolé ainsi qu’un gateway Orq factice.

Teste notamment :

* Récupération après erreur locale transitoire.
* Récupération après persistance de l’identité distante confirmée.
* Mapping déjà commité.
* Perte d’acquittement après commit.
* Finalisation idempotente.
* Redélivrance d’une Activity.
* Deux tentatives concurrentes de récupération.
* Conflit de mapping.
* Snapshot devenu obsolète.
* Opération terminale.
* Identité uniquement candidate.
* UNKNOWN_OUTCOME.
* Épuisement du budget de récupération.
* Absence de deuxième POST.
* Absence de DELETE.
* Préservation de toutes les preuves.
* Compatibilité avec les contrats V2.
* Replay hors ligne des historiques disponibles.

Utilise de véritables transactions PostgreSQL et plusieurs sessions indépendantes lorsque pertinent.

Distingue les erreurs injectées des véritables interruptions de processus.

11. Qualification réelle ultérieure

Prépare un protocole court et ciblé permettant de rejouer le scénario problématique de C4-Q avec :

* Temporal préproduction existant.
* Worker local.
* PostgreSQL temporaire.
* Gateway Orq factice.
* Compteur durable de POST simulés.
* Interruption contrôlée du Worker.
* Vérification du résultat final Temporal et de ProjectOrqSaga.

Notre objectif est de démontrer une amélioration réelle par rapport à C4-Q, et pas uniquement une augmentation du nombre de tests unitaires.

Réutilise les harnesses existants lorsque possible.

Ne recommence pas toute la qualification C6-Q.

N’exécute pas encore ce protocole distant sans mon accord.

12. Périmètre strict

C7b doit uniquement concerner la récupération pendant un Workflow actif.

Ne commence pas :

* C7c : récupération locale après fermeture prouvée du Workflow.
* C7d : lookup résiduel et intégration minimale au Repair.
* L’intégration API de provisioning et operation-progress.
* C8 : intégration frontend.
* Les mécanismes privilégiés de résolution manuelle.
* Le provisioning des autres ressources Orq.

N’introduis aucun nouveau service permanent de surveillance ou de récupération sans nécessité démontrée.

Nous souhaitons conserver une architecture simple et proportionnée.

13. Non-régression

Notre référence applicative reste C6 :

* 607 cas JUnit.
* 580 réussites JUnit.
* 551 tests pytest réussis.
* 29 sous-tests réussis.
* 27 échecs historiques strictement identiques.
* PostgreSQL 18.4.
* Head Alembic : 0004_orq_saga_outbox.
* 32 tables, 17 triggers, 4 fonctions, 85 index et 390 contraintes.

Notre référence de qualification réelle C6-Q comprend également :

* 11 Workflows Temporal réels COMPLETED.
* 11 replays hors ligne réussis.
* 23 tests du harness réussis.
* Aucun double start ou double POST observé.

Exécute les tests ciblés, les tests d’intégration PostgreSQL, les tests cumulés, la suite complète, la compilation Python et pip check.

Compare les échecs historiques avec C6.

Vérifie également le fonctionnement sans SDK Temporal installé.

Aucune nouvelle migration n’est attendue.

14. Contraintes impératives

* Aucune opération Git ou GitLab.
* Aucun déploiement.
* Aucun appel distant Temporal ou Orq pendant C7b.
* Aucun serveur Temporal local.
* Aucune installation de Temporal CLI.
* Aucune modification Kubernetes.
* Aucune modification des ressources Docker existantes.
* Seules les ressources temporaires isolées nécessaires aux tests sont autorisées.
* Aucune modification de Docker Compose ou des Dockerfiles.
* Aucune modification des scripts 01/02/03.
* Aucune modification des configurations VS Code.
* Aucune modification du pont Alembic.
* Aucun changement de la procédure habituelle de lancement du LMC.
* Préservation intégrale de tous les espaces précédents.

15. Documentation et restitution

Crée une documentation technique en anglais :

documentation/C7B_ACTIVE_WORKFLOW_RECOVERY.md

Mets à jour l’index canonique et la roadmap.

Pour chaque fichier ou symbole modifié, documente le comportement avant/après, la justification du changement et les alternatives envisagées.

Présente-moi en français :

* La cause précise de la limitation C4-Q.
* La solution retenue.
* Les changements apportés au Workflow, aux Activities et au Store.
* Les scénarios automatiquement récupérables.
* Les scénarios restant non récupérables.
* Les garanties démontrées.
* Les résultats des tests et des replays.
* Les résultats de non-régression.
* Le protocole court de qualification réelle.
* Le périmètre minimal nécessaire pour C7c et C7d.

Actualise explicitement la roadmap pour conserver l’implémentation de l’API de provisioning et du suivi des opérations avant C8.

Notre objectif principal reste la parité fonctionnelle complète avec le Mock LMC depuis le véritable LMC lancé localement.

Le Repair doit offrir au développeur la même expérience de debug et d’intervention manuelle que pour les autres composants, sans devenir un chantier disproportionné.

Tu peux commencer C7b.

Ne commence pas C7c sans mon accord.