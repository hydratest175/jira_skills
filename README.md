Je valide ID-CRED-2.

Passe à ID-CRED-3 depuis lcc-id-cred-2-identity-persistence, dans un nouveau workspace cumulatif isolé.

Implémente la persistance transactionnelle, les réservations de mutation, les CAS et la gestion de la concurrence pour les Identities globales et les clés temporaires.

Vérifie particulièrement que deux projets provisionnant simultanément le même utilisateur convergent vers une seule Identity, sans doublon ni perte de preuve.

Réutilise les mécanismes existants sans duplication inutile. Qualifie sur PostgreSQL 18.4 réel et explique également l’écart entre les 27 échecs historiques précédents et les 28 actuels.

Toutes nos règles permanentes restent applicables. Documente, teste et actualise la mémoire projet.

Aucun appel distant. Ne commence pas CRED-4.