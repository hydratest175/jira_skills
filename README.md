Je valide C3a sur son périmètre de qualification locale.

Notre nouvelle référence est désormais :

* 236 cas JUnit.
* 209 cas JUnit réussis.
* 180 tests pytest réussis et 29 sous-tests réussis.
* 27 échecs historiques strictement identiques.
* 73 cas de réconciliation ciblés réussis.
* Aucune nouvelle régression.
* PostgreSQL 18.4.
* 32 tables applicatives.
* Head Alembic unique : 0004_orq_saga_outbox.
* Aucune modification des migrations, du schéma, des scripts ou de Docker Compose.
* Aucune nouvelle dépendance introduite dans C3a.

Nous pouvons maintenant commencer C3b — Optional Temporal Foundation.

1. Espace de travail

Crée un nouvel espace local isolé :

/workspace/LEA_Workspace/lcc-c3b-temporal-foundation

Utilise comme base cumulative :

/workspace/LEA_Workspace/lcc-c3a-orq-reconciliation

Notre référence LMC originale reste :

/workspace/LEA_Workspace/lcc_last_version/lcc

Préserve intégralement tous les espaces précédents.

Ne copie aucune métadonnée Git, aucun credential, fichier .env, environnement virtuel ou cache inutile.

2. Réutilisation de T2

Notre objectif est de porter directement notre fondation Temporal précédemment développée et qualifiée.

Relis notamment :

* lcc-t2-temporal-foundation
* lcc-t3-orq-project-workflow
* lcc-mr6-provisioning-contracts
* lcc-mr7-postgresql-state-store
* TEMPORAL_T2_FOUNDATION.md
* C3A_ORQ_PROJECT_RECONCILIATION.md
* LMC_SAGA_REPAIR_CONVERGENCE_ANALYSIS.md
* LMC_WORKSPACE_INDEX.md
* La roadmap de convergence.

Identifie la version finale de T2 après ses derniers durcissements.

Vérifie également si des corrections directement liées à la fondation Temporal ont été introduites dans les espaces ultérieurs.

Réutilise directement le code et les tests existants lorsque cela est possible.

Ne redéveloppe pas une nouvelle fondation Temporal.

3. Qualification historique à préserver

Nous avons déjà qualifié réellement Temporal en préproduction depuis notre environnement de développement.

Les résultats historiques comprennent :

* SDK Python temporalio 1.18.2.
* Connexion au serveur Temporal préproduction.
* Namespace default.
* Santé et visibilité validées.
* Connexion depuis le Dev Container via un tunnel établi depuis le DevEnv.
* Task Queue dédiée et vérifiée.
* Workflow LmcTemporalNoop réellement exécuté avec le statut COMPLETED.
* Arrêt propre du Worker local.
* Aucun appel Orq.ai.
* Aucune modification des Workers ou Workflows existants.

La dernière qualification T2 comportait 41 nouveaux tests réussis.

Ne recommence pas maintenant les recherches Kubernetes, réseau, authentification ou port-forward.

Conserve ces résultats dans la documentation comme qualification historique.

Ils ne constituent pas une nouvelle qualification réelle de C3b sur la base actuelle.

4. Dépendances Temporal

Reprends le mécanisme de dépendances optionnelles précédemment développé dans T2, notamment :

backend/requirements-temporal.lock

Vérifie les chemins exacts dans les espaces historiques.

Préserve les principes suivants :

* SDK Temporal optionnel.
* Dépendances verrouillées.
* Utilisation exclusive des sources de dépendances autorisées.
* Aucune introduction de Temporal dans les dépendances normales du LMC.
* Aucun besoin d’installer Temporal CLI.
* Aucun serveur Temporal local.
* Aucun téléchargement automatique d’un serveur de test Temporal.

Vérifie la compatibilité de temporalio 1.18.2 avec la nouvelle base.

Ne change pas de version sans incompatibilité démontrée et justification technique.

5. Configuration Temporal optionnelle

Porte la configuration finale précédemment qualifiée dans T2.

Préserve notamment :

* Temporal désactivé par défaut.
* Endpoint SDK/gRPC configurable.
* Namespace configurable.
* Task Queue configurable et dédiée.
* Identité du Worker configurable.
* Configuration TLS et authentification, selon les capacités déjà implémentées.
* Deadlines de connexion et de RPC.
* Gestion explicite des configurations invalides.
* Aucune valeur spécifique à nos tests historiques codée en dur.
* Aucun credential ou secret dans le code, les logs ou la documentation.

Ne confonds jamais l’adresse de la Web UI Temporal avec l’endpoint SDK/gRPC.

Ne considère pas le namespace historique default comme une valeur obligatoirement applicable à tous les environnements.

Préserve les mécanismes de validation et de protection de la Task Queue introduits dans T2, notamment le mécanisme d’ownership lorsqu’il est applicable.

Ne présente pas cet ownership comme une garantie d’exclusivité distribuée s’il ne fournit pas réellement cette propriété.

6. Client Temporal et gestion des erreurs

Porte les composants existants permettant :

* La création du client Temporal.
* La validation de la configuration.
* La gestion des connexions.
* Les vérifications de disponibilité.
* La gestion des timeouts.
* La remontée d’erreurs assainies.
* La distinction entre un client optionnel et un client requis.

Préserve le comportement historique :

* Temporal désactivé : aucun appel réseau.
* Temporal optionnel indisponible : aucun impact sur le fonctionnement normal du LMC.
* Temporal requis indisponible : erreur explicite et contrôlée.
* Absence du SDK optionnel : le LMC continue de fonctionner normalement.

Ne crée aucune connexion Temporal automatique au démarrage standard du backend.

Ne couple pas le cycle de vie de Temporal au lifespan FastAPI.

7. Préservation du fonctionnement du LMC

Cette contrainte est impérative.

La manière habituelle de lancer le LMC doit rester strictement inchangée.

Ne modifie pas :

* Les scripts 01, 02 et 03.
* Docker Compose.
* Les configurations VS Code.
* Les mécanismes de démarrage du backend.
* Les configurations Kubernetes.
* Les migrations Alembic.

Temporal ne doit devenir une dépendance obligatoire d’aucune fonctionnalité existante.

Le futur Worker métier sera un processus séparé, optionnel et désactivé par défaut.

Son intégration effective appartient à C4.

8. Préservation de notre architecture Saga

Vérifie la compatibilité de la fondation Temporal avec l’architecture retenue :

* orq_project_mappings : mapping durable et identité distante vérifiée.
* saga_project_orq : unique table d’opérations de provisioning Orq.
* orq_project_temporal_start_outbox : livraison fiable des demandes de démarrage Temporal.

Ne modifie aucune de ces tables.

Ne recrée pas orq_project_provisioning_operations.

Ne développe pas encore la connexion entre Temporal, ProjectOrqSaga et l’outbox.

9. Tests et qualification

Porte les tests historiques T2, y compris les tests ajoutés lors du durcissement final.

Utilise des clients factices et des dépendances contrôlées.

Vérifie notamment :

* Temporal désactivé.
* SDK optionnel absent.
* SDK disponible.
* Configuration valide et invalide.
* Connexion simulée réussie.
* Connexion indisponible.
* Timeout.
* Erreurs assainies.
* Comportement optionnel et requis.
* Validation de la Task Queue.
* Protection d’ownership.
* Absence de connexion implicite au démarrage.
* Absence d’impact sur les fonctionnalités existantes du LMC.

Si les outils historiques de qualification no-op font partie du périmètre T2, conserve-les uniquement comme outils de test explicitement isolés et inactifs.

N’exécute aucun nouveau Workflow distant.

Ne démarre aucun Worker connecté à Temporal préproduction.

Ne lance aucun serveur Temporal local, même temporaire.

N’effectue aucune commande Kubernetes.

Distingue les garanties réellement requalifiées localement des garanties historiques qui devront être revérifiées ultérieurement sur Temporal préproduction.

10. Non-régression

Utilise C3a comme nouvelle référence :

* 236 cas JUnit.
* 209 cas JUnit réussis.
* 180 tests pytest réussis.
* 29 sous-tests réussis.
* 27 échecs historiques identiques.
* Head Alembic 0004_orq_saga_outbox.
* 32 tables applicatives.

Exécute les tests ciblés et la suite complète.

Compare les node IDs, traces normalisées et signatures des échecs avec C3a.

Vérifie également :

* La compilation Python.
* pip check.
* Le fonctionnement des imports sans le SDK Temporal.
* Le fonctionnement des imports avec les dépendances Temporal optionnelles.
* L’absence de nouvelle dérive SQL/ORM.
* L’intégrité des composants C1, C2 et C3a.

Conserve une distinction explicite entre les tests pytest, les sous-tests et les cas JUnit.

11. Limitation du périmètre

C3b doit rester strictement consacrée au portage de la fondation Temporal optionnelle T2.

Ne commence pas :

* C3c : contrats et Workflow V2.
* C3d : Store PostgreSQL.
* C3e : Activities V2.
* C4 : Worker métier.
* Enqueue transactionnel.
* Dispatcher.
* API.
* Frontend.
* Repair.

Aucun nouveau Workflow métier ne doit être implémenté.

Aucun comportement de provisioning ne doit être activé.

12. Contraintes impératives

* Micro-MR minimale et facilement explicable.
* Réutilisation maximale du travail existant.
* Aucune opération Git ou GitLab.
* Aucun changement Kubernetes.
* Aucun déploiement.
* Aucun appel réel à Orq.ai.
* Aucun appel distant à Temporal.
* Aucun nouveau Workflow distant.
* Aucune modification des conteneurs, volumes, réseaux ou bases existants.
* Aucune modification de Docker Compose.
* Aucune modification du pont Alembic.
* Aucune modification des scripts et configurations standards de lancement.
* Préservation intégrale de tous les espaces précédents.
* Temporal et Orq.ai restent optionnels.

13. Documentation et restitution

Crée une documentation technique dédiée en anglais :

documentation/C3B_TEMPORAL_FOUNDATION.md

Mets à jour LMC_WORKSPACE_INDEX.md et la roadmap de convergence.

Pour chaque fichier créé ou modifié, documente :

* Son origine.
* Son rôle.
* Les composants repris directement de T2.
* Les adaptations nécessaires.
* Le comportement avant et après.
* La justification technique.
* Les alternatives éventuelles.

Présente-moi en français :

* Les fichiers portés.
* Les durcissements historiques conservés.
* Les dépendances optionnelles retenues.
* Les adaptations spécifiques à la nouvelle base.
* Les résultats réels des tests.
* Les garanties effectivement requalifiées.
* Les limites restantes.
* Les différences éventuelles avec T2.
* La prochaine micro-MR C3c recommandée.

Notre objectif reste la parité fonctionnelle complète avec le Mock LMC depuis l’interface du véritable LMC lancé localement, en réutilisant le mécanisme Repair existant, avant tout déploiement en préproduction.

Tu peux commencer C3b dans ce périmètre. Ne commence pas C3c sans mon accord.