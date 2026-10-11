# Be a CEO

Un jeu Roblox multijoueur : du garage à ta propre tour, crée ta marque et rivalise avec les entreprises d'une ville partagée.

## État du projet

Le concept est validé et le dépôt est initialisé avec la documentation. Aucun prototype jouable ni projet Rojo n'est encore intégré. Aucune connexion à Roblox Studio ni publication du jeu n'a été effectuée.

## Document de conception

Lire [le document de conception complet](docs/roblox-tycoon-entrepreneur.md) pour les décisions de gameplay, la ville, la concurrence, la progression, la monétisation et la feuille de route.

## Premier prototype

- Ville compacte avec 8 parcelles et bâtiments visibles.
- Attribution d'un garage à chaque joueur.
- Choix de produit, fournisseur, commande et première vente.
- Première amélioration visible de la boutique.
- Clients locaux puis clients disputés et événement de portage sur la place.
- Interface mobile et sauvegarde fiable.

Les systèmes avancés (alliances, espionnage, saisons) viennent après validation de cette boucle.

## Développement prévu

- **Luau** pour les scripts Roblox.
- **GitHub** pour les sources, les versions et la revue des changements.
- **Rojo** pour synchroniser les fichiers locaux avec Roblox Studio.
- **Roblox Studio** pour tester le rendu, le multijoueur et publier l'expérience.

GitHub seul ne contrôle pas Studio. Une connexion locale au serveur MCP de Studio est une option complémentaire pour un client IA compatible.

Les sources gérées par Rojo doivent être modifiées dans le dépôt ; éviter les modifications concurrentes du même script dans Studio. Les secrets ne doivent pas être versionnés.

## Prochaines étapes

1. Configurer l'environnement local Windows ou macOS et Roblox Studio.
2. Ajouter la structure Rojo et les dossiers serveur, client et partagés.
3. Construire la ville et la première vente.
4. Vérifier les sauvegardes, les reconnexions et le jeu à plusieurs dans Studio.

## Références

- [Workflow Rojo et outils externes](https://create.roblox.com/docs/projects/external-tools)
- [Connexion MCP à Roblox Studio](https://create.roblox.com/docs/studio/mcp)
