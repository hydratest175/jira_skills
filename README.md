Je valide MR5 sur son périmètre de qualification.

Les résultats correspondent à nos attentes :

* 276 tests réussis.
* 27 échecs préexistants identiques.
* 15 sous-tests réussis.
* 8 nouveaux tests réussis.
* 33 tables et 18 triggers.
* Migration 0005 validée réellement sur PostgreSQL 16.
* Aucune nouvelle régression.
* Préservation du LMC original.

Nous pouvons maintenant commencer la prochaine micro-MR : MR6 — Provisioning Contracts & Workflow Identity.

1. Espace de travail

Crée un nouvel espace local isolé :

/workspace/LEA_Workspace/lcc-mr6-provisioning-contracts

Utilise MR5 comme base cumulative.

Préserve intégralement tous les espaces précédents.

Ne copie aucune métadonnée Git, aucun credential, fichier .env, environnement virtuel ou cache inutile.

2. Objectif

Aligne les contrats de provisioning développés dans T3 avec les mécanismes de persistance introduits dans MR4 et MR5.

Relis les contrats existants, les modèles ORM, les migrations et la roadmap avant toute modification.

Privilégie une évolution minimale des contrats existants plutôt que la création de nouvelles abstractions.

Le périmètre doit rester limité aux contrats, à l’identification des opérations et à leurs adaptations nécessaires dans le Workflow.

3. Versionnement des contrats

Fais évoluer les contrats nécessaires pour transporter :

* operation_ref.
* project_ref.
* generation.
* La clé Orq vérifiée.
* Les références de configuration désirée strictement nécessaires.
* Le mode PLAN/APPLY, lorsqu’il est pertinent.

Distingue clairement :

* L’identifiant du projet LMC.
* La clé du projet LMC.
* L’identifiant du projet Orq.
* La clé du projet Orq.
* Les credentials et clés API, qui ne doivent jamais être transportés dans les contrats Temporal.

Vérifie la cohérence des types, contraintes, longueurs et valeurs avec le schéma PostgreSQL de MR4/MR5.

Définis explicitement le comportement des anciennes versions de contrats. Ne modifie pas silencieusement un contrat versionné incompatible.

4. Workflow ID

Définis une stratégie déterministe de Workflow ID tenant compte de l’identité de l’opération et de sa génération.

Vérifie les scénarios suivants :

* Même opération soumise plusieurs fois.
* Deux générations différentes pour un même projet.
* PLAN puis APPLY.
* Reprovisioning d’un projet existant.
* Tentative obsolète.
* Perte de l’accusé de réception du démarrage Temporal.
* Nouvelle demande après UNKNOWN_OUTCOME.

Le Workflow ID doit être stable pour une même opération et ne doit jamais permettre de contourner les protections durables associées à une mutation ambiguë.

Vérifie sa compatibilité avec les contraintes d’unicité introduites dans MR5.

Une nouvelle génération ne doit pas pouvoir autoriser automatiquement une nouvelle création Orq lorsqu’une opération précédente reste non résolue.

Ne présente pas le Workflow ID comme une garantie exactly-once.

5. Préservation des garanties de T1 et T3

Conserve impérativement :

* maximum_attempts=1 pour les Activities mutatives.
* Désactivation des retries de transport susceptibles de rejouer une création.
* Absence de retry automatique après mutation potentiellement effectuée.
* Gestion conservatrice des résultats inconnus.
* Interdiction d’adopter un projet sur la seule base de son nom.
* Absence de suppression automatique de ressources Orq.
* Distinction entre identifiant Orq vérifié et identifiant candidat.

Aligne explicitement UNKNOWN_OUTCOME avec sa représentation persistée NEEDS_RECONCILIATION.

Aucune information inconnue concernant une mutation ne doit être interprétée comme une absence de mutation.

6. Points de vigilance pour les futures étapes

MR5 introduit ON DELETE RESTRICT sur les projets possédant des opérations.

Documente l’impact potentiel sur la suppression actuelle des projets LMC, notamment lorsque toutes les opérations sont terminées.

Identifie également les implications des contraintes d’unicité projet/version/mode sur le reprovisioning et les nouvelles tentatives.

Nous devrons définir explicitement ces comportements avant leur exposition dans l’API et le frontend.

Ne modifie pas le schéma MR5 dans cette micro-MR. Si une incohérence structurelle est découverte, présente-la avant toute correction.

7. Limitation du périmètre

Ne développe pas encore :

* Le store SQL.
* Les opérations CAS effectives.
* L’enqueue transactionnel.
* Le dispatcher.
* Le Worker métier exécutable.
* Les endpoints API.
* Le frontend.
* Le provisioning d’autres ressources Orq.

Aucune nouvelle migration Alembic n’est attendue pour MR6.

Évite toute complexité qui ne serait pas directement nécessaire à l’intégration de T3 avec MR4 et MR5.

8. Tests et qualification

Exécute les tests ciblés, les tests cumulés et la suite complète.

La référence de non-régression est désormais :

* 276 tests réussis.
* 27 échecs préexistants.
* 15 sous-tests réussis.

Compare les node IDs et les traces normalisées avec la référence précédente.

Teste notamment la sérialisation, la validation des contrats, leur versionnement, la détermination des Workflow IDs, le déterminisme du Workflow et les scénarios de concurrence pouvant être simulés à ce stade.

Distingue les garanties réellement implémentées de celles qui nécessiteront le futur store SQL et le dispatcher.

9. Contraintes impératives

* Micro-MR minimale et facilement explicable.
* Aucune opération Git ou GitLab.
* Aucun changement Kubernetes.
* Aucun déploiement.
* Aucun appel réel à Orq.ai.
* Aucun nouveau Workflow Temporal distant.
* Aucune modification des conteneurs, volumes ou bases existants.
* Aucune modification du Docker Compose original.
* Aucune modification des scripts 01, 02 et 03.
* Aucune modification des configurations de lancement VS Code.
* La procédure standard de lancement du LMC doit rester strictement inchangée.
* Temporal et Orq.ai doivent rester optionnels.
* Préservation intégrale de tous les espaces précédents.

10. Documentation

Crée une documentation technique dédiée à MR6 en anglais.

Mets à jour LMC_WORKSPACE_INDEX.md et LOCAL_LMC_PARITY_ROADMAP.md.

À la fin, présente-moi en français :

* Les fichiers modifiés.
* Les évolutions des contrats.
* La stratégie de Workflow ID retenue.
* Les décisions et leurs justifications.
* Les résultats réels des tests.
* Les garanties et limites restantes.
* La prochaine micro-MR recommandée.

Ne commence pas l’étape suivante sans mon accord.

Notre priorité reste d’obtenir rapidement une première intégration verticale fonctionnelle depuis l’interface du véritable LMC local, puis d’atteindre la parité complète avec le Mock LMC avant tout déploiement en préproduction.

Tu peux commencer MR6 dans ce périmètre.