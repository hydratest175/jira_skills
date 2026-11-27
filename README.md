Je valide CRED-4 sur son périmètre local. Passe à ID-5 depuis lcc-cred-4-identity-gateways-key-lifecycle.

Implémente le Workflow Identity V1, ses Activities et son Worker dédié en réutilisant au maximum nos fondations Temporal, Store, Saga et outbox existantes.

Vérifie particulièrement :

* Revalidation du Product Access Engineering Companion avant mutation.
* Convergence vers une Identity unique entre projets concurrents.
* Création, utilisation et nettoyage des clés temporaires dans une même Activity, sans token ni profil utilisateur dans l’historique Temporal.
* Récupération automatique après interruption, sans double mutation ni perte des succès partiels.
* Nettoyage borné des clés orphelines, indépendant du Repair.
* Compatibilité avec notre future orchestration globale du provisioning.

Préserve le Workflow projet V2 et la logique commune PLAN/APPLY.

Les capacités Orq non démontrées doivent rester désactivées. Prépare leur qualification contractuelle avant ID-Q.

Qualifie localement avec PostgreSQL réel, Orq simulé et replay des historiques existants. Réutilise le runbook et évite les investigations redondantes.

Actualise la documentation et la mémoire projet. Toutes nos règles permanentes restent applicables.

Aucun appel distant. Ne commence pas ID-6.