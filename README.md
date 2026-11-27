Je valide ID-5 sur son périmètre local.

Passe à ID-6 depuis lcc-id-5-identity-workflow-v1, dans un workspace cumulatif isolé.

Implémente l’intégration API/frontend des Identities et le raccordement transactionnel enqueue/outbox/Dispatcher nécessaire au Workflow Identity V1.

Points de vigilance :

* Réutiliser les utilisateurs et Product Access existants du LMC.
* Distinguer permission de provisioning et éligibilité utilisateur.
* Exposer PLAN/APPLY avec les garanties déjà définies, en présentant le PLAN local comme prévisionnel.
* Réutiliser la section Orq et le suivi de progression existants, sans multiplier les boutons ni reconstruire une interface parallèle.
* Afficher les résultats individuels et agrégés, notamment les succès partiels et les incertitudes.
* Préparer l’orchestration globale via un seul bouton, sans modifier le Workflow projet V2 déjà qualifié.
* Conserver Repair comme outil résiduel de diagnostic/support.

Qualifie les permissions, la concurrence, la livraison Temporal simulée, les contrats API, le build frontend et la non-régression.

Les capacités fournisseur non démontrées restent désactivées.

Toutes nos règles permanentes restent applicables. Réutilise le runbook, documente et actualise la mémoire projet.

Aucun appel distant. Ne commence pas ID-Q.