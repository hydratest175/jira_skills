Je valide C3d sur son périmètre de qualification locale.

Notre nouvelle référence est désormais :

* 384 cas JUnit.
* 357 cas JUnit réussis.
* 328 tests pytest réussis.
* 29 sous-tests réussis.
* 27 échecs historiques strictement identiques.
* 38 tests ciblés C3d réussis.
* 27 scénarios PostgreSQL réels réussis.
* Aucune nouvelle régression.
* PostgreSQL 18.4.
* 32 tables, 17 triggers, 4 fonctions, 85 index et 390 contraintes applicatives.
* Head Alembic unique : 0004_orq_saga_outbox.
* Aucune modification du schéma C2.

Nous pouvons maintenant commencer C3e — Concrete Provisioning Activities V2.

Cette étape constitue le dernier portage du travail précédemment développé jusqu’à MR7.

1. Espace de travail

Crée un nouvel espace local isolé :

/workspace/LEA_Workspace/lcc-c3e-provisioning-activities-v2

Utilise comme base cumulative :

/workspace/LEA_Workspace/lcc-c3d-postgresql-state-store

Notre référence LMC originale reste :

/workspace/LEA_Workspace/lcc_last_version/lcc

Préserve intégralement tous les espaces précédents.

Ne copie aucune métadonnée Git, aucun credential, fichier .env, environnement virtuel ou cache inutile.

2. Réutilisation de MR7

Notre objectif est de porter les Activities V2 déjà développées et qualifiées dans MR7, en les raccordant aux composants désormais disponibles dans C3a, C3c et C3d.

Relis notamment :

* lcc-mr7-postgresql-state-store
* lcc-mr6-provisioning-contracts
* lcc-t3-orq-project-workflow
* POSTGRESQL_STATE_STORE_MR7.md
* C2_ORQ_SAGA_OUTBOX.md
* C3A_ORQ_PROJECT_RECONCILIATION.md
* C3B_TEMPORAL_FOUNDATION.md
* C3C_PROVISIONING_WORKFLOW_V2.md
* C3D_POSTGRESQL_STATE_STORE.md
* LMC_SAGA_REPAIR_CONVERGENCE_ANALYSIS.md
* LMC_WORKSPACE_INDEX.md
* La roadmap de convergence.

Porte principalement le fichier historique :

backend/app/orq_project_activities_v2.py

Ainsi que les tests et interfaces strictement nécessaires à son fonctionnement.

Vérifie les chemins exacts dans les espaces historiques.

Réutilise au maximum le code existant.

Ne redéveloppe ni le Store, ni la réconciliation, ni le Workflow.

3. Architecture à respecter

Les responsabilités sont désormais les suivantes :

* C3a : logique de réconciliation et gateway Orq.
* C3b : fondation Temporal optionnelle.
* C3c : contrats et Workflow déterministe V2.
* C3d : état désiré canonique et Store PostgreSQL.
* C3e : raccordement des Activities concrètes aux composants précédents.

Les Activities doivent constituer la couche d’exécution reliant les contrats du Workflow aux services métier.

Elles ne doivent pas introduire une seconde logique de réconciliation ou de persistance.

La source autoritative du statut métier reste ProjectOrqSaga.

La source autoritative de l’identité distante reste orq_project_mappings.

L’outbox reste responsable de la livraison des demandes de démarrage Temporal.

Ne recrée pas orq_project_provisioning_operations.

Aucune double écriture.

4. Les quatre Activities V2

Porte les quatre Activities historiques correspondant aux responsabilités suivantes :

1. Chargement et validation du contexte.
2. Réconciliation du projet Orq.
3. Persistance du mapping vérifié.
4. Finalisation de l’opération.

Conserve leurs noms contractuels, signatures, types d’entrée et de sortie et leur compatibilité avec le Workflow V2 de C3c.

Vérifie les noms exacts dans le code existant.

Utilise directement les méthodes du Store C3d et la fonction reconcile_orq_project() de C3a.

Les Activities doivent rester injectables et testables indépendamment d’un serveur Temporal.

Ne crée pas encore de Worker exécutable.

5. Activity de chargement du contexte

Réutilise le Store afin de vérifier :

* operation_ref.
* project_ref.
* Identité interne du projet.
* Génération.
* Version du contrat V2.
* Mode.
* Version et hash désirés.
* Statut de l’opération.
* Mapping existant.
* Éventuelles preuves d’une mutation antérieure.

Le contexte chargé ne doit jamais être considéré comme une autorisation permanente de mutation.

La validation autoritative doit être répétée au moment de la réservation durable.

Rejette les contextes obsolètes, incohérents ou non autorisés par les règles métier existantes.

Préserve le traitement STALE_CONTEXT.

Ne transporte aucun credential ni payload sensible dans les résultats destinés à Temporal.

6. Activity de réconciliation

Réutilise directement la logique C3a.

Préserve notamment :

* Aucune adoption uniquement sur la base du nom.
* Réutilisation uniquement via une identité distante vérifiée.
* Distinction entre candidat et identité confirmée.
* Validation stricte des réponses Orq.
* Absence de retry automatique de transport mutatif.
* Absence de DELETE ou compensation automatique.
* Conservation de UNKNOWN_OUTCOME.

Les lectures et vérifications distantes doivent rester distinctes du chemin mutatif.

Ne réserve pas une mutation inutilement lorsque la réconciliation peut aboutir uniquement par des lectures ou par la réutilisation d’un mapping vérifié.

Utilise des gateways factices pour tous les tests impliquant Orq.

7. Réservation durable avant POST

Ce point constitue le principal critère de validation de C3e.

Raccorde effectivement le chemin create_project() à la réservation durable C3d.

Avant tout POST mutatif :

* Revalider le contexte autoritatif.
* Recalculer le hash désiré selon les mécanismes C3d.
* Vérifier l’éligibilité de l’opération.
* Effectuer la réservation CAS.
* Persister mutation_attempted=True.
* Confirmer le commit de la transaction.
* Libérer les verrous et la session SQL.

L’appel HTTP mutatif ne doit pouvoir être envoyé qu’après confirmation effective de cette réservation.

Un refus de réservation, un conflit CAS, un rollback ou une incertitude sur le commit doivent empêcher l’envoi du POST.

Aucune transaction SQL ne doit rester ouverte pendant les appels réseau.

Vérifie qu’aucun chemin alternatif de création ne peut contourner cette protection.

Ne considère pas le simple état IN_PROGRESS ou mutation_attempted=True comme une autorisation suffisante pour rejouer une création.

Une Activity redélivrée après interruption ne doit jamais réutiliser une ancienne réservation pour envoyer un second POST.

8. Retry et interruptions

Conserve les garanties du Workflow V2 :

* maximum_attempts=1 pour l’Activity mutative.
* Retry logique uniquement pour RETRYABLE avec mutation_attempted=False.
* Aucun retry de transport mutatif.
* Aucun retry automatique après une mutation potentielle.

Teste les différentes fenêtres d’interruption :

1. Avant la réservation.
2. Pendant la transaction de réservation.
3. Après le commit mais avant le POST.
4. Pendant le POST.
5. Après la mutation distante mais avant la persistance du candidat.
6. Après persistance du candidat mais avant vérification complète.
7. Après persistance de l’identité confirmée mais avant le mapping.
8. Après persistance du mapping mais avant finalisation.
9. Après finalisation mais avant retour du résultat de l’Activity.

Pour chaque scénario, documente les preuves persistées, le comportement d’une reprise et le nombre d’appels mutatifs effectivement observés.

Un crash après réservation mais avant POST peut conduire à un état conservateur nécessitant une réconciliation.

Ne cherche pas à optimiser cette situation au prix d’un risque de double création.

Ne revendique aucune garantie exactly-once entre PostgreSQL et Orq.

9. Persistance du candidat et du résultat confirmé

Réutilise les mécanismes CAS C3d.

Lorsqu’un résultat candidat est disponible, conserve-le conformément aux règles existantes.

Un candidat ne doit jamais être considéré comme un mapping autoritatif.

Lorsqu’une identité Orq est vérifiée, persiste durablement :

* L’identifiant Orq confirmé.
* La clé projet Orq vérifiée.
* L’action de réconciliation.
* Les informations de résultat nécessaires.

La persistance du résultat confirmé doit intervenir avant la finalisation du mapping.

En cas de perte du résultat avant sa persistance, conserve au minimum la preuve de réservation durable et l’état incertain approprié.

En cas d’échec du mapping après confirmation de l’identité distante, conserve le résultat dans ProjectOrqSaga et utilise NEEDS_RECONCILIATION avec LOCAL_PERSISTENCE.

Ne recrée jamais automatiquement le projet distant pour résoudre un problème de persistance locale.

10. Activity de persistance du mapping

Utilise exclusivement les mécanismes du Store C3d.

Vérifie :

* L’identité de l’opération.
* La génération.
* La version et le hash.
* L’identité distante confirmée.
* Les préconditions CAS.
* La cohérence avec un éventuel mapping existant.

Une ancienne génération ou un résultat tardif ne doit jamais écraser un mapping plus récent.

La répétition d’une persistance strictement identique doit rester idempotente lorsque les préconditions le permettent.

Cette Activity ne doit déclencher aucun appel mutatif Orq.

11. Activity de finalisation

Réutilise les transitions autorisées par ProjectOrqSaga.

Préserve les états :

* PENDING.
* IN_PROGRESS.
* SUCCEEDED.
* FAILED.
* NEEDS_RECONCILIATION.

Respecte les classifications établies dans C3c et C3d, notamment :

* STALE_CONTEXT.
* UNKNOWN_OUTCOME.
* ACTIVITY_OUTCOME_LOST.
* LOCAL_PERSISTENCE.
* CONFLICT.

Ne transforme jamais une mutation potentiellement exécutée en simple échec autorisant implicitement une nouvelle création.

Une finalisation répétée et cohérente doit rester idempotente.

Une finalisation tardive ou contradictoire doit être rejetée.

La finalisation ne doit jamais supprimer les opérations historiques.

12. Diagnostics et sécurité

C3d indique que les diagnostics textuels ne sont pas écrits par le Store et que leur sanitization appartient aux futures couches.

Prends cette limitation en compte pour les Activities.

Les erreurs retournées ou persistées par les Activities doivent utiliser les codes et classifications contrôlés déjà disponibles.

Réutilise les champs de support existants lorsque cela est compatible avec les contrats.

Aucun secret, token, clé API, credential, header HTTP, payload arbitraire, réponse SDK complète ou message d’exception brut ne doit être exposé :

* Dans les résultats des Activities.
* Dans les exceptions destinées à Temporal.
* Dans les logs.
* Dans ProjectOrqSaga.
* Dans les futurs historiques Temporal.

Teste explicitement les erreurs contenant des données sensibles synthétiques.

Ne développe pas encore un nouveau système d’audit ou de support.

Documente les garanties de sanitization effectivement implémentées et celles qui restent à traiter dans C7, C8 et C9.

13. Temporal optionnel

Préserve intégralement C3b.

* Temporal reste désactivé par défaut.
* Le SDK reste optionnel.
* Les dépendances normales du LMC restent inchangées.
* Aucun Worker ne démarre automatiquement.
* Aucun import des Activities depuis le démarrage standard FastAPI ne doit rendre Temporal obligatoire.
* Aucun couplage au lifespan FastAPI.

Vérifie les imports et le fonctionnement normal du LMC sans SDK Temporal installé.

Les composants nécessitant explicitement le SDK doivent rester isolés.

La création et l’enregistrement du Worker métier appartiennent à C4.

14. Qualification des Activities

Réutilise les tests historiques MR7 et complète-les lorsque nécessaire pour vérifier le raccordement effectif des composants.

Utilise notamment :

* Les contrats réels C3c.
* Le Store réel C3d.
* PostgreSQL 18.4 réel.
* La réconciliation réelle C3a.
* Des gateways HTTP factices ou des transports simulés.

Vérifie au minimum :

* Création nominale simulée.
* Réutilisation d’un mapping valide sans POST.
* Rejet d’un contexte obsolète.
* Collision ou incohérence d’identité.
* Refus de réservation.
* Concurrence entre deux exécutions.
* Un seul POST observé lorsqu’une création est autorisée.
* Commit observable depuis une session indépendante avant le POST.
* Absence de verrou SQL pendant le POST simulé.
* Absence de POST après échec du commit.
* Redélivrance d’une Activity après réservation.
* Timeout après mutation potentielle.
* Perte du résultat.
* Persistance et promotion du candidat.
* Résultat confirmé conservé malgré un échec de mapping.
* Finalisation idempotente.
* Résultat tardif.
* Ancienne génération.
* Conservation de UNKNOWN_OUTCOME après redémarrage.
* Sanitization des erreurs.
* Absence de compensation DELETE.
* Rejet du mode PLAN dans le chemin APPLY.

Pour les scénarios critiques, évite de mocker simultanément le Store et la réconciliation : nous devons vérifier leur interaction réelle.

Lorsque cela est possible, simule une interruption réelle entre deux transactions ou via une nouvelle instance du Store.

Distingue les interruptions réellement reproduites des exceptions et pertes de résultat simulées.

Aucun serveur Temporal local ou distant ne doit être utilisé pour cette étape.

Aucun appel réel à Orq.ai.

15. Non-régression

Utilise C3d comme nouvelle référence :

* 384 cas JUnit.
* 357 réussites JUnit.
* 328 tests pytest réussis.
* 29 sous-tests réussis.
* 27 échecs historiques identiques.
* Head Alembic 0004_orq_saga_outbox.
* 32 tables applicatives.
* 17 triggers.
* 4 fonctions.
* 85 index.
* 390 contraintes applicatives.

Exécute :

* Les tests ciblés des Activities.
* Les tests d’intégration PostgreSQL réels.
* Les tests cumulés C1 à C3e.
* La suite complète.
* La compilation Python.
* pip check.
* Les vérifications pertinentes sans SDK Temporal.

Compare les node IDs, traces normalisées et signatures des échecs historiques avec C3d.

Distingue les tests portés, adaptés et nouvellement ajoutés.

Vérifie que le schéma SQL, les migrations et les modèles ORM restent inchangés.

Aucune nouvelle migration Alembic n’est attendue.

16. Décisions encore ouvertes

Conserve explicitement les limitations précédemment identifiées :

* Absence de compteur de version désirée indépendant.
* Équipes Orq non gérées.
* Politique de modification concurrente du projet.
* Hard delete bloqué après opération.
* Retry manuel à configuration identique.
* project_ref encore mutable en base.
* Taxonomie d’audit.
* Résolution privilégiée de UNKNOWN_OUTCOME.
* Qualification Python sur la version cible du LMC.
* Audit CVE.
* Replay Temporal réel.
* Qualification du pont Alembic et de la procédure standard.
* Compatibilité des migrations avec les bases historiques.

Documente notamment l’ordre de verrouillage du Store C3d afin que les futurs composants C5 et C6 restent compatibles et n’introduisent pas d’ordre de verrouillage contradictoire.

Ne résous pas silencieusement ces décisions dans C3e.

17. Limitation du périmètre

C3e doit rester strictement consacrée au portage et au raccordement des Activities V2.

Ne commence pas :

* C4 : Worker métier.
* C5 : allocation de génération et enqueue transactionnel.
* C6 : dispatcher Temporal.
* C7 : Repair backend.
* C8 : frontend.
* C9 : résolution privilégiée.
* Provisioning réel Orq.
* Provisioning des autres ressources Orq.

N’active aucun comportement métier dans le LMC existant.

18. Contraintes impératives

* Micro-MR minimale et facilement explicable.
* Réutilisation maximale du travail existant.
* Aucune opération Git ou GitLab.
* Aucun changement Kubernetes.
* Aucun déploiement.
* Aucun appel distant Orq ou Temporal.
* Aucun serveur Temporal local.
* Aucun Worker connecté.
* Aucune modification des conteneurs, volumes, réseaux ou bases existants.
* Seules les ressources Docker temporaires strictement isolées nécessaires aux tests sont autorisées.
* Aucune modification de Docker Compose.
* Aucune modification des migrations existantes.
* Aucune modification des scripts 01, 02 et 03.
* Aucune modification des configurations VS Code.
* Aucune modification du pont Alembic.
* Préservation intégrale de tous les espaces précédents.

La procédure habituelle de lancement du LMC doit rester strictement inchangée.

Temporal et Orq.ai doivent rester optionnels.

19. Documentation et restitution

Crée une documentation technique dédiée en anglais :

documentation/C3E_PROVISIONING_ACTIVITIES_V2.md

Mets à jour LMC_WORKSPACE_INDEX.md et la roadmap de convergence.

Documente pour chaque fichier :

* Son origine.
* Son rôle.
* Le comportement avant et après.
* Le code directement réutilisé de MR7.
* Les adaptations nécessaires.
* Leur justification.
* Les alternatives éventuelles.

Présente-moi en français :

* Les fichiers portés.
* Le fonctionnement des quatre Activities.
* Leur raccordement à C3a, C3c et C3d.
* La preuve du commit avant POST.
* Les résultats des scénarios de concurrence et d’interruption.
* Les garanties réellement vérifiées.
* Les résultats de non-régression.
* Les limitations restantes.

Réalise également un bilan synthétique du portage complet C0 à C3e.

Identifie les éventuels composants historiques encore non portés et vérifie que nous disposons de toutes les fondations nécessaires pour commencer C4.

Prépare uniquement une proposition de périmètre C4, concernant le Worker métier V2 séparé, optionnel et désactivé par défaut.

Notre objectif reste d’atteindre rapidement la parité fonctionnelle complète avec le Mock LMC depuis l’interface du véritable LMC lancé localement, en réutilisant les mécanismes existants de support et de Repair, avant tout déploiement en préproduction.

Tu peux commencer C3e dans ce périmètre. Ne commence pas C4 sans mon accord.