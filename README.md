Je valide l’option 1 : création d’une permission explicite provision_orq_project dans SpiceDB.

Cette permission doit être accordée à super_admin et project_manager_scope, en respectant strictement le périmètre projet et les conventions d’autorisation existantes du LMC.

Contraintes :

* Ne pas modifier le comportement des permissions existantes.
* Ne pas modifier les relations ou les droits existants des utilisateurs.
* Ne pas coupler le provisioning aux permissions update, delete ou repair.
* Réutiliser les mécanismes d’autorisation et d’audit existants.
* Vérifier l’autorisation côté backend avant toute lecture ou restitution d’opération et avant toute création de Saga/outbox.
* Refuser par défaut en cas d’échec ou d’indisponibilité du mécanisme d’autorisation.
* Vérifier réellement l’atomicité de l’audit avec la création Saga/outbox.
* Tester les permissions positives et négatives, notamment l’impossibilité pour un Project Manager de provisionner un projet hors de son périmètre.
* Vérifier l’absence de régression sur toutes les permissions existantes.

La modification du schéma SpiceDB est autorisée uniquement dans le workspace isolé C5, ainsi que son application sur une instance de test locale et isolée.

Ne modifie aucune instance SpiceDB existante, aucune configuration Kubernetes, aucune ressource Docker existante ni la procédure habituelle de lancement du LMC.

Concernant la stratégie SQL proposée, le verrou projet comme mutex avec lectures MVCC et insertion atomique Saga/outbox me convient, sous réserve de démontrer réellement l’absence de deadlock avec le Store C3d, l’allocation concurrente des générations et la déduplication des demandes.

Documente précisément ces décisions et poursuis C5 conformément au périmètre précédemment défini.

Ne commence pas C6.