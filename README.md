Je confirme avoir supprimé manuellement dans Orq le projet réel utilisé pour notre qualification. Je n’ai effectué aucune autre modification.

Consigne cette confirmation dans les preuves et la mémoire projet. Conserve la Saga, le mapping et l’outbox historiques intacts. Ne réutilise pas cette base de qualification pour les futurs provisionings.

Je valide ID-CRED-1. Passe à ID-CRED-2 depuis le workspace cumulatif actuel.

Implémente la migration additive et les modèles de persistance nécessaires aux Identities globales, aux opérations par projet, aux états individuels et au suivi des clés temporaires.

Réutilise au maximum nos mécanismes existants. Aucun stockage de token brut, aucune duplication des utilisateurs, rôles ou Product Access du LMC.

Qualifie les migrations, contraintes d’unicité, intégrité référentielle et non-régression sur PostgreSQL 18.4 réel, en réutilisant notre runner documenté.

Les garanties fournisseur encore non démontrées doivent rester explicitement ouvertes.

Toutes nos contraintes permanentes restent applicables. Documente les résultats et actualise la mémoire projet. Ne commence pas ID-CRED-3 sans validation.