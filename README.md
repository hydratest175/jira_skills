Je valide C0 sur son périmètre de qualification locale.

Nous disposons désormais d’une nouvelle référence :

* 147 cas JUnit.
* 120 tests réussis.
* 27 échecs historiques identiques.
* Aucune nouvelle régression.
* PostgreSQL 18.4.
* 30 tables applicatives.
* 13 triggers.
* 2 fonctions.
* 75 index.
* 329 contraintes applicatives.
* Head Alembic unique : 0002_baseline_reference_data.
* Équivalence du catalogue applicatif produit par Alembic et par le reset SQL sur une base neuve.

Nous pouvons maintenant commencer C1 — Final Orq Project Mapping.

1. Espace de travail

Crée un nouvel espace local isolé :

/workspace/LEA_Workspace/lcc-c1-orq-project-mapping

Utilise comme base cumulative :

/workspace/LEA_Workspace/lcc-c0-baseline-qualification

Notre référence LMC originale reste :

/workspace/LEA_Workspace/lcc_last_version/lcc

Préserve intégralement tous les espaces précédents.

Ne copie aucune métadonnée Git, aucun credential, fichier .env, environnement virtuel ou cache inutile.

2. Réutilisation de MR1 et MR4

Notre objectif est de porter le travail déjà réalisé, et non de le réimplémenter.

Relis notamment :

* lcc-mr1-orq-project-mapping
* lcc-mr4-orq-project-mapping-state
* lcc-mr7-postgresql-state-store
* C0_BASELINE_QUALIFICATION.md
* LMC_SAGA_REPAIR_CONVERGENCE_ANALYSIS.md
* LOCAL_LMC_PARITY_ROADMAP.md
* LMC_WORKSPACE_INDEX.md

Réutilise directement les modèles, contraintes, migrations, tests et décisions techniques précédemment qualifiés lorsque cela est possible.

Adapte uniquement les éléments rendus nécessaires par la nouvelle version du LMC et PostgreSQL 18.4.

Identifie explicitement les portions de code reprises sans modification et celles nécessitant une adaptation.

3. Migration finale du mapping

Consolide MR1 et MR4 dans une seule migration Alembic additive située après le head officiel actuel.

Ne reporte pas successivement nos anciennes migrations provisoires 0003 et 0004.

La nouvelle migration doit directement créer le schéma final de orq_project_mappings avec :

* La référence interne au projet LMC.
* L’identifiant Orq unique avec une longueur maximale de 256 caractères.
* La clé projet Orq vérifiée.
* La version de configuration désirée.
* Le hash de configuration désirée.
* La génération nécessaire aux futures protections CAS.
* Les timestamps.
* Les contraintes et le trigger précédemment qualifiés.

Reprends les types, nullabilités, contraintes et valeurs initiales de notre schéma final MR4, sauf incompatibilité justifiée avec la nouvelle base.

Vérifie notamment les conventions SQLAlchemy, les clés étrangères, les types PostgreSQL et les mécanismes de timestamps existants.

La limite de 256 caractères reste une borne défensive interne et non une limitation officielle Orq.

Aucune troncature silencieuse ne doit être possible.

Ne modifie aucune migration officielle existante.

4. Compatibilité avec la future Saga Orq

Notre architecture de convergence est désormais définie :

* saga_project_orq sera l’unique table d’opérations de provisioning Orq.
* orq_project_mappings conserve l’identité distante vérifiée.
* orq_project_temporal_start_outbox conserve l’état de livraison Temporal.
* orq_project_provisioning_operations ne sera pas recréée.

Vérifie que le mapping introduit dans C1 reste compatible avec le futur enrichissement de ProjectOrqSaga et le portage du Store PostgreSQL MR7.

Ne modifie cependant pas ProjectOrqSaga dans C1.

Cette évolution appartient exclusivement à C2.

5. Pont local entre reset SQL et Alembic

Tu as identifié la nécessité du pont suivant après le reset SQL :

alembic stamp 0002_baseline_reference_data

alembic upgrade head

Je valide le principe technique de ce pont pour une base locale fraîchement réinitialisée et dont la conformité avec 0002 a été vérifiée.

Cependant, je souhaite séparer cette adaptation de la procédure interne de migration du développement du mapping Orq.

Pour C1 :

* Ne modifie aucun script standard.
* Qualifie la migration directement sur PostgreSQL 18.4 isolé.
* Tu peux tester le pont manuellement sur une base temporaire fraîchement initialisée par le reset SQL.
* Vérifie que le schéma correspond réellement à 0002 avant tout stamp.
* Ne réalise jamais de stamp automatique sur une base historique ou déjà utilisée.
* N’utilise pas stamp pour contourner une migration échouée ou masquer une divergence de schéma.

Prépare séparément le diff minimal permettant d’intégrer ultérieurement ce pont dans le mécanisme standard d’initialisation locale.

Présente ce diff pour validation, sans l’appliquer aux scripts existants.

La procédure utilisateur de lancement du LMC doit impérativement rester inchangée.

Nous ne souhaitons pas reprendre intégralement le chantier officiel Alembic.

6. Qualification réelle PostgreSQL 18.4

Réutilise les scénarios de tests MR1 et MR4.

Vérifie notamment :

* La migration depuis une base vide.
* La migration depuis une base 0002 contenant des données représentatives.
* La préservation des données LMC existantes.
* Le head Alembic unique.
* La cohérence ORM/SQL.
* L’unicité du mapping.
* Les contraintes de validité.
* Les identifiants de 256 caractères.
* Le rejet des identifiants trop longs.
* Le comportement des timestamps et du trigger.
* Les valeurs initiales de génération, version et hash.
* La réapplication de upgrade head.
* Le comportement du downgrade.
* Le refus d’un downgrade susceptible de supprimer silencieusement des mappings existants.

Teste également la compatibilité avec les attentes du futur Store PostgreSQL MR7.

Ne présente pas la présence d’un champ generation comme une garantie CAS effective.

Utilise exclusivement des bases et ressources Docker temporaires strictement isolées.

7. Non-régression

Notre nouvelle référence est celle de C0 :

* 120 tests réussis.
* 27 échecs historiques.
* 147 cas JUnit.

Exécute les tests ciblés et la suite complète.

Compare les node IDs, traces normalisées et signatures des échecs avec C0.

Distingue les tests directement réutilisés de MR1/MR4 des éventuels nouveaux tests nécessaires à la convergence.

Vérifie la compilation et pip check.

Ne cherche pas à retrouver artificiellement les anciens nombres de tests MR7, puisque le portage de nos composants sera progressif.

8. Limitation du périmètre

C1 doit rester strictement consacrée au mapping durable Orq.

Ne commence pas :

* L’enrichissement de ProjectOrqSaga.
* La création de l’outbox.
* Le portage de T1 ou T2.
* Le portage des contrats ou Workflows.
* Le Store PostgreSQL.
* Les Activities.
* Le Worker.
* Le dispatcher.
* L’API.
* Le frontend.
* Le Repair.

Ces développements seront traités dans les micro-MR suivantes.

9. Contraintes impératives

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
* Préservation intégrale des espaces précédents.
* Temporal et Orq.ai doivent rester optionnels.

La nouvelle migration reste locale et non déployable tant que les chemins d’upgrade historiques et le chantier officiel Alembic n’ont pas été validés.

10. Documentation et restitution

Crée une documentation technique dédiée à C1 en anglais.

Mets à jour LMC_WORKSPACE_INDEX.md et la roadmap de convergence.

Pour chaque fichier modifié, explique :

* Son rôle.
* Le comportement avant et après.
* Le code directement réutilisé.
* Les adaptations nécessaires.
* La justification technique.
* Les alternatives éventuelles.

À la fin, présente-moi en français :

* Les fichiers créés et modifiés.
* Le schéma final du mapping.
* Le travail réutilisé de MR1 et MR4.
* Les résultats réels des tests.
* Les garanties effectivement validées.
* Le diff proposé pour le pont local Alembic, sans l’appliquer.
* Les limites restantes.
* La prochaine micro-MR recommandée.

Notre objectif reste la parité fonctionnelle complète avec le Mock LMC depuis l’interface du véritable LMC local, incluant les mécanismes existants de support et de réparation, avant tout déploiement en préproduction.

Tu peux commencer C1 dans ce périmètre. Ne commence pas C2 sans mon accord.