Nous allons séparer les modifications locales déjà réalisées dans le vrai LMC (/workspace/LEA_Workspace/lcc, ou chemin équivalent dans ton environnement) en deux merge requests indépendantes.

Objectif : préserver intégralement le travail existant et préparer une première MR uniquement consacrée à la correction des incohérences Alembic 0001/0002.

Règles impératives

1. Ne perds, n’écrase et n’annule aucune modification existante dans le workspace LCC.
2. N’utilise pas git reset --hard, git clean, ni de stash global.
3. Tu peux utiliser un Git worktree local distinct basé sur origin/main pour isoler proprement les corrections. Vérifie d’abord son état.
4. Ne fais aucun commit, push, merge, rebase distant ou création de merge request. Je m’occupe personnellement de toutes les opérations GitLab et de la soumission des MR.
5. Ne touche à aucune ressource Orq, Vault, Kubernetes ou base de données distante.
6. Respecte strictement le principe de modification minimale : aucun refactoring non indispensable.
7. Toute modification doit être justifiée et documentée.

Phase A — Préserver et identifier

Analyse les diffs et fichiers non suivis présents dans LCC.

Sépare précisément :

MR 0 — Correction des baselines Alembic

* Checksums des migrations 0001_baseline_schema.py et 0002_baseline_reference_data.py.
* Corrections minimales des tests historiques correspondants.
* Alignement des assertions avec le contenu SQL réellement versionné.
* Documentation dédiée.

MR 1 — Mapping projet LMC / Orq

* 0003_orq_project_mappings.py.
* Modèle SQLAlchemy OrqProjectMapping.
* Tests de mapping, de contraintes et de migration.
* Adaptation du test global des métadonnées à 31 tables.
* Documentation d’intégration Orq déjà commencée.

Vérifie le classement par hunk et non seulement par fichier, car plusieurs modifications peuvent être mélangées dans un même fichier.

Phase B — Préparer MR 0 de manière isolée

À partir du véritable origin/main disponible, prépare dans un environnement local séparé uniquement les corrections nécessaires aux baselines.

Le schéma SQL initial contient déjà 30 tables. MR 0 doit refléter cet état, sans inclure la table Orq ajoutée par MR 1.

Ne modifie pas les fichiers SQL des baselines si leur contenu est déjà correct.

Recalcule les checksums et vérifie leur correspondance exacte avec les fichiers SQL concernés.

Vérifie également les autres attentes de tests affectées, notamment les nombres de tables, triggers et insertions de références, sur la base des fichiers réellement présents.

N’introduis aucune dépendance à 0003, OrqProjectMapping ou au provisioning Orq.

Phase C — Documentation de MR 0

Crée documentation/ALEMBIC_BASELINE_FIX.md dans l’espace local isolé.

Ce document doit être compréhensible par le développeur responsable du LMC sans qu’il ait besoin de te poser des questions.

Inclure obligatoirement :

* Contexte et découverte du problème.
* Causes exactes vérifiées dans le code.
* Liste exhaustive des fichiers et symboles modifiés.
* Valeurs avant/après des checksums et assertions.
* Pourquoi le changement est nécessaire indépendamment d’Orq.
* Pourquoi le SQL de référence n’est pas modifié.
* Impact attendu sur les nouvelles bases et sur les bases existantes.
* Alternatives examinées et raisons de leur rejet.
* Tests exécutés, résultats et limites.
* Procédure de rollback.
* Confirmation de l’absence de modification des autres fonctionnalités LMC.

Documente chaque modification au moment où tu la fais.

Phase D — Vérifications

Exécute les tests ciblés disponibles sans modifier les dépendances du projet inutilement.

Si possible, valide les migrations sur une base PostgreSQL vierge et un scénario compatible avec une base déjà initialisée.

Si l’environnement ne permet pas ces tests, indique clairement ce qui n’a pas été vérifié. Ne présente pas des vérifications statiques comme des tests d’intégration réussis.

Vérifie également que MR 0 peut être appliquée indépendamment sur origin/main, sans les changements de MR 1.

Phase E — Préparer la suite

Ne modifie pas encore le périmètre fonctionnel de MR 1.

Fournis un inventaire précis de tout ce qui restera à transférer dans MR 1 après fusion de MR 0, en conservant les modifications existantes.

À la fin, donne-moi :

1. Les fichiers exacts de MR 0.
2. Le résumé des changements avant/après.
3. Les tests exécutés et leurs résultats.
4. Les éventuels blocages.
5. Le chemin de l’espace de travail local isolé.
6. Les actions Git que je devrai effectuer moi-même pour soumettre MR 0.

Arrête-toi une fois MR 0 préparée localement et documentée. N’enchaîne pas automatiquement sur MR 1.