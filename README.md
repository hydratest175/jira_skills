Je valide l’option 1 : instance PostgreSQL 18.4 temporaire et isolée.

Vérifie la compatibilité exacte du catalogue avant d’appliquer les migrations 0003/0004. Si la base PG16 historique diffère du baseline attendu, privilégie une base PG18 initialisée proprement avec des données synthétiques.

Préserve intégralement la base PG16, ses volumes et les services existants. Isole également les éventuelles écritures SpiceDB.

Lance C8 reviewed sur le port 4180 et guide-moi pour tester l’interface réelle depuis mon navigateur.

Aucun appel Temporal ou Orq réel à ce stade.

Ne modifie pas notre procédure habituelle de lancement du LMC. Documente la procédure temporaire et conserve les ressources de qualification le temps de nos tests.