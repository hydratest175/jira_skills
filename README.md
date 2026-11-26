Je valide C4 sur son périmètre de qualification locale.

Notre nouvelle référence est désormais :

* 451 cas JUnit.
* 424 cas JUnit réussis.
* 395 tests pytest réussis.
* 29 sous-tests réussis.
* 27 échecs historiques strictement identiques.
* 57 tests ciblés C4 réussis.
* Aucune nouvelle régression.
* SDK Temporal 1.18.2.
* PostgreSQL 18.4.
* Head Alembic unique : 0004_orq_saga_outbox.
* 32 tables, 17 triggers, 4 fonctions, 85 index et 390 contraintes.
* Aucune modification du schéma.

Avant de commencer C5, nous allons réaliser C4-Q : qualification réelle du Worker métier V2 avec Temporal préproduction et Orq simulé.

1. Espace de travail

Utilise comme référence :

/workspace/LEA_Workspace/lcc-c4-temporal-provisioning-worker

Crée un espace de qualification distinct si nécessaire :

/workspace/LEA_Workspace/lcc-c4q-temporal-real-qualification

Préserve intégralement C4 et tous les espaces précédents.

Notre référence LMC originale reste :

/workspace/LEA_Workspace/lcc_last_version/lcc

C4-Q est une étape de qualification, pas une nouvelle fonctionnalité applicative.

Ne modifie pas le code applicatif qualifié de C4.

Si une anomalie nécessite une correction, présente-la avec les preuves et propose une correction ciblée avant de modifier le code.

2. Documentation et historique

Relis notamment :

* TEMPORAL_T2_FOUNDATION.md
* C3B_TEMPORAL_FOUNDATION.md
* C3C_PROVISIONING_WORKFLOW_V2.md
* C3D_POSTGRESQL_STATE_STORE.md
* C3E_PROVISIONING_ACTIVITIES_V2.md
* C4_TEMPORAL_PROVISIONING_WORKER.md
* C4_TEMPORAL_REAL_QUALIFICATION_PLAN.md
* LMC_SAGA_REPAIR_CONVERGENCE_ANALYSIS.md
* LMC_WORKSPACE_INDEX.md
* La roadmap de convergence.

Retrouve également les commandes et résultats de la qualification réelle T2.

Nous avons déjà réussi :

* La connexion au serveur Temporal préproduction.
* La validation de la santé du serveur.
* La visibilité du namespace default.
* La connexion depuis le Dev Container via un tunnel établi depuis le DevEnv.
* L’exécution réelle du Workflow LmcTemporalNoop.
* L’utilisation d’une Task Queue de test dédiée.

Ne recommence pas toute la recherche réseau, Kubernetes ou Artifactory.

Réutilise les mécanismes précédemment qualifiés après avoir vérifié leur disponibilité actuelle.

3. Répartition des responsabilités

Software Companion fonctionne depuis le Dev Container.

Il n’a pas directement accès à kubectl ni au DevEnv.

Je réaliserai personnellement les commandes Kubernetes nécessaires depuis le DevEnv, comme pendant T2.

Lorsque mon intervention est nécessaire :

* Donne-moi les commandes exactes à exécuter.
* Précise dans quel terminal les exécuter.
* Explique brièvement leur objectif.
* Indique le résultat attendu.
* Attends mon retour avant de poursuivre les opérations dépendantes.

Tu peux rechercher les commandes historiques dans notre documentation locale.

Ne tente pas d’installer gcloud, kubectl, Temporal CLI ou de récupérer mes credentials DevEnv.

Ne modifie pas le Dev Container pour obtenir un accès Kubernetes.

4. Revalidation de la connexion Temporal

Réutilise le mécanisme de connexion précédemment qualifié pendant T2.

Vérifie :

* Le tunnel depuis le DevEnv.
* L’accessibilité depuis le Dev Container.
* L’identité du cluster attendu.
* Le namespace autorisé.
* La santé du serveur.
* La compatibilité du SDK.
* Le mode TLS/authentification effectivement utilisé.

Ne suppose pas que les anciennes adresses réseau sont encore valides.

Ne modifie pas l’exposition réseau du cluster et ne contourne aucune restriction.

N’expose pas le tunnel au-delà du périmètre nécessaire au test.

Arrête-toi si l’environnement, les autorisations ou l’identité du cluster ne peuvent pas être confirmés.

5. Isolation de la qualification

Utilise exclusivement :

* Le serveur Temporal préproduction existant et autorisé.
* Une Task Queue de qualification unique.
* Un Worker local dans le Dev Container.
* Une base PostgreSQL 18.4 temporaire et isolée.
* Des projets LMC entièrement synthétiques.
* Des identités Orq entièrement synthétiques.
* Un gateway Orq factice.

La Task Queue doit respecter les conventions C4 :

lmc-orq-project-provisioning-v2-{12hex}

L’identité du Worker doit respecter les conventions correspondantes.

Génère un nouvel identifiant pour cette qualification et vérifie que la queue ne présente pas de poller inattendu.

Conserve la même queue et la même identité logique pendant les scénarios de redémarrage qui nécessitent de reprendre un Workflow existant.

La convention de nommage ne doit pas être présentée comme une garantie d’exclusivité distribuée.

Ne réutilise aucune queue de traitement de documents ni la queue no-op historique.

6. Interdiction effective des appels Orq réels

Ce point est impératif.

Le Worker utilisé pendant C4-Q ne doit jamais pouvoir atteindre le véritable service Orq.ai.

Utilise le mécanisme d’injection du gateway développé dans C4.

Le harness de qualification doit :

* Injecter obligatoirement un gateway factice.
* Refuser de démarrer si cette injection n’est pas effective.
* Ne charger aucun credential Orq.
* Ne charger aucun fichier .env provenant du LMC original.
* Ne permettre aucun fallback vers le gateway réel.
* Comptabiliser les appels de lecture et de mutation simulés.

Mets en place une protection locale, limitée au processus de qualification, contre les appels réseau Orq réels.

Cette protection ne doit pas modifier le firewall, les réseaux Docker existants ni les configurations réseau de l’entreprise.

Vérifie son efficacité avant tout démarrage de Workflow.

7. PostgreSQL temporaire

Crée uniquement les ressources Docker temporaires strictement nécessaires à la qualification.

Utilise PostgreSQL 18.4 et applique les migrations C4 sur une base neuve.

Vérifie :

* Le head Alembic 0004_orq_saga_outbox.
* Les 32 tables applicatives.
* La présence de ProjectOrqSaga.
* La présence du mapping et de l’outbox.
* L’absence de l’ancienne table orq_project_provisioning_operations.

Ne touche à aucune base, aucun conteneur, volume ou réseau existant.

Ne lance aucun reset sur la stack LMC originale.

8. Préparation du harness de qualification

C5 n’étant pas encore implémentée, prépare les opérations de test directement dans la base isolée via un mécanisme de test explicite.

Préserve les contraintes C2 et les contrats V2.

Le harness devra préparer :

* Un projet LMC synthétique.
* Une opération ProjectOrqSaga valide.
* Une génération valide.
* Un snapshot désiré cohérent.
* Le hash canonique correspondant.
* L’outbox de test nécessaire.
* Un Workflow ID déterministe conforme à C3c.

Le démarrage du Workflow sera effectué explicitement par le harness de qualification, et non par le Worker.

Le harness ne doit pas constituer une implémentation alternative de C5 ou C6.

Documente précisément que cette qualification contourne volontairement les futures couches enqueue et dispatcher, encore inexistantes.

9. Scénario nominal réel

Démarre le Worker métier V2 sur la queue dédiée, puis lance un véritable Workflow LmcOrqProjectProvisionV2 depuis le harness.

Vérifie dans l’historique Temporal l’exécution réelle des quatre Activities :

* lmc.orq_project.load_context.v2
* lmc.orq_project.reconcile_once.v2
* lmc.orq_project.persist_mapping.v2
* lmc.orq_project.record_outcome.v2

Vérifie dans PostgreSQL :

* La validation du contexte.
* La réservation durable.
* Le commit de mutation_attempted avant le POST simulé.
* La libération des verrous.
* La persistance du candidat.
* La persistance de l’identité confirmée.
* La création du mapping.
* La finalisation de ProjectOrqSaga.

Critères attendus :

* Workflow terminé.
* Saga SUCCEEDED.
* Mapping vérifié et cohérent.
* Exactement un POST simulé pour cette opération.
* Aucun appel Orq réel.
* Aucun DELETE.

10. Scénario de réutilisation

Prépare une opération distincte disposant d’un mapping autoritatif valide et d’une ressource Orq simulée correspondante.

Vérifie qu’un Workflow V2 réel peut réutiliser cette identité distante sans nouvelle création.

Critères attendus :

* Mapping cohérent.
* Opération correctement finalisée.
* Zéro POST simulé pour cette opération.

11. Scénario de redémarrage réel du Worker

Qualifie la reprise d’une exécution Temporal après interruption du processus Worker local.

Utilise une nouvelle opération de test.

Choisis un point d’interruption contrôlable permettant d’obtenir des preuves fiables, idéalement après la persistance du résultat confirmé et avant la finalisation.

Le mécanisme de synchronisation du test doit rester extérieur au code applicatif.

Vérifie :

* L’arrêt effectif du Worker de qualification.
* La conservation de l’état dans PostgreSQL.
* La conservation de l’historique Temporal.
* Le redémarrage du Worker sur la même queue.
* La reprise ou la classification correcte du Workflow.
* L’absence de second POST simulé.
* L’absence de perte du mapping ou des preuves persistées.

Le compteur d’appels simulés doit survivre au redémarrage du Worker afin de démontrer réellement l’absence de doublon.

Distingue un arrêt gracieux, un arrêt forcé du processus et une exception simulée.

Ne présente pas ces différents scénarios comme équivalents.

N’arrête jamais un Worker existant autre que celui créé par notre qualification.

12. Scénario de résultat ambigu

Qualifie également, avec une opération distincte, un résultat ambigu après mutation simulée.

Le gateway factice doit permettre de simuler une mutation dont la réponse est perdue ou incertaine.

Vérifie :

* La persistance du marqueur mutation_attempted.
* La classification appropriée du résultat.
* La conservation des preuves.
* L’état NEEDS_RECONCILIATION lorsque prévu par les contrats.
* L’absence de nouvelle création automatique.
* L’absence de compensation DELETE.

Ne cherche pas à forcer artificiellement le statut SUCCEEDED.

La sécurité contre les doublons reste prioritaire.

Le statut métier autoritatif doit être lu dans ProjectOrqSaga.

Conserve la limitation C3e relative à LOCAL_PERSISTENCE après perte d’acquittement et documente son comportement observé.

13. Replay Temporal réel

Récupère uniquement l’historique de nos Workflows de qualification.

Exécute un replay hors ligne avec le SDK Temporal et les véritables définitions du Workflow V2.

Vérifie :

* La compatibilité de l’historique avec le Workflow.
* L’absence d’erreur de déterminisme.
* L’absence de nouvelle exécution métier distante pendant le replay.
* L’absence de données sensibles dans les historiques de qualification.

Utilise exclusivement des données synthétiques dès la création des Workflows.

Ne modifie pas les événements nécessaires au déterminisme pour assainir artificiellement l’historique.

Si un historique ne peut pas être conservé conformément aux contraintes de sécurité, ne l’exporte pas et documente la limitation.

14. Sécurité et arrêt

Les seuls effets distants autorisés sont les exécutions de qualification Temporal explicitement prévues et leurs historiques.

Limite le nombre de Workflows aux scénarios documentés et borne leurs durées.

N’effectue aucune opération administrative sur le serveur Temporal.

En cas d’échec :

* Ne relance pas aveuglément le Workflow.
* Analyse les preuves persistées.
* N’interviens que sur nos propres exécutions de test.
* Demande mon intervention avant toute action distante supplémentaire non prévue.

À la fin :

* Arrête le Worker local.
* Vérifie qu’aucun processus de qualification ne reste actif.
* Vérifie l’état des Workflows de qualification.
* Supprime uniquement les ressources Docker temporaires créées pour C4-Q.
* Préserve les preuves et résultats assainis.
* Donne-moi les instructions pour arrêter le tunnel DevEnv.

Ne supprime aucun historique Temporal existant.

Documente les historiques de qualification qui subsistent conformément à la rétention du serveur.

15. Non-régression

Utilise C4 comme référence :

* 451 cas JUnit.
* 424 réussites JUnit.
* 395 tests pytest réussis.
* 29 sous-tests réussis.
* 27 échecs historiques identiques.
* Head Alembic 0004_orq_saga_outbox.
* 32 tables applicatives.

Vérifie l’intégrité de C4 et des espaces précédents.

Exécute les tests ciblés et les tests de non-régression pertinents.

Si du code de test permanent est ajouté, exécute également la suite complète.

Distingue clairement :

* Tests unitaires.
* Tests PostgreSQL réels.
* Tests Temporal réels.
* Appels Orq simulés.
* Replay hors ligne.
* Scénarios d’interruption réellement reproduits.
* Scénarios uniquement simulés.

Ne présente aucune garantie exactly-once distribuée comme acquise.

16. Contraintes impératives

* Aucun commit, branche, push, merge, rebase ou création de MR.
* Aucun changement Kubernetes.
* Aucune commande Kubernetes exécutée par Software Companion.
* Aucun déploiement LMC.
* Aucun appel au véritable service Orq.ai.
* Aucun serveur Temporal local.
* Aucune installation Temporal CLI.
* Aucune modification des ressources Docker existantes.
* Aucune modification de Docker Compose.
* Aucune modification des Dockerfiles.
* Aucune modification des migrations applicatives.
* Aucune modification du pont Alembic.
* Aucune modification des scripts 01/02/03.
* Aucune modification des configurations VS Code.
* Aucun changement de la procédure habituelle de lancement du LMC.
* Aucun nouveau développement C5, C6, C7, C8 ou C9.

La qualification reste strictement isolée et ne doit avoir aucun impact sur les utilisateurs ou services existants.

17. Documentation et restitution

Crée une documentation technique en anglais :

documentation/C4Q_TEMPORAL_REAL_QUALIFICATION.md

Mets à jour LMC_WORKSPACE_INDEX.md et la roadmap de convergence.

Documente les commandes utilisées, les scénarios exécutés, les résultats réels, les preuves, les ressources temporaires et leur nettoyage.

Présente-moi en français :

* Les étapes effectivement réalisées.
* La connexion réelle à Temporal.
* Les résultats de chaque Workflow.
* Les Activities observées dans les historiques.
* Les transitions PostgreSQL.
* Le nombre de POST simulés par opération.
* Les résultats du redémarrage du Worker.
* Les résultats du replay.
* Les éventuelles anomalies.
* Les limites restantes.
* Les prérequis pour C5.

Les limitations liées à la version Python cible, à l’audit CVE, aux migrations historiques et aux futures politiques métier restent ouvertes tant qu’elles ne sont pas réellement traitées.

Commence par relire le protocole existant et préparer les prérequis locaux.

Indique-moi ensuite les éventuelles commandes que je dois exécuter depuis le DevEnv pour rétablir la connexion Temporal.

Tu peux poursuivre la qualification dans ce périmètre une fois les préconditions d’isolation et d’autorisation vérifiées.

Ne commence pas C5 sans mon accord.