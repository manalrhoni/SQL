-- Q1 : Quels sont les noms des étudiants de la 2ème année qui ont une note supérieure à 10 en "Base de données".
-- Analyse :
-- 1. Jointure de 3 tables : Etudiant (pour le nom/classe), Examen (pour la note), Matiere (pour le nom du cours).
-- 2. Filtres multiples dans le WHERE.
-- 3. DISTINCT pour éviter les doublons si l'étudiant a eu plusieurs notes > 10 (ex: plusieurs contrôles).

SELECT DISTINCT et.Nom_etud 
FROM Etudiant AS et
JOIN Examen AS ex ON et.Num_etud = ex.Num_etud
JOIN Matiere AS mat ON mat.Num_mat = ex.Num_mat
WHERE et.Classe_etud = '2éme année' 
AND mat.Nom_mat = 'base de données' 
AND ex.Note > 10;

-- Q2-A : Plus grande note de l'étudiant 23 en "Compilation".
SELECT MAX(ex.Note)
FROM Examen AS ex
JOIN Matiere AS mat ON ex.Num_mat = mat.Num_mat -- Le lien obligatoire !
WHERE ex.Num_etud = 23
AND mat.Nom_mat = 'Compilation';

-- ==============================================================================
-- Q2 : Quelle est la plus grande note à l’examen obtenue par l’étudiant n°23 ?
-- ==============================================================================

-- A. Pour la matière "Compilation" uniquement
-- Analyse : On filtre sur l'étudiant ET sur le nom de la matière.
SELECT MAX(ex.Note) AS Note_Max
FROM Examen AS ex
JOIN Matiere AS mat ON ex.Num_mat = mat.Num_mat
WHERE ex.Num_etud = 23
AND mat.Nom_mat = 'Compilation';

-- B. Pour CHAQUE matière
-- Analyse : On garde le filtre sur l'étudiant, mais on GROUPE par matière pour avoir un max par cours.
SELECT mat.Nom_mat, MAX(ex.Note) AS Note_Max
FROM Examen AS ex
JOIN Matiere AS mat ON ex.Num_mat = mat.Num_mat
WHERE ex.Num_etud = 23
GROUP BY mat.Nom_mat;

-- Q3 : Nombre d’étudiants qui ont une note inférieure à 7 en "base de données".
-- Analyse :
-- 1. COUNT(DISTINCT ...) : On compte les étudiants uniques (pas les copies).
-- 2. Filtres : Note < 7 ET Matière = "base de données".

SELECT COUNT(DISTINCT ex.Num_etud) AS Nbr_Etudiants_En_Echec
FROM Examen AS ex 
JOIN Matiere AS mat ON mat.Num_mat = ex.Num_mat
WHERE ex.Note < 7 
AND mat.Nom_mat = 'base de données';


-- REEFAAIIREE Q4 : Nombre d’étudiants ayant des moyennes > 15 dans TOUTES les matières, par classe.
-- Analyse :
-- 1. On utilise la logique inverse : On cherche ceux qui ont au moins une moyenne <= 15 ("La Liste Noire").
-- 2. Ensuite, on compte les étudiants qui NE SONT PAS dans cette liste noire.

SELECT et.Classe_etud, COUNT(DISTINCT et.Num_etud) AS Nbr_Excellents
FROM Etudiant AS et
WHERE et.Num_etud NOT IN (
    -- DÉBUT LISTE NOIRE : Ceux qui ont foiré au moins une matière
    SELECT Num_etud
    FROM Examen
    GROUP BY Num_etud, Num_mat
    HAVING AVG(Note) <= 15
    -- FIN LISTE NOIRE
)
GROUP BY et.Classe_etud;


-- Q5 : Lister toutes les matières qui n’ont pas de TP.
-- Analyse :
-- On utilise l'opérateur ensembliste NOT IN.
-- On sélectionne les matières dont le numéro n'apparait PAS dans la liste des numéros de la table TP.

SELECT Nom_mat
FROM Matiere
WHERE Num_mat NOT IN (
    SELECT Num_mat 
    FROM Tp
);

-- Q6 : Augmenter la note de TP pour augmenter la moyenne générale de 0.02.
-- Analyse :
-- Formule : Moyenne = 80% Examen + 20% TP
-- On veut : Delta_Moyenne = +0.02
-- Donc : 0.2 * Delta_TP = 0.02  =>  Delta_TP = 0.02 / 0.2 = +0.1
-- Action : UPDATE simple.

UPDATE Tp
SET Not_tp = Not_tp + (0.02 / 0.2);

-- Q7 (Partie 1) : Création de la table temporaire 'Finale'
CREATE TABLE Finale (
    Num_etud INT,
    Num_mat INT,
    Note_Finale DECIMAL(4,2), -- Attention : (4,2) pour pouvoir stocker 20.00
    PRIMARY KEY (Num_etud, Num_mat),
    FOREIGN KEY (Num_etud) REFERENCES Etudiant(Num_etud),
    FOREIGN KEY (Num_mat) REFERENCES Matiere(Num_mat)
);

-- Q7 (Partie A) : Insertion des matières SANS TP
-- Formule : NoteFinale = Moyenne des examens
INSERT INTO Finale (Num_etud, Num_mat, Note_Finale)
SELECT Num_etud, Num_mat, AVG(Note)
FROM Examen
WHERE Num_mat NOT IN (SELECT Num_mat FROM Tp) -- On prend que ceux sans TP
GROUP BY Num_etud, Num_mat; -- On groupe par Etudiant ET Matière pour avoir une ligne par couple.

-- Q7 (Partie B) : Insertion des matières AVEC TP
-- Formule : NoteFinale = (2 * Somme_Examens + Note_TP) / 5

INSERT INTO Finale (Num_etud, Num_mat, Note_Finale)
SELECT tp.Num_etud, tp.Num_mat, (2 * SUM(ex.Note) + tp.Not_tp) / 5
FROM Tp AS tp 
JOIN Examen AS ex ON tp.Num_mat = ex.Num_mat 
                  AND tp.Num_etud = ex.Num_etud
GROUP BY tp.Num_etud, tp.Num_mat, tp.Not_tp; -- On ajoute tp.Not_tp ici


-- Q8 : Dans quelle classe sera chaque étudiant l'année prochaine ?
-- Analyse : On calcule la moyenne générale. Si >= 10, on ajoute +1 à la classe. Sinon, on garde la même.

SELECT et.Nom_etud, 
       CASE 
           WHEN AVG(fin.Note_Finale) >= 10 THEN et.Classe_etud + 1 
           ELSE et.Classe_etud 
       END AS Future_Classe
FROM Etudiant AS et
JOIN Finale AS fin ON et.Num_etud = fin.Num_etud
GROUP BY et.Num_etud, et.Nom_etud, et.Classe_etud;

-- Q9 : Quelles matières sont enseignées dans quelles classes ?
SELECT DISTINCT et.Classe_etud, fin.Num_mat
FROM Etudiant AS et
JOIN Finale AS fin ON et.Num_etud = fin.Num_etud
ORDER BY et.Classe_etud;

-- Q10 : Bulletin annuel (Nom Étudiant, Nom Matière, Note Finale)
SELECT et.Nom_etud, mat.Nom_mat, fin.Note_Finale
FROM Finale AS fin
JOIN Etudiant AS et ON fin.Num_etud = et.Num_etud
JOIN Matiere AS mat ON fin.Num_mat = mat.Num_mat
ORDER BY et.Nom_etud, mat.Nom_mat;
