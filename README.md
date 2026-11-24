Je valide définitivement T2 sur son périmètre de qualification.

La comparaison avec T1 explique correctement les 33 échecs préexistants. Les 41 nouveaux tests réussis, l’identité des node IDs et des traces normalisées ainsi que le Workflow no-op réel permettent de clôturer cette étape.

Je valide également globalement la proposition décrite dans documentation/TEMPORAL_T3_ORQ_PROJECT_PROPOSAL.md.

Tu peux maintenant commencer l’implémentation de T3 — Orq Project Provisioning Workflow.

1. Périmètre

T3 doit rester une micro-MR indépendante, ciblée, facilement explicable et construite sur T1 + T2.

Crée un nouvel espace de travail local isolé lcc-t3-orq-project-workflow, sans métadonnées Git.

Préserve intégralement les espaces de travail précédents.

Le périmètre de T3 est strictement limité à la réconciliation des projets Orq.ai.

Ne développe pas encore :

* Le provisioning des Identities.
* Les budgets.
* Les agents.
* Les prompts.
* Les modèles.
* Les Skills.
* L’intégration frontend.
* Les endpoints applicatifs de déclenchement.
* Le déploiement du Worker de production.

2. Architecture validée

Implémente le Workflow LmcOrqProjectProvisionV1 en réutilisant les fondations de T2.

Utilise des Activities distinctes pour :

* Le chargement du contexte projet.
* La réconciliation Orq via T1.
* La persistance du mapping.
* La persistance du statut final.

Réutilise directement reconcile_orq_project() sans duplication de la logique métier.

Le Workflow doit rester déterministe. Toutes les interactions réseau, SDK, base de données et autres opérations externes doivent être réalisées dans les Activities.

Vérifie les contrats et les fonctionnalités réellement disponibles dans temporalio 1.18.2 et orq-ai-sdk 4.13.14.

3. Protection contre les doublons

Cette partie est impérative.

Utilise maximum_attempts=1 pour toute Activity susceptible d’effectuer une mutation Orq.

Vérifie également les éventuels mécanismes de retry internes au SDK Orq et à son transport HTTP. Désactive les retries automatiques susceptibles de rejouer un POST de création ambigu, si le SDK le permet. Dans le cas contraire, documente le blocage.

Un retry explicite ne peut être autorisé que si :

* Le résultat est RETRYABLE.
* L’indicateur mutation_attempted est False.
* L’absence de tentative de mutation est effectivement démontrée.

Une information manquante ou un résultat d’Activity perdu ne doit jamais être assimilé à mutation_attempted=False.

Tout timeout, perte de résultat, panne Worker ou interruption après une possible mutation doit être traité de manière conservatrice comme UNKNOWN_OUTCOME.

Ne relance jamais automatiquement une création Orq après un résultat ambigu.

Si la création Orq réussit mais que la persistance du mapping échoue, seule la persistance peut être retentée. Ne rejoue pas la création.

N’adopte jamais automatiquement un projet Orq sur la seule base de son nom.

Si une adaptation minimale du contrat T1 est nécessaire pour garantir ces comportements, justifie-la précisément et isole-la dans le diff T3. Ne modifie pas l’espace T1 original.

4. Workflow ID et concurrence

Utilise un Workflow ID stable construit à partir du project_ref.

Définis explicitement :

* La politique de conflit lorsque plusieurs demandes concernent simultanément le même projet.
* La politique de réutilisation du Workflow ID après une exécution terminée ou échouée.
* Le comportement après UNKNOWN_OUTCOME.
* Le comportement en cas de retry manuel ou de redémarrage.

Ne considère pas le Workflow ID comme une garantie durable d’idempotence.

Identifie les limites liées à la rétention de l’historique Temporal et aux appels externes.

Aucune nouvelle exécution ne doit pouvoir contourner silencieusement un résultat ambigu antérieur.

5. Persistance et indépendance vis-à-vis d’Alembic

MR 0 et MR 1 restent en pause.

Ne les importe pas, ne les fusionne pas et ne crée aucune nouvelle migration Alembic.

Utilise des interfaces ou abstractions minimales pour représenter la future persistance des mappings, des tentatives de mutation et des statuts.

Pour les tests, utilise des implémentations contrôlées et des mocks.

Ne présente pas une implémentation en mémoire comme une solution de persistance de production.

Toute activation réelle du provisioning devra rester bloquée tant qu’une persistance autoritative et les protections nécessaires contre les doublons ne sont pas disponibles.

6. Annulation et gestion des erreurs

Distingue clairement :

* Annulation avant mutation.
* Annulation pendant une Activity mutative.
* Annulation après mutation confirmée.
* Timeout d’Activity.
* Perte du Worker.
* Résultat inconnu.
* Erreur permanente.
* Erreur temporaire sans mutation.

Une annulation Temporal ne doit jamais être assimilée à un rollback de l’opération Orq.

Vérifie les mécanismes de cancellation réellement disponibles dans le SDK Python et documente leurs limites.

N’effectue aucune suppression automatique de ressources Orq.

7. Tests et qualification

Prévois une couverture complète des scénarios nominaux et dégradés, notamment :

* Projet déjà provisionné.
* Création réussie.
* Mapping invalide.
* Collision de noms.
* Erreur temporaire avant mutation.
* HTTP 429 et erreurs réseau pendant une mutation.
* Timeout après création potentielle.
* Perte du Worker après appel Orq.
* Échec de persistance après création.
* Concurrence entre plusieurs demandes.
* Nouvelle demande après UNKNOWN_OUTCOME.
* Annulation avant, pendant et après mutation.
* Déterminisme et replay du Workflow.
* Absence de secrets ou de credentials dans les inputs, outputs et historiques Temporal.
* Configuration Temporal désactivée.

Exécute les tests ciblés T3, puis T1 + T2 + T3 et la suite complète.

La référence finale T2 est :

* 192 tests réussis.
* 15 sous-tests réussis.
* 33 échecs préexistants.

Compare les node IDs et les traces normalisées dans des conditions identiques afin de démontrer l’absence de nouvelle régression.

N’installe aucun serveur Temporal local. Si certains tests nécessitent un serveur réel, prépare-les et indique les conditions de leur exécution, sans lancer de nouveaux Workflows distants pour le moment.

8. Documentation

Maintiens une documentation technique en anglais, dédiée à T3.

Documente :

* Les décisions d’architecture.
* Les fichiers créés et modifiés.
* La justification de chaque modification.
* Les contrats d’entrée et de sortie.
* Les politiques de retry, timeout et cancellation.
* Les garanties et limites d’idempotence.
* Les dépendances futures envers la persistance.
* Les tests exécutés et leurs résultats.
* Les conditions nécessaires à l’activation réelle.

La documentation doit être suffisamment claire pour que je puisse expliquer individuellement chaque fichier et chaque choix lors de la future revue.

9. Contraintes impératives

* Aucun appel réel à Orq.ai.
* Aucun nouveau Workflow distant.
* Aucune modification Kubernetes.
* Aucune modification Docker ou Docker Compose.
* Aucun déploiement.
* Aucun changement des services ou Workers existants.
* Aucune opération Git ou GitLab.
* Préservation intégrale de MR 0, MR 1, T1 et T2.
* Documentation en anglais, restitution en français.

Tu peux maintenant implémenter T3 et réaliser l’ensemble des validations locales possibles.

Sois autonome et sollicite-moi uniquement lorsqu’un véritable blocage ou une décision d’architecture indispensable apparaît.

À la fin, présente le diff, les résultats de tests, les limites restantes et les éventuels prérequis pour une validation réelle. Ne commence pas T4 sans mon accord.