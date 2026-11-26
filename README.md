Je valide C7b-Q avec la classification ACCEPTED.

La correction de la limitation C4-Q est désormais réellement qualifiée sur Temporal préproduction.

Résultats acquis :

* Deux Workflows Temporal réels exécutés, tous COMPLETED.
* Scénario nominal réussi.
* Redémarrage réel du Worker réussi.
* Même Workflow et même Run repris.
* Commit LOCAL_PERSISTENCE vérifié depuis une session PostgreSQL indépendante.
* Activity recover_local_persistence.v2 réussie dès le premier essai.
* Saga SUCCEEDED et mapping exact.
* Un seul POST simulé par scénario.
* Aucun appel au gateway Orq après la barrière de redémarrage.
* Aucun DELETE.
* 2/2 nouveaux historiques rejoués.
* 14/14 anciens historiques C4-Q et C6-Q rejoués.
* 20 tests harness réussis.
* 110 tests ciblés cumulés réussis.
* 629 cas JUnit, 602 réussites et 27 échecs historiques identiques.
* Backend C7b-Q byte-identique à C7b.

Nous pouvons commencer C7c — Minimal Local Recovery After Proven Workflow Closure.

1. Espace de travail

Utilise comme base applicative cumulative :

/workspace/LEA_Workspace/lcc-c7b-active-workflow-recovery

Crée un nouvel espace isolé :

/workspace/LEA_Workspace/lcc-c7c-closed-workflow-recovery

C7b-Q reste une référence de qualification et non une nouvelle base applicative.

Préserve intégralement tous les espaces précédents.

2. Documentation et références

Relis notamment :

* C7A_ORQ_RECOVERY_AND_REPAIR_ANALYSIS.md
* C7B_ACTIVE_WORKFLOW_RECOVERY.md
* C7BQ_ACTIVE_WORKFLOW_RECOVERY_QUALIFICATION.md
* C3D_POSTGRESQL_STATE_STORE.md
* C3E_PROVISIONING_ACTIVITIES_V2.md
* C4Q_TEMPORAL_REAL_QUALIFICATION.md
* C6Q_TEMPORAL_REAL_QUALIFICATION.md
* LMC_SAGA_REPAIR_CONVERGENCE_ANALYSIS.md
* LMC_WORKSPACE_INDEX.md
* La roadmap canonique.

Inspecte particulièrement les méthodes de récupération locale introduites dans C7b et les mécanismes de vérification d’identité Temporal introduits dans C6.

Réutilise ces composants au maximum.

3. Objectif et proportionnalité

C7c doit rester une petite micro-MR.

Notre principal scénario de récupération automatique pendant un Workflow actif est désormais réellement qualifié.

C7c doit uniquement permettre une convergence locale lorsque le Workflow est déjà fermé et que les preuves durables nécessaires existent.

Ne développe pas :

* Un nouveau moteur de récupération.
* Un second orchestrateur.
* Un service permanent de surveillance.
* Une nouvelle Saga.
* Un système de support indépendant.
* Une nouvelle boucle de polling.
* Un nouveau mécanisme complexe de retry.

Privilégie un service applicatif minimal, réutilisable et testable.

Ce service pourra être invoqué ultérieurement par un mécanisme de récupération approprié. Ne prétends pas que la récupération est automatique tant qu’aucun déclencheur effectif n’existe.

4. Préconditions de récupération

Une récupération après fermeture ne doit être autorisée que si les preuves nécessaires sont réunies.

Vérifie notamment :

* L’identité exacte de l’opération.
* Le projet interne.
* La génération.
* Le Workflow ID.
* Le Run ID.
* Le cluster et le namespace.
* Le type de Workflow.
* La correspondance avec les données autoritatives de la Saga et de l’outbox.
* La fermeture effectivement vérifiée de l’exécution concernée.
* La présence d’une identité distante confirmée.
* La cohérence du snapshot accepté.
* La compatibilité du mapping existant.

Réutilise l’adapter Temporal C6 pour la vérification d’identité lorsque pertinent.

Une exécution introuvable, un historique expiré ou une indisponibilité Temporal ne constituent jamais une preuve de fermeture.

La fermeture du Workflow ne prouve pas à elle seule que toutes les anciennes Activities ont cessé d’exécuter du code. Vérifie les protections CAS et les éventuelles courses avec des Activities tardives.

Si les préconditions ne peuvent pas être démontrées, conserve l’état existant et un diagnostic exploitable.

5. Récupération exclusivement locale

C7c doit pouvoir traiter les cas suivants lorsque les preuves sont suffisantes :

* Identité distante confirmée mais mapping absent.
* Mapping déjà persisté mais finalisation incomplète.
* Perte d’acquittement d’une transaction locale.
* Preuve LOCAL_PERSISTENCE complète conservée après fermeture du Workflow.
* Succès déjà persisté nécessitant uniquement une restitution idempotente.

Réutilise les méthodes de récupération et les CAS de C7b/C3d.

Ne duplique aucune logique de persistance métier.

Conserve les protections de génération, d’identité et d’immuabilité.

Ne contourne pas les contraintes des opérations terminales. Si une transition nécessaire n’est pas actuellement autorisée, expose précisément le blocage avant toute modification de ces contraintes.

6. Situations non récupérables

Le service ne doit pas transformer arbitrairement les situations suivantes en succès :

* UNKNOWN_OUTCOME.
* Identité uniquement candidate.
* Identité distante non confirmée.
* Mapping conflictuel.
* Collision globale d’identité.
* Snapshot incompatible.
* Workflow encore actif.
* Fermeture non démontrable.
* Historique Temporal expiré ou inaccessible.
* Incohérence entre Saga, outbox et exécution distante.

Ces cas doivent rester correctement identifiés pour le futur support.

Ne développe pas leur résolution privilégiée pendant C7c.

7. Conservation des garanties

La récupération locale ne doit jamais provoquer :

* Un nouveau POST Orq.
* Un DELETE.
* Un nouveau démarrage de Workflow.
* Une nouvelle génération.
* Une nouvelle Saga.
* Un écrasement des preuves persistées.
* Un changement arbitraire de l’identité distante.
* Un contournement des protections CAS.

Aucun gateway Orq ne doit être nécessaire à cette récupération.

La vérification Temporal éventuelle doit être exclusivement en lecture seule.

Aucun verrou SQL ne doit être conservé pendant les RPC Temporal.

Ne transforme pas un ancien Workflow FAILED en Workflow COMPLETED. Son historique reste inchangé.

Une convergence locale réussie peut permettre de finaliser correctement l’état métier dans PostgreSQL, sous réserve des transitions autorisées, indépendamment du résultat historique du Workflow.

Documente clairement cette distinction.

8. Concurrence et sécurité

Vérifie les interactions avec :

* Le Store C3d.
* La récupération pendant Workflow actif C7b.
* Le Dispatcher C6.
* Le service d’enqueue C5.
* Une éventuelle Activity tardive.
* Deux tentatives concurrentes de récupération.

Réutilise les ordres de verrouillage existants.

Toutes les transitions doivent revalider les preuves et préconditions dans la transaction d’écriture.

Aucune donnée obsolète provenant d’une vérification antérieure ne doit permettre d’écraser un état plus récent.

N’introduis aucune nouvelle permission SpiceDB pendant C7c.

Le futur appel depuis le Repair devra rester protégé par les permissions existantes et audité conformément aux conventions du LMC.

9. Tests ciblés

Utilise PostgreSQL 18.4 réel et isolé, avec un adapter Temporal factice lorsque nécessaire.

Teste notamment :

* Fermeture exacte confirmée et preuve LOCAL_PERSISTENCE complète.
* Mapping absent.
* Mapping déjà présent.
* Finalisation incomplète.
* Succès déjà commité.
* Perte d’acquittement local.
* Deux récupérations concurrentes.
* Interaction avec une ancienne Activity.
* Workflow encore actif.
* Workflow introuvable.
* Historique expiré.
* Mauvais Run ID.
* Incohérence de génération.
* Snapshot incompatible.
* Identité candidate uniquement.
* UNKNOWN_OUTCOME.
* Conflit de mapping.
* Indisponibilité Temporal.
* Aucun appel Orq.
* Aucun nouveau start.
* Absence de nouvelle Saga.
* Absence de modification des preuves autoritatives.

Distingue les transactions PostgreSQL réellement exécutées des comportements Temporal simulés.

Ne multiplie pas inutilement les tests redondants avec C7b.

10. Non-régression

Notre référence applicative est C7b :

* 629 cas JUnit.
* 602 réussites.
* 27 échecs historiques identiques.
* PostgreSQL 18.4.
* Head Alembic 0004_orq_saga_outbox.
* 32 tables, 17 triggers, 4 fonctions, 85 index et 390 contraintes.

Notre référence de qualification comprend également les 16 historiques Temporal rejoués avec succès et la qualification ACCEPTED de C7b-Q.

Exécute les tests ciblés, les tests PostgreSQL pertinents, les tests cumulés, la suite complète, la compilation Python et pip check.

Vérifie le fonctionnement sans SDK Temporal lorsque pertinent.

Compare précisément les échecs historiques.

Aucune nouvelle migration n’est attendue.

Ne modifie pas le Workflow V2 si C7c peut être implémentée indépendamment, ce qui est préférable.

11. Limitation du périmètre

Ne commence pas :

* C7d : diagnostics et lookup résiduel.
* L’intégration au Repair.
* L’API HTTP de provisioning.
* La projection Orq dans operation-progress.
* Le frontend.
* La résolution privilégiée.
* Le provisioning des autres ressources Orq.

Ne réalise aucune qualification distante pendant C7c.

Il n’est pas nécessaire de recréer une grande campagne de qualification isolée pour cette micro-MR. Propose plutôt d’intégrer sa validation réelle pertinente à la future qualification fonctionnelle du LMC.

12. Contraintes impératives

* Aucune opération Git ou GitLab.
* Aucun déploiement.
* Aucun appel distant Temporal ou Orq.
* Aucune modification Kubernetes.
* Aucun serveur Temporal local.
* Aucune installation de Temporal CLI.
* Aucune modification des ressources Docker existantes.
* Seules les ressources temporaires isolées nécessaires aux tests sont autorisées.
* Aucune modification de Docker Compose ou des Dockerfiles.
* Aucune modification des scripts 01/02/03.
* Aucune modification des configurations VS Code.
* Aucune modification du pont Alembic.
* Aucun changement de la procédure habituelle de lancement du LMC.
* Préservation intégrale des espaces précédents.

13. Documentation et restitution

Crée une documentation technique en anglais :

documentation/C7C_CLOSED_WORKFLOW_RECOVERY.md

Mets à jour l’index canonique et la roadmap.

Pour chaque fichier et symbole créé ou modifié, documente son rôle, son comportement avant/après, les composants réutilisés, les décisions techniques et les alternatives envisagées.

Présente-moi en français :

* Le service minimal implémenté.
* Les préconditions de récupération.
* Les preuves nécessaires.
* Les protections contre les Activities tardives.
* Les transitions métier autorisées.
* Les scénarios récupérables.
* Les scénarios restant bloqués.
* Les résultats des tests.
* Les résultats de non-régression.
* Les limitations restantes.
* Le déclencheur de récupération restant éventuellement à raccorder.
* Le périmètre minimal proposé pour C7d.

Conserve explicitement dans la roadmap les travaux encore nécessaires avant C8 :

* Endpoint HTTP de provisioning utilisant C5.
* Projection Orq dans operation-progress.
* Suivi par operation_ref.
* Permissions de lecture existantes.
* Intégration minimale au Repair existant.

Le Repair reste un outil résiduel de debug et d’intervention manuelle destiné au développeur. Il ne doit pas devenir le mécanisme principal de récupération.

Notre priorité reste la parité fonctionnelle complète avec le Mock LMC depuis le véritable LMC lancé localement.

Nous avons suffisamment investi dans les fondations. Je souhaite maintenant que les prochaines étapes restent ciblées et permettent d’avancer rapidement vers l’intégration utilisateur.

Tu peux commencer C7c.

Ne commence pas C7d sans mon accord.