Je valide C7c sur son périmètre de qualification locale.

Nous pouvons commencer C7d — Minimal Orq Diagnostics and Existing Repair Integration.

Cette étape doit rester volontairement petite. Notre objectif est de terminer l’intégration au mécanisme de debug existant, puis de passer directement à l’API et au frontend.

1. Espace de travail

Utilise comme base applicative cumulative :

/workspace/LEA_Workspace/lcc-c7c-closed-workflow-recovery

Crée un nouvel espace isolé :

/workspace/LEA_Workspace/lcc-c7d-minimal-repair-integration

Préserve intégralement tous les espaces précédents.

La référence applicative C7c est désormais :

* 666 cas JUnit.
* 639 réussites.
* 610 tests pytest et 29 sous-tests réussis.
* 27 échecs historiques strictement identiques.
* 117 tests ciblés réussis.
* 57 tests PostgreSQL ciblés réussis.
* 110 tests PostgreSQL cumulés réussis.
* 168 tests réussis sans SDK Temporal, un test ignoré.
* 16/16 historiques Temporal rejoués.
* PostgreSQL 18.4.
* Head Alembic 0004_orq_saga_outbox.
* Catalogue applicatif inchangé : 32 tables, 17 triggers, 4 fonctions, 85 index et 390 contraintes.

2. Documentation et composants existants

Relis notamment :

* C7A_ORQ_RECOVERY_AND_REPAIR_ANALYSIS.md
* C7B_ACTIVE_WORKFLOW_RECOVERY.md
* C7BQ_ACTIVE_WORKFLOW_RECOVERY_QUALIFICATION.md
* C7C_CLOSED_WORKFLOW_RECOVERY.md
* C6_TEMPORAL_OUTBOX_DISPATCHER.md
* C6Q_TEMPORAL_REAL_QUALIFICATION.md
* LMC_SAGA_REPAIR_CONVERGENCE_ANALYSIS.md
* LMC_WORKSPACE_INDEX.md
* La roadmap canonique.

Inspecte le véritable mécanisme Repair du LMC et son utilisation pour SDA, les connecteurs et les autres composants existants.

Vérifie notamment les routes, services, contrats, permissions et mécanismes d’audit associés à :

* POST /v1/projects/{project_ref}/repair
* GET /v1/projects/{project_ref}/operation-progress
* LmcRepairProjectModal.tsx
* project#repair

Vérifie les noms et chemins exacts dans le code.

3. Vision du Repair

Le Repair existant est principalement un outil de debug et de support destiné au développeur du LMC.

Nous souhaitons lui offrir une expérience comparable pour Orq, sans créer un nouveau système de support.

La priorité reste la récupération automatique des erreurs lorsque celle-ci est sûre.

C7b a déjà démontré réellement cette récupération pendant un Workflow actif.

C7c fournit un service minimal de convergence locale après fermeture prouvée du Workflow, mais aucun déclencheur ne l’invoque encore.

C7d doit simplement raccorder les mécanismes résiduels nécessaires au Repair existant.

Ne développe pas de plateforme de support indépendante, de nouveau moteur de récupération, de nouveau Worker ou de service permanent de surveillance.

4. Diagnostics Orq minimaux

Construis un modèle de lecture minimal permettant de distinguer :

* État métier de ProjectOrqSaga.
* État de livraison de l’outbox.
* Présence et cohérence du mapping.
* LOCAL_PERSISTENCE.
* UNKNOWN_OUTCOME.
* TEMPORAL_START_UNCERTAIN.
* Conflit d’identité ou de mapping.
* Snapshot incompatible.
* Workflow dont l’état ne peut plus être vérifié.

Réutilise les codes d’erreur et références de support existants.

Ne crée aucun nouveau statut persisté lorsque les informations existantes suffisent.

Un Workflow FAILED ne signifie pas nécessairement que la mutation Orq a échoué.

Une Saga SUCCEEDED ne doit pas être dégradée par un simple problème d’acquittement de l’outbox.

Ne transforme pas une opération bloquée en simple provisioning en cours.

Prépare une projection réutilisable ultérieurement dans operation-progress et dans la modale Repair existante.

Les consultations ordinaires doivent rester sans mutation et ne pas dépendre d’appels réseau à Temporal ou Orq.

5. Lookup résiduel TEMPORAL_START_UNCERTAIN

Réutilise les mécanismes de vérification d’identité développés dans C6.

Lorsqu’une intervention Repair explicite concerne une livraison incertaine, autorise uniquement une recherche du Workflow exact.

Vérifie :

* Cluster.
* Namespace.
* Workflow ID.
* Run ID observé.
* Type de Workflow.
* Task Queue.
* Payload correspondant à l’opération.
* Génération et références persistées.

Lorsque l’exécution exacte est retrouvée et vérifiée, permets la récupération de son acquittement dans l’outbox par une transition CAS autorisée.

La vérification distante reste exclusivement en lecture seule. Seule la persistance locale de l’acquittement vérifié peut modifier PostgreSQL.

Inspecte les transitions actuelles de l’outbox, notamment depuis FAILED. Ne contourne aucune contrainte pour forcer STARTED.

Respecte les leases, dispatch_version et protections contre les acquittements tardifs.

Aucun verrou SQL ne doit être conservé pendant les RPC Temporal.

Si le Workflow est absent, inaccessible, hors rétention ou incompatible, conserve l’incertitude et un diagnostic exploitable.

Ne déclenche jamais un nouveau start pour résoudre TEMPORAL_START_UNCERTAIN.

6. Invocation du service C7c

Raccorde le service OrqProjectPostClosureRecoveryService au mécanisme Repair existant.

Réutilise directement :

* TemporalSdkClosedWorkflowObserver.
* load_postclosure_recovery_target().
* OrqProjectLocalConvergenceService.
* Les protections CAS C7b/C7c.

Lorsque la livraison a d’abord nécessité une récupération d’acquittement, vérifie les nouvelles préconditions avant d’invoquer C7c.

Ne duplique aucune logique de récupération locale.

La récupération doit rester strictement conditionnée à la fermeture prouvée du Workflow, à l’identité distante confirmée et à la cohérence des preuves persistées.

Le service ne doit jamais :

* Effectuer un POST Orq.
* Effectuer un DELETE.
* Démarrer, signaler ou reset un Workflow.
* Créer une nouvelle Saga.
* Allouer une nouvelle génération.
* Promouvoir une identité uniquement candidate.
* Écraser un mapping conflictuel.
* Affaiblir une preuve persistée.

Préserve le comportement des opérations terminales.

Le résultat historique du Workflow Temporal reste inchangé.

7. Intégration au Repair existant

Réutilise le point d’entrée existant et les conventions du LMC.

Ne crée aucun endpoint Repair parallèle.

Ne modifie pas le frontend pendant C7d : son raccordement sera effectué pendant C8.

L’intervention Orq doit être explicite et ciblée sur le projet et l’opération concernés.

Vérifie que le comportement des réparations SDA, Looker, Keycloak et connecteurs reste inchangé.

Le Repair doit restituer simplement :

* L’état observé.
* Le diagnostic.
* L’action effectuée, le cas échéant.
* Le résultat de cette action.
* Les éventuelles limitations nécessitant une intervention manuelle.

Il ne doit pas prétendre avoir réparé une situation qui reste incertaine.

8. Autorisation et audit

Réutilise la permission existante project#repair.

Vérifie le périmètre projet et l’identité authentifiée de l’acteur.

Préserve la distinction entre les permissions de provisioning, de consultation et de réparation.

N’étends pas implicitement les droits de provisioning à travers Repair.

Réutilise les mécanismes d’audit existants pour les interventions manuelles.

L’audit doit permettre d’identifier l’intention, l’acteur, l’opération et le résultat lorsque les conventions existantes le permettent.

Ne développe pas un système d’audit parallèle.

Si une garantie d’audit nécessaire ne peut pas être obtenue avec les mécanismes actuels, expose le blocage plutôt que de contourner la politique existante.

N’expose aucun credential, token, DSN, payload brut ou exception fournisseur.

9. Récupération automatique et proportionnalité

Ne développe pas de nouveau processus permanent pour déclencher C7c automatiquement.

La récupération pendant Workflow actif, qualifiée dans C7b-Q, reste notre mécanisme principal.

Pour les Workflows déjà fermés, le raccordement manuel à Repair constitue une première solution résiduelle acceptable.

Documente honnêtement que cette récupération post-fermeture n’est pas automatique.

Si un mécanisme automatique simple peut être ajouté ultérieurement en réutilisant un composant existant, documente cette possibilité sans l’implémenter pendant C7d.

Ne ralentis pas l’intégration fonctionnelle pour résoudre tous les cas exceptionnels théoriques.

10. Tests ciblés

Utilise PostgreSQL et SpiceDB réels et isolés lorsque pertinent, ainsi qu’un adapter Temporal factice.

Teste notamment :

* Repair autorisé sur le projet concerné.
* Refus hors périmètre.
* Refus sans permission Repair.
* Indisponibilité SpiceDB.
* Diagnostics métier et livraison.
* TEMPORAL_START_UNCERTAIN avec Workflow exact retrouvé.
* Acquittement local récupéré sans nouveau start.
* Workflow absent.
* Historique expiré.
* Identité incompatible.
* Lease actif ou version devenue obsolète.
* Invocation C7c avec fermeture prouvée.
* Mapping récupéré correctement.
* Finalisation idempotente.
* UNKNOWN_OUTCOME non contourné.
* Deux interventions concurrentes.
* Audit des interventions autorisées.
* Aucun POST Orq.
* Aucun nouveau start Temporal.
* Aucune nouvelle Saga ou génération.
* Absence de fuite d’informations sensibles.
* Non-régression du Repair historique.

Ne répète pas inutilement tous les tests déjà réalisés dans C7b et C7c.

Qualifie les nouvelles interfaces et les interactions entre les composants.

11. Non-régression

Utilise C7c comme référence :

* 666 cas JUnit.
* 639 réussites.
* 27 échecs historiques identiques.
* PostgreSQL 18.4.
* Head Alembic 0004_orq_saga_outbox.
* Catalogue applicatif inchangé.

Exécute les tests ciblés, les tests d’intégration pertinents, la suite complète, la compilation Python et pip check.

Vérifie les node IDs et traces normalisées des échecs historiques.

Préserve le fonctionnement normal du LMC sans SDK Temporal.

Les 16 historiques Temporal précédemment qualifiés restent notre référence de replay. Si aucun Workflow n’est modifié, ne développe pas une nouvelle campagne de replay disproportionnée.

Aucune migration n’est attendue.

12. Contraintes impératives

* Aucune opération Git ou GitLab.
* Aucun déploiement.
* Aucun appel distant Temporal ou Orq pendant C7d.
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
* Aucune nouvelle UI.
* Aucune nouvelle plateforme de support.
* Préservation intégrale des espaces précédents.

13. Documentation et restitution

Crée une documentation technique en anglais :

documentation/C7D_MINIMAL_REPAIR_INTEGRATION.md

Mets à jour l’index canonique et la roadmap.

Documente chaque fichier et symbole modifié, le comportement avant/après, les composants réutilisés, les choix techniques et les alternatives envisagées.

Présente-moi en français :

* L’intégration au Repair existant.
* Les diagnostics disponibles.
* Les actions réellement réalisables.
* Les permissions et mécanismes d’audit.
* Les protections contre les doublons.
* Les résultats des tests.
* Les résultats de non-régression.
* Les limitations restantes.

Ne lance pas de qualification distante spécifique C7d-Q. Les vérifications réelles pertinentes pourront être intégrées à la future qualification fonctionnelle depuis le LMC.

14. Étape suivante obligatoire

Après C7d, nous devons passer directement à C7e — Provisioning API and Operation Progress Integration.

C7e devra impérativement implémenter :

* L’endpoint HTTP de provisioning utilisant C5.
* La projection Orq dans operation-progress.
* Le suivi par operation_ref.
* Les permissions de consultation existantes.
* Les contrats nécessaires au frontend C8.

Ces composants n’ont pas été implémentés pendant C7a, qui était uniquement documentaire.

Ne les oublie pas dans la roadmap.

Notre priorité absolue est désormais d’atteindre rapidement la parité fonctionnelle complète avec le Mock LMC depuis le véritable LMC lancé localement.

Le Repair doit rester un outil simple de debug, et non devenir le centre de notre architecture.

Tu peux commencer C7d. Ne commence pas C7e sans mon accord.