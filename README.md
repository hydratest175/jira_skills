Je valide C3c sur son périmètre de qualification locale.

Notre nouvelle référence est désormais :

* 346 cas JUnit.
* 319 cas JUnit réussis.
* 290 tests pytest réussis.
* 29 sous-tests réussis.
* 27 échecs historiques strictement identiques.
* 64 tests ciblés réussis avec SDK Temporal.
* 43 tests ciblés réussis sans SDK et 4 tests SDK-dépendants ignorés proprement.
* Aucune nouvelle régression.
* Head Alembic unique : 0004_orq_saga_outbox.
* 32 tables applicatives.
* Aucune nouvelle migration ni modification ORM.

Nous pouvons maintenant commencer C3d — PostgreSQL State Store.

1. Espace de travail

Crée un nouvel espace local isolé :

/workspace/LEA_Workspace/lcc-c3d-postgresql-state-store

Utilise comme base cumulative :

/workspace/LEA_Workspace/lcc-c3c-provisioning-workflow-v2

Notre référence LMC originale reste :

/workspace/LEA_Workspace/lcc_last_version/lcc

Préserve intégralement tous les espaces précédents.

Ne copie aucune métadonnée Git, aucun credential, fichier .env, environnement virtuel ou cache inutile.

2. Réutilisation de MR7

Notre objectif est de porter directement le Store PostgreSQL déjà développé et qualifié dans MR7, en l’adaptant à notre nouvelle architecture de persistance.

Relis notamment :

* lcc-mr7-postgresql-state-store
* lcc-mr6-provisioning-contracts
* lcc-mr5-provisioning-operations-outbox
* POSTGRESQL_STATE_STORE_MR7.md
* C1_ORQ_PROJECT_MAPPING.md
* C2_ORQ_SAGA_OUTBOX.md
* C3A_ORQ_PROJECT_RECONCILIATION.md
* C3C_PROVISIONING_WORKFLOW_V2.md
* LMC_SAGA_REPAIR_CONVERGENCE_ANALYSIS.md
* LMC_WORKSPACE_INDEX.md
* La roadmap de convergence.

Porte principalement les composants historiques correspondant à :

* orq_project_desired_state.py
* orq_project_state_store.py
* Les interfaces et contrats strictement nécessaires au Store.
* Les tests unitaires associés.
* Les tests d’intégration PostgreSQL associés.

Vérifie les chemins exacts dans les espaces historiques.

Réutilise directement notre implémentation lorsque cela est possible.

Ne redéveloppe pas une nouvelle couche de persistance.

Ne porte pas encore les Activities V2 concrètes : elles appartiennent à C3e.

3. Adaptation à ProjectOrqSaga

Notre architecture de persistance est désormais constituée de :

* orq_project_mappings : identité distante autoritative et mapping durable.
* saga_project_orq : unique table d’opérations, statuts, mutations, résultats et diagnostics.
* orq_project_temporal_start_outbox : état de livraison Temporal.

Adapte le Store historique afin qu’il utilise directement ProjectOrqSaga.

Remplace les références à l’ancien modèle OrqProjectProvisioningOperation.

Prends notamment en compte :

* operation_ref comme clé primaire.
* operation_started_at à la place de started_at.
* workflow_contract_version=2 explicite pour les opérations V2.
* Les statuts spécifiques à Orq.
* Les champs de support et de diagnostic existants.
* Les résultats candidats et confirmés.
* Les contraintes introduites dans C2.
* Les nouvelles correspondances définies dans C3c.

Ne recrée jamais orq_project_provisioning_operations.

Ne mets en place aucune double écriture.

Ne modifie pas les autres Sagas du LMC.

Aucune nouvelle migration Alembic ni modification ORM n’est attendue dans C3d.

Si une incompatibilité structurelle indispensable est découverte, présente-la avant toute modification du schéma.

4. État désiré canonique

Porte le mécanisme historique de construction et de hash de l’état désiré.

Conserve le périmètre fonctionnel précédemment validé :

* Business Line.
* Sensibilité du projet.
* Nom.
* Description.
* teams=None.

teams=None signifie explicitement que les équipes Orq ne sont pas gérées dans notre périmètre actuel.

Aucune suppression, modification ou réconciliation d’équipe Orq ne doit être déclenchée par cette valeur.

Préserve :

* La canonicalisation déterministe.
* Le hash SHA-256.
* La validation stricte des données.
* La stabilité du hash pour un état équivalent.
* La modification du hash lorsque la configuration pertinente change.

Vérifie la correspondance des champs avec les modèles de la nouvelle version du LMC.

N’introduis pas de nouvelles règles de normalisation susceptibles de modifier silencieusement les hashes historiques.

Le projet LMC ne dispose pas encore d’un compteur de version désirée indépendant.

Conserve cette limitation : la version est vérifiée contre l’opération persistée et le hash est recalculé depuis l’état réel du projet.

Ne crée pas de compteur supplémentaire dans C3d.

5. Validation autoritative du contexte

Le Store doit vérifier réellement les informations persistées avant toute transition :

* operation_ref.
* project_ref.
* Identité interne du projet.
* Génération.
* Mode.
* Version désirée.
* Hash désiré.
* Version du contrat.
* Statut courant de l’opération.
* Identité Orq éventuellement déjà associée.

Un contexte obsolète, incohérent ou contradictoire doit être rejeté de manière contrôlée.

Préserve la classification STALE_CONTEXT.

Une opération terminale ne doit pas être réécrite par un résultat tardif.

Une ancienne génération ne doit pas pouvoir modifier le mapping d’une génération plus récente.

Une opération présentant déjà un résultat ambigu ne doit pas pouvoir redevenir automatiquement éligible à une nouvelle mutation.

6. Réservation durable avant mutation

Reprends la stratégie de réservation PostgreSQL développée dans MR7.

Préserve impérativement :

* Recalcul du hash autoritatif sous verrou immédiatement avant la réservation.
* Validation de la génération, de l’opération et du snapshot.
* Transaction courte.
* Réservation protégée par CAS.
* Passage approprié à IN_PROGRESS.
* Persistance irréversible de mutation_attempted=True.
* Commit effectif avant que l’appel mutatif puisse être envoyé.
* Une seule réservation concurrente gagnante.

Ne conserve aucun verrou SQL pendant un futur appel réseau.

Ne confonds pas une lecture distante avec une mutation distante.

La réservation doit protéger précisément le chemin qui pourra déclencher create_project().

Si un crash intervient après la réservation mais avant la confirmation du résultat, une nouvelle tentative automatique ne doit jamais pouvoir rejouer aveuglément la création.

Il est acceptable qu’un crash intervenu après la réservation mais avant l’envoi réel conduise à un état conservateur nécessitant une réconciliation.

La sécurité contre les doublons est prioritaire sur une reprise automatique non prouvée.

Dans C3d, implémente et teste les primitives de réservation du Store, sans les raccorder encore à une Activity réelle ou à un appel HTTP Orq.

7. CAS et concurrence

Réutilise les opérations CAS précédemment développées.

Vérifie les protections fondées sur :

* L’identité de l’opération.
* La génération.
* La version.
* Le hash.
* Le statut attendu.
* L’identité distante éventuellement déjà vérifiée.

Les opérations doivent être transactionnelles.

Un résultat concurrent, obsolète ou contradictoire ne doit jamais pouvoir écraser une information autoritative.

Ne considère pas la seule présence de la colonne generation comme une protection CAS effective.

Teste réellement les comportements concurrents avec plusieurs sessions PostgreSQL indépendantes.

L’allocation de nouvelles générations et l’enqueue transactionnel restent hors périmètre C3d.

8. Persistance des résultats Orq

Préserve la distinction historique entre :

* Identifiant candidat.
* Identité distante confirmée.
* Mapping durable.
* Résultat métier final.

Un candidat ne doit jamais être utilisé comme mapping autoritatif.

La promotion d’un candidat vers une identité confirmée doit respecter les contraintes C2.

Lorsqu’une identité est confirmée, préserve le mécanisme MR7 permettant de persister durablement :

* L’identifiant Orq.
* La clé projet Orq vérifiée.
* L’action de réconciliation.
* Les informations de résultat nécessaires.

Cette persistance doit être effectuée avant la finalisation du mapping afin de permettre une reprise sûre si celle-ci échoue.

En cas d’échec de persistance du mapping après enregistrement du résultat confirmé :

* Conserver les preuves disponibles.
* Utiliser NEEDS_RECONCILIATION et LOCAL_PERSISTENCE selon les contrats existants.
* Permettre une finalisation locale idempotente lorsque les préconditions sont vérifiées.
* Ne jamais recréer automatiquement le projet distant.

Documente explicitement la fenêtre résiduelle où un crash pourrait survenir avant la persistance du résultat distant.

Ne revendique aucune garantie exactly-once entre PostgreSQL et Orq.

9. Gestion des résultats ambigus

Conserve les mécanismes MR7 concernant :

* UNKNOWN_OUTCOME.
* ACTIVITY_OUTCOME_LOST.
* LOCAL_PERSISTENCE.
* CONFLICT.
* NEEDS_RECONCILIATION.
* mutation_attempted.

Une opération ambiguë doit conserver son état et ses preuves après redémarrage du Store.

Le marqueur mutation_attempted ne doit jamais revenir à false.

Aucune nouvelle création automatique ne doit être autorisée en présence d’une mutation potentiellement exécutée et non résolue.

Ne développe aucun mécanisme de compensation DELETE.

Ne développe pas encore le mécanisme privilégié de résolution manuelle des résultats ambigus.

Celui-ci reste prévu dans C9.

10. Diagnostics, support et sécurité

Réutilise les champs et conventions de diagnostic existants de ProjectOrqSaga.

Vérifie que les futurs services pourront exposer :

* Des codes d’erreur contrôlés.
* Des messages de diagnostic bornés et assainis.
* Une référence de support.
* Le statut métier.
* Les informations nécessaires au Repair existant.

Aucun credential, token, clé API, payload arbitraire, réponse HTTP brute ou message d’exception non assaini ne doit être persisté ou journalisé.

La clé projet Orq vérifiée est un identifiant distant, pas une clé API.

Ne modifie pas encore les endpoints Repair ni les composants frontend.

Distingue les garanties de sanitization réellement implémentées dans le Store de celles qui devront être ajoutées dans les futures couches applicatives.

11. Tests PostgreSQL 18.4 réels

Cette étape nécessite une qualification réelle sur PostgreSQL, et pas uniquement des mocks.

Réutilise les scénarios historiques MR7 et adapte-les à ProjectOrqSaga.

Teste notamment :

* Validation d’un contexte correct.
* Rejet d’un contexte obsolète.
* Hash désiré modifié.
* Version ou génération incompatible.
* Version de contrat incompatible.
* Réservation concurrente depuis plusieurs sessions.
* Une seule réservation gagnante.
* Commit de la réservation avant retour au futur appelant.
* Rollback d’une réservation échouée.
* Persistance de mutation_attempted.
* Redémarrage du Store après réservation.
* Rejet d’une seconde réservation après mutation potentielle.
* Persistance d’un candidat.
* Promotion d’un candidat vers une identité vérifiée.
* Rejet d’un candidat contradictoire.
* Persistance d’un résultat confirmé.
* Échec simulé de persistance du mapping.
* Conservation du résultat confirmé.
* Finalisation locale idempotente.
* Mapping CAS concurrent.
* Résultat tardif.
* Ancienne génération.
* Opération terminale non réécrivable.
* UNKNOWN_OUTCOME persistant après redémarrage.
* Modification ou soft-delete concurrent du projet.
* Préservation des preuves après modification du projet.
* Absence de modification des autres Sagas.

Vérifie également la libération effective des transactions et verrous lorsque les méthodes du Store retournent.

Utilise uniquement PostgreSQL 18.4 et des ressources Docker temporaires strictement isolées.

Ne touche à aucune base, aucun volume, réseau ou conteneur existant.

N’effectue aucun appel réel à Orq.ai.

12. Compatibilité avec les étapes précédentes

Vérifie que le Store est compatible avec :

* Le mapping C1.
* ProjectOrqSaga et les contraintes C2.
* La réconciliation C3a.
* La fondation Temporal C3b.
* Les contrats et le Workflow V2 C3c.

Préserve les contrats existants.

N’introduis aucune dépendance obligatoire à Temporal dans la logique de persistance PostgreSQL.

Le Store doit rester testable indépendamment de Temporal.

Ne développe pas une seconde logique de réconciliation Orq dans le Store.

13. Décisions fonctionnelles encore ouvertes

Conserve explicitement les limitations identifiées précédemment :

* Absence de compteur de version désirée indépendant sur le projet.
* Équipes Orq non gérées.
* Politique de modification concurrente du projet encore ouverte.
* Hard delete bloqué même après une opération terminée.
* Retry manuel à configuration identique actuellement bloqué.
* project_ref encore mutable directement en base.
* Taxonomie d’audit système à définir.
* Résolution privilégiée des résultats ambigus non implémentée.

Ne résous pas silencieusement ces questions en modifiant les règles métier ou le schéma.

Identifie leur impact sur le futur provisioning depuis l’interface locale.

14. Non-régression

Utilise C3c comme nouvelle référence :

* 346 cas JUnit.
* 319 réussites JUnit.
* 290 tests pytest réussis.
* 29 sous-tests réussis.
* 27 échecs historiques identiques.
* Head Alembic 0004_orq_saga_outbox.
* 32 tables applicatives.

Exécute :

* Les tests ciblés du Store.
* Les tests PostgreSQL réels.
* Les tests cumulés C1 à C3d.
* La suite complète.
* La compilation Python.
* pip check.

Compare les node IDs, traces normalisées et signatures des échecs historiques avec C3c.

Distingue les tests directement portés de MR7, les tests adaptés à ProjectOrqSaga et les nouveaux tests.

Ne cherche pas à reproduire artificiellement les nombres de tests historiques.

Vérifie que les migrations, les modèles ORM et le catalogue applicatif restent conformes à C2.

Conserve la distinction entre tests pytest, sous-tests et cas JUnit.

15. Limites de qualification héritées

Conserve dans la roadmap :

* La qualification sur la version Python cible du LMC.
* L’audit CVE encore bloqué par les restrictions réseau.
* Le replay réel du Workflow V2 sur un historique Temporal compatible.
* La qualification réelle du Worker métier.
* La qualification du pont Alembic dans la procédure standard.
* La compatibilité des migrations avec les bases historiques.

Ne présente aucune de ces validations comme réalisée si elle ne l’a pas été.

16. Limitation du périmètre

C3d doit rester strictement consacrée au Store PostgreSQL et au hash canonique de l’état désiré.

Ne commence pas :

* C3e : Activities V2 concrètes.
* C4 : Worker métier.
* C5 : allocation de génération et enqueue transactionnel.
* C6 : dispatcher Temporal.
* C7 : Repair backend.
* C8 : frontend.
* C9 : résolution privilégiée.
* Provisioning réel Orq.
* Provisioning des autres ressources Orq.

Aucun comportement métier ne doit être activé dans le LMC existant.

17. Contraintes impératives

* Micro-MR minimale et facilement explicable.
* Réutilisation maximale du code et des tests historiques.
* Aucune opération Git ou GitLab.
* Aucun changement Kubernetes.
* Aucun déploiement.
* Aucun appel distant Orq ou Temporal.
* Aucun serveur Temporal local.
* Aucune modification des conteneurs, volumes, réseaux ou bases existants.
* Seules les ressources Docker temporaires isolées nécessaires aux tests sont autorisées.
* Aucune modification de Docker Compose.
* Aucune modification des migrations existantes.
* Aucune modification du pont Alembic.
* Aucune modification des scripts 01, 02 et 03.
* Aucune modification des configurations de lancement VS Code.
* Préservation intégrale de tous les espaces précédents.

La procédure habituelle de lancement du LMC doit rester strictement inchangée.

Temporal et Orq.ai doivent rester optionnels.

18. Documentation et restitution

Crée une documentation technique dédiée en anglais :

documentation/C3D_POSTGRESQL_STATE_STORE.md

Mets à jour LMC_WORKSPACE_INDEX.md et la roadmap de convergence.

Pour chaque fichier créé ou modifié, documente :

* Son origine.
* Son rôle.
* Le comportement avant et après.
* Le code directement réutilisé de MR7.
* Les adaptations spécifiques à ProjectOrqSaga.
* Leur justification.
* Les alternatives éventuelles.

Présente-moi en français :

* Les fichiers portés et modifiés.
* Les adaptations spécifiques à ProjectOrqSaga.
* Le fonctionnement du hash canonique.
* Le fonctionnement des transactions et du CAS.
* Le cycle de réservation durable avant mutation.
* Les garanties réellement vérifiées sur PostgreSQL.
* Les scénarios de concurrence et de crash testés.
* Les résultats réels de non-régression.
* Les limites et décisions restantes.
* Les prérequis pour C3e.

Notre objectif reste d’atteindre rapidement la parité fonctionnelle complète avec le Mock LMC depuis l’interface du véritable LMC lancé localement, en réutilisant les mécanismes existants de support et de Repair, avant tout déploiement en préproduction.

Tu peux commencer C3d dans ce périmètre. Ne commence pas C3e sans mon accord.