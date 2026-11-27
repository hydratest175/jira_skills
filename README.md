Nouvelle exigence métier pour le futur chantier Budgets, au-delà de la parité Mock LMC :

* Budget Project : plafond financier configurable, période de renouvellement et plafond de requêtes par minute (RPM).
* Budget Identity : uniquement un plafond de requêtes par minute, sans plafond financier individuel.
* Aucun plafond de tokens à exposer dans le périmètre actuel.

Privilégier les mécanismes natifs Orq : limits.amount, limits.period et rate_limit.requests_per_minute.

Les deux niveaux doivent s’appliquer simultanément. Tenir compte du caractère global des Identities et empêcher les modifications de limites globales par un Project Manager non habilité.

Vérifier ultérieurement les contrats API, les permissions, l’attribution runtime des requêtes et les capacités de notre instance Orq.

Documente cette décision dans project-memory et adapte la roadmap Budgets.

Ne commence pas son implémentation maintenant. Poursuis la mission Identity en cours.