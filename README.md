L’absence de pytest dans le venv n’est pas un blocage suffisant pour reporter la qualification.

Reconstitue l’environnement de test en utilisant les dépendances et versions déjà prévues par le projet, comme lors des qualifications précédentes. Exécute ensuite la suite complète avec PostgreSQL 18.4 réel et vérifie la non-régression.

Ne modifie aucun fichier de dépendances et ne recommence pas les investigations déjà réalisées.

Ajoute également une règle permanente dans project-memory : résoudre de manière autonome les problèmes ordinaires d’environnement et de dépendances de test avant de déclarer une qualification bloquée.

Limite tes lectures et tes investigations au strict nécessaire. Actualise les résultats, puis arrête-toi avant ID-CRED-3.