## 1. Concept de l'application
Création d'une application de gestion de listes d'épicerie permettant aux utilisateurs de créer, gérer, et suivre leurs achats.

## 2. Utilisateurs et Enregistrement
- Prise en charge de plusieurs utilisateurs.
- Possibilité pour un nouvel utilisateur de s'enregistrer depuis la page d'accueil.
- Gestion d'informations utilisateur pour la création de groupes ou d'autres informations.

## 3. Articles d'épicerie
- Liste globale partagée entre tous les utilisateurs.
- Possibilité d'ajouter de nouveaux articles.
- Caractéristiques minimales des articles : Nom, Utilisateur ayant ajouté l'article, Catégorie d'article.

## 4. Épiceries
- Création de plusieurs listes d'épicerie.
- Conservation d'un journal des épiceries passées.
- Attributs d'une épicerie : Date de l'épicerie, Liste d'articles à acheter (avec indicateur d'ordre, référence sur la liste globale, statut de l'article, date/heure de l'achat).

## 5. Épicerie Courante
- Stockage local dans la base de données.
- Possibilité de faire l'épicerie hors ligne.

## 6. Groupe/Famille
- Possibilité pour les utilisateurs de créer des groupes.
- Ajout d'autres utilisateurs dans un groupe via l'ajout d'adresses e-mail.

## 7. Page d'Accueil
- Identification des utilisateurs.
- Création de compte pour les nouveaux utilisateurs.

## 8. Ajout d'Articles
- Ajout d'articles à la liste globale d'articles.
- Numérisation d'articles via la caméra avec utilisation de l'API world.openfoodfacts.org.
- Gestion des scénarios où le code n'est pas trouvé dans la base de données.

## 9. Liste d'Épicerie
- Vue des épiceries complétées.
- Possibilité de voir les articles achetés ou non lors de l'épicerie.

## 10. Fonctionnalités de Planification
- Structuration des épiceries.
- Ajout d'articles et ordonnancement de la liste pour une planification facile.

## 11. Épicerie en Cours
- Page dédiée pour faire l'épicerie.
- Indication des articles achetés.
- Retrait de la vue courante des articles achetés.

## 12. Liste d'Article
- Affichage de tous les articles possibles.
- Filtrage de la liste par catégorie.

## 13. Vue Détaillée d'un Article
- Affichage des détails lors de la numérisation ou du clic sur un article.
- Informations présentes : Nom de l'article, Catégories, Image de l'article, Informations nutritives.
