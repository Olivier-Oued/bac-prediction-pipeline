-- ==============================================
-- 04_database/schema.sql
-- Auteur : Olivier OUEDRAOGO
-- ==============================================

-- ─── Création du schéma dédié ─────────────────
CREATE SCHEMA IF NOT EXISTS bac;

-- ─── Table : notes lycée ──────────────────────
DROP TABLE IF EXISTS bac.lycee_notes;

CREATE TABLE bac.lycee_notes (
    id              SERIAL          PRIMARY KEY,
    student_code    VARCHAR(128)    NOT NULL,
    age             NUMERIC(10, 6),
    level           VARCHAR(100),
    class_name      VARCHAR(50),
    semester        VARCHAR(50),
    subject         VARCHAR(100)    NOT NULL,
    eval_type       VARCHAR(100),
    mark            NUMERIC(5, 2),
    CONSTRAINT chk_mark_lycee CHECK (mark BETWEEN 0 AND 20)
);

CREATE INDEX idx_lycee_student  ON bac.lycee_notes(student_code);
CREATE INDEX idx_lycee_subject  ON bac.lycee_notes(subject);
CREATE INDEX idx_lycee_level    ON bac.lycee_notes(level);
CREATE INDEX idx_lycee_semester ON bac.lycee_notes(semester);


-- ─── Table : résultats bac ────────────────────
DROP TABLE IF EXISTS bac.bac_results;

CREATE TABLE bac.bac_results (
    id              SERIAL          PRIMARY KEY,
    student_code    VARCHAR(128)    NOT NULL,
    age             NUMERIC(10, 6),
    bac_level       VARCHAR(100),
    subject         VARCHAR(100)    NOT NULL,
    eval_type       VARCHAR(50),
    mark            NUMERIC(5, 2),
    CONSTRAINT chk_mark_bac CHECK (mark BETWEEN 0 AND 20)
);

CREATE INDEX idx_bac_student ON bac.bac_results(student_code);
CREATE INDEX idx_bac_level   ON bac.bac_results(bac_level);
CREATE INDEX idx_bac_subject ON bac.bac_results(subject);


-- ─── Vue : moyenne par élève ──────────────────
CREATE OR REPLACE VIEW bac.v_student_avg AS
SELECT
    l.student_code,
    l.level,
    ROUND(AVG(l.mark)::NUMERIC, 2)  AS avg_lycee,
    ROUND(AVG(b.mark)::NUMERIC, 2)  AS avg_bac,
    COUNT(DISTINCT l.subject)        AS nb_subjects_lycee,
    COUNT(DISTINCT b.subject)        AS nb_subjects_bac
FROM bac.lycee_notes l
LEFT JOIN bac.bac_results b USING (student_code)
GROUP BY l.student_code, l.level;
