Nous avons validé l’étape précédente : le Mock LMC permet désormais de créer un véritable projet dans Orq.ai.

Je souhaite passer à l’étape suivante : le provisioning des Identities Orq.ai.

Objectif

Lorsqu’un projet Mock LMC est provisionné, créer ou retrouver les Identities Orq.ai correspondant aux utilisateurs membres de ce projet.

Fonctionnement attendu

1. Récupérer les utilisateurs membres du projet depuis SQLite.
2. Pour chaque utilisateur, rechercher son Identity dans Orq.ai à partir d’un external_id stable.
3. Si l’Identity existe déjà, la réutiliser.
4. Sinon, créer une nouvelle Identity via le SDK Orq.ai.
5. Enregistrer dans SQLite les correspondances entre utilisateurs locaux et Identities Orq.ai.
6. Afficher dans le Mock LMC un statut permettant de vérifier que les Identities ont été provisionnées.

Contraintes importantes

* Une seule Identity Orq.ai par utilisateur, réutilisable entre plusieurs projets.
* Ne pas créer une nouvelle Identity à chaque provisioning.
* Réutiliser le SDK Orq.ai 4.13.14 déjà intégré.
* Vérifier les signatures et les permissions nécessaires directement dans le SDK installé.
* Conserver le fonctionnement actuel de création des projets.
* Le projet test_auto étant déjà provisionné, un nouveau provisioning doit ajouter les Identities sans recréer le projet.
* Prévoir une gestion simple des erreurs et une reprise idempotente.
* Ne pas créer de budgets, modèles, agents, folders ou Routing Rules pour le moment.
* Ne pas modifier les autres repositories.
* Ne pas exécuter d’opérations réelles sur Orq.ai sans mon accord.

Validation

Je vérifierai personnellement dans Orq Studio que les Identities ont été créées correctement.

Inutile de développer des tests d’intégration complexes ou des tests automatisés qui nécessitent de multiplier les appels Orq.ai.

Implémente uniquement cette fonctionnalité et explique-moi comment la tester depuis le Mock LMC.

Ne passe pas à l’étape suivante sans ma validation.

Réponds en français.