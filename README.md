# 🎓 Bac Prediction Pipeline

![Python](https://img.shields.io/badge/Python-3.14-blue?logo=python)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?logo=postgresql)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?logo=powerbi)
![scikit-learn](https://img.shields.io/badge/scikit--learn-ML-F7931E?logo=scikit-learn)
![Streamlit](https://img.shields.io/badge/Streamlit-App-FF4B4B?logo=streamlit)
![Status](https://img.shields.io/badge/Statut-En%20cours-orange)

---

## 👤 À Propos de l'Auteur

Je suis **Olivier OUEDRAOGO**, passionné par la donnée et son cycle de vie complet.

Après une formation en **ingénierie des systèmes informatiques au Maroc** axée sur la Data Science, je développe aujourd'hui des compétences en **Data Engineering en France** — avec pour objectif de maîtriser toute la chaîne de la donnée : de la collecte brute jusqu'au déploiement d'applications intelligentes.

Ce projet est la **refonte complète** d'un ancien projet réalisé durant ma formation. À l'époque, le travail se limitait à des notebooks Jupyter avec des CSV locaux et un modèle ANN dont le R²=1.00 trahissait un overfitting non traité. Aujourd'hui, je reprends ce projet avec une approche **Data Engineering professionnelle** — pipeline structuré, base de données cloud-ready, analyse SQL avancée, BI et ML rigoureux.

📧 olivierouedraogo290@gmail.com

---

## 🎯 Objectif du Projet

**Problématique** : Peut-on prédire la note d'un élève au baccalauréat national marocain à partir de son parcours complet au lycée ?

Ce projet répond à cette question en construisant un **pipeline de données de bout en bout** :

```
Données brutes CSV  →  ETL  →  PostgreSQL  →  Analyse SQL  →  Power BI  →  ML  →  Streamlit
```

L'enjeu est double :
- **Technique** : maîtriser chaque brique du pipeline Data Engineering
- **Métier** : identifier les facteurs qui expliquent la chute massive des notes entre le lycée (moy. 16.15) et le bac national (moy. ~11.58)

---

## 🏗️ Architecture Complète

```
bac-prediction-pipeline/
│
├── 01_data/                    # Données brutes — ne jamais modifier
│   ├── data_lycee.csv          # 43 108 lignes · 186 élèves · notes lycée
│   └── data_bac.csv            # 440 lignes · 86 élèves · résultats bac
│
├── 02_ingestion/               # ✅ FAIT — Lecture & validation
│   ├── ingest.py               # Détection encodage · séparateur auto · rapport qualité
│   └── quality_report.py       # Nulls · doublons · distributions
│
├── 03_etl/                     # ✅ FAIT — Nettoyage & chargement
│   ├── db_connection.py        # Connexion PostgreSQL (séparé des scripts)
│   ├── transform.py            # 6 corrections identifiées et appliquées
│   └── load_postgres.py        # Schéma SQL + chargement PostgreSQL
│
├── 04_database/                # ✅ FAIT — Scripts SQL
│   ├── schema.sql              # Tables + index + vue analytique
│   └── queries_analysis.sql    # 13 requêtes — 3 niveaux de complexité
│
├── 05_analysis/                # ✅ FAIT — BI
│   └── bac_prediction.pbix     # Dashboard Power BI — 4 visuels + KPIs
│
├── 06_ml/                      # 🚧 EN COURS — Machine Learning
│   ├── 01_preprocessing.ipynb  # Features · encodage · train/test split
│   ├── 02_training.ipynb       # Modèles · cross-validation
│   └── 03_evaluation.ipynb     # Métriques · SHAP · comparaison
│
├── 07_app/                     # ⏳ À VENIR — Application Streamlit
│   └── app.py                  # Interface · prédictions · orientation
│
├── output/                     # Fichiers générés (non versionnés)
├── .env.example                # Template credentials
├── .gitignore
├── requirements.txt
└── README.md
```

---

## ✅ Ce Qui Est Fait

### 1. Ingestion & Qualité des Données
Le script `02_ingestion/ingest.py` charge les deux CSV avec :
- Détection automatique de l'encodage (chardet)
- Détection automatique du séparateur
- Rapport qualité immédiat : nulls, doublons, types

**Résultats :**
```
data_lycee.csv  →  43 108 lignes × 9 colonnes  |  160 nulls dans mark
data_bac.csv    →  440 lignes × 7 colonnes      |  0 null  |  mark en string
```

---

### 2. ETL — Nettoyage & Transformation
Le script `03_etl/transform.py` corrige **6 problèmes identifiés** :

| Problème | Correction |
|----------|------------|
| `mark` en string `"18,50"` (data_bac) | Virgule → point + cast float |
| `Unnamed: 0` — index inutile | Suppression |
| 160 nulls dans `mark` (lycée) | Suppression des lignes (0.4%) |
| `"Premiere semestre"` vs `"Premier semestre"` | Unification |
| Espaces en tête dans `level` | strip() |
| Saut de ligne dans `subject` | replace('\n', ' ') |

**Résultat :** `lycee_clean.csv` (42 948 lignes) + `bac_clean.csv` (440 lignes)

---

### 3. Base de Données PostgreSQL
Architecture propre avec **schéma dédié** :

```sql
bac_prediction (base)
└── bac (schéma)
    ├── lycee_notes   -- 42 948 lignes + 4 index
    ├── bac_results   -- 440 lignes + 3 index
    └── v_student_avg -- Vue : moy lycée + moy bac par élève
```

Contraintes appliquées : `CHECK (mark BETWEEN 0 AND 20)` sur les deux tables.

---

### 4. Analyse SQL — 3 Niveaux

**13 requêtes analytiques** progressives :

#### Niveau 1 — Agrégations
```
Q1  Vue d'ensemble         → 42 948 évals · 186 élèves · 17 matières
Q2  Moyenne générale       → 16.15 au lycée
Q3  Moyenne par filière    → 2ème Bac domine (18.64) · Tronc commun (15.16)
Q4  Top/flop matières      → Assiduité (19.64) · Histoire-Géo (14.39)
Q5  Évolution semestrielle → S1: 15.79 → S2: 16.51 (+0.72)
Q5b Par filière ET semestre → Tous les groupes progressent au S2
Q6  Résultats au bac       → Physiques (12.60) · Maths (11.58) · Eco (10.26)
Q7b Mentions au bac        → 29% insuffisant · 12% très bien
```

#### Niveau 2 — Jointures & Sous-requêtes
```
Q8  INNER JOIN  → Moyenne lycée vs bac : chute moyenne de -4.5 points
Q9  LEFT JOIN   → 100 élèves du lycée ne sont pas allés au bac
                  dont certains avec 19/20 au lycée !
Q10 CTE (WITH)  → Profils : 1 progression · 15 légère baisse
                            27 baisse modérée · 43 forte baisse (50%)
```

#### Niveau 3 — Fenêtrage
```
Q11 RANK() OVER          → Classement général + classement par filière
Q12 AVG() OVER PARTITION → Chaque élève comparé à la moyenne de sa filière
Q13 ROW_NUMBER() + filtre → Top 3 par filière
```

---

### 5. Dashboard Power BI

4 visuels construits sur connexion directe à PostgreSQL local :

| Visuel | Type | Insight principal |
|--------|------|-------------------|
| Moyenne au Bac par filière | Histogramme | Sciences Physiques meilleures (12.60) |
| Répartition des élèves | Camembert | 61% en Sciences Physiques |
| Moyenne par matière | Barres horiz. | Langue Anglaise 1ère · Maths dernière |
| Lycée vs Bac par élève | Scatter plot | Faible corrélation — dispersion massive |

**KPIs** : 86 élèves au bac · 186 au lycée · Moy. lycée 16.15 · Moy. bac ~11.58

---

## 🚧 En Cours — Machine Learning

### Objectif
Prédire la moyenne d'un élève au bac national à partir de ses notes au lycée.

### Approche
```
1. Feature engineering
   → Pivot : une ligne par élève · une colonne par matière
   → Calcul de progression S1→S2
   → Exclusion ASSIDUITE ET CONDUITE (non académique)

2. Modèles testés
   → Régression linéaire (baseline)
   → Random Forest (modèle principal)
   → XGBoost (optimisation)

3. Évaluation rigoureuse
   → Cross-validation 5 folds (évite l'overfitting R²=1.00 de l'ancien projet)
   → Métriques : RMSE, MAE, R²
   → SHAP values pour l'explicabilité

4. Sauvegarde
   → Modèle final exporté avec joblib
```

### Pourquoi c'est difficile
La chute lycée → bac est **massive et peu prévisible** :
- Un élève à **19/20 au lycée** peut avoir **11/20 au bac**
- **50% des élèves** subissent une baisse de plus de 6 points
- **1 seul élève sur 86** progresse entre lycée et bac

C'est précisément ce qui rend ce problème ML **intéressant et réaliste**.

---

## ⏳ À Venir — Application Streamlit

```python
# Fonctionnalités prévues :
1. Saisie des notes lycée d'un élève
2. Prédiction de sa moyenne au bac
3. Recommandation de filière
4. Visualisation de son profil vs la moyenne
5. Déploiement local
```

---

## 📊 Chiffres Clés du Projet

```
43 108  lignes de données lycée traitées
   440  résultats bac chargés en base
   186  élèves uniques au lycée
    86  élèves ayant passé le bac
    13  requêtes SQL analytiques (3 niveaux)
     6  problèmes qualité corrigés dans l'ETL
     4  visuels Power BI
    -4.5 points  chute moyenne lycée → bac
    50%  élèves en forte baisse (> 6 points)
```

---

## 🚀 Installation

```bash
# 1. Cloner le dépôt
git clone https://github.com/OlivierOuedraogo/bac-prediction-pipeline.git
cd bac-prediction-pipeline

# 2. Environnement virtuel
python -m venv venv
venv\Scripts\activate           # Windows
source venv/bin/activate        # Mac/Linux

# 3. Dépendances
pip install -r requirements.txt

# 4. Configuration
cp .env.example .env
# Remplir PG_USER, PG_PASSWORD dans .env

# 5. Données
# Copier data_lycee.csv et data_bac.csv dans 01_data/

# 6. Lancer le pipeline
python 02_ingestion/ingest.py
python 03_etl/transform.py
python 03_etl/load_postgres.py
```

---

## 📋 Statut du Pipeline

| Étape | Description | Statut |
|-------|-------------|--------|
| Ingestion | Lecture CSV + validation qualité | ✅ Terminé |
| ETL | Nettoyage + transformation + chargement | ✅ Terminé |
| Base de données | Schéma PostgreSQL + 13 requêtes SQL | ✅ Terminé |
| BI | Dashboard Power BI — 4 visuels + KPIs | ✅ Terminé |
| ML | Preprocessing + modèles + évaluation | 🚧 En cours |
| Application | Streamlit — prédiction + orientation | ⏳ À venir |

---

## 💡 Ce Que Ce Projet M'a Appris

```
Data Engineering
├── Construire un pipeline reproductible de A à Z
├── Séparer les responsabilités (ingestion / ETL / BDD / ML / App)
├── Gérer la qualité des données en amont
└── Versionner et documenter chaque étape

SQL Analytique
├── Niveau 1 : COUNT, AVG, GROUP BY, HAVING, CASE WHEN
├── Niveau 2 : INNER JOIN, LEFT JOIN, CTE (WITH)
└── Niveau 3 : RANK(), ROW_NUMBER(), AVG() OVER(PARTITION BY)

Power BI
├── Connexion directe à PostgreSQL
├── Construction de visuels analytiques
└── KPI Cards + Scatter plot + Dashboard structuré

Bonnes Pratiques
├── Schéma dédié en base (pas tout dans public)
├── Fichier db_connection.py séparé des scripts
├── .env pour les credentials sensibles
└── On ajoute, on ne remplace jamais une requête
```

---

## 👤 Auteur

**Olivier OUEDRAOGO**  
Data Engineer en formation — France  
Formation initiale : Ingénierie des Systèmes Informatiques — Maroc  
📧 olivierouedraogo290@gmail.com

*Projet LinkedIn à venir à la fin du développement complet.*

---

⭐ *Si ce projet vous est utile, n'hésitez pas à le mettre en favori !*
