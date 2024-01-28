# Structure de la base de donneés

- Users: table regroupant les utilisateurs de l'application
  - email : String
  - username : String

- Groups: table regroupant les groupes des utilisateurs
  - adminEmail : String
  - memberCount: int
  - name : String

- GroupUser: table d'association des groupes et users (vraiment pas la meilleure chose à faire dans firestore, garder les id des users dans un tableau à l'intérieur de groupes serait plus optimal) 
  - userId : String
  - groupId : String

- Products: table regroupant les produits
  - le id de la table se génère automatiquement dans le cas d'un ajout manuel.
  - si le produit est ajouté par code cup, le code cup est attribué comme id à l'article
  - addedBy : String (store l'email de l'utilisateur qui a ajouté le produit)
  - category : String
  - imageUrl : String
  - name : String
  - nutritionFacts : String (obtenu du json['nutriments'] lors de l'ajout par code cup, String regroupant les 10 premières informations nutritives du produit)

- Groceries: table regroupant les épiceries
  - createdBy: String (email du créateur)
  - date : Timestamp (date de création de l'épicerie)
  - groups : [] (tableau regroupant les id des groupes qui ont des vues sur l'épicerie)
  - products : [] (tableau de maps représentant des produits. ces produits ne sont pas les mêmes que ceux dans la table 'Products', car ils possèdent des attributs 'isMissing : bool' et 'boughtOn : Timestamp', qui permettent de persister l'état des produits d'une épicerie dans la BD, et donc de retrouver les produits manquants et achetés lorsqu'on fetch des épiceries)

Produits dans Groceries:  <img width="1139" alt="image" src="https://github.com/420-andrelaurendeau/420-456-al-h23-tp-final-yskuridov/assets/89847927/63b8465c-9b61-4ef9-acb0-4c936ab3e3f5">
