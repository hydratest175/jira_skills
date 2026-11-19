Le plan de la MR 1 est validé.

Tu peux procéder à son implémentation locale en respectant strictement le périmètre présenté.

Précisions :

* Conserver la migration 0003 indépendante des migrations baseline existantes.
* Ne pas modifier les changements préexistants du workspace.
* Vérifier les contraintes PostgreSQL et la correspondance exacte avec le modèle SQLAlchemy.
* Ne pas ajouter de comportement de suppression distante Orq : ce sujet sera traité dans un lot ultérieur.
* Exécuter les tests ciblés et la suite locale pertinente.
* Mettre à jour documentation/LMC_ORQ_INTEGRATION.md avec les modifications exactes, leur justification, leurs conséquences et les tests.
* Ne pas modifier les workflows, API, Workers ou autres composants non nécessaires à ce lot.

Aucune action Git d’écriture : pas de commit, push, changement de branche, stash ni Merge Request.

À la fin, présente-moi les fichiers modifiés, le diff, les résultats des tests et les éventuelles limitations. Je gérerai personnellement GitLab.