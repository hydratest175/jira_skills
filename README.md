Je valide C2 sur son périmètre de qualification locale.

Notre nouvelle référence est désormais :

* 136 tests réussis.
* 27 échecs historiques identiques.
* 10 nouveaux tests C2 réussis.
* 163 cas JUnit.
* Aucune nouvelle régression.
* PostgreSQL 18.4.
* 32 tables applicatives.
* 17 triggers.
* 4 fonctions.
* 85 index.
* 390 contraintes applicatives.
* Head Alembic unique : 0004_orq_saga_outbox.

ProjectOrqSaga est désormais notre unique modèle d’opérations de provisioning Orq.

Nous pouvons commencer C3a — Orq Project Reconciliation Core.

1. Espace de travail

Crée un nouvel espace local isolé :

/workspace/LEA_Workspace/lcc-c3a-orq-reconciliation

Utilise comme base cumulative :

/workspace/LEA_Workspace/lcc-c2-orq-saga-outbox

Notre référence LMC originale reste :

/workspace/LEA_Workspace/lcc_last_version/lcc

Préserve intégralement tous les espaces précédents.

Ne copie aucune métadonnée Git, aucun credential, fichier .env, environnement virtuel ou cache inutile.

2. Réutilisation de T1

Notre objectif est de porter le travail existant, et non de le réimplémenter.

Relis notamment :

* lcc-t1-orq-reconciliation
* lcc-t3-orq-project-workflow
* lcc-mr6-provisioning-contracts
* lcc-mr7-postgresql-state-store
* C2_ORQ_SAGA_OUTBOX.md
* LMC_SAGA_REPAIR_CONVERGENCE_ANALYSIS.md
* LMC_WORKSPACE_INDEX.md
* La roadmap de convergence.

Ne te limite pas à la première version de T1.

Identifie également les corrections et durcissements apportés à sa logique de réconciliation lors de T3, MR6 et MR7.

Détermine la version cumulative la plus pertinente de chaque fichier à reporter afin de ne pas réintroduire des comportements précédemment corrigés.

Ne porte toutefois pas les composants Temporal, Store ou Activities appartenant aux étapes suivantes.

3. Périmètre fonctionnel

Porte les composants de réconciliation de projet Orq précédemment développés, notamment les fichiers correspondant à :

* orq_project_resources.py
* orq_project_reconciliation.py
* La fonction reconcile_orq_project()
* Les contrats nécessaires à cette logique.
* Les gateways et interfaces associées.
* La classification des résultats et des erreurs.
* Les tests unitaires et gateways factices existants.

Vérifie les chemins et noms exacts dans les espaces historiques.

Réutilise directement le code existant lorsque cela est possible.

N’introduis aucune nouvelle abstraction ou duplication de logique métier sans nécessité démontrée.

4. Garanties de réconciliation

Préserve impérativement les décisions précédemment validées :

* Réutilisation d’un projet Orq uniquement lorsque son identité et son association au projet LMC sont vérifiées.
* Aucune adoption d’un projet Orq uniquement sur la base de son nom.
* Distinction entre un identifiant candidat et une identité distante vérifiée.
* Validation de l’ID et de la clé projet Orq.
* Aucune invention de mapping.
* Aucune création automatique après un résultat ambigu.
* Aucune suppression ou compensation DELETE automatique.
* Classification correcte des erreurs connues et des résultats incertains.
* Conservation de UNKNOWN_OUTCOME.
* Aucun retry automatique après une mutation potentielle.
* Désactivation des retries de transport pour les appels mutatifs.

Ne considère pas une erreur HTTP, un timeout ou une perte de connexion après l’envoi potentiel d’une mutation comme une preuve que la création a échoué.

Préserve notamment les durcissements concernant mutation_attempted introduits dans nos développements ultérieurs.

Vérifie la compatibilité avec les attentes du futur Store PostgreSQL C3d.

La réservation durable et le CAS applicatif ne sont pas encore raccordés dans C3a. Ne présente donc pas le portage de T1 comme une garantie d’idempotence distribuée complète.

5. Compatibilité avec le SDK Orq

Notre qualification historique utilisait orq-ai-sdk==4.13.14.

Vérifie la version réellement disponible et utilisée dans la nouvelle base du LMC.

Privilégie la réutilisation des dépendances existantes et autorisées.

Identifie les éventuelles incompatibilités concernant :

* Les méthodes de création et de consultation des projets.
* Les structures de réponse.
* Les types d’identifiants.
* La clé projet Orq.
* La classification des erreurs.
* La configuration des retries et des timeouts.

Ne présume pas de l’existence d’un mécanisme d’idempotence natif Orq sans preuve.

N’effectue aucun appel réel à Orq.ai pour cette qualification.

Ne modifie pas les dépendances existantes sans nécessité technique justifiée.

6. Compatibilité avec la nouvelle architecture Saga

Notre architecture est désormais composée de :

* orq_project_mappings : identité distante et mapping durable.
* saga_project_orq : opérations, mutations, résultats, statuts et diagnostics.
* orq_project_temporal_start_outbox : livraison Temporal.

Vérifie que les résultats produits par la réconciliation sont compatibles avec les champs et contraintes introduits dans C1 et C2.

Ne recrée pas orq_project_provisioning_operations.

Préserve la séparation entre la logique métier de réconciliation, la persistance PostgreSQL et l’orchestration Temporal.

Ne raccorde pas encore directement T1 au Store.

7. Helper Orq existant dans le LMC

La nouvelle version du LMC contient déjà un helper de création de projet Orq.

L’analyse de convergence a identifié des incompatibilités potentielles avec nos garanties, notamment concernant les résultats ambigus et les compensations automatiques.

Vérifie que le portage de T1 :

* Ne réutilise pas accidentellement ce comportement incompatible.
* Ne déclenche aucune suppression automatique.
* Ne modifie pas le fonctionnement actuel du LMC.
* N’introduit pas deux chemins actifs de provisioning Orq.

Ne supprime ni ne modifie ce helper dans C3a.

Documente précisément la manière dont notre future intégration devra éviter son utilisation incompatible.

8. Tests et qualification

Porte les tests historiques de T1 ainsi que les tests de durcissement ultérieurs relevant directement de la réconciliation.

Notre qualification historique T1 comportait 37 tests ciblés réussis.

Ne cherche cependant pas à reproduire artificiellement ce nombre si les tests ont évolué depuis.

Vérifie notamment :

* Réutilisation d’un mapping valide.
* Mapping incohérent ou obsolète.
* Absence de mapping.
* Collision de noms.
* Création nominale simulée.
* Résultat incomplet.
* Résultat candidat non vérifié.
* Identité distante contradictoire.
* Timeout pendant une mutation.
* Perte de connexion.
* Erreurs HTTP pertinentes.
* Absence de retry mutatif automatique.
* Classification UNKNOWN_OUTCOME.
* Absence de compensation DELETE.
* Rejet des identifiants invalides.
* Compatibilité avec les contrats attendus par MR7.

Utilise exclusivement des gateways factices et des dépendances contrôlées.

Distingue clairement les tests portés, les tests adaptés et les nouveaux tests.

9. Non-régression

Utilise C2 comme nouvelle référence :

* 136 tests réussis.
* 27 échecs historiques identiques.
* 163 cas JUnit.
* 32 tables.
* 17 triggers.
* Head Alembic 0004_orq_saga_outbox.

Exécute les tests ciblés et la suite complète.

Compare les node IDs, traces normalisées et signatures des échecs avec C2.

Vérifie également la compilation Python et pip check.

Aucune nouvelle migration Alembic ni modification du schéma SQL n’est attendue.

10. Limitation du périmètre

C3a doit rester exclusivement consacrée au portage de la logique de réconciliation T1.

Ne commence pas :

* C3b : Temporal Foundation.
* C3c : contrats et Workflow V2.
* C3d : Store PostgreSQL.
* C3e : Activities V2.
* Worker Temporal.
* Enqueue transactionnel.
* Dispatcher.
* API.
* Frontend.
* Repair.

Ne modifie aucun comportement applicatif existant pour activer notre provisioning.

11. Contraintes impératives

* Micro-MR minimale et facilement explicable.
* Réutilisation maximale du code et des tests existants.
* Aucune opération Git ou GitLab.
* Aucun changement Kubernetes.
* Aucun déploiement.
* Aucun appel réel à Orq.ai.
* Aucun Workflow Temporal distant.
* Aucune modification des conteneurs, volumes, réseaux ou bases existants.
* Aucune modification des scripts 01, 02 et 03.
* Aucune modification du Docker Compose original.
* Aucune modification des configurations de lancement VS Code.
* Aucune modification du pont Alembic.
* Préservation intégrale de tous les espaces précédents.

La procédure habituelle de lancement du LMC doit rester inchangée.

Temporal et Orq.ai doivent rester optionnels pour les fonctionnalités existantes.

12. Documentation et restitution

Crée une documentation technique dédiée en anglais :

documentation/C3A_ORQ_PROJECT_RECONCILIATION.md

Mets à jour LMC_WORKSPACE_INDEX.md et la roadmap de convergence.

Pour chaque fichier créé ou modifié, documente :

* Son origine.
* Son rôle.
* Le comportement avant et après.
* Le code directement réutilisé.
* Les adaptations nécessaires.
* Leur justification.
* Les alternatives éventuelles.

Présente-moi en français :

* Les fichiers portés.
* Les corrections historiques conservées.
* Les adaptations spécifiques à la nouvelle base.
* Les résultats réels des tests.
* Les garanties effectivement validées.
* Les limites restantes.
* La compatibilité avec les futurs contrats, Store et Activities.
* La prochaine micro-MR C3b recommandée.

Notre objectif reste d’atteindre rapidement la parité fonctionnelle complète avec le Mock LMC depuis l’interface du véritable LMC lancé localement, en réutilisant le mécanisme Repair existant, avant tout déploiement en préproduction.

Tu peux commencer C3a dans ce périmètre. Ne commence pas C3b sans mon accord.