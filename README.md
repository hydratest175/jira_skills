Je valide l’option 1.

Tu es autorisé à adapter minimalement backend/tests/test_db_metadata_alignment.py afin que les tests prennent en compte la nouvelle table orq_project_mappings.

Conditions :

* Vérifie que le passage de 30 à 31 tables correspond exactement à l’ajout attendu.
* Mets à jour uniquement les assertions nécessaires.
* Ajoute une vérification explicite de la présence de orq_project_mappings si cela est pertinent pour le test.
* Préserve intégralement toutes les autres modifications préexistantes du fichier.
* Ne touche pas aux migrations baseline existantes ni à leurs checksums.
* Ne modifie aucun autre comportement du LMC.
* Documente cette adaptation dans LMC_ORQ_INTEGRATION.md, en expliquant pourquoi le test devait évoluer.

Tu peux ensuite poursuivre et terminer l’implémentation locale du lot 1, exécuter les tests et me présenter le diff complet.

Rappel : aucun commit, push, changement de branche ni Merge Request. Je gère exclusivement Git/GitLab.