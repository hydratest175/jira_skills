Je valide C5 sur son périmètre local. Nous pouvons commencer C6 — Temporal Outbox Dispatcher.

1. Référence et espace de travail

Utilise comme base cumulative :

/workspace/LEA_Workspace/lcc-c5-transactional-provisioning-enqueue

Crée un nouvel espace local isolé :

/workspace/LEA_Workspace/lcc-c6-temporal-outbox-dispatcher

La référence LMC originale reste :

/workspace/LEA_Workspace/lcc_last_version/lcc

Préserve intégralement tous les espaces précédents.

Ne copie aucune métadonnée Git, credential, fichier .env, environnement virtuel ou historique Temporal sensible.

La référence de non-régression C5 est désormais :

* 529 cas JUnit.
* 502 réussites JUnit.
* 473 tests pytest réussis.
* 29 sous-tests réussis.
* 27 échecs historiques strictement identiques.
* 78 réussites supplémentaires par rapport à C4.
* 28 tests PostgreSQL 18.4 réels.
* 5 tests SpiceDB réels.
* 85 tests réussis sans SDK Temporal.
* Head Alembic : 0004_orq_saga_outbox.
* 32 tables, 17 triggers, 4 fonctions, 85 index et 390 contraintes.

2. Documentation à relire

Relis les documents existants concernant :

* C2 : ProjectOrqSaga et outbox.
* C3b : fondation Temporal.
* C3c : contrats et Workflow V2.
* C3d : Store PostgreSQL.
* C3e : Activities V2.
* C4 : Worker métier.
* C4-Q : qualification réelle Temporal.
* C5 : enqueue transactionnel.
* LMC_SAGA_REPAIR_CONVERGENCE_ANALYSIS.md.
* LMC_WORKSPACE_INDEX.md.
* La roadmap de convergence.

Inspecte le code réellement implémenté avant de prendre des décisions.

Réutilise les composants existants et ne duplique aucune logique métier.

3. Objectif de C6

Implémente un Dispatcher Temporal indépendant, responsable de la livraison des demandes persistées par C5 dans orq_project_temporal_start_outbox.

Le Dispatcher doit :

* Identifier les entrées éligibles.
* Réserver une entrée de manière transactionnelle.
* Gérer les leases et leur expiration.
* Utiliser le Workflow ID déterministe déjà persisté.
* Rechercher une éventuelle exécution Temporal existante.
* Démarrer le Workflow V2 lorsque cela est autorisé.
* Persister l’acquittement du démarrage.
* Gérer les échecs transitoires et les résultats incertains.
* Reprendre les demandes après interruption ou redémarrage.

C6 est une couche de livraison, pas une nouvelle couche d’orchestration métier.

4. Sources autoritatives

Conserve les responsabilités existantes :

* ProjectOrqSaga : état métier autoritatif de l’opération.
* orq_project_mappings : identité distante Orq autoritative.
* orq_project_temporal_start_outbox : état de livraison à Temporal.
* Temporal : orchestration et historique des exécutions.
* Worker V2 : exécution du Workflow et des Activities.

Un statut STARTED dans l’outbox signifie uniquement que l’exécution Temporal correspondante a été identifiée et que son démarrage est confirmé.

Il ne signifie pas que le provisioning Orq est réussi.

Ne crée aucune nouvelle table d’opérations, Saga parallèle ou seconde outbox.

Aucune migration n’est attendue. Si le schéma C2 ne permet pas une garantie indispensable, expose le blocage avant toute modification.

5. Claim transactionnel et concurrence

Réutilise les champs et contraintes existants :

* Statut PENDING/DISPATCHING/STARTED/FAILED.
* attempt_count.
* dispatch_version.
* lease_owner.
* lease_expires_at.
* last_attempt_at.
* Workflow ID.
* Temporal Run ID.
* Acknowledgement.
* Code d’erreur symbolique.

Inspecte leurs noms et contraintes exacts dans C2.

Implémente une réservation transactionnelle courte avec un mécanisme adapté, notamment FOR UPDATE SKIP LOCKED si compatible avec le schéma et les ordres de verrouillage existants.

Garantis :

* Une seule réservation gagnante pour une même entrée et une même version.
* La possibilité pour plusieurs Dispatchers de traiter des entrées distinctes.
* L’incrémentation cohérente des tentatives et de la version de dispatch.
* La récupération des leases expirés.
* L’impossibilité pour un ancien propriétaire de lease d’écraser un résultat plus récent.
* L’absence de verrou SQL conservé pendant les appels Temporal.

Respecte les stratégies existantes de C3d et C5.

Ne crée aucun nouvel ordre de verrouillage susceptible d’introduire un cycle entre Saga, projet, outbox et mapping.

Teste réellement les accès concurrents.

6. Leases et CAS

Toute transition effectuée après un appel Temporal doit être protégée par un CAS adapté à l’état de l’outbox.

Vérifie notamment :

* L’identité de l’entrée.
* Le propriétaire du lease.
* La version de dispatch.
* Le statut attendu.
* La validité du lease selon la stratégie retenue.

Un résultat tardif provenant d’un Dispatcher ayant perdu son lease ne doit pas écraser un acquittement confirmé.

Définis des durées cohérentes entre les leases et les deadlines RPC.

Si un renouvellement de lease est nécessaire, justifie-le et teste-le. Sinon, démontre comment les appels bornés et la réconciliation protègent les transitions.

Utilise une référence temporelle cohérente pour les comparaisons d’expiration.

Ne revendique aucune garantie d’exclusivité distribuée absolue sur les appels réseau.

7. Démarrage du Workflow

Réutilise strictement les contrats V2 et le mécanisme de démarrage défini dans C3c.

Workflow :

LmcOrqProjectProvisionV2

Utilise :

* Le Workflow ID exact déjà persisté dans l’outbox.
* La génération existante.
* L’operation_ref existante.
* Le snapshot désiré existant.
* La Task Queue métier configurée.
* Les politiques REJECT_DUPLICATE et FAIL prévues par C3c.

Vérifie leur utilisation effective avec le SDK Temporal 1.18.2.

Ne génère jamais un nouveau Workflow ID pour résoudre une erreur de livraison.

Ne crée jamais une nouvelle Saga ou génération depuis le Dispatcher.

N’autorise aucun fallback vers le Workflow V1, le Workflow no-op ou les Workflows documentaires.

Le Dispatcher et le Worker doivent partager une configuration cohérente du namespace et de la Task Queue métier.

8. Lookup et acquittement incertain

Ce point est prioritaire.

Une perte de réponse après start_workflow ne signifie pas que le démarrage a échoué.

Le Dispatcher doit distinguer :

* Démarrage confirmé.
* Workflow correspondant déjà existant.
* Workflow absent avec réponse fiable.
* Erreur réseau transitoire.
* Résultat de démarrage incertain.
* Conflit d’identité.
* Erreur permanente de configuration ou d’autorisation.

En cas de démarrage incertain, rechercher le Workflow ID exact avant toute nouvelle tentative.

Un Workflow déjà terminé doit également pouvoir constituer une preuve de livraison si son identité et sa correspondance avec l’opération sont vérifiées.

Ne considère pas une simple erreur AlreadyStarted comme une preuve suffisante sans contrôler l’exécution correspondante.

Vérifie les informations disponibles permettant d’établir la correspondance entre Workflow, namespace, type, queue et opération, sans inventer de capacité du SDK.

Ne revendique pas une garantie de déduplication illimitée dans le temps : prends en compte la rétention des historiques Temporal.

Si l’absence d’un Workflow ne peut pas être interprétée de manière sûre après un résultat incertain, bloque la reprise automatique et conserve un diagnostic exploitable par le futur Repair.

Aucun changement d’identité, nouvelle génération ou nouveau Workflow ID ne doit permettre de contourner cette protection.

9. Retry et erreurs

Implémente une stratégie de retry bornée pour la livraison Temporal.

Prévois :

* Backoff configurable et borné.
* Nombre maximal de tentatives.
* Deadlines RPC.
* Absence de boucle intensive.
* Distinction entre erreurs transitoires, permanentes et incertaines.
* Conservation de diagnostics symboliques et assainis.
* Reprise après redémarrage.

Distingue les retries de livraison du Dispatcher des retries métier du Workflow et des mutations Orq.

Le Dispatcher ne doit jamais relancer une mutation Orq.

Il ne doit pas non plus transformer automatiquement un échec de livraison en échec métier définitif si l’exécution Temporal peut avoir démarré.

Ne laisse pas une demande définitivement bloquée sans état ou diagnostic exploitable par le futur Repair.

10. Intégration avec C5 et C3d

Le Dispatcher doit consommer les véritables entrées créées par le service C5.

Réutilise le Store et les contrats existants lorsque pertinent.

Ne recalcule pas arbitrairement le hash, la version ou la génération d’une demande.

Ne modifie pas une opération immuable.

La revalidation du projet avant mutation reste sous la responsabilité des composants C3.

Vérifie les situations où le Worker commence à exécuter ou termine un Workflow avant que le Dispatcher ait persisté son acquittement.

La finalisation tardive de la livraison ne doit jamais écraser le statut métier de ProjectOrqSaga.

Le Dispatcher agit uniquement sur une intention durable déjà autorisée par C5. Il ne doit exposer aucune nouvelle voie de provisioning utilisateur ni inventer une politique de réautorisation.

Documente séparément les questions de révocation des permissions après enqueue, si elles ne sont pas encore couvertes.

11. Cycle de vie du Dispatcher

Implémente un Dispatcher :

* Séparé de FastAPI.
* Séparé du Worker métier C4.
* Optionnel.
* Désactivé par défaut.
* Importable sans SDK Temporal.
* Démarrable explicitement depuis le Dev Container.
* Compatible avec les mécanismes existants de configuration.
* Arrêtable proprement via SIGINT et SIGTERM.

Prévois des paramètres bornés pour le polling, les batches, les leases et les retries.

Évite toute multiplication inutile de variables de configuration.

Lorsque le Dispatcher est désactivé, aucun client Temporal ne doit être chargé et aucun appel réseau ne doit intervenir.

Le fonctionnement et le lancement habituels du LMC doivent rester strictement inchangés.

N’intègre pas le Dispatcher au lifespan FastAPI, à Docker Compose, aux scripts de démarrage ou à Kubernetes.

12. Sécurité

* Aucun credential dans les entrées outbox.
* Aucun token, DSN, header ou payload fournisseur brut dans les logs.
* Aucun message d’exception SDK brut exposé.
* Aucun appel Orq.
* Aucun DELETE.
* Aucune compensation automatique.
* Aucun accès aux Workflows ou Task Queues documentaires existants.
* Aucune modification des permissions introduites par C5.

Réutilise les conventions de support, corrélation et audit existantes.

L’audit asynchrone système reste une décision ouverte : ne développe pas un système parallèle pour C6.

13. Qualification locale

Utilise PostgreSQL 18.4 réel et isolé, avec un client Temporal factice ou injectable.

Teste notamment :

Livraison nominale

* Création réelle Saga/outbox via C5.
* Claim de l’outbox.
* Start avec le Workflow ID exact.
* Acquittement et persistance du Run ID.
* Nouvelle itération sans redémarrage du Workflow.
* Workflow existant déjà terminé.

Concurrence

* Deux Dispatchers sur la même entrée.
* Plusieurs Dispatchers sur des entrées distinctes.
* Expiration et récupération d’un lease.
* Résultat tardif d’un ancien propriétaire.
* Rejet d’une ancienne dispatch_version.
* Interaction concurrente avec C5 et C3d.
* Worker finalisant l’opération avant l’acquittement du Dispatcher.
* Absence de verrou SQL pendant les RPC simulés.

Interruption et reprise

* Interruption après claim mais avant start.
* Start accepté suivi d’une perte de réponse.
* Start confirmé suivi d’un échec de persistance.
* Perte d’acquittement du commit PostgreSQL.
* Redémarrage après lease expiré.
* Workflow existant retrouvé par lookup.
* Lookup indisponible.
* Conflit d’identité.
* Résultat ancien dont l’historique Temporal peut avoir expiré.
* Épuisement des tentatives.

Non-régression

* Opérations UNKNOWN_OUTCOME non contournées.
* Opérations LOCAL_PERSISTENCE non recréées.
* Aucune nouvelle génération créée par le Dispatcher.
* Aucun changement du statut métier par une simple confirmation de livraison.
* Aucun appel réel Orq.
* Aucun appel réel Temporal pendant C6.
* Aucun comportement actif lorsque le Dispatcher est désactivé.
* Fonctionnement sans SDK Temporal.

Utilise plusieurs sessions PostgreSQL réellement indépendantes pour les scénarios de concurrence.

Ne présente pas les exceptions simulées comme des interruptions réelles du processus.

14. Préparation de la qualification réelle C6-Q

Prépare un protocole de qualification distinct, sans l’exécuter pendant C6.

Cette future qualification devra utiliser :

* Temporal préproduction existant.
* Le tunnel précédemment qualifié pendant T2 et C4-Q.
* Une Task Queue dédiée et unique.
* Le véritable service C5 pour créer Saga et outbox.
* Le Dispatcher C6 réel.
* Le Worker C4 réel.
* PostgreSQL 18.4 isolé.
* Un gateway Orq exclusivement factice.

Elle devra notamment vérifier une perte d’acquittement du start, le redémarrage du Dispatcher et la conservation du Workflow ID.

Contrairement à C4-Q, cette qualification ne devra pas préparer manuellement les opérations ni démarrer directement le Workflow depuis le harness lorsque le scénario concerne la chaîne nominale.

Préserve le contrôle explicite de l’environnement, des autorisations et des appels réseau.

Je réaliserai personnellement les commandes Kubernetes nécessaires depuis le DevEnv.

Ne rétablis aucun tunnel et ne connecte aucun Worker ou Dispatcher à Temporal préproduction pendant C6.

15. Limites à transmettre à C7

Conserve dans la roadmap :

* La reprise LOCAL_PERSISTENCE confirmée comme limitation pendant C4-Q.
* Le Workflow FAILED malgré la conservation des preuves et l’absence de double POST.
* Les opérations devenues obsolètes après enqueue.
* La réparation des mappings confirmés.
* Le traitement des livraisons Temporal incertaines.
* L’absence de retry manuel d’une opération terminale identique.
* La résolution privilégiée de UNKNOWN_OUTCOME.

Le futur Repair doit rester intégré aux mécanismes existants du LMC.

Il ne doit jamais créer une deuxième opération pour masquer une première opération incertaine.

Ne commence pas son implémentation pendant C6.

16. Non-régression complète

Exécute :

* Les tests ciblés C6.
* Les tests PostgreSQL réels.
* Les tests cumulés C1 à C6.
* La suite complète.
* Les tests sans SDK Temporal.
* La compilation Python.
* pip check.

Compare avec C5 :

* Nombre de tests.
* Node IDs des 27 échecs historiques.
* Traces normalisées.
* Signature des échecs.
* Head Alembic.
* Catalogue PostgreSQL.
* Permissions SpiceDB.
* Intégrité des composants précédents.

Ne modifie aucun test historique uniquement pour obtenir artificiellement une suite verte.

17. Contraintes impératives

* Aucune opération Git ou GitLab.
* Aucun commit, branche, push, merge, rebase ou création de MR.
* Aucun déploiement.
* Aucun changement Kubernetes.
* Aucun appel distant Temporal ou Orq.
* Aucun serveur Temporal local.
* Aucune installation de Temporal CLI.
* Aucun Worker connecté.
* Aucune modification des ressources Docker existantes.
* Seules les ressources Docker temporaires strictement isolées nécessaires aux tests sont autorisées.
* Aucune modification de Docker Compose.
* Aucune modification des Dockerfiles.
* Aucune modification des migrations existantes.
* Aucune modification du pont Alembic.
* Aucune modification des scripts 01/02/03.
* Aucune modification des configurations VS Code.
* Aucun changement de la procédure habituelle de lancement du LMC.
* Aucun nouvel endpoint public.
* Aucun changement frontend.
* Aucun développement C7, C8 ou C9.

Préserve intégralement tous les espaces précédents.

18. Documentation et restitution

Crée les documents techniques en anglais :

* documentation/C6_TEMPORAL_OUTBOX_DISPATCHER.md
* documentation/C6Q_TEMPORAL_REAL_QUALIFICATION_PLAN.md

Mets à jour l’index canonique et la roadmap de convergence.

Documente chaque fichier créé ou modifié, les composants réutilisés, les décisions techniques et les garanties réellement démontrées.

Présente-moi en français :

* L’architecture du Dispatcher.
* Les transitions d’état de l’outbox.
* La stratégie de claim, lease et CAS.
* L’ordre de verrouillage.
* Les politiques de lookup/start/retry.
* La gestion des acquittements incertains.
* Les résultats des tests PostgreSQL et de concurrence.
* Les résultats de non-régression.
* Les limitations restantes.
* Le protocole proposé pour C6-Q.
* Les prérequis de C7.

Ne revendique aucune garantie exactly-once distribuée.

Notre objectif reste la parité fonctionnelle complète avec le Mock LMC depuis le véritable LMC lancé localement, avec le Repair existant, avant tout déploiement en préproduction.

Tu peux commencer C6 dans ce périmètre.

Ne commence ni C6-Q ni C7 sans mon accord.