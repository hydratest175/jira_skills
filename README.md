Je valide C3e sur son périmètre de qualification locale.

Notre nouvelle référence est désormais :

* 419 cas JUnit.
* 392 cas JUnit réussis.
* 363 tests pytest réussis.
* 29 sous-tests réussis.
* 27 échecs historiques strictement identiques.
* 35 tests ciblés C3e réussis.
* 12 tests d’intégration Activities/PostgreSQL réels réussis.
* Aucune nouvelle régression.
* PostgreSQL 18.4.
* Head Alembic unique : 0004_orq_saga_outbox.
* 32 tables, 17 triggers, 4 fonctions, 85 index et 390 contraintes.
* Aucune modification du schéma.

La phase de convergence et de portage C0 à C3e est désormais terminée. Tout le code réutilisable développé jusqu’à MR7 est porté ou explicitement supersédé.

Nous pouvons commencer C4 — Optional Temporal Provisioning Worker V2.

1. Espace de travail

Crée un nouvel espace local isolé :

/workspace/LEA_Workspace/lcc-c4-temporal-provisioning-worker

Utilise comme base cumulative :

/workspace/LEA_Workspace/lcc-c3e-provisioning-activities-v2

Notre référence LMC originale reste :

/workspace/LEA_Workspace/lcc_last_version/lcc

Préserve intégralement tous les espaces précédents.

Ne copie aucune métadonnée Git, aucun credential, fichier .env, environnement virtuel ou cache inutile.

2. Documentation et travail existant

Relis notamment :

* TEMPORAL_T2_FOUNDATION.md
* C3B_TEMPORAL_FOUNDATION.md
* C3C_PROVISIONING_WORKFLOW_V2.md
* C3D_POSTGRESQL_STATE_STORE.md
* C3E_PROVISIONING_ACTIVITIES_V2.md
* LMC_SAGA_REPAIR_CONVERGENCE_ANALYSIS.md
* LMC_WORKSPACE_INDEX.md
* La roadmap de convergence.
* Les composants Worker historiques disponibles dans T2 et T3.

Réutilise les mécanismes existants de configuration, de connexion, de validation et d’arrêt gracieux.

Ne redéveloppe aucune fondation Temporal déjà disponible.

3. Objectif de C4

Implémente un Worker métier Temporal V2 :

* Séparé du backend FastAPI.
* Optionnel.
* Désactivé par défaut.
* Exécutable explicitement depuis le Dev Container.
* Configurable.
* Testable avec des dépendances injectées.
* Compatible avec le Store PostgreSQL et les Activities existantes.
* Utilisant une Task Queue métier dédiée.

Ce Worker doit être capable d’exécuter le Workflow V2 lorsque celui-ci sera ultérieurement déclenché par les composants applicatifs.

Il ne doit démarrer lui-même aucun Workflow.

4. Enregistrement du Workflow et des Activities

Enregistre exclusivement le Workflow de provisioning V2 développé dans C3c et les quatre Activities concrètes de C3e :

* lmc.orq_project.load_context.v2
* lmc.orq_project.reconcile_once.v2
* lmc.orq_project.persist_mapping.v2
* lmc.orq_project.record_outcome.v2

Vérifie leurs noms exacts et leurs signatures dans le code source.

Préserve strictement la compatibilité des contrats.

N’enregistre pas :

* Le Workflow V1 historique.
* Le Workflow no-op de qualification T2.
* Les Workflows de traitement de documents.
* Des Activities historiques obsolètes.
* Des Workflows ou Activities sans rapport avec le provisioning Orq.

Ne modifie ni le Workflow V2 ni ses contrats sans incompatibilité démontrée.

5. Composition des dépendances

Le Worker doit assembler les composants déjà disponibles :

* Client Temporal C3b.
* Workflow V2 C3c.
* Store PostgreSQL C3d.
* Gateway Orq C3a.
* Activities V2 C3e.

Réutilise les mécanismes existants du LMC concernant les sessions PostgreSQL, la configuration et les accès aux services.

Ne duplique aucune logique métier.

Le Worker doit posséder une composition de dépendances explicite permettant de remplacer le gateway Orq par un gateway factice pendant les tests.

Vérifie la compatibilité entre la nature synchrone ou asynchrone des Activities, les sessions SQLAlchemy et le modèle d’exécution du SDK Temporal.

Aucune session SQLAlchemy ne doit être partagée de manière non sûre entre plusieurs Activities concurrentes.

Aucun appel bloquant ne doit immobiliser indéfiniment la boucle événementielle du Worker.

6. Configuration et activation

Réutilise la configuration optionnelle C3b.

Préserve notamment :

* Endpoint SDK/gRPC configurable.
* Namespace configurable.
* Task Queue configurable.
* Identité Worker configurable.
* Configuration TLS/authentification existante.
* Deadlines et timeouts.
* Chargement optionnel du SDK.

Prévois une activation explicite du Worker métier.

Par défaut, aucune connexion à Temporal, PostgreSQL ou Orq ne doit être initiée par le Worker désactivé.

Ne code en dur aucune adresse interne, valeur de test, identité ou credential.

En cas de configuration indispensable manquante ou incohérente, le Worker doit refuser de démarrer avec une erreur contrôlée et assainie.

Ne modifie pas les dépendances normales du LMC.

7. Task Queue et isolation

Utilise une Task Queue exclusivement dédiée au provisioning Orq V2.

Vérifie que les mécanismes historiques de validation des queues restent applicables.

Ne réutilise jamais :

* La queue de traitement de documents.
* La queue no-op historique.
* Une queue appartenant à un autre service.

Distingue clairement la convention de nommage, le contrôle de configuration et une éventuelle garantie d’exclusivité distribuée.

Ne revendique pas une exclusivité que le SDK ou notre mécanisme d’ownership ne garantit pas réellement.

Documente la stratégie de nommage et les protections contre une connexion accidentelle à un environnement ou une queue incorrecte.

8. Cycle de vie du Worker

Implémente un cycle de vie autonome comprenant :

* Validation de la configuration.
* Initialisation explicite des dépendances.
* Création du client Temporal.
* Enregistrement du Workflow et des Activities.
* Démarrage de la boucle Worker.
* Gestion des erreurs d’initialisation.
* Gestion de SIGINT et SIGTERM.
* Arrêt gracieux.
* Libération des ressources.

Réutilise les mécanismes historiques lorsque cela est pertinent.

Prévois des délais d’arrêt bornés et cohérents avec les timeouts des Activities.

Vérifie notamment qu’une interruption pendant une Activity mutative ne permet pas de contourner les protections de réservation durable.

Un arrêt gracieux ne doit pas être présenté comme une garantie que toutes les mutations distantes ont nécessairement terminé.

Ne déclenche aucune compensation DELETE lors de l’arrêt du Worker.

9. Préservation du lancement standard du LMC

Cette contrainte est impérative.

La manière habituelle de lancer le LMC doit rester strictement inchangée.

Ne modifie pas :

* Les scripts 01, 02 et 03.
* Docker Compose.
* Les Dockerfiles existants.
* Les configurations de lancement VS Code.
* Le lifespan FastAPI.
* Les mécanismes actuels de démarrage du backend et du frontend.
* Les configurations Kubernetes.

Le Worker doit être lancé séparément et uniquement lorsque le provisioning est explicitement nécessaire.

Le LMC doit continuer à fonctionner normalement :

* Sans SDK Temporal installé.
* Sans Worker.
* Sans connexion Temporal.
* Sans configuration Orq.

Documente la commande permettant de lancer manuellement le Worker depuis le Dev Container, mais ne l’exécute pas contre Temporal préproduction pendant C4.

10. Préservation des garanties métier

Le Worker doit conserver intégralement les garanties C3a à C3e :

* Réservation durable commitée avant POST.
* Libération des verrous SQL avant appel réseau.
* CAS et protection des générations.
* mutation_attempted irréversible.
* Aucun retry mutatif automatique.
* Aucun nouveau POST après une mutation ambiguë.
* Aucun DELETE automatique.
* Distinction candidat/identité confirmée.
* Persistance du résultat confirmé avant mapping.
* Finalisation idempotente lorsque les préconditions le permettent.
* Conservation des preuves après interruption.
* UNKNOWN_OUTCOME et NEEDS_RECONCILIATION.

Ne déplace pas ces responsabilités vers le Worker.

Le Worker constitue uniquement la couche d’exécution et de composition.

La source autoritative du statut métier reste ProjectOrqSaga.

La source autoritative de l’identité distante reste orq_project_mappings.

11. Limite identifiée dans C3e

C3e a identifié qu’une perte d’acquittement après confirmation peut retourner un résultat conservateur alors qu’un état LOCAL_PERSISTENCE plus informatif existe déjà en base.

Conserve explicitement cette limitation.

Vérifie que le Worker n’introduit aucune transition supplémentaire susceptible d’écraser cet état autoritatif.

Inscris dans les critères de C7 que le futur Repair devra s’appuyer sur les preuves et statuts persistés dans ProjectOrqSaga, plutôt que sur le seul résultat du Workflow.

Ne développe pas encore le Repair et ne modifie pas silencieusement les contrats pour résoudre cette limitation.

12. Sécurité

Aucun secret ou credential ne doit être présent dans :

* Les paramètres du Workflow.
* Les résultats des Activities.
* Les logs du Worker.
* Les messages d’erreur.
* Les futures données d’historique Temporal.
* La documentation.

Ne journalise pas les configurations complètes contenant potentiellement des credentials.

Réutilise les mécanismes existants de sanitization.

N’utilise pas le helper Orq historique susceptible de déclencher des suppressions automatiques.

Ne désactive aucune vérification TLS.

Ne contourne aucune restriction réseau ou de sécurité.

13. Tests locaux C4

Qualifie le Worker avec les composants et clients factices appropriés.

Teste notamment :

* Import du LMC sans SDK Temporal.
* Worker désactivé par défaut.
* Absence de connexion réseau lorsque désactivé.
* Configuration valide et invalide.
* SDK optionnel absent.
* Échec de connexion Temporal.
* Échec d’initialisation des dépendances.
* Enregistrement exact du Workflow V2.
* Enregistrement exact des quatre Activities.
* Absence de Workflow ou Activity legacy.
* Validation de la Task Queue.
* Injection du gateway Orq factice.
* Initialisation et fermeture des ressources.
* Arrêt gracieux.
* Annulation et propagation contrôlée des erreurs.
* Sanitization des exceptions.
* Absence de démarrage automatique d’un Workflow.
* Absence d’appel distant Orq ou Temporal.
* Préservation du comportement FastAPI.

Vérifie que le SDK accepte réellement les définitions du Workflow et des Activities.

Distingue les tests utilisant le véritable SDK des tests utilisant un Worker ou un client factice.

N’assimile pas une validation des définitions à une exécution réelle sur Temporal.

Utilise des ressources PostgreSQL temporaires strictement isolées uniquement lorsque nécessaire.

14. Préparation de la qualification réelle Temporal

Nous avons déjà qualifié Temporal préproduction dans T2 :

* SDK Python temporalio 1.18.2.
* Connexion au serveur.
* Santé et visibilité du namespace default validées.
* Connexion depuis le Dev Container via un tunnel établi depuis le DevEnv.
* Task Queue de test dédiée.
* Workflow LmcTemporalNoop réellement exécuté avec succès.

Ne recommence pas toute la recherche réseau ou Kubernetes.

Prépare un protocole distinct de qualification réelle du Worker V2, sans l’exécuter pendant C4.

Ce protocole devra prévoir :

* Revalidation de l’endpoint et du namespace autorisé.
* Réutilisation du tunnel précédemment qualifié.
* Task Queue de test unique et dédiée.
* Worker local dans le Dev Container.
* PostgreSQL 18.4 temporaire et isolé.
* Opération de test identifiable et préalablement persistée.
* Gateway Orq exclusivement factice.
* Impossibilité de déclencher accidentellement un véritable appel Orq.
* Exécution d’un véritable Workflow V2.
* Vérification des quatre Activities dans l’historique Temporal.
* Vérification des transitions ProjectOrqSaga.
* Vérification du mapping final.
* Récupération d’un historique assaini pour le replay.
* Arrêt du Worker et nettoyage des seules ressources locales créées pour le test.

Décris également un scénario de redémarrage contrôlé permettant de vérifier la reprise du Workflow sans second POST simulé.

Ne développe pas de second mécanisme applicatif d’enqueue pour les besoins de cette qualification.

Si un harness de test est nécessaire, propose son périmètre et son isolation.

Je réaliserai moi-même les éventuelles commandes Kubernetes depuis le DevEnv.

Ne démarre aucun Workflow distant avant validation explicite de ce protocole.

15. Non-régression

Utilise C3e comme nouvelle référence :

* 419 cas JUnit.
* 392 réussites JUnit.
* 363 tests pytest réussis.
* 29 sous-tests réussis.
* 27 échecs historiques identiques.
* PostgreSQL 18.4.
* Head Alembic 0004_orq_saga_outbox.
* 32 tables, 17 triggers, 4 fonctions, 85 index et 390 contraintes.

Exécute les tests ciblés C4, les tests cumulés pertinents et la suite complète.

Compare les node IDs, traces normalisées et signatures des échecs historiques avec C3e.

Vérifie également :

* Compilation Python.
* pip check.
* Fonctionnement sans SDK optionnel.
* Intégrité des migrations.
* Intégrité des modèles ORM.
* Intégrité des composants C3a à C3e.
* Absence de modification des mécanismes standards de lancement.

Ne cherche pas à reproduire artificiellement un nombre attendu de nouveaux tests.

16. Limites héritées

Conserve dans la roadmap :

* Qualification avec la version Python cible du LMC.
* Audit CVE des dépendances.
* Replay Temporal réel.
* Qualification réelle du Worker métier.
* Qualification du pont Alembic et de la procédure standard.
* Compatibilité avec les bases historiques.
* Politique de modification concurrente des projets.
* Hard delete.
* Retry manuel à configuration identique.
* Résolution privilégiée de UNKNOWN_OUTCOME.
* Taxonomie d’audit.

Ne résous pas silencieusement ces décisions dans C4.

17. Limitation du périmètre

C4 doit rester une micro-MR exclusivement consacrée au Worker métier V2.

Ne commence pas :

* C5 : allocation de génération et enqueue transactionnel.
* C6 : dispatcher Temporal.
* C7 : Repair backend.
* C8 : frontend.
* C9 : résolution privilégiée.
* Provisioning des autres ressources Orq.

Ne crée aucun endpoint applicatif supplémentaire.

Ne déclenche aucun Workflow réel.

Aucune mutation distante Orq ne doit être effectuée.

18. Contraintes impératives

* Aucune opération Git ou GitLab.
* Aucun déploiement.
* Aucune commande ou modification Kubernetes.
* Aucun appel distant Temporal ou Orq.
* Aucun serveur Temporal local.
* Aucune installation de Temporal CLI.
* Aucune modification des conteneurs, volumes, réseaux ou bases existants.
* Seules les ressources locales temporaires et isolées nécessaires aux tests sont autorisées.
* Aucune modification de Docker Compose.
* Aucune modification des migrations ou du pont Alembic.
* Aucune modification des scripts 01/02/03.
* Aucune modification des configurations standards de lancement.
* Préservation intégrale de tous les espaces précédents.

19. Documentation et restitution

Crée une documentation technique en anglais :

documentation/C4_TEMPORAL_PROVISIONING_WORKER.md

Crée également le protocole de qualification réelle :

documentation/C4_TEMPORAL_REAL_QUALIFICATION_PLAN.md

Mets à jour LMC_WORKSPACE_INDEX.md et la roadmap de convergence.

Pour chaque fichier créé ou modifié, documente son origine, son rôle, les composants réutilisés, le comportement avant/après, les choix techniques et leur justification.

Présente-moi en français :

* Le fonctionnement du Worker.
* Les fichiers créés ou modifiés.
* Les mécanismes réutilisés.
* La commande exacte de lancement manuel.
* Les dépendances nécessaires.
* Les garanties réellement testées.
* Les résultats de non-régression.
* Les limites restantes.
* Le protocole proposé pour sa qualification réelle avec Temporal préproduction.
* Les prérequis de C5.

Notre objectif reste d’atteindre rapidement la parité fonctionnelle complète avec le Mock LMC depuis l’interface du véritable LMC lancé localement, en réutilisant le Repair existant, avant tout déploiement du LMC en préproduction.

Tu peux commencer C4 dans ce périmètre. Ne commence ni la qualification distante ni C5 sans mon accord.