-- ==============================================================================
-- 0. PRÉPARATION (Nettoyage)
-- ==============================================================================
-- Si la base existe déjà, on la supprime pour repartir à zéro (utile pour les tests)
DROP DATABASE IF EXISTS Facturation;

-- ==============================================================================
-- Q1 : CRÉATION DE LA BASE ET DES TABLES (DDL)
-- ==============================================================================

-- 1. Création du conteneur
CREATE DATABASE Facturation;
USE Facturation;

/* REMARQUE IMPORTANTE SUR L'ORDRE DE CRÉATION :
   Il faut toujours créer les tables "Pères" (Article, Facture) AVANT 
   les tables "Fils" (Lign_Fac) qui contiennent les Clés Étrangères.
*/

-- 2. Table Article (Père)
CREATE TABLE Article (
    Num_Art INT PRIMARY KEY,
    Description VARCHAR(50),
    PU DECIMAL(10, 2) -- DECIMAL est mieux que FLOAT pour l'argent
);

-- 3. Table Facture (Père)
CREATE TABLE Facture (
    Num_Fac INT PRIMARY KEY,
    Date_Fac DATE,    -- Format standard SQL : AAAA-MM-JJ
    Total DECIMAL(10, 2)
);

-- 4. Table Lign_Fac (Fils / Liaison)
/* Correction Logique par rapport à l'énoncé :
   L'énoncé montre "Num_Lign" comme première colonne. Mais pour lier une ligne 
   à une facture, cette colonne DOIT correspondre à Num_Fac.
*/
CREATE TABLE Lign_Fac (
    Num_Fac INT,          -- Remplaçant de "Num_Lign" pour la cohérence
    Num_Art INT,
    Qte_Comd INT,
    Montant DECIMAL(10, 2),
    
    -- La Clé Primaire est composée (Couple unique Facture + Article)
    PRIMARY KEY (Num_Fac, Num_Art),
    
    -- Contraintes d'intégrité (Clés Étrangères)
    FOREIGN KEY (Num_Fac) REFERENCES Facture(Num_Fac),
    FOREIGN KEY (Num_Art) REFERENCES Article(Num_Art)
);

-- ==============================================================================
-- Q2 : MODIFICATION DE STRUCTURE (ALTER)
-- ==============================================================================
-- "Ajouter l’attribut num_cli dans la table facture."

ALTER TABLE Facture 
ADD Num_Cli INT;

-- ==============================================================================
-- Q3 : ALIMENTATION DES DONNÉES (INSERT)
-- ==============================================================================
/*
   ANALYSE DES DONNÉES DE L'IMAGE :
   Tableau Lign_Fac contient :
   - Ligne 1 : Facture 3, Article 1 (OK, ces IDs existent dans les tableaux parents)
   - Ligne 2 : Facture 1, Article 2 (ATTENTION : Ces IDs n'existent pas dans les tableaux parents !)
   
   SOLUTION : Je dois créer les "Fantômes" (Facture 1 et Article 2) pour que 
   l'insertion ne plante pas à cause des Clés Étrangères.
*/

-- 1. Remplissage de ARTICLE
INSERT INTO Article (Num_Art, Description, PU) VALUES (1, 'Imp', 100.00);
INSERT INTO Article (Num_Art, Description, PU) VALUES (3, 'Pc', 10000.00);
-- Ajout de l'article manquant pour la cohérence
INSERT INTO Article (Num_Art, Description, PU) VALUES (2, 'Souris', 50.00); 

-- 2. Remplissage de FACTURE
-- Rappel format date : '1996-12-05'
INSERT INTO Facture (Num_Fac, Date_Fac, Total, Num_Cli) VALUES (3, '1996-12-05', 10.00, 101);
INSERT INTO Facture (Num_Fac, Date_Fac, Total, Num_Cli) VALUES (4, '1996-12-07', 20.00, 102);
-- Ajout de la facture manquante pour la cohérence
INSERT INTO Facture (Num_Fac, Date_Fac, Total, Num_Cli) VALUES (1, '1996-12-01', 100.00, 103);

-- 3. Remplissage de LIGN_FAC
INSERT INTO Lign_Fac (Num_Fac, Num_Art, Qte_Comd, Montant) VALUES (3, 1, 10, 10.00);
INSERT INTO Lign_Fac (Num_Fac, Num_Art, Qte_Comd, Montant) VALUES (1, 2, 50, 100.00);

-- ==============================================================================
-- Q4 : AFFICHAGE DES DONNÉES (SELECT)
-- ==============================================================================
SELECT * FROM Article;
SELECT * FROM Facture;
SELECT * FROM Lign_Fac;

-- ==============================================================================
-- Q5 : FILTRER PAR DATE
-- ==============================================================================
-- "Afficher le nombre de factures effectuées entre D1 et D2."
-- On suppose D1 = 01/12/96 et D2 = 31/12/96

SELECT COUNT(*) AS Nombre_Factures_Decembre
FROM Facture
WHERE Date_Fac BETWEEN '1996-12-01' AND '1996-12-31';

-- ==============================================================================
-- Q6 : FILTRE COMPLEXE (OR)
-- ==============================================================================
-- "Afficher les articles dont le prix est > 500 OU <= 350."

SELECT * FROM Article
WHERE PU > 500 
   OR PU <= 350;

-- ==============================================================================
-- Q7 : MISE À JOUR (UPDATE)
-- ==============================================================================
-- "Augmenter le prix unitaire d’une somme forfaitaire de 5."

UPDATE Article
SET PU = PU + 5;

-- Vérification après mise à jour (Optionnel)
-- SELECT * FROM Article;

-- ==============================================================================
-- GESTION DES DROITS (DCL - Data Control Language)
-- ==============================================================================

-- Q8 : "Limiter l’utilisation de la base de données pour l’administrateur KIKI."
-- Interprétation : Créer un Admin qui a tous les droits.

CREATE USER IF NOT EXISTS 'KIKI'@'localhost' IDENTIFIED BY '1234';
GRANT ALL PRIVILEGES ON Facturation.* TO 'KIKI'@'localhost';
FLUSH PRIVILEGES; -- Toujours valider les droits

-- Q9 : "Donner le droit de consulter la table T1 (Facture) pour KAKA et KOKO."

-- Création des utilisateurs
CREATE USER IF NOT EXISTS 'KAKA'@'localhost' IDENTIFIED BY 'pass';
CREATE USER IF NOT EXISTS 'KOKO'@'localhost' IDENTIFIED BY 'pass';

-- Attribution du droit SELECT (Lecture seule) uniquement sur Facture
GRANT SELECT ON Facture TO 'KAKA'@'localhost';
GRANT SELECT ON Facture TO 'KOKO'@'localhost';

-- Q10 : "Supprimer le droit de consultation de T1 pour KOKO."

REVOKE SELECT ON Facture FROM 'KOKO'@'localhost';
-- Maintenant KOKO ne peut plus rien voir.

-- ==============================================================================
-- Q11 : SUPPRESSION DE TABLE (DDL)
-- ==============================================================================
-- "Supprimer la table T2 (Article)."

/*
   ATTENTION : 
   On ne peut pas supprimer 'Article' directement car 'Lign_Fac' contient 
   des articles (Clé étrangère). SQL va bloquer pour protéger les données.
   
   Solution : Il faut supprimer la table fille d'abord, ou désactiver les vérifications.
*/

-- Méthode brutale (Désactiver la sécurité) :
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE Article;
SET FOREIGN_KEY_CHECKS = 1;

-- Méthode douce (Recommandée) :
-- DROP TABLE Lign_Fac;
-- DROP TABLE Article;

/* FIN DU FICHIER */
