# 🎓 Bac Prediction Pipeline

![Python](https://img.shields.io/badge/Python-3.14-blue?logo=python)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?logo=postgresql)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?logo=powerbi)
![scikit-learn](https://img.shields.io/badge/scikit--learn-ML-F7931E?logo=scikit-learn)
![Streamlit](https://img.shields.io/badge/Streamlit-App-FF4B4B?logo=streamlit)
![Status](https://img.shields.io/badge/Statut-✅%20Terminé-brightgreen)

---

## 👤 À Propos de l'Auteur

Je suis **Olivier OUEDRAOGO**, passionné par la donnée et son cycle de vie complet.

Après une formation en **ingénierie des systèmes informatiques au Maroc** axée sur la Data Science, je développe aujourd'hui des compétences en **Data Engineering en France** — avec pour objectif de maîtriser toute la chaîne de la donnée : de la collecte brute jusqu'au déploiement d'applications intelligentes.

📧 olivierouedraogo290@gmail.com

---

## 🎯 Contexte et Objectif

Ce projet est la **refonte complète** d'un ancien projet réalisé durant ma formation. À l'époque, le travail se limitait à des notebooks Jupyter avec des CSV locaux et un modèle ANN dont le **R²=1.00 trahissait un overfitting** non traité.

Aujourd'hui, je reprends ce projet avec une approche **Data Engineering professionnelle** :

```
Pipeline structuré → Base de données → Analyse SQL → BI → ML rigoureux → Application
```

**Problématique** : Peut-on prédire la note d'un élève au baccalauréat national marocain à partir de son parcours complet au lycée ?

---

## 🏗️ Architecture du Pipeline

```
📁 Données brutes (CSV)
        ↓
🐍 Ingestion & Validation (Python · chardet · pandas)
        ↓
🔄 ETL & Nettoyage (Python · SQLAlchemy · psycopg2)
        ↓
🐘 Stockage (PostgreSQL 16 · schéma dédié bac)
        ↓
🔍 Analyse SQL (pgAdmin · 13 requêtes · 3 niveaux)
        ↓
📊 Business Intelligence (Power BI Desktop)
        ↓
🤖 Machine Learning (Jupyter · scikit-learn · Random Forest)
        ↓
🚀 Application (Streamlit · déployée localement)
```

---

## 📦 Stack Technique

| Catégorie | Outils |
|-----------|--------|
| Langage | Python 3.14 |
| Data Engineering | pandas · SQLAlchemy · psycopg2 · chardet |
| Base de données | PostgreSQL 16 — schéma dédié `bac` |
| Analyse SQL | pgAdmin 4 |
| BI & Visualisation | Power BI Desktop |
| Machine Learning | scikit-learn · joblib · Jupyter Anaconda |
| Application | Streamlit |
| Versioning | Git / GitHub |

---

## 📂 Structure du Projet

```
bac-prediction-pipeline/
│
├── 01_data/                    # Données brutes (non versionnées)
│   ├── data_lycee.csv          # 43 108 lignes · notes lycée · 186 élèves
│   └── data_bac.csv            # 440 lignes · résultats bac · 86 élèves
│
├── 02_ingestion/               # Lecture & validation des CSV
│   ├── ingest.py               # Détection encodage · séparateur auto
│   └── quality_report.py       # Nulls · doublons · distributions
│
├── 03_etl/                     # Nettoyage, transformation, chargement
│   ├── db_connection.py        # Connexion PostgreSQL via .env
│   ├── transform.py            # 6 corrections appliquées
│   └── load_postgres.py        # Schéma SQL + chargement PostgreSQL
│
├── 04_database/                # Scripts SQL
│   ├── schema.sql              # CREATE TABLE + index + vue analytique
│   └── queries_analysis.sql    # 13 requêtes — 3 niveaux de complexité
│
├── 05_analysis/                # Dashboard Power BI
│   └── bac_prediction.pbix     # 4 visuels + KPIs
│
├── 06_ml/                      # Machine Learning
│   └── notebook_ml.ipynb       # Pipeline ML complet — 8 sections
│
├── 07_app/                     # Application Streamlit
│   └── app.py                  # Interface · prédictions · orientation
│
├── output/                     # Fichiers générés (non versionnés)
├── .env.example                # Template credentials
├── .gitignore
├── requirements.txt
└── README.md
```

---

## ✅ Ce Qui Est Fait — Détail Complet

### 1️⃣ Ingestion & Qualité des Données

**Scripts :** `02_ingestion/ingest.py` · `02_ingestion/quality_report.py`

- Détection automatique de l'encodage avec `chardet`
- Détection automatique du séparateur (`,` `;` `\t`)
- Rapport qualité immédiat : nulls, doublons, types, distributions

**Résultats :**
```
data_lycee.csv  →  43 108 lignes × 9 colonnes  |  160 nulls dans mark
data_bac.csv    →  440 lignes × 7 colonnes      |  mark en string "18,50"
```

---

### 2️⃣ ETL — Nettoyage & Transformation

**Script :** `03_etl/transform.py`

6 problèmes identifiés et corrigés :

| Problème détecté | Correction appliquée |
|------------------|----------------------|
| `mark` en string `"18,50"` | Virgule → point + cast float |
| `Unnamed: 0` — index inutile | Suppression |
| 160 nulls dans `mark` lycée | Suppression des lignes (0.4%) |
| `"Premiere semestre"` vs `"Premier semestre"` | Unification |
| Espaces en tête dans `level` | strip() |
| Saut de ligne dans `subject` | replace('\n', ' ') |

**Résultat :** `lycee_clean.csv` (42 948 lignes) + `bac_clean.csv` (440 lignes)

---

### 3️⃣ Base de Données PostgreSQL

**Script :** `03_etl/load_postgres.py` · `04_database/schema.sql`

Architecture avec **schéma dédié** — bonne pratique professionnelle :

```sql
bac_prediction (base)
└── bac (schéma dédié)
    ├── lycee_notes   -- 42 948 lignes + 4 index
    ├── bac_results   -- 440 lignes + 3 index
    └── v_student_avg -- Vue analytique : moy lycée + moy bac par élève
```

Contraintes appliquées : `CHECK (mark BETWEEN 0 AND 20)` sur les deux tables.

---

### 4️⃣ Analyse SQL — 3 Niveaux de Complexité

**Script :** `04_database/queries_analysis.sql`

**13 requêtes analytiques progressives :**

#### Niveau 1 — Agrégations de base
```
Q1  Vue d'ensemble         →  42 948 évals · 186 élèves · 17 matières · 6 filières
Q2  Moyenne générale       →  16.15 / 20 au lycée
Q3  Moyenne par filière    →  2ème Bac domine (18.64) · Tronc commun (15.16)
Q4  Top/flop matières      →  Assiduité (19.64) · Histoire-Géo (14.39)
Q5  Évolution semestrielle →  S1: 15.79 → S2: 16.51 (+0.72 point)
Q5b Par filière ET semestre →  Tous les groupes progressent au S2
Q6  Résultats au bac       →  Physiques (12.60) · Maths (11.58) · Eco (10.26)
Q7b Mentions au bac        →  29% insuffisant · 12% très bien · total = 86 ✅
```

#### Niveau 2 — Jointures & Sous-requêtes
```
Q8  INNER JOIN  →  Chute moyenne de -4.5 points lycée → bac
Q9  LEFT JOIN   →  100 élèves du lycée sans bac (dont certains à 19/20 !)
Q10 CTE (WITH)  →  Profils : 1 progression · 15 légère baisse
                              27 modérée · 43 forte baisse (50% des élèves)
```

#### Niveau 3 — Fenêtrage (Window Functions)
```
Q11 RANK() OVER          →  Classement général + classement par filière
Q12 AVG() OVER PARTITION →  Chaque élève comparé à la moyenne de sa filière
Q13 ROW_NUMBER() + filtre →  Top 3 élèves par filière
```

---

### 5️⃣ Dashboard Power BI

**Fichier :** `05_analysis/bac_prediction.pbix`

Connexion directe à PostgreSQL local en mode Import.

| Visuel | Type | Insight |
|--------|------|---------|
| Moyenne au Bac par filière | Histogramme | Sciences Physiques meilleures (12.60) |
| Répartition des élèves | Camembert | 61% en Sciences Physiques |
| Moyenne par matière | Barres horiz. | Langue Anglaise 1ère · Maths dernière |
| Lycée vs Bac par élève | Scatter plot | Faible corrélation — dispersion massive |

**KPIs :** 86 élèves bac · 186 au lycée · Moy. lycée 16.15 · Moy. bac 11.94

---

### 6️⃣ Machine Learning

**Notebook :** `06_ml/notebook_ml.ipynb`

**Feature Engineering :**
- Exclusion de `ASSIDUITE ET CONDUITE` (non académique)
- Pivot : une ligne par élève · une colonne par matière (16 features)
- Imputation des nulls par médiane (matières non suivies selon la filière)
- Split : 68 élèves train · 18 élèves test

**Modèles comparés :**

| Modèle | RMSE | MAE | R² Test | R² CV |
|--------|------|-----|---------|-------|
| Régression Linéaire | 2.789 | 2.213 | 0.396 | -0.173 ❌ |
| **Random Forest** | **2.316** | **1.848** | **0.584** | **0.279** ✅ |

**Meilleur modèle → Random Forest**
- R²=0.584 → explique 58% de la variance (honnête vu la difficulté du problème)
- RMSE=2.316 → erreur moyenne de ±2.3 points sur 20
- Pas d'overfitting (R²=1.00 de l'ancien projet corrigé ✅)

**Top matières prédictives :**
```
🥇 Sciences de la Vie et de la Terre  → 18%
🥈 Physique Chimie                    → 15%
🥉 Mathématiques                      → 15%
4. Philosophie                         → 10%
5. Langue Anglaise                     →  9%
```

---

### 7️⃣ Application Streamlit

**Script :** `07_app/app.py`

Interface interactive permettant de :
- Saisir les notes d'un élève via des sliders (16 matières)
- Prédire sa moyenne au bac national
- Afficher la mention estimée
- Comparer à la moyenne de la promotion (11.94/20)
- Voir les top matières prédictives

**Lancement :**
```bash
python -m streamlit run 07_app/app.py
```

---

## 📊 Chiffres Clés du Projet

```
43 108  lignes de données lycée traitées
   440  résultats bac chargés en base
   186  élèves uniques au lycée
    86  élèves ayant passé le bac national
    13  requêtes SQL analytiques (3 niveaux)
     6  problèmes qualité corrigés dans l'ETL
     4  visuels Power BI + KPIs
    16  features ML (matières lycée)
   0.584 R² du meilleur modèle (Random Forest)
   2.316 RMSE — erreur moyenne en points
   -4.5  points de chute moyenne lycée → bac
    50%  élèves subissant une forte baisse (> 6 points)
```

---

## 💡 Ce Que Ce Projet M'a Appris

**Data Engineering**
- Construire un pipeline reproductible de A à Z
- Séparer les responsabilités (ingestion / ETL / BDD / ML / App)
- Gérer la qualité des données en amont avec des corrections documentées
- Versionner et documenter chaque étape

**SQL Analytique**
- Niveau 1 : COUNT, AVG, GROUP BY, HAVING, CASE WHEN
- Niveau 2 : INNER JOIN, LEFT JOIN, CTE (WITH), sous-requêtes
- Niveau 3 : RANK(), ROW_NUMBER(), AVG() OVER(PARTITION BY)

**Machine Learning**
- Feature engineering sur données scolaires
- Comparaison de modèles avec cross-validation rigoureuse
- Correction de l'overfitting (R²=1.00 → R²=0.584)
- Interprétation des importances de features

**Power BI**
- Connexion directe à PostgreSQL
- Construction de visuels analytiques pertinents
- KPI Cards + Scatter plot + Dashboard structuré

**Bonnes Pratiques**
- Schéma dédié en base (pas tout dans public)
- Credentials via `.env` — jamais en dur dans le code
- `git rm --cached` pour corriger des erreurs de versioning
- On ajoute, on ne remplace jamais une requête SQL

---

## 🚀 Installation & Utilisation

```bash
# 1. Cloner le dépôt
git clone https://github.com/Olivier-Oued/bac-prediction-pipeline.git
cd bac-prediction-pipeline

# 2. Environnement virtuel
python -m venv venv
venv\Scripts\activate           # Windows
source venv/bin/activate        # Mac/Linux

# 3. Dépendances
pip install -r requirements.txt

# 4. Configuration
cp .env.example .env
# Remplir PG_USER, PG_PASSWORD, PG_HOST, PG_PORT, PG_NAME

# 5. Données
# Copier data_lycee.csv et data_bac.csv dans 01_data/

# 6. Lancer le pipeline complet
python 02_ingestion/ingest.py
python 03_etl/transform.py
python 03_etl/load_postgres.py

# 7. Lancer l'application
python -m streamlit run 07_app/app.py
```

---

## 📋 Statut Final du Pipeline

| Étape | Description | Statut |
|-------|-------------|--------|
| Ingestion | Lecture CSV + validation qualité | ✅ Terminé |
| ETL | Nettoyage + transformation + chargement | ✅ Terminé |
| Base de données | Schéma PostgreSQL + 13 requêtes SQL | ✅ Terminé |
| BI | Dashboard Power BI — 4 visuels + KPIs | ✅ Terminé |
| ML | Random Forest R²=0.584 · RMSE=2.316 | ✅ Terminé |
| Application | Streamlit — prédiction + orientation | ✅ Terminé |

---

## 👤 Auteur

**Olivier OUEDRAOGO**  
Data Engineer en formation — France  
Formation initiale : Ingénierie des Systèmes Informatiques — Maroc  
📧 olivierouedraogo290@gmail.com

*Publication LinkedIn à venir.*

---

⭐ *Si ce projet vous est utile, n'hésitez pas à le mettre en favori !*