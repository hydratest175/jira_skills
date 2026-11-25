Je valide l’architecture de convergence proposée avec la réutilisation directe de ProjectOrqSaga.

Nous retenons les décisions suivantes :

* saga_project_orq devient l’unique table d’opérations de provisioning Orq.
* orq_project_mappings conserve le mapping durable et l’identité distante vérifiée.
* orq_project_temporal_start_outbox conserve l’état de livraison Temporal.
* orq_project_provisioning_operations ne sera pas créée dans la nouvelle base de convergence.
* Aucune double écriture.
* Réutilisation maximale de notre Store PostgreSQL, de nos contrats V2, de nos Activities, de notre Workflow et de nos tests existants.
* Réutilisation des mécanismes Repair, des endpoints et des permissions existants.
* Conservation de toutes nos protections contre les mutations concurrentes et ambiguës.

Nous pouvons maintenant poursuivre et terminer C0.

1. Espace de qualification

Utilise comme nouvelle base de référence :

/workspace/LEA_Workspace/lcc_last_version/lcc

Crée, si ce n’est pas déjà fait :

/workspace/LEA_Workspace/lcc-c0-baseline-qualification

Ne reporte encore aucun développement Orq dans cet espace.

Préserve intégralement tous les espaces de travail existants.

Ne copie aucun credential, fichier .env, environnement virtuel, cache inutile ou métadonnée Git.

2. Qualification des tests existants

Tu as identifié :

* 30 tables SQL.
* 30 tables ORM.
* 13 triggers.
* 2 fonctions.
* 22 inserts de référence.
* 9 tests ciblés réussis.
* 3 échecs liés à des assertions apparemment obsolètes.

Vérifie précisément que les différences constatées correspondent à des évolutions légitimes du LMC.

Ne modifie pas simplement les valeurs attendues des tests pour les faire passer.

Identifie les nouvelles tables et données de référence, puis vérifie leur cohérence avec les modèles ORM et les migrations.

Exécute la suite complète des tests disponibles afin d’établir une nouvelle référence de non-régression.

Conserve les node IDs, traces normalisées et signatures des échecs préexistants.

Présente séparément les éventuelles corrections minimales nécessaires.

3. Qualification réelle PostgreSQL et Alembic

Utilise PostgreSQL 18.4 neuf et strictement isolé, conformément à la nouvelle version du LMC et aux sources d’images autorisées dans notre environnement.

Vérifie réellement :

* La chaîne Alembic officielle.
* Le head unique.
* L’exécution de alembic upgrade head depuis une base vide.
* La cohérence du schéma obtenu avec les modèles ORM.
* Les tables, triggers, fonctions, contraintes et données de référence.
* La réapplication de upgrade head.
* Le comportement du mécanisme actuel d’initialisation des bases.
* Les éventuelles divergences entre la baseline SQL et les migrations Alembic.

Si possible, reconstruis des états historiques sur des bases temporaires isolées à partir des versions précédentes disponibles localement, afin de qualifier les chemins d’upgrade reproductibles.

Ne considère pas une base synthétique comme une preuve de compatibilité avec toutes les bases historiques réelles.

N’accède à aucune base existante pour effectuer cette qualification.

Si l’inventaire d’une véritable base historique devient indispensable, explique précisément pourquoi et présente-moi la procédure de lecture seule nécessaire avant toute intervention.

4. Limitation du chantier Alembic

Nous ne souhaitons pas reprendre intégralement le chantier officiel Alembic.

Distingue clairement :

* Les problèmes bloquant réellement notre développement local.
* Les problèmes non bloquants hérités du LMC.
* Les problèmes concernant uniquement les migrations de bases historiques.
* Les problèmes concernant uniquement le futur déploiement Kubernetes.

Notre objectif est de poursuivre rapidement notre développement local.

Si une correction est indispensable, présente le diff minimal proposé et sa justification avant de modifier le schéma ou les migrations.

Ne crée aucun système de migrations concurrent.

5. Préparation de C1 et C2

Prépare le plan précis des deux prochaines micro-MR, sans commencer leur implémentation.

C1 devra consolider MR1 et MR4 dans le mapping durable final.

C2 devra enrichir directement saga_project_orq en réutilisant le schéma final de MR5 et MR7, puis créer l’outbox associée.

Pour C2, conserve les champs et conventions Saga existants lorsque leurs responsabilités sont compatibles avec notre architecture.

Prévois notamment :

* operation_ref comme identifiant unique d’opération.
* Plusieurs opérations historiques par projet.
* Générations et snapshots immuables.
* Réservation durable avant mutation.
* Résultats candidats et vérifiés.
* Références de support.
* Statuts propres à la Saga Orq.
* Conservation de UNKNOWN_OUTCOME.
* Association fiable avec l’outbox.

Ne modifie pas l’enum partagé par les autres Sagas.

Ne supprime pas les opérations Orq après réussite.

Ne crée aucune table intermédiaire inutile.

Concernant les éventuelles données historiques présentes dans saga_project_orq, privilégie une stratégie fail-fast tant qu’aucune migration sûre de ces données n’a été définie et validée.

N’invente aucun ID, clé, mapping ou hash Orq.

Aucune ancienne opération ambiguë ne doit devenir automatiquement dispatchable.

6. Préparation du portage

Identifie précisément les fichiers de MR0 à MR7 qui pourront être directement réutilisés.

Privilégie la réutilisation de notre implémentation et de nos tests plutôt qu’une réécriture.

Découpe le futur portage C3 en micro-MR distinctes si nécessaire, notamment pour :

* T1 et la réconciliation.
* T2 et les fondations Temporal.
* Les contrats et le Workflow V2.
* Le Store PostgreSQL.
* Les Activities V2.

Chaque étape devra être réellement qualifiée avant de poursuivre.

Conserve également les décisions fonctionnelles encore ouvertes concernant la suppression des projets, le retry manuel à configuration identique et les modifications concurrentes du projet.

7. Contraintes impératives

* Aucun développement C1 ou ultérieur pour le moment.
* Aucune opération Git ou GitLab.
* Aucun changement Kubernetes.
* Aucun déploiement.
* Aucun appel distant à Orq.ai.
* Aucun nouveau Workflow Temporal distant.
* Aucune modification des conteneurs, volumes, réseaux ou bases existants.
* Seules les ressources Docker temporaires strictement isolées nécessaires à la qualification sont autorisées.
* Aucune modification du Docker Compose original.
* Aucune modification de la procédure standard de lancement du LMC.
* Temporal et Orq.ai doivent rester optionnels.
* Préservation intégrale de tous les espaces précédents.

8. Documentation et restitution

Complète la documentation de convergence et crée la documentation technique dédiée à C0 en anglais.

Mets à jour LMC_WORKSPACE_INDEX.md et la roadmap de convergence.

Présente-moi en français :

* Les résultats réels des tests.
* La nouvelle référence de non-régression.
* Les résultats PostgreSQL et Alembic.
* Les problèmes hérités.
* Les corrections minimales nécessaires.
* Les éventuels blocages.
* Le plan précis de C1 et C2.
* Les composants existants qui pourront être directement réutilisés.

Indique explicitement si nous pouvons commencer C1 sans attendre la finalisation du chantier officiel Alembic.

Notre objectif reste la parité fonctionnelle complète avec le Mock LMC depuis l’interface du véritable LMC lancé localement, incluant le support et le Repair, avant tout déploiement en préproduction.

Tu peux terminer C0 dans ce périmètre. Ne commence pas C1 sans mon accord.