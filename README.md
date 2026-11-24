Avant de poursuivre, je souhaite clarifier les 27 échecs observés dans la suite pytest.

Notre objectif n’est pas de corriger tous les problèmes préexistants du LMC. Nous voulons uniquement nous assurer que MR 0 et MR 1 ne créent aucune régression et fonctionnent correctement.

Analyse précisément les 27 échecs :

1. Reproduis-les sur le code main non modifié, dans un environnement de test équivalent.
2. Identifie pour chaque échec le test concerné, sa cause, le composant testé et son éventuel lien avec MR 0 ou MR 1.
3. Distingue les tests SDA, configuration, connecteurs et autres catégories.
4. Vérifie si les échecs sont strictement identiques entre main, MR 0 et MR 1, sans te limiter au nombre total.
5. Détermine lesquels peuvent être considérés comme préexistants et hors périmètre, et lesquels doivent impérativement être résolus.
6. Propose un ensemble de tests de validation pertinent pour MR 0 et MR 1, sans masquer les échecs exclus.

Ne corrige aucun problème hors périmètre et ne modifie pas le code à ce stade.

Documente en anglais les exclusions justifiées et les limites de validation dans les documents existants.

Tout reste local : aucun commit, push, branche, merge, rebase ou création de Merge Request. Préserve les modifications existantes.

Je veux un bilan clair en français avec une recommandation argumentée sur les tests que nous pouvons raisonnablement exclure du critère bloquant de nos MR.