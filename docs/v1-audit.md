# Audit V1 — 11 octobre 2026

Cet audit distingue présence du code et validation réelle. La V1 n'est pas encore certifiée prête à publier.

Dernière exécution Studio : **87 assertions réussies** (économie 40, progression 29, opérations 18). Vérification par l'interface : commande 180 $, colis visible sans créditer le stock, recrutement du réceptionnaire 150 $, disparition du colis et marchandises disponibles pour les ventes. Le portage manuel complet, les vacanciers et les transferts entre deux vrais joueurs restent à tester de bout en bout.

| Critère | État | Preuve / travail restant |
|---|---|---|
| Ville, 8 parcelles, garages visitables | Présent, démarrage solo vérifié | Construction `World.Build`, huit emplacements. Charge à huit joueurs à tester. |
| Attribution et libération | Présent | Attribution serveur ; libération après départ. Reconnexion et départs simultanés à tester. |
| Sauvegarde fiable | Implémentée, non validée en production | Verrou de session, tentatives, pause en cas d'échec. Studio utilise des profils temporaires ; tests sur serveur publié indispensables. |
| Trois fournisseurs et trois produits | Présent et testé | Tests de rentabilité des neuf combinaisons. |
| Négociation, commandes, ventes, clients | Présent | Trois accords. Nouvelle réception manuelle et caisse locale : validation interactive à compléter après ce changement. |
| Garage → boutique, personnalisation | Présent | Cinq niveaux, quatre palettes, luxe et véhicules. Parcours complet à équilibrer. |
| Clients locaux et disputés | Présent | Locaux encaissés au comptoir ou par caissier. Les ventes spéciales restent des bonus directs. Concurrence à plusieurs à tester. |
| Événement et portage | Présent | VIP, bus, commande collective, tendance ; ajout des vacanciers portables. Interruptions et concurrence à vérifier à plusieurs. |
| Mobile et tutoriel | Partiel | Interface adaptable, prompts tactiles Roblox, guide commande → colis → caisse → équipe. Pas encore vérifié sur téléphone réel. |
| Aucune perte/duplication | Non certifié | Suites de tests isolées ; indispensables mais insuffisantes pour prouver la fiabilité des sauvegardes réseau. |
| Boucle compréhensible et amusante | Premier retour positif | Retour utilisateur sur l'ancien prototype ; à réévaluer après réception manuelle et recrutement. |

## Ajouts de gestion

- Caissier : 120 / 240 / 360 dollars ; automatise les clients locaux et accélère le service.
- Réceptionnaire : 150 / 300 / 450 dollars ; range les colis après 12 / 8 / 4 secondes.
- Responsable commandes : entreprise niveau 2, 250 / 500 / 750 dollars ; seuil de stock 3 / 4 / 5, activation explicite du réapprovisionnement.
- Gérant : entreprise niveau 4, 1 200 / 2 400 / 3 600 dollars ; sur activation explicite, recrute et forme les trois autres postes jusqu'à son niveau, garde deux lots de réserve. Ne dépense pas en bâtiments ou achats personnels.
- Tous ces frais sont ponctuels dans cette version. Pas de salaires récurrents cachés. Les employés sont visibles mais leurs tâches sont actuellement temporisées, sans trajet animé.

## Colis et rivalité

Le stock n'est crédité qu'après réception du colis. Un colis non réceptionné bloque la prochaine commande et le changement de gamme. Les colis en attente restent dans le profil ; les états de portage ne sont pas sauvegardés. Déconnexion ou interruption repose le colis, sans créer une deuxième marchandise.

Le vol est **expérimental et limité à Studio** : niveau 2 des deux entreprises, consentement des deux joueurs, protection initiale de 20 secondes, même gamme chez le voleur, remboursement de 50 % du prix au propriétaire. Aucun vol d'argent ou de bâtiment. En serveur publié, le vol est bloqué tant qu'un mécanisme transactionnel durable entre deux profils et ses tests de panne ne sont pas disponibles.

## Validation à terminer avant lancement

### Passe visuelle du 11 octobre

Dernière exécution Studio : **349 assertions réussies** (87 existantes et 262 vérifications des personnages et véhicules). Démarrage et déplacement des passants observés dans Studio ; bus visible en jeu.

- PNJ articulés, visages, cheveux, accessoires par rôle, animations procédurales de marche et d'attente.
- Passants sur les trottoirs, promenades des touristes après arrivée du bus et petits déplacements des employés. Ces déplacements sont décoratifs, sur parcours prédéfinis : les tâches des employés restent temporisées, sans navigation jusqu'aux colis.
- Voitures, camionnette et bus enrichis : vitrages, roues et jantes, phares, sièges et détails de carrosserie. Arrivée animée du bus et départ de la camionnette.
- Modèles stylisés construits localement, sans Meshy ni achat d'assets. La conduite, les performances mobiles et les interactions de portage doivent encore être vérifiées après cette passe.

1. Parcours complet manuel, puis automatisé, jusqu'à la tour.
2. Deux puis huit clients : colis, vacanciers, VIP, départs, décès, véhicules, double interaction.
3. Téléphone portrait/paysage et conduite tactile.
4. Sauvegardes réelles, reconnexions, échecs réseau et verrou de profil.
5. Retours joueurs : compréhension, temps jusqu'au premier employé et envie de revenir.
