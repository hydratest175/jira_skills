Je valide MR6 sur son périmètre de qualification.

Les résultats sont satisfaisants :

* 309 tests réussis.
* 27 échecs préexistants identiques.
* 15 sous-tests réussis.
* 33 nouveaux tests réussis.
* Contrats V1 préservés.
* Contrats V2 versionnés.
* Workflow ID déterministe par projet, génération et opération.
* Head Alembic 0005 inchangé.
* Aucune nouvelle régression.
* Aucun appel distant.

Nous pouvons maintenant commencer MR7 — PostgreSQL State Store & Activities V2.

1. Espace de travail

Crée un nouvel espace local isolé :

/workspace/LEA_Workspace/lcc-mr7-postgresql-state-store

Utilise MR6 comme base cumulative.

Préserve intégralement tous les espaces de travail précédents.

Ne copie aucune métadonnée Git, aucun credential, fichier .env, environnement virtuel ou cache inutile.

2. Objectif

Implémente les Activities V2 et le OrqProjectStateStore PostgreSQL recommandés dans ton précédent rapport.

Notre objectif est de raccorder réellement les contrats V2, la logique de réconciliation T1 et les schémas de persistance MR4/MR5.

Relis les composants existants avant toute modification.

Réutilise au maximum :

* Les modèles SQLAlchemy existants.
* Les sessions et transactions du LMC.
* Les mécanismes existants de verrouillage.
* Les mécanismes d’audit et de journalisation.
* Les contrats et interfaces T3/MR6.
* La logique de réconciliation T1.

N’introduis pas de nouvelle couche d’abstraction ou de dépendance si les mécanismes existants répondent déjà au besoin.

3. Vérification préalable des limitations MR5/MR6

Tu as identifié plusieurs limitations importantes :

* ON DELETE RESTRICT bloque également la suppression des projets dont toutes les opérations sont terminées.
* L’unicité projet/version/mode bloque une nouvelle tentative à configuration identique.
* L’outbox garantit au plus une ligne, mais pas son existence obligatoire.
* DISPATCHING peut être représenté avec zéro tentative.
* project_ref n’est pas garanti immuable en base.
* La table d’opérations ne conserve pas la clé Orq si la persistance du mapping échoue.

Analyse précisément lesquelles doivent impérativement être résolues pour implémenter le Store SQL et les Activities V2 de manière sûre.

En particulier, nous devons pouvoir récupérer un résultat Orq confirmé lorsque la persistance du mapping échoue, sans relancer la création.

Si une correction du schéma est indispensable, présente-moi une proposition minimale avant toute nouvelle migration.

Ne modifie aucune migration existante.

Ne résous pas silencieusement les questions fonctionnelles concernant la suppression des projets et les nouvelles tentatives après échec.

4. Store PostgreSQL

Implémente les opérations de persistance strictement nécessaires aux Activities V2.

Le Store doit notamment permettre :

* Le chargement de l’opération et de son contexte.
* La vérification du projet et de son mapping.
* La comparaison de la génération, de la version et du hash désirés.
* La détection des opérations obsolètes.
* Les transitions d’état autorisées.
* L’enregistrement durable d’une tentative de mutation.
* La persistance des résultats Orq vérifiés.
* La persistance du mapping.
* La persistance du statut final.
* La conservation durable de NEEDS_RECONCILIATION.

Aligne chaque opération sur les contrats et contraintes MR5/MR6.

Les écritures doivent être transactionnelles et protégées contre les mises à jour concurrentes.

N’utilise pas de stockage en mémoire comme implémentation de production.

5. CAS et concurrence

Implémente effectivement les protections Compare-And-Swap préparées dans les étapes précédentes.

Une opération ne doit pouvoir modifier un état que si les identifiants, la génération et les autres conditions attendues correspondent encore à l’état persistant.

Teste les accès concurrents avec plusieurs véritables sessions PostgreSQL.

Vérifie notamment :

* Deux exécutions concurrentes pour le même projet.
* Une Activity recevant un snapshot obsolète.
* Un résultat tardif provenant d’une ancienne génération.
* La tentative de réécriture d’un résultat final.
* Une concurrence entre persistance du mapping et changement d’état.
* Le blocage d’une nouvelle mutation après UNKNOWN_OUTCOME.

Ne conserve pas une transaction SQL ou un verrou de ligne ouvert pendant un appel réseau Orq.

La protection contre une mutation concurrente doit être établie durablement avant l’appel externe.

Un simple contrôle de génération effectué avant l’appel externe ne suffit pas à garantir cette protection.

6. Protection contre les mutations ambiguës

Cette partie est impérative.

Avant toute tentative de mutation Orq, le Store doit pouvoir conserver durablement une réservation ou une indication de mutation potentielle, protégée contre la concurrence.

Si le processus s’arrête entre cette étape et la réception du résultat Orq, une nouvelle exécution ne doit pas considérer automatiquement la création comme non effectuée.

Distingue clairement :

* Mutation non tentée et absence de mutation démontrée.
* Mutation réservée ou potentiellement commencée.
* Mutation confirmée.
* Résultat inconnu.

Respecte l’irréversibilité de mutation_attempted définie dans MR5.

Si le schéma ou les contrats actuels ne permettent pas de représenter correctement ces situations, signale le blocage avant de poursuivre.

Conserve maximum_attempts=1 pour l’Activity mutative et la désactivation des retries de transport.

En cas de perte de résultat après une possible mutation, utilise UNKNOWN_OUTCOME / NEEDS_RECONCILIATION.

Un changement de génération ou un snapshot devenu obsolète après une possible mutation ne doit jamais faire disparaître cette information.

Si Orq a confirmé la création mais que la persistance échoue, ne relance jamais la création. Préserve ou récupère uniquement le résultat confirmé lorsque cela est possible.

N’adopte jamais automatiquement un projet sur la seule base de son nom.

Aucune suppression ou compensation automatique de ressources Orq.

7. Activities V2

Implémente les Activities nécessaires au Workflow V2 en utilisant le nouveau Store PostgreSQL.

Les responsabilités doivent rester distinctes :

* Chargement du contexte.
* Réconciliation Orq via T1.
* Persistance du mapping.
* Persistance du résultat et du statut final.

Utilise exclusivement des gateways Orq factices pour les qualifications de MR7.

Les interactions avec PostgreSQL et les gateways doivent rester dans les Activities et ne jamais être introduites directement dans le Workflow déterministe.

Préserve les contrats et comportements V1.

Ne rends pas les Activities V1 accessibles par une future activation accidentelle du provisioning V2.

8. Tests réels PostgreSQL

Utilise PostgreSQL 16 neuf et isolé pour qualifier les mécanismes de persistance.

Teste notamment :

* Les transitions d’état valides et invalides.
* Les opérations CAS réussies et refusées.
* Les écritures concurrentes.
* Le rollback des transactions.
* La perte de résultat simulée.
* Une panne après réservation de mutation.
* Une panne après création simulée mais avant persistance.
* Un échec de persistance du mapping.
* La conservation de UNKNOWN_OUTCOME après redémarrage ou recréation du Store.
* Les tentatives de mutation dupliquées.
* Les résultats tardifs ou obsolètes.
* La conservation des mappings historiques.
* L’absence de secrets dans les données persistées.

Utilise les véritables contraintes PostgreSQL plutôt que SQLite pour les tests de concurrence.

Distingue clairement les tests unitaires, les tests mockés et les tests réellement exécutés contre PostgreSQL.

9. Limitation du périmètre

MR7 doit rester ciblée sur les Activities V2 et le Store PostgreSQL.

Ne développe pas encore :

* Le Worker métier exécutable.
* Le dispatcher Temporal.
* L’enqueue transactionnel applicatif complet.
* Les endpoints API.
* Le frontend.
* Le provisioning des autres ressources Orq.
* Le dry-run PLAN.
* La résolution manuelle de UNKNOWN_OUTCOME exposée aux utilisateurs.

Si le Store et les Activities représentent un diff trop important pour une seule micro-MR, conserve deux étapes distinctes et qualifiables : Store PostgreSQL puis Activities V2.

Ne multiplie cependant pas les étapes préparatoires sans nécessité technique.

10. Non-régression

La référence actuelle est :

* 309 tests réussis.
* 27 échecs préexistants.
* 15 sous-tests réussis.
* 33 tables.
* 18 triggers.
* Head Alembic 0005.

Exécute les tests ciblés, cumulés et la suite complète.

Compare les node IDs, traces normalisées et signatures des échecs avec MR6.

Vérifie également la compilation Python et pip check.

Aucune nouvelle régression ne doit être introduite.

11. Contraintes impératives

* Aucun appel réel à Orq.ai.
* Aucun nouveau Workflow Temporal distant.
* Aucun changement Kubernetes.
* Aucun déploiement.
* Aucune opération Git ou GitLab.
* Aucune modification des conteneurs, volumes et bases existants.
* Seules les ressources Docker temporaires strictement isolées nécessaires aux tests PostgreSQL sont autorisées.
* Aucun changement du Docker Compose original.
* Aucun changement des scripts 01, 02 et 03.
* Aucun changement des configurations de lancement VS Code.
* La procédure habituelle de lancement du LMC doit rester strictement inchangée.
* Temporal et Orq.ai doivent rester optionnels.
* Préservation de tous les espaces précédents.

Notre chaîne Alembic reste provisoire et non déployable tant qu’elle n’a pas été adaptée au futur head officiel.

12. Documentation

Crée une documentation technique dédiée à MR7 en anglais.

Mets à jour LMC_WORKSPACE_INDEX.md et LOCAL_LMC_PARITY_ROADMAP.md.

Explique précisément les transactions, les opérations CAS, les transitions d’état et les protections contre les mutations concurrentes ou ambiguës.

À la fin, présente-moi en français :

* Les fichiers créés et modifiés.
* Les responsabilités de chaque composant.
* Les garanties effectivement implémentées.
* Les résultats réels des tests.
* Les décisions fonctionnelles restant à prendre.
* Les limitations et risques résiduels.
* La prochaine micro-MR recommandée.

Notre priorité reste d’obtenir une première intégration verticale fonctionnelle depuis l’interface du véritable LMC local, puis d’atteindre la parité complète avec le Mock LMC avant tout déploiement en préproduction.

Tu peux commencer MR7 dans ce périmètre. Ne commence pas l’étape suivante sans mon accord.