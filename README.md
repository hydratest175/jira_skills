Je souhaite harmoniser l’organisation de nos espaces de travail.

MR 0, T1, T2 et T3 disposent chacun d’un dossier dédié, mais MR 1 est actuellement conservée dans le dossier principal lcc.

Je souhaite sécuriser MR 1 avant de poursuivre nos travaux.

Crée un nouvel espace local isolé :

/workspace/LEA_Workspace/lcc-mr1-orq-project-mapping

Cet espace doit contenir l’état complet et cumulatif de MR 0 + MR 1, sans métadonnées Git, comme pour T1, T2 et T3.

Vérifie précisément :

* Que toutes les modifications de MR 0 et MR 1 sont présentes.
* Que les éventuelles modifications étrangères à MR 0 et MR 1 ne sont pas copiées.
* Que les migrations Alembic et les modèles associés sont présents.
* Que la documentation et les tests sont conservés.
* Que les différences entre MR 0 et MR 1 correspondent bien au périmètre attendu.
* Qu’aucun credential, fichier sensible ou environnement virtuel inutile n’est copié.

Ne déplace et ne supprime aucun fichier du dossier lcc original. Ne restaure pas encore son état initial.

Préserve intégralement tous les autres espaces de travail.

Aucune opération Git ou GitLab, aucune modification Docker ou Kubernetes.

Mets à jour la documentation pour préciser l’emplacement et le contenu cumulatif de chaque espace de travail.

Présente-moi le résultat de cette sauvegarde et les vérifications effectuées.