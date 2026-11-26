Je valide C6 sur son périmètre de qualification locale.

Notre nouvelle référence applicative est désormais :

* 607 cas JUnit.
* 580 réussites JUnit.
* 551 tests pytest réussis.
* 29 sous-tests réussis.
* 27 échecs historiques strictement identiques.
* 78 réussites supplémentaires par rapport à C5.
* 106 tests ciblés non-PostgreSQL.
* 25 tests PostgreSQL 18.4 réels.
* 5 tests SpiceDB C5 inchangés.
* 133 tests réussis sans SDK Temporal.
* Head Alembic unique : 0004_orq_saga_outbox.
* 32 tables, 17 triggers, 4 fonctions, 85 index et 390 contraintes.

Nous pouvons commencer C6-Q — Real End-to-End Temporal Provisioning Chain Qualification.

1. Espace de travail

Utilise comme référence applicative :

/workspace/LEA_Workspace/lcc-c6-temporal-outbox-dispatcher

Crée un espace de qualification isolé :

/workspace/LEA_Workspace/lcc-c6q-temporal-real-qualification

Utilise également comme référence historique de qualification :

/workspace/LEA_Workspace/lcc-c4q-temporal-real-qualification

Préserve intégralement tous les espaces précédents et le LMC original.

Ne copie aucun credential, fichier .env réel, historique Temporal sensible, environnement virtuel ou métadonnée Git.

C6-Q est une qualification et non une nouvelle fonctionnalité applicative.

Ne modifie pas silencieusement le code applicatif C6. Si une anomalie nécessite une correction, documente-la et propose un correctif ciblé avant son implémentation.

2. Documentation existante

Relis notamment :

* C4_TEMPORAL_PROVISIONING_WORKER.md
* C4Q_TEMPORAL_REAL_QUALIFICATION.md
* C5_TRANSACTIONAL_PROVISIONING_ENQUEUE.md
* C6_TEMPORAL_OUTBOX_DISPATCHER.md
* C6Q_TEMPORAL_REAL_QUALIFICATION_PLAN.md
* Les documents C2 et C3 pertinents.
* LMC_SAGA_REPAIR_CONVERGENCE_ANALYSIS.md
* LMC_WORKSPACE_INDEX.md
* La roadmap de convergence.

Réutilise les mécanismes de qualification existants de T2 et C4-Q lorsque cela est possible.

Ne recommence pas inutilement les recherches réseau, Kubernetes ou SDK déjà réalisées.

3. Objectif principal

Qualifier réellement la chaîne suivante :

Service C5 → PostgreSQL → Outbox → Dispatcher C6 → Temporal préproduction → Worker C4 → Workflow V2 → Activities V2 → Gateway Orq factice.

Contrairement à C4-Q, les demandes nominales doivent être créées par le véritable service C5.

Le véritable Dispatcher C6 doit ensuite récupérer ces demandes et démarrer les Workflows.

Il est interdit, pour le scénario nominal :

* De préparer manuellement les lignes Saga/outbox.
* De démarrer directement le Workflow depuis le harness.
* De remplacer le Dispatcher par un mock.
* De remplacer le Worker par un mock.
* De simuler le serveur Temporal.

Le harness peut préparer les projets synthétiques, les acteurs, les permissions et les dépendances nécessaires, mais ne doit pas remplacer la logique applicative qualifiée.

4. Connexion à Temporal préproduction

Nous avons déjà réussi à utiliser Temporal préproduction pendant T2 et C4-Q.

Réutilise les commandes et mécanismes de tunnel précédemment qualifiés.

Je réaliserai personnellement les commandes Kubernetes nécessaires depuis le DevEnv.

Software Companion travaille depuis le Dev Container.

Lorsque mon intervention est nécessaire :

* Donne-moi les commandes exactes.
* Précise le terminal concerné.
* Explique leur objectif.
* Indique les résultats attendus.
* Attends mon retour avant les opérations dépendantes.

Ne tente pas d’installer kubectl, gcloud ou Temporal CLI dans le Dev Container.

Vérifie de nouveau le cluster, le namespace, la santé du serveur, les autorisations, le SDK et les paramètres de connexion.

Ne suppose pas que les anciens endpoints sont toujours valides.

Ne contourne aucune restriction réseau ou de sécurité.

5. Isolation complète

Utilise exclusivement :

* Temporal préproduction existant et autorisé.
* PostgreSQL 18.4 temporaire.
* Une instance SpiceDB locale et isolée pour les contrôles d’autorisation.
* Des projets et acteurs entièrement synthétiques.
* Une Task Queue métier unique dédiée à C6-Q.
* Le véritable Dispatcher C6.
* Le véritable Worker C4.
* Un gateway Orq factice obligatoire.

La Task Queue et les identités doivent respecter les conventions existantes C4/C6.

Ne réutilise aucune queue documentaire, aucune queue no-op et aucune ancienne queue de qualification.

Vérifie l’absence de pollers inattendus.

Pendant les scénarios de reprise, conserve la même Task Queue, les mêmes opérations, les mêmes Workflow IDs et la même base PostgreSQL.

Ne modifie aucune ressource existante.

6. Interdiction effective des appels Orq réels

Réutilise les protections qualifiées pendant C4-Q.

Le harness doit :

* Injecter exclusivement le gateway Orq factice.
* Refuser de démarrer si cette injection n’est pas effective.
* Ne charger aucun credential Orq.
* Interdire tout fallback vers le gateway réel.
* Bloquer les appels réseau Orq réels dans le périmètre du processus de qualification.
* Comptabiliser durablement les appels simulés.

Le compteur des POST simulés et les données du fournisseur factice doivent survivre aux redémarrages des processus.

Vérifie ces protections avant tout démarrage distant de Workflow.

Aucune modification du firewall, des réseaux existants ou des configurations de sécurité n’est autorisée.

7. Scénario nominal complet

Crée un projet LMC synthétique et utilise un acteur réellement autorisé à travers la permission SpiceDB provision_orq_project.

Appelle le véritable service C5.

Vérifie :

* L’autorisation.
* La création atomique de Saga, outbox et audit.
* L’allocation de génération.
* La construction du snapshot désiré.
* La génération du Workflow ID déterministe.

Démarre ensuite le Dispatcher et le Worker selon leurs véritables mécanismes de composition.

Vérifie :

* Le claim de l’outbox.
* Le lease et la dispatch_version.
* Le démarrage réel du Workflow.
* La confirmation du Run ID.
* L’état STARTED de l’outbox.
* L’exécution des quatre Activities dans Temporal.
* La réservation durable avant POST simulé.
* La persistance de l’identité confirmée.
* La création du mapping.
* La finalisation de ProjectOrqSaga.

Critères attendus :

* Workflow COMPLETED.
* Saga SUCCEEDED.
* Outbox STARTED.
* Mapping cohérent.
* Exactement un POST simulé.
* Aucun appel Orq réel.
* Aucun DELETE.

Vérifie également qu’une nouvelle demande identique via C5 restitue l’opération existante et ne déclenche aucun nouveau Workflow.

Teste un acteur non autorisé et vérifie qu’aucune Saga, outbox, intention d’audit de provisioning acceptée ou exécution Temporal n’est créée.

8. Qualification de l’identité Temporal

Vérifie réellement les mécanismes utilisés par l’adapter SDK 1.18.2 :

* Workflow ID persisté.
* Workflow type LmcOrqProjectProvisionV2.
* Namespace.
* Cluster.
* Task Queue.
* Run ID.
* Premier événement de l’historique.
* Payload V2 correspondant à l’opération.
* Politique REJECT_DUPLICATE.
* Politique de conflit FAIL.
* request_id correspondant à operation_ref.

Vérifie comment ces paramètres sont réellement transmis au SDK ou au RPC.

Ne te limite pas à constater leur présence dans la configuration locale.

Ne journalise aucun payload brut.

Teste la capacité de l’adapter à identifier une exécution déjà terminée.

9. Perte d’acquittement du start

Il s’agit du scénario prioritaire de C6-Q.

Utilise une nouvelle opération créée par C5.

Le véritable appel de démarrage doit atteindre Temporal et être accepté.

Injecte ensuite une perte de réponse au niveau de la frontière de qualification, avant que le Dispatcher puisse considérer le démarrage comme acquitté.

Vérifie :

* La persistance préalable du marqueur TEMPORAL_START_UNCERTAIN.
* L’existence réelle du Workflow.
* La recherche par Workflow ID exact.
* La récupération et la vérification du Run ID.
* La confirmation de l’outbox STARTED.
* L’absence de deuxième invocation applicative de start_workflow.
* L’absence de nouvelle génération.
* L’absence de double POST simulé.

Distingue les appels effectués par le Dispatcher des éventuelles retransmissions internes du SDK ou du transport.

Ne prétends pas avoir simulé une perte réseau réelle si l’injection intervient après réception de la réponse SDK.

10. Arrêts forcés du Dispatcher

Qualifie les fenêtres d’interruption suivantes avec des opérations distinctes.

A. Arrêt après claim, avant le CAS de phase

Arrête effectivement le processus Dispatcher avant le passage à TEMPORAL_START_UNCERTAIN.

Après expiration du lease, redémarre le Dispatcher.

Vérifie que la reprise est autorisée après un lookup absent fiable et qu’un seul démarrage logique intervient.

B. Arrêt après le CAS de phase, avant l’appel start

Vérifie que TEMPORAL_START_UNCERTAIN a été réellement commité avant l’arrêt.

Redémarre le Dispatcher après expiration du lease.

Le comportement attendu de C6 est une récupération lookup-only, même si aucun Workflow n’a été créé.

Après épuisement du budget de récupération, vérifie le statut FAILED de l’outbox et le diagnostic TEMPORAL_START_UNCERTAIN.

La Saga métier doit rester inchangée par le Dispatcher.

Ce scénario représente une limitation de disponibilité volontairement conservatrice, pas une récupération métier réussie.

C. Arrêt après acceptation du start, avant acquittement PostgreSQL

Vérifie l’existence réelle du Workflow dans Temporal.

Arrête le processus Dispatcher avant la persistance de son acquittement.

Après expiration du lease, redémarre-le.

Vérifie la récupération du Workflow exact, la confirmation STARTED et l’absence de nouveau démarrage applicatif.

D. Acquittement PostgreSQL perdu

Simule une perte d’acquittement après commit de la transition STARTED.

Vérifie qu’une nouvelle instance peut constater l’état durable sans recréer de Workflow.

Utilise de véritables arrêts de processus pour les scénarios A, B et C lorsque techniquement possible.

Distingue explicitement les interruptions réelles des injections d’exceptions.

11. Concurrence entre Dispatchers

Exécute deux instances réelles du Dispatcher sur la même base PostgreSQL isolée.

Teste :

* Deux Dispatchers visant la même entrée.
* Plusieurs entrées distinctes.
* Expiration d’un lease.
* Reprise par un nouveau propriétaire.
* Acquittement tardif provenant de l’ancien propriétaire.
* Rejet d’une ancienne dispatch_version.
* Interactions avec C5 et C3d.

Vérifie les compteurs d’appels, les transitions SQL, les Workflow IDs et les Run IDs.

Ne revendique aucune exclusivité distribuée absolue.

Vérifie que la perte d’un lease ne permet pas à un ancien propriétaire d’écraser un résultat plus récent.

12. Worker terminant avant acquittement du Dispatcher

Qualifie le scénario suivant :

* Temporal accepte le démarrage.
* Le Worker exécute entièrement le Workflow.
* ProjectOrqSaga devient SUCCEEDED.
* Le Dispatcher n’a pas encore persisté STARTED.
* Le Dispatcher retrouve ensuite le Workflow terminé.

Vérifie que l’acquittement tardif de l’outbox n’altère ni le mapping ni le statut métier.

Le statut STARTED doit uniquement représenter la confirmation de livraison à Temporal.

13. Résultats incertains et conflits

Vérifie que les états de phase stockés dans last_error_code restent cohérents après retry, redémarrage, expiration de lease et épuisement du budget.

Un résultat incertain ne doit jamais être réinitialisé en NOT_ATTEMPTED par erreur.

Teste notamment :

* Lookup temporairement indisponible.
* Workflow absent après démarrage potentiellement accepté.
* Conflit d’identité.
* Payload ne correspondant pas à l’opération.
* Budget de récupération épuisé.

Les tests nécessitant une expiration d’historique ou un conflit artificiel peuvent rester simulés lorsque leur réalisation distante serait intrusive ou disproportionnée.

Ne modifie pas les paramètres de rétention Temporal.

N’interviens sur aucun Workflow extérieur à la qualification.

N’autorise jamais un nouveau Workflow ID pour contourner une incertitude.

14. Limitation héritée de C4-Q

Conserve explicitement les résultats précédents :

* Redémarrage Worker conservant LOCAL_PERSISTENCE.
* Aucun double POST.
* Workflow terminé FAILED.
* Replay du scénario de redémarrage non qualifié.

C6-Q ne doit pas masquer cette limitation.

Ne développe pas encore le Repair et ne recommence pas inutilement tous les scénarios C4-Q déjà validés.

Prépare les preuves nécessaires pour C7, notamment la distinction entre :

* Livraison Temporal incertaine.
* Workflow non démarré.
* Mutation Orq incertaine.
* Identité Orq confirmée avec échec de persistance.
* Mapping confirmé avec finalisation incomplète.
* Snapshot devenu obsolète.

15. Replay et sécurité des historiques

Récupère uniquement les historiques de nos propres exécutions de qualification.

Effectue les replays hors ligne pertinents avec les véritables définitions du Workflow V2.

Vérifie l’absence de données sensibles dans les historiques et diagnostics.

Ne conserve aucun historique sensible.

Ne modifie pas les événements nécessaires au déterminisme pour produire artificiellement un replay réussi.

Si un historique ne peut pas être conservé pour des raisons de sécurité, documente explicitement le scénario non rejoué.

16. Nettoyage et effets distants

Avant toute exécution distante, établis une matrice bornée des scénarios, avec le nombre maximal de Workflows et leurs durées maximales.

Les seules écritures distantes autorisées sont les exécutions Temporal de qualification prévues.

Aucune opération administrative, modification de rétention ou suppression d’historique n’est autorisée.

À la fin :

* Vérifie l’état de toutes nos exécutions.
* Arrête les Workers et Dispatchers de qualification.
* Supprime uniquement les ressources Docker temporaires créées pour C6-Q.
* Supprime les artefacts sensibles.
* Préserve les preuves assainies.
* Donne-moi les instructions nécessaires pour arrêter le tunnel DevEnv.

Documente les historiques Temporal qui subsistent jusqu’à leur expiration naturelle.

17. Non-régression

Utilise C6 comme référence :

* 607 cas JUnit.
* 580 réussites JUnit.
* 551 tests pytest réussis.
* 29 sous-tests réussis.
* 27 échecs historiques identiques.
* PostgreSQL 18.4.
* Head Alembic 0004_orq_saga_outbox.
* Catalogue PostgreSQL inchangé.

Vérifie l’intégrité de la base applicative C6 et des espaces précédents.

Exécute les tests pertinents de non-régression et la suite complète si du code de test permanent est ajouté.

Distingue les tests réels PostgreSQL, SpiceDB, Temporal, les appels Orq simulés, les interruptions réelles et les injections de fautes.

Ne revendique aucune garantie exactly-once distribuée.

18. Contraintes impératives

* Aucune opération Git ou GitLab.
* Aucun déploiement du LMC.
* Aucune modification Kubernetes.
* Aucune commande Kubernetes exécutée par Software Companion.
* Aucun appel réel Orq.
* Aucun serveur Temporal local.
* Aucune installation de Temporal CLI.
* Aucune modification des ressources Docker existantes.
* Aucune modification de Docker Compose ou des Dockerfiles.
* Aucune modification des migrations existantes.
* Aucune modification du pont Alembic.
* Aucune modification des scripts 01/02/03.
* Aucune modification des configurations VS Code.
* Aucun changement de la procédure standard de lancement du LMC.
* Aucun développement C7, C8 ou C9.
* Préservation intégrale de tous les espaces précédents.

19. Documentation et restitution

Crée une documentation technique en anglais :

documentation/C6Q_TEMPORAL_REAL_QUALIFICATION.md

Mets à jour LMC_WORKSPACE_INDEX.md et la roadmap de convergence.

Présente-moi en français :

* Les scénarios réellement exécutés.
* Les résultats de chaque opération.
* Les transitions Saga et outbox.
* Les Workflow IDs et Run IDs synthétiques correspondants.
* Le nombre d’appels start par opération.
* Le nombre de POST Orq simulés par opération.
* Les résultats des scénarios d’interruption.
* Les résultats de concurrence.
* Les résultats des replays.
* Les résultats de non-régression.
* Les anomalies et limitations.
* Les preuves et critères d’acceptation à transmettre à C7.

Classe chaque scénario comme réussi, partiellement qualifié, échoué ou non exécuté.

Ne présente pas une protection contre les doublons comme une preuve de reprise métier complète.

Conserve également les limitations Python cible, audit CVE, migrations historiques, pont Alembic, audit asynchrone, révocation après enqueue, retry manuel, hard delete et résolution privilégiée.

Notre objectif est maintenant de terminer rapidement la qualification de la chaîne technique et de passer à l’intégration fonctionnelle dans le LMC.

Commence par relire le protocole existant, préparer les prérequis locaux et me communiquer les commandes nécessaires depuis le DevEnv.

Tu peux poursuivre C6-Q lorsque l’environnement, l’isolation et les autorisations sont vérifiés.

Ne commence pas C7 sans mon accord.