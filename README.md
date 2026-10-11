# Be a CEO

Un jeu Roblox multijoueur : du garage à ta propre tour, crée ta marque et rivalise avec les entreprises d'une ville partagée.

## État du projet

Le concept est validé et le dépôt contient maintenant le socle Rojo relié au lieu Roblox du projet. Le prototype jouable reste à construire.

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

## Environnement de développement Windows

Le projet utilise Rojo 7.7.1 et le port local `34872`.

- `src/shared` est synchronisé vers `ReplicatedStorage/BeACEO`.
- `src/server` est synchronisé vers `ServerScriptService/BeACEO`.
- `src/client` est synchronisé vers `StarterPlayer/StarterPlayerScripts/BeACEO`.

La configuration conserve les instances inconnues : la baseplate, le point d'apparition et les objets créés hors des dossiers `BeACEO` ne sont pas supprimés par Rojo.

1. Exécuter `scripts/setup-rojo.ps1` une seule fois si Rojo n'est pas déjà disponible.
2. Exécuter `scripts/serve.ps1` et laisser le serveur ouvert.
3. Dans Roblox Studio, ouvrir le plugin Rojo et se connecter à `localhost:34872`.
4. Exécuter `scripts/build.ps1` pour valider la configuration sans modifier la scène ouverte.
5. Vérifier les changements avec `git status`, puis les envoyer vers GitHub avec un commit et un push.

## Prochaines étapes

1. Construire la ville et la première boucle de vente.
2. Ajouter l'attribution des garages et la progression visible.
3. Vérifier les sauvegardes, les reconnexions et le jeu à plusieurs dans Studio.
4. Tester l'interface sur mobile avant d'ajouter les systèmes avancés.

## Références

- [Workflow Rojo et outils externes](https://create.roblox.com/docs/projects/external-tools)
- [Connexion MCP à Roblox Studio](https://create.roblox.com/docs/studio/mcp)
