Les secrets précédemment exposés ont été renouvelés de mon côté.

Je souhaite maintenant poursuivre notre qualification sans ouvrir un chantier de sécurité disproportionné.

Je t’autorise à apporter les modifications strictement nécessaires au Dockerfile et au générateur de configuration pour :

* Utiliser les secrets BuildKit sans exposer les nouveaux credentials dans les logs, les couches Docker ou le cache.
* Générer une configuration de qualification fake-only, sans clé Orq réelle.
* Préserver notre procédure habituelle de lancement 02/03.

Isole cette correction du développement fonctionnel Orq. Documente les éventuelles améliorations de sécurité restantes dans une future MR dédiée.

Vérifie également le périmètre résiduel d’exposition des anciens secrets et propose un nettoyage ciblé, sans supprimer de cache global ni de ressources existantes.

Termine ensuite le lancement standard du LMC, vérifie le bon fonctionnement de la pile et prépare notre provisioning intégré avec Temporal réel et Orq simulé.

Lorsque tout est prêt, donne-moi les commandes pour établir le tunnel Temporal.

Toutes nos contraintes permanentes restent applicables. Actualise la documentation et la mémoire projet.

Évite les investigations redondantes : notre priorité est désormais d’avancer sur l’implémentation fonctionnelle complète.