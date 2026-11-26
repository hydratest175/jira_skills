Précision importante concernant notre vision du Repair et la suite de l’intégration.

Le mécanisme Repair existant du LMC est principalement un outil de debug et de support local destiné au développeur du LMC, qui souhaite pouvoir diagnostiquer les erreurs et intervenir manuellement, comme il le fait déjà pour SDA et les autres composants.

Notre objectif est simplement de lui offrir une expérience équivalente pour Orq, en réutilisant son mécanisme existant.

Nous ne souhaitons pas faire du Repair un composant central du parcours métier de provisioning, ni développer une plateforme de réparation complexe.

Notre priorité est que le provisioning fonctionne de manière autonome, fiable et avec le moins d’interventions humaines possible.

Pour la suite :

* Privilégier la prévention des erreurs.
* Automatiser les reprises lorsque celles-ci peuvent être effectuées sans risque.
* Réutiliser les mécanismes natifs de Temporal lorsque cela est pertinent.
* Permettre la récupération automatique des mappings et finalisations locales lorsque les preuves persistées sont suffisantes.
* Privilégier la réconciliation en lecture seule lorsqu’une mutation distante est incertaine.
* Ne jamais effectuer un nouveau POST ou un nouveau start à l’aveugle.
* Utiliser le Repair existant essentiellement pour les diagnostics et les interventions manuelles résiduelles.

Inspecte notamment les possibilités de récupération automatique du scénario LOCAL_PERSISTENCE observé pendant C4-Q et des problèmes de livraison observés pendant C6-Q.

Distingue les reprises possibles pendant un Workflow actif de celles nécessitant un mécanisme de récupération après sa fermeture.

Ne suppose pas qu’une simple activation des retries Temporal suffit à résoudre ces situations.

Inspecte également le comportement réel du Repair SDA et des autres composants existants afin de reproduire une expérience similaire pour Orq, sans inventer de fonctionnalités supplémentaires ni modifier les permissions existantes.

Ne surdimensionne pas le chantier Repair.

Notre objectif principal reste la parité fonctionnelle avec le Mock LMC depuis le véritable LMC local.

Poursuis C7a conformément au périmètre actuel. Mets à jour la documentation et la roadmap avec cette clarification, puis propose les améliorations ciblées à réaliser dans les étapes suivantes.

Ne commence pas ces améliorations sans validation préalable.