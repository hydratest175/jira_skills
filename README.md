Nous avons validé les étapes précédentes de notre POC Mock LMC :

* Création des projets Orq.ai.
* Création des Identities.
* Création et synchronisation des budgets projet et Identity.

Tout fonctionne.

Nous passons maintenant au provisioning des configurations de modèles LLM.

OBJECTIF

Lorsqu’un projet est provisionné depuis le Mock LMC, créer automatiquement dans Orq.ai les configurations des modèles sélectionnés pour ce projet.

Nous avons pris une décision architecturale importante : nous ne souhaitons pas gérer l’Access Control des modèles dans Orq.ai pour ce POC.

Les utilisateurs finaux n’accéderont jamais directement à Orq.ai. Les autorisations seront appliquées ultérieurement par le backend Engineering Companion.

1. CONFIGURATIONS DE MODÈLES PAR PROJET

Chaque projet Mock LMC doit disposer de ses propres configurations de modèles.

Exemple :

Projet Satellite :

* gpt56-satellite → GPT-5.6
* mistral-satellite → Mistral

Projet Radar :

* gpt56-radar → GPT-5.6

Même si deux configurations utilisent le même modèle sous-jacent, elles doivent posséder des identifiants distincts.

Attention : les configurations sont techniquement créées au niveau du workspace Orq.ai. Leur association logique aux projets sera conservée dans SQLite.

Nous acceptons que ces modèles soient techniquement accessibles aux autres projets Orq.ai. L’isolation des modèles par utilisateur et projet sera assurée ultérieurement par Engineering Companion.

2. CRÉATION DES MODÈLES

Utilise le SDK orq-ai-sdk 4.13.14 déjà intégré.

Inspecte ses méthodes et modèles Pydantic pour créer les configurations.

Les configurations doivent reprendre les paramètres nécessaires :

* Model name.
* Model ID.
* Model type.
* Provider.
* Base URL.
* API Key du fournisseur si nécessaire.
* Paramètres complémentaires pris en charge.

Réutilise les configurations enregistrées dans le Mock LMC.

Ne considère pas les valeurs fictives du catalogue comme des configurations réellement utilisables.

Si certaines informations nécessaires manquent, adapte uniquement les champs concernés du Mock LMC pour permettre leur saisie ou leur configuration sécurisée côté backend.

Les secrets des fournisseurs ne doivent jamais être exposés dans React, enregistrés en clair dans SQLite ou affichés dans les logs.

3. ACCESS CONTROL

Ne cherche plus à automatiser le partage des modèles entre projets dans Orq.ai.

Ne développe aucune intégration Terraform.

Les configurations peuvent être activées avec le comportement de partage par défaut d’Orq.ai, conformément à notre décision pour ce POC.

En revanche, conserve impérativement dans SQLite :

* Les modèles associés à chaque projet.
* Les modèles autorisés pour chaque utilisateur dans chaque projet.
* Les identifiants réels des configurations Orq.ai.

Ces données serviront ensuite au backend Engineering Companion pour appliquer les autorisations.

Ne présente pas cette association logique comme une isolation de sécurité native dans Orq.ai.

4. IDEMPOTENCE

Le provisioning doit rester idempotent.

* Ne pas recréer une configuration déjà provisionnée.
* Utiliser des identifiants fonctionnels stables.
* Retrouver les ressources existantes avant création.
* Enregistrer les mappings dans SQLite.
* Permettre la synchronisation des configurations lorsque c’est possible.
* Ne pas modifier les modèles appartenant logiquement à un autre projet.
* Ne supprimer aucune ressource existante.

5. INTÉGRATION AU WORKFLOW

Le bouton « Provisionner » doit désormais effectuer :

1. Création ou récupération du projet Orq.ai.
2. Création ou récupération des Identities.
3. Synchronisation des budgets.
4. Création ou synchronisation des configurations de modèles.
5. Enregistrement des mappings.
6. Affichage du résultat dans le Mock LMC.

Les fonctionnalités déjà validées ne doivent pas être modifiées inutilement.

6. PRÉPARATION DES ROUTING RULES

Nous utiliserons ultérieurement les Routing Rules pour permettre à un utilisateur de sélectionner dynamiquement son modèle depuis Engineering Companion.

Pour cette étape, conserve simplement les identifiants réels des modèles afin qu’ils puissent être référencés par les futures Routing Rules.

N’implémente pas encore les Routing Rules.

N’implémente pas non plus les agents ni les folders utilisateurs.

7. CONTRAINTES

* Travaille uniquement dans mock-lmc-orq-poc.
* Ne modifie pas le véritable LMC.
* Ne modifie pas Engineering Companion.
* Utilise le SDK existant.
* Conserve la configuration Docker actuelle.
* Ne modifie pas inutilement l’interface React.
* N’ajoute pas d’infrastructure supplémentaire.
* Ne journalise aucun secret.
* Ne lance aucune opération réelle Orq.ai sans mon autorisation.
* Évite les tests automatisés nécessitant des appels externes. Je réaliserai les validations fonctionnelles manuellement dans Orq Studio.

8. RÉSULTAT ATTENDU

Je veux pouvoir sélectionner plusieurs modèles dans mon Mock LMC, cliquer sur « Provisionner », puis retrouver leurs configurations dans Orq.ai.

Je veux également pouvoir créer un deuxième projet utilisant le même modèle sous-jacent et obtenir une configuration distincte.

Un deuxième provisioning ne doit pas créer de doublons.

À la fin, indique-moi comment reconstruire l’application et vérifier manuellement les configurations créées dans Orq Studio.

Ne passe pas aux agents ni aux Routing Rules avant ma validation.

Réponds en français.