Je valide C7b sur son périmètre de qualification locale.

Notre nouvelle référence applicative est désormais :

* 629 cas JUnit.
* 602 réussites.
* 27 échecs historiques strictement identiques.
* 90 tests ciblés réussis.
* 49 tests PostgreSQL ciblés réussis.
* 102 tests PostgreSQL cumulés réussis.
* 5 tests SpiceDB réussis.
* 155 tests réussis sans SDK Temporal, avec un test SDK ignoré.
* 14/14 historiques Temporal C4-Q et C6-Q rejoués avec succès.
* PostgreSQL 18.4.
* Head Alembic : 0004_orq_saga_outbox.
* Catalogue applicatif inchangé : 32 tables, 17 triggers, 4 fonctions, 85 index et 390 contraintes.

Nous allons maintenant réaliser C7b-Q — Targeted Real Qualification of Active Workflow Recovery.

Cette qualification doit rester courte, ciblée et proportionnée.

1. Espace de travail

Utilise comme référence applicative :

/workspace/LEA_Workspace/lcc-c7b-active-workflow-recovery

Crée un espace de qualification distinct :

/workspace/LEA_Workspace/lcc-c7bq-active-workflow-recovery-qualification

Préserve intégralement les espaces précédents.

C7b-Q constitue une qualification, pas une nouvelle base applicative.

Ne copie aucun credential, fichier .env réel, historique sensible, environnement virtuel ou métadonnée Git.

2. Réutilisation de l’existant

Relis notamment :

* C7B_ACTIVE_WORKFLOW_RECOVERY.md
* C7A_ORQ_RECOVERY_AND_REPAIR_ANALYSIS.md
* C4Q_TEMPORAL_REAL_QUALIFICATION.md
* C6Q_TEMPORAL_REAL_QUALIFICATION.md
* LMC_SAGA_REPAIR_CONVERGENCE_ANALYSIS.md
* LMC_WORKSPACE_INDEX.md
* La roadmap canonique.

Réutilise autant que possible les harnesses de qualification C4-Q et C6-Q.

Ne reconstruis pas une nouvelle infrastructure de test si les composants existants permettent cette qualification.

Ne recommence pas les recherches réseau, Kubernetes, SDK ou Artifactory déjà réalisées.

3. Objectif principal

Reproduire réellement le scénario de redémarrage qui avait échoué pendant C4-Q.

Lors de C4-Q :

* record_confirmed_result() avait commité LOCAL_PERSISTENCE.
* Le Worker avait été interrompu avant l’acquittement Temporal.
* Le Workflow avait produit ACTIVITY_OUTCOME_LOST.
* Le Store avait correctement refusé d’écraser la preuve persistée.
* Le Workflow avait terminé FAILED.
* Aucun deuxième POST n’avait été effectué.

C7b introduit désormais :

* L’Activity lmc.orq_project.recover_local_persistence.v2.
* Le mécanisme workflow.patched(“orq-v2-active-local-persistence-recovery-v1”).
* Une récupération exclusivement locale.
* Une récupération bornée à trois essais.
* La réutilisation des CAS persist_mapping() et record_outcome().

L’objectif de C7b-Q est de démontrer que cette correction fonctionne réellement sur Temporal.

4. Infrastructure et isolation

Utilise exclusivement :

* Temporal préproduction existant et autorisé.
* Le SDK Temporal 1.18.2.
* Une Task Queue de qualification unique.
* PostgreSQL 18.4 temporaire et isolé.
* Un Worker local C7b.
* Le véritable service C5 et Dispatcher C6 lorsque cela est pertinent.
* Un gateway Orq obligatoirement factice.
* Des projets et acteurs entièrement synthétiques.
* Un compteur durable des POST simulés.

Réutilise les protections contre les appels Orq réels déjà qualifiées pendant C4-Q et C6-Q.

Aucun fallback vers le gateway réel ne doit être possible.

Vérifie de nouveau le cluster, le namespace, les autorisations, la connexion et l’absence de pollers inattendus.

Je réaliserai personnellement les éventuelles commandes Kubernetes et le tunnel depuis le DevEnv.

Communique-moi uniquement les commandes nécessaires en réutilisant les procédures précédemment qualifiées.

5. Scénario nominal de contrôle

Exécute un scénario nominal court avec la version C7b.

Vérifie :

* Workflow COMPLETED.
* Saga SUCCEEDED.
* Outbox STARTED.
* Mapping exact.
* Un seul POST simulé.
* Absence de déclenchement inutile de l’Activity de récupération.

Cela permettra de démontrer que la nouvelle logique n’introduit pas de récupération superflue dans le parcours normal.

6. Scénario principal : redémarrage du Worker

Utilise une opération distincte.

Reproduis aussi précisément que possible la fenêtre d’interruption C4-Q :

1. Le Workflow démarre normalement.
2. Le gateway factice effectue la mutation simulée.
3. L’identité distante est confirmée.
4. record_confirmed_result() persiste et commite la preuve LOCAL_PERSISTENCE.
5. Une session PostgreSQL indépendante vérifie que le commit est effectif.
6. Le processus Worker de qualification est réellement interrompu avant l’acquittement de l’Activity auprès de Temporal.
7. Un nouveau processus Worker est démarré sur la même Task Queue.
8. Le Workflow existant poursuit son exécution.
9. La nouvelle Activity de récupération locale intervient.
10. Le mapping est persisté ou retrouvé.
11. ProjectOrqSaga est correctement finalisée.

Ne modifie pas le code applicatif pour introduire les points d’interruption.

Utilise les mécanismes de synchronisation et d’injection du harness.

Vérifie que l’interruption intervient réellement après le commit PostgreSQL et avant l’acquittement Temporal.

Si cette fenêtre exacte n’a pas été atteinte, classe le résultat comme partiel.

7. Critères de réussite obligatoires

Pour le scénario principal :

* Même opération_ref.
* Même génération.
* Même Workflow ID.
* Même exécution Temporal reprise.
* Nouveau PID Worker.
* Exactement un POST simulé au total.
* Aucune nouvelle création distante.
* Aucun DELETE.
* Aucun accès au gateway Orq pendant la récupération locale.
* Preuves persistées conservées.
* Mapping exact et cohérent.
* Saga SUCCEEDED.
* Workflow COMPLETED.
* Présence de l’Activity recover_local_persistence.v2 dans l’historique Temporal.

Vérifie également que le nombre de tentatives de récupération respecte le budget configuré.

Ne confonds pas la réussite de la Saga avec la réussite technique du Workflow : les deux doivent être vérifiées séparément.

8. Contrôles complémentaires

Vérifie la compatibilité du patch Temporal et la préservation du déterminisme.

Rejoue hors ligne les nouveaux historiques lorsque leur conservation est autorisée et sûre.

Conserve les résultats des 14 historiques précédemment rejoués.

Ne prétends pas avoir rejoué l’ancien historique de redémarrage C4-Q, puisqu’il n’avait pas été conservé.

Les scénarios UNKNOWN_OUTCOME, candidat non confirmé, conflit de mapping et épuisement du budget restent couverts par les tests locaux C7b.

Ne multiplie pas inutilement les exécutions distantes pour répéter ces tests.

9. Périmètre de qualification

Limite normalement cette qualification à deux exécutions Temporal :

* Un scénario nominal de contrôle.
* Un scénario de redémarrage réel.

Si une exécution supplémentaire est nécessaire à cause d’une fenêtre d’interruption manquée, documente précisément sa justification et demande mon accord avant de la lancer.

Ne recommence pas la qualification complète C6-Q.

Ne développe pas encore C7c, C7d, l’API ou le frontend.

Si une anomalie applicative est identifiée, documente-la et propose une correction ciblée avant de modifier C7b.

10. Contraintes impératives

* Aucun appel réel Orq.
* Aucun déploiement LMC.
* Aucune opération Git ou GitLab.
* Aucune modification Kubernetes.
* Aucun serveur Temporal local.
* Aucune installation de Temporal CLI.
* Aucune modification des ressources Docker existantes.
* Aucune modification de Docker Compose ou des Dockerfiles.
* Aucune modification des migrations ou du pont Alembic.
* Aucune modification des scripts 01/02/03.
* Aucune modification des configurations VS Code.
* Aucun changement de la procédure habituelle de lancement du LMC.
* Préservation intégrale des espaces précédents.

Les seules écritures distantes autorisées sont les exécutions Temporal de qualification explicitement prévues, après vérification des autorisations.

11. Nettoyage et non-régression

À la fin :

* Arrête les processus de qualification.
* Vérifie les états finaux des Workflows.
* Vérifie l’absence de pollers de qualification restants.
* Supprime uniquement les ressources Docker temporaires créées.
* Supprime les artefacts sensibles.
* Préserve les preuves assainies.
* Donne-moi les instructions pour arrêter le tunnel DevEnv.

Documente les historiques distants qui subsistent jusqu’à leur expiration naturelle.

Vérifie que le code applicatif C7b reste inchangé.

Exécute les tests pertinents de non-régression et la suite complète si du code de test permanent est ajouté.

Notre référence reste 629 cas JUnit, dont 602 réussites et 27 échecs historiques identiques.

12. Documentation et restitution

Crée :

documentation/C7BQ_ACTIVE_WORKFLOW_RECOVERY_QUALIFICATION.md

Rédige la documentation technique en anglais et restitue-moi les résultats en français.

Présente notamment :

* Les scénarios réellement exécutés.
* Le point d’interruption exact.
* Les preuves PostgreSQL.
* Les anciens et nouveaux PID.
* Les états finaux Temporal, Saga et outbox.
* Le nombre de POST simulés.
* Les Activities réellement observées.
* Les résultats des replays.
* Les limitations restantes.
* Une comparaison directe avec C4-Q.

Mets à jour l’index canonique et la roadmap.

Conserve explicitement dans la roadmap :

* C7c : récupération locale minimale après fermeture prouvée du Workflow.
* C7d : lookup résiduel et Repair existant.
* Endpoint HTTP de provisioning au-dessus de C5.
* Projection Orq dans operation-progress.
* Suivi par operation_ref.
* Permissions de lecture existantes.
* C8 : intégration frontend.
* Qualification du lancement standard et du pont Alembic.

Le Repair reste un outil résiduel de debug pour le développeur. Nous ne souhaitons pas développer une plateforme de support complexe.

Notre priorité demeure la parité fonctionnelle complète avec le Mock LMC depuis le véritable LMC local.

Tu peux commencer C7b-Q dans ce périmètre.

Ne commence pas C7c sans mon accord.