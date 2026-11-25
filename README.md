Je valide C1 sur son périmètre de qualification locale.

Les résultats correspondent à nos attentes :

* 126 tests réussis.
* 27 échecs historiques identiques.
* 6 nouveaux tests réussis.
* 153 cas JUnit.
* Aucune nouvelle régression.
* PostgreSQL 18.4.
* 31 tables, 14 triggers, 2 fonctions, 77 index et 342 contraintes applicatives.
* Head Alembic unique : 0003_orq_project_mapping.
* Consolidation réussie de MR1 et MR4.
* Pont local reset SQL/Alembic qualifié manuellement.
* Aucun changement des scripts standards.

Nous pouvons maintenant commencer C2 — ProjectOrqSaga & Temporal Outbox.

1. Espace de travail

Crée un nouvel espace local isolé :

/workspace/LEA_Workspace/lcc-c2-orq-saga-outbox

Utilise comme base cumulative :

/workspace/LEA_Workspace/lcc-c1-orq-project-mapping

Notre nouvelle référence LMC originale reste :

/workspace/LEA_Workspace/lcc_last_version/lcc

Préserve intégralement tous les espaces précédents.

Ne copie aucune métadonnée Git, aucun credential, fichier .env, environnement virtuel ou cache inutile.

2. Objectif principal

C2 doit reprendre le schéma final de persistance développé dans MR5 et MR7 et l’intégrer directement au modèle ProjectOrqSaga existant.

Nous retenons définitivement les trois responsabilités suivantes :

* saga_project_orq : unique table d’opérations de provisioning Orq.
* orq_project_mappings : mapping durable et identité distante vérifiée.
* orq_project_temporal_start_outbox : état de livraison des demandes de démarrage Temporal.

Ne crée jamais la table orq_project_provisioning_operations dans cette nouvelle architecture.

Aucune duplication fonctionnelle et aucune double écriture.

3. Réutilisation du travail existant

Relis notamment :

* lcc-mr5-provisioning-operations-outbox
* lcc-mr6-provisioning-contracts
* lcc-mr7-postgresql-state-store
* C0_BASELINE_QUALIFICATION.md
* C1_ORQ_PROJECT_MAPPING.md
* LMC_SAGA_REPAIR_CONVERGENCE_ANALYSIS.md
* LMC_WORKSPACE_INDEX.md
* La roadmap de convergence.

Réutilise directement les modèles, contraintes, triggers, index, mécanismes de protection et tests précédemment qualifiés.

Ne réimplémente pas une logique déjà développée lorsque celle-ci peut être portée mécaniquement.

Identifie précisément les éléments repris sans modification, ceux adaptés et les raisons de chaque adaptation.

4. Enrichissement de ProjectOrqSaga

Fais évoluer directement la table saga_project_orq.

Conserve les champs existants lorsque leur responsabilité est compatible avec notre architecture, notamment :

* project_id.
* operation_type.
* operation_started_at.
* Support reference.
* Code et message d’erreur.
* Timestamps.

Intègre les capacités issues du schéma final MR5/MR7 :

* operation_ref comme clé primaire UUID.
* Plusieurs opérations historiques par projet.
* Génération.
* Mode PLAN/APPLY.
* Version et hash de configuration désirée.
* Snapshots immuables.
* Compteurs de tentatives.
* mutation_attempted irréversible.
* Identifiant Orq candidat.
* Identifiant et clé Orq vérifiés.
* Action de réconciliation.
* Failure kind.
* Timestamp de fin d’opération.
* Contraintes nécessaires à la prévention des opérations concurrentes.

Reprends précisément les contraintes de notre schéma final, sauf incompatibilité justifiée.

La clé projet Orq ne doit jamais être confondue avec une clé API ou un credential.

Aucun secret, token, payload arbitraire, message d’exception brut ou réponse SDK complète ne doit être persisté.

Ne modifie pas le mapping C1 sauf découverte d’une incompatibilité bloquante, auquel cas présente-moi d’abord la correction proposée.

5. Statuts spécifiques à Orq

Définis un statut propre à ProjectOrqSaga permettant de représenter :

* PENDING.
* IN_PROGRESS.
* SUCCEEDED.
* FAILED.
* NEEDS_RECONCILIATION.

Conserve la distinction entre un échec connu et UNKNOWN_OUTCOME.

Ne modifie pas l’enum partagé utilisé par les autres Sagas du LMC.

Ne modifie pas le comportement des mécanismes SDA, Looker et connecteurs.

Contrairement à certaines Sagas existantes, les opérations Orq réussies doivent rester persistées pour conserver l’historique et les preuves nécessaires à la prévention des doublons.

6. Garanties de persistance

Préserve les garanties développées dans MR5 et MR7 :

* Identité d’opération immuable.
* Une génération unique par projet.
* Une seule opération non résolue par projet.
* Immutabilité des snapshots.
* mutation_attempted ne peut jamais revenir à false.
* Compteurs de tentatives non décroissants.
* Distinction entre résultat candidat et résultat vérifié.
* Cohérence entre ID Orq, clé Orq et action de réconciliation.
* Conservation des informations relatives aux mutations ambiguës.
* Protection contre la réécriture des résultats confirmés.
* Conservation des opérations historiques.

Vérifie la compatibilité des contraintes avec les contrats V2 de MR6.

Distingue les garanties effectivement imposées par PostgreSQL de celles qui nécessiteront encore le Store, les opérations CAS ou le dispatcher.

Ne présente pas le schéma seul comme une garantie exactly-once.

7. Temporal Outbox

Porte la table orq_project_temporal_start_outbox depuis notre implémentation MR5.

Adapte sa clé étrangère pour référencer :

saga_project_orq.operation_ref

Conserve les mécanismes précédemment qualifiés :

* Workflow ID unique.
* Relation un-à-un avec l’opération.
* Statuts PENDING, DISPATCHING, STARTED et FAILED.
* Compteurs de tentatives.
* Version de dispatch.
* Lease owner et expiration.
* Planification.
* Temporal run ID.
* Accusé de réception.
* Codes d’erreur symboliques.
* Index nécessaires aux futures opérations du dispatcher.

Vérifie également les limitations précédemment identifiées concernant la cohérence de DISPATCHING et les valeurs NULL.

Corrige uniquement les incohérences structurelles dont la correction est indispensable et mécaniquement justifiée. Si cela implique une nouvelle décision métier, présente-la avant implémentation.

Ne développe pas encore l’enqueue transactionnel ni le dispatcher.

8. Migration Alembic

Crée une seule migration additive après :

0003_orq_project_mapping

Cette migration doit enrichir directement saga_project_orq et créer son outbox.

Ne modifie aucune migration existante.

Ne crée aucune table intermédiaire inutile.

Avant toute transformation de saga_project_orq, vérifie son contenu dans la base ciblée par la migration.

La stratégie retenue pour le moment est fail-fast si des lignes historiques existent et qu’aucune transition sûre n’a été validée.

Dans ce cas :

* Arrête la migration sans modification persistante.
* Ne supprime aucune donnée.
* N’invente aucune génération, identité Orq, clé, configuration ou information de mutation.
* Ne crée automatiquement aucun mapping ni aucune outbox.
* Ne transforme aucune ancienne opération en opération dispatchable.

Teste réellement ce comportement sur PostgreSQL avec des données historiques synthétiques.

Prévois également un downgrade sûr, refusé lorsqu’il entraînerait la perte d’opérations ou de données importantes.

9. Suppression des projets et nouvelles tentatives

Conserve les protections historiques introduites dans MR5.

Cependant, documente précisément les implications :

* Du passage de ON DELETE CASCADE à ON DELETE RESTRICT.
* Du blocage éventuel de la suppression après des opérations terminées.
* De l’unicité projet/version/mode sur les nouvelles tentatives.
* Des modifications concurrentes du projet.
* De l’immuabilité de project_ref.

Ne résous pas silencieusement ces décisions fonctionnelles.

Identifie les adaptations qui devront être traitées avant l’exposition du provisioning et du Repair aux utilisateurs.

10. Compatibilité avec le mécanisme Repair

La future intégration devra réutiliser :

* ProjectOrqSaga.
* frontend/src/components/LmcRepairProjectModal.tsx.
* POST /v1/projects/{project_ref}/repair.
* GET /v1/projects/{project_ref}/operation-progress.
* Les permissions SpiceDB existantes.

Vérifie que le schéma retenu permettra de présenter les états, diagnostics, références support et résultats nécessaires au futur Repair.

Une action Repair normale ne devra jamais rejouer automatiquement une création Orq après une mutation potentiellement effectuée.

Ne modifie cependant aucun endpoint ni composant frontend dans C2.

11. Qualification réelle PostgreSQL 18.4

Réutilise les tests de migration et de persistance de MR5 et MR7 applicables au périmètre C2.

Teste notamment :

* Migration depuis une base vide.
* Migration depuis C1 avec des projets et mappings représentatifs.
* Préservation intégrale des données existantes.
* Migration avec saga_project_orq vide.
* Refus sûr de migration avec des lignes Saga historiques.
* Plusieurs opérations historiques pour un projet.
* Contraintes d’unicité des générations.
* Blocage de plusieurs opérations non résolues.
* Immutabilité des snapshots.
* Irréversibilité de mutation_attempted.
* Cohérence des résultats candidats et vérifiés.
* Contraintes de l’outbox.
* Cohérence des leases et compteurs.
* Intégrité référentielle.
* Comportements de suppression.
* Rollback des transactions invalides.
* Réapplication de upgrade head.
* Downgrade dangereux refusé.
* Downgrade sur données compatibles puis upgrade.
* Absence de régression sur les autres Sagas.

Vérifie qu’un seul head Alembic subsiste et que la table orq_project_provisioning_operations n’existe pas dans le catalogue final.

Utilise exclusivement PostgreSQL 18.4 sur des ressources temporaires strictement isolées.

12. Non-régression

La nouvelle référence est celle de C1 :

* 126 tests réussis.
* 27 échecs historiques identiques.
* 153 cas JUnit.
* 31 tables.
* 14 triggers.
* Head Alembic 0003_orq_project_mapping.

Exécute les tests ciblés et la suite complète.

Compare les node IDs, les traces normalisées et la signature des échecs avec C1.

Vérifie également la compilation Python et pip check.

Distingue les tests portés depuis MR5/MR7 des nouveaux tests spécifiques à la convergence.

13. Limitation du périmètre

C2 doit rester consacrée au schéma de persistance de ProjectOrqSaga et à l’outbox.

Ne commence pas encore :

* Le portage de T1.
* Le portage de T2.
* Les contrats et le Workflow V2.
* Le Store PostgreSQL.
* Les Activities.
* Le Worker Temporal.
* L’enqueue transactionnel.
* Le dispatcher.
* L’API.
* Le frontend.
* Le Repair.

Ces composants seront reportés lors des prochaines micro-MR.

14. Contraintes impératives

* Micro-MR minimale et facilement explicable.
* Réutilisation maximale du travail existant.
* Aucune opération Git ou GitLab.
* Aucun changement Kubernetes.
* Aucun déploiement.
* Aucun appel réel à Orq.ai.
* Aucun Workflow Temporal distant.
* Aucune modification des conteneurs, volumes, réseaux ou bases existants.
* Aucune modification du Docker Compose original.
* Aucune modification des scripts 01, 02 et 03.
* Aucune modification des configurations de lancement VS Code.
* Préservation intégrale de tous les espaces précédents.
* Temporal et Orq.ai doivent rester optionnels.

Le pont local entre reset SQL et Alembic reste qualifié manuellement mais ne doit pas être intégré aux scripts standards dans C2.

La procédure habituelle de lancement du LMC doit rester inchangée.

Notre chaîne de migrations reste non déployable tant que sa compatibilité avec le chantier officiel Alembic et les bases historiques n’a pas été validée.

15. Documentation et restitution

Crée une documentation technique dédiée à C2 en anglais.

Mets à jour LMC_WORKSPACE_INDEX.md et la roadmap de convergence.

Pour chaque fichier modifié, documente :

* Son rôle.
* Le comportement avant et après.
* Les éléments repris de MR5/MR7.
* Les adaptations spécifiques à ProjectOrqSaga.
* Les justifications techniques.
* Les alternatives éventuelles.

À la fin, présente-moi en français :

* Les fichiers créés et modifiés.
* Le schéma final de ProjectOrqSaga.
* Le schéma final de l’outbox.
* Le travail directement réutilisé.
* Les contraintes et garanties effectivement implémentées.
* Les résultats réels des tests.
* Les impacts potentiels sur les fonctionnalités existantes.
* Les limitations et décisions restantes.
* Le prochain portage C3a recommandé.

Notre priorité reste d’obtenir rapidement une première intégration verticale fonctionnelle depuis l’interface du véritable LMC local, avec le mécanisme Repair existant, puis d’atteindre la parité complète avec le Mock LMC avant tout déploiement en préproduction.

Tu peux commencer C2 dans ce périmètre. Ne commence pas C3a sans mon accord.