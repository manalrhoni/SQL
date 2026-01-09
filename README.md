# SQL
Révision complète du module SQL (FSTT). Ce dépôt centralise les résumés de cours, les corrections des TDs et les préparations aux examens (Anciens CCs).

# 📌 FAQ : L'Indexation SQL

## 1. À quoi ça sert ?

L'indexation sert à **accélérer considérablement la récupération des données** (les requêtes de lecture).

* **Le principe :** Sans index, SQL doit parcourir toute la table ligne par ligne pour trouver une info (ce qu'on appelle un *Full Table Scan*). Avec un index, il pointe directement vers la bonne ligne.
* **L'analogie :** C'est exactement comme l'**index alphabétique** à la fin d'un livre. Au lieu de lire les 500 pages pour trouver le mot "Join", tu regardes l'index qui te dit "Page 42".

**En résumé :** Elle optimise les performances des `SELECT`, `WHERE` et `JOIN`.

## 2. Comment on la fait ?

On utilise la commande **`CREATE INDEX`**.

```sql
-- Syntaxe Générale :
CREATE INDEX nom_de_l_index ON Nom_de_la_Table (Nom_de_la_Colonne);

-- Exemple concret :
-- Créer un index sur la colonne 'Ville' de la table 'Etudiants' pour accélérer les recherches par ville.
CREATE INDEX idx_ville ON Etudiants (Ville);

```

## 3. Remarque (Point Bonus Examen)

Il ne faut pas mettre des index partout car ils **ralentissent les écritures** (`INSERT`, `UPDATE`, `DELETE`).

* **Pourquoi ?** Parce qu'à chaque fois qu'on ajoute ou modifie une donnée, le système doit mettre à jour la table **ET** l'index.
