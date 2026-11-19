Nous commençons officiellement l’intégration progressive du POC Mock LMC × Orq.ai dans le véritable LMC.

Nous allons travailler par micro-lots indépendants, chacun correspondant idéalement à une future Merge Request extrêmement ciblée.

MR 1 — Persistent LMC-to-Orq Project Mapping

Objectif : mettre en place uniquement la persistance durable du mapping entre un projet LMC et son projet Orq correspondant.

Contraintes impératives

1. Analyse d’abord les modèles et mécanismes de persistance existants dans LEA_Workspace/lcc, notamment Project, ProjectOrqSaga et les migrations Alembic.
2. Réutilise l’existant si cela permet de répondre correctement au besoin. N’ajoute une table ou un champ que si c’est réellement indispensable.
3. Conserve les mécanismes actuels PostgreSQL, SQLAlchemy async et Alembic.
4. Ne modifie jamais les migrations baseline existantes.
5. Garantit l’unicité et la cohérence du mapping, y compris en présence d’opérations concurrentes.
6. Ne modifie aucun workflow de création ou de suppression de projet.
7. N’intègre pas encore le SDK Orq, les agents, les budgets, les modèles, Temporal ou les Workers.
8. Ne modifie pas Keycloak, SpiceDB, SDA, Vault, MCP ou Engineering Companion.
9. Préserve toutes les modifications préexistantes du workspace.
10. Aucun appel ni aucune modification de ressources externes.

Règle absolue — Git et GitLab

Tu travailles uniquement en local. Toute la gestion Git/GitLab est exclusivement sous ma responsabilité.

Il est strictement interdit de :

* Créer, changer, renommer ou supprimer une branche.
* Effectuer un git add, git commit, git push, git pull, git merge ou git rebase.
* Effectuer un git reset, git restore, git checkout, git clean ou git stash.
* Créer, modifier, fermer ou soumettre une Merge Request.
* Modifier l’index Git, les références Git ou l’historique du dépôt.
* Déclencher une pipeline, un déploiement ou toute action distante sur GitLab.

Tu peux utiliser des commandes Git strictement en lecture seule, comme git status, git diff et git log, uniquement pour analyser l’état du dépôt et vérifier les modifications.

Ton travail consiste exclusivement à modifier les fichiers locaux nécessaires, à exécuter les tests locaux et à documenter les changements.

À la fin, tu me présentes les modifications réalisées. Je m’occuperai personnellement du commit, du push et de la Merge Request.

Documentation obligatoire

Maintiens le document LMC_ORQ_INTEGRATION.md dans le répertoire de documentation existant.

Documente précisément chaque fichier modifié, le comportement avant/après, la justification technique, les alternatives envisagées, les tests, les risques et le rollback.

Cette documentation doit être compréhensible indépendamment par le développeur du LMC.

Elle doit être actualisée à chaque nouvelle modification du code.

Méthode de travail

Commence par vérifier que ce lot ne duplique aucune fonctionnalité existante.

Présente ensuite le périmètre minimal des modifications nécessaires.

Si l’analyse confirme que le mapping doit être ajouté, implémente uniquement cette fonctionnalité et ses tests, en local exclusivement.

À la fin, fournis :

* La liste exacte des fichiers modifiés.
* Le résumé du diff et la justification de chaque changement.
* Les résultats des tests.
* Les éventuelles limites restantes.
* Le document d’intégration mis à jour.
* Une suggestion de titre et de description de Merge Request, à titre purement informatif.

Ne réalise aucun changement en dehors du périmètre de cette MR.

Important : si tu découvres qu’une décision d’architecture est indispensable ou qu’un composant existant pourrait être affecté, arrête-toi et présente le problème avant de modifier le code.

Rappel final : aucun commit, aucun push, aucune création de branche, aucune Merge Request. Toutes les modifications doivent rester exclusivement locales.