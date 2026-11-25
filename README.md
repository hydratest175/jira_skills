Je valide la migration minimale 0006_prov_op_orq_key et l’approche conservatrice concernant l’état désiré.

Conserve une chaîne Alembic unique et ne modifie aucune migration précédente.

Qualifie séparément la migration 0006 avant de poursuivre l’implémentation du Store PostgreSQL et des Activities V2.

Pour l’état désiré, utilise les données autoritatives actuellement disponibles dans le LMC : BL, sensibilité, nom et description, avec un hash canonique déterministe.

Conserve teams=None pour le moment. Vérifie que cette valeur signifie bien l’absence de gestion des équipes, et non leur suppression ou leur remplacement dans Orq.

N’introduis pas de nouveau compteur de version au niveau du projet LMC à ce stade. Valide la version contre l’opération persistée et documente explicitement les limites de cette approche.

Vérifie le hash au moment de la réservation de mutation. Aucun verrou SQL ne doit rester ouvert pendant un appel réseau.

Si la configuration change après une possible mutation, préserve impérativement les informations relatives à cette mutation et son résultat. Ne transforme jamais cette situation en autorisation de recréer un projet.

Teste particulièrement la concurrence, la perte de résultat, l’échec de persistance du mapping et les redémarrages.

Préserve les contraintes V1 et V2, ainsi que toutes nos garanties contre les doublons.

Tu peux ensuite poursuivre MR7 dans le périmètre précédemment autorisé.

Toutes nos contraintes restent applicables : aucune modification de l’infrastructure existante, aucune opération Git/GitLab, aucun appel distant Orq ou Temporal, aucune modification de la procédure standard de lancement du LMC.

Documentation en anglais et restitution en français.