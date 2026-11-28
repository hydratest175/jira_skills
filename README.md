L’absence de /v2/api-keys/capabilities ne doit pas constituer un blocage systématique : le Mock LMC gérait déjà les clés temporaires avec cette instance.

Recherche le contrat compatible avec notre version Orq à partir du Mock, du SDK, des réponses réelles déjà observées et des références disponibles.

Adapte la gateway aux formats réellement supportés, notamment le listing JSON, les permissions, l’expiration et les preuves d’ownership. Ne rends pas l’endpoint capabilities obligatoire si ces garanties peuvent être obtenues autrement.

Si tu confirmes le contrat et les permissions minimales, poursuis directement la qualification réelle du cycle de vie d’une clé temporaire Identity : création, lecture Identity, suppression ciblée et vérification du nettoyage.

Ne crée pas de clé unrestricted pour contourner le problème.

Si une information reste réellement manquante, indique-moi précisément ce que je dois vérifier dans l’interface Orq.

Conserve nos autorisations et restrictions précédentes. Teste, documente et actualise la mémoire projet. Aucun Budget ni C9.