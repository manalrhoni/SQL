/* Q1 : Création de la table Notes.
   Analyse :
   1. La table possède une Clé Primaire COMPOSÉE de 3 colonnes (Code_Matiere, Code_Etudiant, CC).
      Cela signifie qu'un étudiant peut avoir plusieurs notes dans une matière, mais une seule note pour le CC n°1, une seule pour le CC n°2, etc.
   2. Il faut créer les liens (Clés Étrangères) vers les tables parents (Matieres et Etudiants).
*/

CREATE TABLE Notes (
    Code_Matiere VARCHAR(20),
    Code_Etudiant VARCHAR(20),
    CC INT,                -- Identifiant du Contrôle Continu (1, 2, 3...)
    Note DECIMAL(4,2),     -- Format décimal (Total 4 chiffres, dont 2 après la virgule. Ex: 18.50)

    -- Définition de la contrainte d'unicité (Clé Primaire Composée)
    CONSTRAINT PK_Notes PRIMARY KEY (Code_Matiere, Code_Etudiant, CC),

    -- Définition des relations (Clés Étrangères)
    CONSTRAINT FK_Notes_Matiere FOREIGN KEY (Code_Matiere) REFERENCES Matieres(Code_Matiere),
    CONSTRAINT FK_Notes_Etudiant FOREIGN KEY (Code_Etudiant) REFERENCES Etudiants(Code_Etudiant)
);

/* Q2 : Affichage des étudiants habitant à Dakhla.
   Analyse :
   - C'est une requête de sélection simple (SELECT).
   - Le filtre (WHERE) se fait sur une chaîne de caractères, donc il faut utiliser les guillemets simples.
*/

SELECT * FROM Etudiants 
WHERE Ville_Etudiant = 'Dakhla';

/* Q3 : Afficher les étudiants ayant au moins une note.
   
   Analyse :
   - On cherche les étudiants qui existent dans la table "Etudiants" ET qui apparaissent aussi dans la table "Notes".
   - Il faut éviter les doublons (DISTINCT) car un étudiant peut avoir plusieurs notes.
*/

-- MÉTHODE 1 : Avec JOINTURE (INNER JOIN)
-- On ne garde que les lignes où la correspondance existe entre les deux tables.
SELECT DISTINCT E.Code_Etudiant, E.Nom_Etudiant, E.Prenom_Etudiant
FROM Etudiants E
JOIN Notes N ON E.Code_Etudiant = N.Code_Etudiant;


-- MÉTHODE 2 : Avec le prédicat IN (Sous-requête)
-- On sélectionne les étudiants dont le Code fait partie de la liste des codes présents dans la table Notes.
SELECT * FROM Etudiants 
WHERE Code_Etudiant IN (
    SELECT DISTINCT Code_Etudiant 
    FROM Notes
);


/* Q4 : Calcul de la moyenne d'un étudiant spécifique dans une matière spécifique.
   
   Analyse :
   - Fonction d'agrégation : On utilise AVG() pour la moyenne.
   - Jointure : Nécessaire entre "Notes" et "Matieres" pour filtrer sur le NOM de la matière ('BDD').
     (Si 'BDD' était le code, on n'aurait pas besoin de jointure, mais on suppose ici que c'est le nom).
   - Filtres (WHERE) : On sélectionne l'étudiant 'P00021' ET la matière 'BDD'.
*/

SELECT AVG(N.Note) AS Moyenne_Generale
FROM Notes N
JOIN Matieres M ON N.Code_Matiere = M.Code_Matiere
WHERE N.Code_Etudiant = 'P00021'
  AND M.Nom_Matiere = 'BDD';
