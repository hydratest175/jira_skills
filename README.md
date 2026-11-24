Merci pour l’audit Temporal. Nous allons suivre ton découpage en commençant uniquement par T1 — Orq Project Reconciliation Core.

L’objectif est de fiabiliser la création ou la réutilisation d’un projet Orq.ai avant de construire des activités Temporal susceptibles d’être réexécutées.

Avant toute modification, examine en détail le helper Orq déjà présent dans le vrai LMC et les mécanismes de réconciliation/idempotence déjà développés dans notre Mock LMC. Réutilise le code existant lorsque c’est pertinent, sans introduire de duplication inutile.

Implémente ensuite uniquement le périmètre minimal de T1 :

* Définir le contrat d’entrée d’un projet Orq désiré.
* Définir une interface testable pour les opérations Orq nécessaires.
* Réconcilier un projet existant avant de tenter une création.
* Identifier les cas ambigus et éviter les créations en double lors des retries.
* Distinguer les résultats created et reused, et classifier correctement les échecs.
* Ajouter des tests unitaires couvrant les succès, retries, timeouts, erreurs et tentatives concurrentes pertinentes.

Ne suppose pas que la simple recherche avant création garantit l’idempotence. Vérifie les garanties réellement offertes par les APIs et le client Orq existants. Signale les limites si une création exactement une fois ne peut pas être garantie.

Isolation du travail : MR 0 et MR 1 sont actuellement des modifications locales non publiées. Préserve-les intégralement. Prépare T1 dans un espace de travail local distinct, sans mélanger ses modifications avec celles des autres lots. Vérifie l’état des worktrees et les dépendances avant de modifier les fichiers.

Exclusions : aucun SDK Temporal, aucun Worker, aucune nouvelle table, aucune migration, aucun endpoint de provisioning et aucun appel distant réel. Ne modifie pas Docker, Kubernetes, la CI/CD ou la configuration de lancement du LMC.

Exécute les tests ciblés et les vérifications de non-régression réellement disponibles, puis documente précisément les résultats et limites en anglais.

Tout reste local. Ne crée aucune branche Git, aucun commit, push, merge, rebase ou Merge Request. Je gère personnellement toutes ces opérations.

À la fin, fournis un rapport en français avec les fichiers modifiés, les décisions techniques, les tests exécutés et les éventuels blocages. Ne commence pas T2 automatiquement.