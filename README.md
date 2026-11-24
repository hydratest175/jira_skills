Je souhaite que tu poursuives les recherches et les tests de manière autonome en exploitant les accès Docker, Kubernetes, Vault, les dépôts locaux et les configurations déjà disponibles dans ton environnement.

Concernant la recherche des paramètres Temporal :

* Recherche toi-même l’ensemble des paramètres nécessaires à la connexion.
* Inspecte les ressources existantes, leurs configurations, leurs variables d’environnement non sensibles et leurs logs, exclusivement en lecture seule.
* Analyse notamment la configuration du Worker Temporal Engineering Companion déjà déployé en préproduction.
* Ne modifie, ne crée, ne supprime et ne redémarre aucune ressource Kubernetes, aucun conteneur Docker et aucun service existant.
* N’expose aucune valeur de secret et ne contourne aucune restriction d’accès.
* Si certaines informations restent introuvables après avoir exploité les différentes pistes disponibles, indique-moi précisément lesquelles et où je pourrais les trouver afin que je puisse t’aider.

Concernant les autorisations de test :

* Les tests non destructifs sont autorisés.
* Tu peux effectuer des tests de connectivité réseau, des connexions SDK, des appels descriptifs, des tests unitaires et des tests d’intégration.
* Tu peux créer et exécuter un Workflow Temporal de test sans effet métier, avec un Worker local dans le Dev Container et une Task Queue dédiée, à condition que cet usage soit autorisé et qu’il n’interfère pas avec les Workflows et Workers existants.
* Tu peux créer du code et des tests dans un espace de travail local isolé.
* Aucun appel métier ni création de ressources Orq.ai à ce stade.

Contraintes impératives :

* Aucune modification de l’infrastructure existante.
* Aucune modification, création ou suppression de ressources Kubernetes ou de conteneurs Docker.
* Aucun changement de configuration Docker Compose ou Kubernetes.
* Aucun déploiement ni redémarrage de service.
* Aucune installation de Temporal CLI ou de serveur Temporal local.
* Aucune perturbation des services, Workers et Workflows existants.
* Préserve intégralement MR 0, MR 1 et T1.
* Aucune opération Git ou GitLab.
* Documentation technique en anglais et restitution des résultats en français.

L’objectif est que tu sois le plus autonome possible dans tes recherches et tes tests, sans prendre le moindre risque pour l’infrastructure existante.

Ne t’arrête pas au premier obstacle : explore les différentes pistes accessibles et autorisées. Si une information indispensable reste manquante, si un accès supplémentaire est nécessaire ou si un test risque d’affecter l’existant, sollicite-moi avant de poursuivre. Je pourrai effectuer des recherches complémentaires pour t’aider.

Je vais également te transmettre les informations que j’ai déjà obtenues manuellement sur Kubernetes.