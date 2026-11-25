Avant de poursuivre, je souhaite clarifier un point fondamental concernant notre roadmap et notre objectif final.

Notre objectif n’est pas simplement d’intégrer Temporal et de disposer d’un Workflow capable de créer un projet Orq.ai.

Notre objectif est d’intégrer progressivement dans le véritable LMC l’intégralité du périmètre fonctionnel déjà développé et validé dans notre Mock LMC.

Aucun déploiement de notre nouvelle version du LMC en préproduction ne sera envisagé tant que l’intégration complète ne sera pas fonctionnelle et validée depuis le véritable LMC lancé localement.

Je dois pouvoir utiliser l’interface du LMC local pour créer un projet, le configurer, déclencher son provisioning et retrouver les ressources correspondantes dans Orq.ai.

Le périmètre fonctionnel doit reprendre celui du Mock LMC :

* Création du projet Orq.ai.
* Identities.
* Budgets projet et utilisateurs.
* Configuration des modèles.
* Folders.
* Prompts.
* Agents personnels.
* Agent orchestrateur.
* Agents spécialistes Jira et GitLab.
* Configuration des connecteurs.

Analyse à nouveau le code du Mock LMC existant afin de retrouver précisément l’intégralité de son périmètre fonctionnel et de ne perdre aucune fonctionnalité.

Je souhaite obtenir rapidement une première intégration verticale fonctionnelle permettant de provisionner un projet Orq depuis l’interface du vrai LMC local, puis enrichir progressivement ce provisioning avec les autres ressources.

La roadmap doit donc inclure :

1. La finalisation des fondations Temporal.
2. L’intégration du Worker.
3. La persistance durable et sécurisée des mappings et des états de provisioning.
4. L’intégration des endpoints backend.
5. L’intégration frontend.
6. Le provisioning progressif de toutes les ressources du Mock LMC.
7. La qualification fonctionnelle complète depuis le LMC local.
8. Les tests réels de bout en bout.
9. Le walkthrough complet de l’application.
10. Ma validation finale avant tout déploiement en préproduction.

L’utilisation de Temporal préproduction depuis notre environnement local reste possible dans le périmètre autorisé. Cela ne doit pas être confondu avec un déploiement du LMC en préproduction.

Reprends notre roadmap existante et complète-la en conséquence. Identifie les dépendances entre les étapes, notamment celles concernant Alembic, et propose un découpage en micro-MR extrêmement ciblées.

Nous conservons toutes nos exigences de tests, de documentation, de sécurité, d’idempotence et de non-régression.

Préserve MR 0, MR 1, T1, T2 et T3.

Aucune opération Git ou GitLab. Aucune modification de l’infrastructure. Aucun nouvel appel distant à ce stade.

Pour le moment, mets à jour la roadmap et la documentation de notre intégration. Ne commence pas T4 avant validation de cette roadmap.