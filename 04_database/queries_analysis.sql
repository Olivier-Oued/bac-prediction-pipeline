-- =====================================================
-- 04_database/queries_analysis.sql
-- Requêtes analytiques — bac_prediction
-- Auteur : Olivier OUEDRAOGO
-- =====================================================
-- NIVEAU 1 — Agrégations de base
-- =====================================================


-- ─────────────────────────────────────────────────────
-- Q1. Vue d'ensemble des données
-- Concept : COUNT pour compter les lignes
--           COUNT DISTINCT pour compter les valeurs uniques
-- ─────────────────────────────────────────────────────
SELECT
    COUNT(*)                     AS nb_evaluations,
    COUNT(DISTINCT student_code) AS nb_eleves,
    COUNT(DISTINCT subject)      AS nb_matieres,
    COUNT(DISTINCT level)        AS nb_filieres,
    COUNT(DISTINCT semester)     AS nb_semestres
FROM bac.lycee_notes;


-- ─────────────────────────────────────────────────────
-- Q2. Moyenne générale au lycée
-- Concept : AVG pour calculer la moyenne
--           ROUND pour arrondir à 2 décimales
-- ─────────────────────────────────────────────────────
SELECT
    ROUND(AVG(mark), 2) AS moyenne_generale,
    ROUND(MIN(mark), 2) AS note_minimum,
    ROUND(MAX(mark), 2) AS note_maximum,
    COUNT(*)            AS nb_evaluations
FROM bac.lycee_notes;


-- ─────────────────────────────────────────────────────
-- Q3. Moyenne par filière (lycée)
-- Concept : GROUP BY pour regrouper par catégorie
--           ORDER BY DESC pour trier du plus grand au plus petit
-- ─────────────────────────────────────────────────────
SELECT
    level                        AS filiere,
    ROUND(AVG(mark), 2)          AS moyenne,
    COUNT(DISTINCT student_code) AS nb_eleves,
    COUNT(*)                     AS nb_evaluations
FROM bac.lycee_notes
GROUP BY level
ORDER BY moyenne DESC;


-- ─────────────────────────────────────────────────────
-- Q4. Moyenne par matière (lycée) — top et flop
-- Concept : HAVING pour filtrer après un GROUP BY
--           WHERE filtre avant, HAVING filtre après l'agrégation
-- ─────────────────────────────────────────────────────
SELECT
    subject             AS matiere,
    ROUND(AVG(mark), 2) AS moyenne,
    COUNT(*)            AS nb_evaluations
FROM bac.lycee_notes
GROUP BY subject
HAVING COUNT(*) > 50        -- on garde seulement les matières avec assez de données
ORDER BY moyenne DESC;


-- ─────────────────────────────────────────────────────
-- Q5. Moyenne par semestre (lycée)
-- Concept : voir l'évolution dans le temps
-- ─────────────────────────────────────────────────────
SELECT
    semester                     AS semestre,
    ROUND(AVG(mark), 2)          AS moyenne,
    COUNT(DISTINCT student_code) AS nb_eleves
FROM bac.lycee_notes
GROUP BY semester
ORDER BY semester;


-- ─────────────────────────────────────────────────────
-- Q5b. Moyenne par filière ET par semestre
-- Concept : GROUP BY sur plusieurs colonnes simultanément
-- ─────────────────────────────────────────────────────
SELECT
    level                        AS filiere,
    semester                     AS semestre,
    ROUND(AVG(mark), 2)          AS moyenne,
    COUNT(DISTINCT student_code) AS nb_eleves
FROM bac.lycee_notes
GROUP BY level, semester
ORDER BY level, semester;


-- ─────────────────────────────────────────────────────
-- Q6. Résultats au bac par filière
-- Concept : même logique sur la table bac_results
-- ─────────────────────────────────────────────────────
SELECT
    bac_level                    AS filiere_bac,
    ROUND(AVG(mark), 2)          AS moyenne_bac,
    ROUND(MIN(mark), 2)          AS note_min,
    ROUND(MAX(mark), 2)          AS note_max,
    COUNT(DISTINCT student_code) AS nb_eleves
FROM bac.bac_results
GROUP BY bac_level
ORDER BY moyenne_bac DESC;


-- ─────────────────────────────────────────────────────
-- Q7. Distribution des notes au bac par tranche (VERSION INCORRECTE)
-- Concept : CASE WHEN pour créer des catégories
-- PROBLÈME : un élève est compté plusieurs fois (une par matière)
--            donc le total dépasse 86 élèves
-- ─────────────────────────────────────────────────────
-- SELECT
--     CASE
--         WHEN mark >= 16 THEN 'Très bien (16-20)'
--         WHEN mark >= 14 THEN 'Bien (14-16)'
--         WHEN mark >= 12 THEN 'Assez bien (12-14)'
--         WHEN mark >= 10 THEN 'Passable (10-12)'
--         ELSE                 'Insuffisant (< 10)'
--     END                          AS mention,
--     COUNT(DISTINCT student_code) AS nb_eleves,
--     ROUND(AVG(mark), 2)          AS moyenne_tranche
-- FROM bac.bac_results
-- GROUP BY mention
-- ORDER BY moyenne_tranche DESC;


-- ─────────────────────────────────────────────────────
-- Q7b. Distribution correcte des mentions au bac
-- Concept : SOUS-REQUÊTE (subquery) — on imbrique deux SELECT
--   Niveau 1 (intérieur) : calcule la moyenne par élève
--   Niveau 2 (extérieur) : attribue la mention sur cette moyenne
-- RÉSULTAT : exactement 86 élèves au total
-- ─────────────────────────────────────────────────────
SELECT
    CASE
        WHEN avg_mark >= 16 THEN 'Très bien (16-20)'
        WHEN avg_mark >= 14 THEN 'Bien (14-16)'
        WHEN avg_mark >= 12 THEN 'Assez bien (12-14)'
        WHEN avg_mark >= 10 THEN 'Passable (10-12)'
        ELSE                     'Insuffisant (< 10)'
    END             AS mention,
    COUNT(*)        AS nb_eleves
FROM (
    -- Sous-requête : une ligne par élève avec sa moyenne générale au bac
    SELECT
        student_code,
        AVG(mark) AS avg_mark
    FROM bac.bac_results
    GROUP BY student_code
) AS moyennes_par_eleve
GROUP BY mention
ORDER BY MIN(avg_mark) DESC;

-- =====================================================
-- NIVEAU 2 — Jointures et sous-requêtes
-- =====================================================


-- ─────────────────────────────────────────────────────
-- Q8. Moyenne lycée vs moyenne bac par élève
-- Concept : INNER JOIN — relie les deux tables
--           uniquement les élèves présents dans les deux
-- ─────────────────────────────────────────────────────
SELECT
    l.student_code,
    ROUND(AVG(l.mark), 2)  AS moyenne_lycee,
    ROUND(AVG(b.mark), 2)  AS moyenne_bac,
    ROUND(AVG(b.mark) - AVG(l.mark), 2) AS ecart
FROM bac.lycee_notes  l
INNER JOIN bac.bac_results b ON l.student_code = b.student_code
GROUP BY l.student_code
ORDER BY moyenne_bac DESC;

-- ─────────────────────────────────────────────────────
-- Q9. Élèves du lycée qui ne sont PAS allés au bac
-- Concept : LEFT JOIN — garde tous les élèves du lycée
--           même ceux sans correspondance dans bac_results
--           NULL dans les colonnes bac = pas allé au bac
-- ─────────────────────────────────────────────────────
SELECT
    l.student_code,
    l.level                      AS derniere_filiere,
    ROUND(AVG(l.mark), 2)        AS moyenne_lycee
FROM bac.lycee_notes l
LEFT JOIN bac.bac_results b ON l.student_code = b.student_code
WHERE b.student_code IS NULL    -- uniquement ceux SANS correspondance au bac
GROUP BY l.student_code, l.level
ORDER BY moyenne_lycee DESC;

-- ─────────────────────────────────────────────────────
-- Q10. Comparaison lycée vs bac avec catégorie de progression
-- Concept : CTE (WITH) — nommer une sous-requête
--           pour la réutiliser proprement
-- ─────────────────────────────────────────────────────
WITH moyennes AS (
    -- CTE 1 : moyenne lycée par élève
    SELECT
        student_code,
        ROUND(AVG(mark), 2) AS moy_lycee
    FROM bac.lycee_notes
    GROUP BY student_code
),
resultats_bac AS (
    -- CTE 2 : moyenne bac par élève
    SELECT
        student_code,
        ROUND(AVG(mark), 2) AS moy_bac
    FROM bac.bac_results
    GROUP BY student_code
)
-- Requête principale qui utilise les deux CTEs
SELECT
    m.student_code,
    m.moy_lycee,
    r.moy_bac,
    ROUND(r.moy_bac - m.moy_lycee, 2) AS ecart,
    CASE
        WHEN r.moy_bac >= m.moy_lycee        THEN 'Progression'
        WHEN r.moy_bac >= m.moy_lycee - 3    THEN 'Légère baisse'
        WHEN r.moy_bac >= m.moy_lycee - 6    THEN 'Baisse modérée'
        ELSE                                       'Forte baisse'
    END AS profil
FROM moyennes m
INNER JOIN resultats_bac r ON m.student_code = r.student_code
ORDER BY ecart DESC;

-- =====================================================
-- NIVEAU 3 — Fonctions de fenêtrage (Window Functions)
-- =====================================================


-- ─────────────────────────────────────────────────────
-- Q11. Classement des élèves par moyenne au bac
-- Concept : RANK() OVER — attribue un rang
--           PARTITION BY — recommence le rang par groupe
-- ─────────────────────────────────────────────────────
WITH moy_bac AS (
    SELECT
        student_code,
        bac_level,
        ROUND(AVG(mark), 2) AS moyenne_bac
    FROM bac.bac_results
    GROUP BY student_code, bac_level
)
SELECT
    student_code,
    bac_level                                        AS filiere,
    moyenne_bac,
    RANK() OVER (ORDER BY moyenne_bac DESC)          AS rang_general,
    RANK() OVER (
        PARTITION BY bac_level
        ORDER BY moyenne_bac DESC
    )                                                AS rang_dans_filiere
FROM moy_bac
ORDER BY rang_general;


-- ─────────────────────────────────────────────────────
-- Q12. Chaque élève comparé à la moyenne de sa filière
-- Concept : AVG() OVER (PARTITION BY) — moyenne glissante
--           sans réduire le nombre de lignes
-- ─────────────────────────────────────────────────────
WITH moy_bac AS (
    SELECT
        student_code,
        bac_level,
        ROUND(AVG(mark), 2) AS moyenne_bac
    FROM bac.bac_results
    GROUP BY student_code, bac_level
)
SELECT
    student_code,
    bac_level                                            AS filiere,
    moyenne_bac,
    ROUND(AVG(moyenne_bac) OVER (
        PARTITION BY bac_level
    ), 2)                                                AS moy_filiere,
    ROUND(moyenne_bac - AVG(moyenne_bac) OVER (
        PARTITION BY bac_level
    ), 2)                                                AS ecart_a_la_moyenne,
    CASE
        WHEN moyenne_bac > AVG(moyenne_bac) OVER (
            PARTITION BY bac_level)  THEN 'Au dessus'
        WHEN moyenne_bac < AVG(moyenne_bac) OVER (
            PARTITION BY bac_level)  THEN 'En dessous'
        ELSE                              'Dans la moyenne'
    END                                                  AS position
FROM moy_bac
ORDER BY bac_level, moyenne_bac DESC;


-- ─────────────────────────────────────────────────────
-- Q13. Top 3 élèves par filière au bac
-- Concept : ROW_NUMBER() + filtre sur le rang
--           pour garder uniquement les N meilleurs
-- ─────────────────────────────────────────────────────
WITH moy_bac AS (
    SELECT
        student_code,
        bac_level,
        ROUND(AVG(mark), 2) AS moyenne_bac
    FROM bac.bac_results
    GROUP BY student_code, bac_level
),
ranked AS (
    SELECT
        student_code,
        bac_level,
        moyenne_bac,
        ROW_NUMBER() OVER (
            PARTITION BY bac_level
            ORDER BY moyenne_bac DESC
        ) AS rang
    FROM moy_bac
)
SELECT
    bac_level   AS filiere,
    rang,
    student_code,
    moyenne_bac
FROM ranked
WHERE rang <= 3
ORDER BY bac_level, rang;