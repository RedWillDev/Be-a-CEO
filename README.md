# Be a CEO

Un jeu Roblox multijoueur : du garage à ta propre tour, crée ta marque et rivalise avec les entreprises d'une ville partagée.

## État du projet

Le premier prototype jouable est implémenté : ville de huit parcelles, commandes MarketBridge, ventes, bâtiments évolutifs, client VIP, achats personnels et véhicules liés au niveau de l'entreprise. Voir [le guide de test et les limites actuelles](docs/prototype-playtest.md). Les essais multijoueurs, mobiles et de sauvegarde en serveur publié restent nécessaires avant le lancement.

La deuxième itération ajoute les objectifs permanents et quotidiens, le calendrier de cadeaux, trois accords fournisseurs, les événements de ville, les contributions collectives, la réputation, la publicité, le réapprovisionnement automatique et les ventes hors ligne plafonnées. Deux suites de tests isolés valident 69 assertions dans Studio. Ce n'est pas encore une version commerciale complète.

La gestion comprend désormais la réception physique des colis, la caisse manuelle des clients locaux, quatre postes améliorables et le portage des vacanciers. Le vol de colis est expérimental et volontaire, uniquement dans Studio. Lire [l'audit V1](docs/v1-audit.md) avant toute publication.

## Document de conception

Lire [le document de conception complet](docs/roblox-tycoon-entrepreneur.md) pour les décisions de gameplay, la ville, la concurrence, la progression, la monétisation et la feuille de route.

Direction d'overhaul validée le 13 octobre 2026 : première vente guidée, changements complets de bâtiments jusqu'au gratte-ciel new-yorkais (hall d'accueil, arbres, dragons au sommet), vacanciers reconnaissables, collections de produits et événements de quartier. Meshy est prévu pour les assets 3D adaptés ; leur production n'est pas encore réalisée. Voir la [roadmap mise à jour](docs/roblox-tycoon-entrepreneur.md#13-feuille-de-route--overhaul-validé-le-13-octobre-2026).

## Premier prototype

- Ville compacte avec 8 parcelles et bâtiments visibles.
- Attribution d'un garage à chaque joueur.
- Choix de produit, fournisseur, commande et première vente.
- Première amélioration visible de la boutique.
- Clients locaux puis clients disputés et événement de portage sur la place.
- Interface adaptable et sauvegarde serveur implémentées, encore à valider sur mobile et en conditions réelles.

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

1. Première réussite guidée : lot initial offert une seule fois, indications visuelles et premier encaissement.
2. Cadrage artistique puis transformations garage → gratte-ciel : modèles distincts, accueil, arbres et dragons ; premier essai Meshy avant production complète.
3. Vacanciers : demandes illustrées, personnalités et protection après accueil.
4. Collections : variantes déblocables par objectifs et vitrine dédiée.
5. Événements : bus enrichi, fête du quartier, livraison express et prototype de colis bonus disputés.
6. Validation avant publication : huit joueurs, téléphone, performances des tours et sauvegardes réelles/reconnexions.

Les essais en jeu sont effectués par le joueur. Une génération Rojo réussie ne remplace pas ces validations. Aucun changement de gameplay ni asset Meshy n'a été produit lors de cette mise à jour documentaire.

## Références

- [Workflow Rojo et outils externes](https://create.roblox.com/docs/projects/external-tools)
- [Connexion MCP à Roblox Studio](https://create.roblox.com/docs/studio/mcp)
