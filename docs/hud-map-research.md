# HUD et repérage dans la ville — 13 octobre 2026

Étude documentaire et revue du code pour la cible de travail 10–14 ans. Aucun essai de jeu ou observation d'adolescents effectué par l'assistant ; pas de classement de tendances par âge ni de promesse de rétention.

## Sources et conclusions

- [Design for Roblox](https://create.roblox.com/docs/production/game-design/design-for-roblox) : entrée rapide, jeu social, interface visuelle et attention aux appareils mobiles. Application au projet : garder une ville compacte et lisible, sans reconstruire tout le quartier pour suivre une mode.
- [UI and UX design](https://create.roblox.com/docs/production/game-design/ui-ux-design) : hiérarchie de l'information, contexte, conventions et modération des couleurs/animations. Application : argent/stock en premier, événement ensuite, deux bonus séparés et une prochaine étape.
- [Onboarding techniques](https://create.roblox.com/docs/production/game-design/onboarding-techniques) : repères dans le monde, mise en évidence et aide contextuelle. Application : indiquer sa boutique, le colis ou la caisse utiles plutôt qu'ajouter une minimap permanente.

Ce sont des principes documentés, pas la preuve d'une préférence universelle des 10–14 ans. Le choix de ne pas ajouter de minimap est une décision de conception pour cette petite carte.

## Changements implémentés

- Deux badges de départ : vitesse +50 % et ventes x2, chacun avec le même compte à rebours.
- Navigation courte et horizontale sur téléphone étroit ; menu paysage remonté lorsque la navigation est masquée, pour laisser plus de place à son contenu.
- Repère « Ta boutique » visible seulement par son propriétaire, avec distance en studs.
- Une cible contextuelle à la fois : rapporter, encaisser, prendre le colis ou commander. Les tâches automatisées n'affichent pas de repère de corvée inutile.
- Mise en évidence locale de la cible. Aucun téléporteur supplémentaire, aucune modification des trajets des PNJ.
- Passage piéton central et panneaux bus/vacanciers et place/VIP, sans collisions bloquantes.
- Réutilisation des marqueurs après reconstruction du bâtiment ; recherche des colis par propriétaire.

## Validation restant au joueur

Vérifier petits écrans, orientation, menus et boutons Roblox ; regarder si un nouveau joueur trouve sa boutique et la caisse sans aide ; vérifier l'absence de chevauchement des repères et les déplacements des PNJ. Une génération Rojo réussie ne valide ni le rendu ni la compréhension.

Les gratte-ciels, dragons et assets Meshy restent le chantier architectural prévu dans la roadmap, non exécuté dans cette passe HUD/repérage.
