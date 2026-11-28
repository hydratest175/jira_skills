Le problème réseau est résolu.

Avant de me demander une nouvelle clé, analyse précisément le mécanisme d’authentification du Mock LMC pour les Identities et les API keys.

Compare avec ID-Q2 :

* Type de clé utilisée : management ou product.
* Permissions, scopes et périmètre.
* Headers, endpoints et méthode d’authentification.
* Cycle de création et d’utilisation des clés temporaires.

Identifie la cause probable du 403 et indique-moi exactement quelle clé et quelles permissions sont nécessaires dans Orq.

Réutilise le fonctionnement déjà éprouvé du Mock lorsqu’il est compatible avec notre architecture actuelle.

Ne lis ni n’affiche les valeurs des secrets. Aucun nouvel appel distant ni changement de permissions pour l’instant.