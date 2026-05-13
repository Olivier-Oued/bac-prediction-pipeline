# ══════════════════════════════════════════════════
# 07_app/app.py
# Application Streamlit — Prédiction Bac
# Auteur : Olivier OUEDRAOGO
# ══════════════════════════════════════════════════

import streamlit as st
import pandas as pd
import numpy as np
import joblib
from pathlib import Path

# ── Configuration page ─────────────────────────────
st.set_page_config(
    page_title = "Prédiction Bac",
    page_icon  = "🎓",
    layout     = "wide"
)

# ── Chargement modèle ──────────────────────────────
ROOT          = Path(__file__).resolve().parent.parent
model         = joblib.load(ROOT / "output" / "model_rf.joblib")
feature_names = joblib.load(ROOT / "output" / "feature_names.joblib")

# Chargement des données d'entraînement pour recréer l'imputer
X_train = pd.read_csv(ROOT / "output" / "X_train.csv")

# Recréation de l'imputer directement dans Streamlit
from sklearn.impute import SimpleImputer
imputer = SimpleImputer(strategy='median')
imputer.fit(X_train)

# ── Titre ──────────────────────────────────────────
st.title("🎓 Prédiction de la Note au Baccalauréat")
st.markdown("**Auteur** : Olivier OUEDRAOGO — Data Engineering Pipeline")
st.markdown("---")

# ── Sidebar : saisie des notes ─────────────────────
st.sidebar.header("📝 Notes au Lycée")
st.sidebar.markdown("Entrez les notes de l'élève (laisser 0 si matière non suivie)")

notes = {}
for feature in feature_names:
    label = feature.replace('_', ' ').title()
    notes[feature] = st.sidebar.slider(
        label    = label,
        min_value = 0.0,
        max_value = 20.0,
        value     = 10.0,
        step      = 0.25
    )

# ── Prédiction ─────────────────────────────────────
if st.sidebar.button("🔮 Prédire la note au Bac", type="primary"):

    # Préparation des données
    X_input = pd.DataFrame([notes])
    X_input = X_input[feature_names]

    # Remplacement des 0 par NaN (matière non suivie)
    X_input = X_input.replace(0, np.nan)

    # Imputation
    X_imp = imputer.transform(X_input)

    # Prédiction
    prediction = model.predict(X_imp)[0]
    prediction = round(float(prediction), 2)

    # ── Résultats ──────────────────────────────────
    st.markdown("## 📊 Résultat de la Prédiction")

    col1, col2, col3 = st.columns(3)

    with col1:
        st.metric(
            label = "Note prédite au Bac",
            value = f"{prediction} / 20"
        )

    with col2:
        # Mention
        if prediction >= 16:
            mention = "🏆 Très Bien"
        elif prediction >= 14:
            mention = "🥇 Bien"
        elif prediction >= 12:
            mention = "🥈 Assez Bien"
        elif prediction >= 10:
            mention = "🥉 Passable"
        else:
            mention = "❌ Insuffisant"

        st.metric(label="Mention estimée", value=mention)

    with col3:
        # Moyenne lycée
        moy_lycee = round(np.nanmean(list(notes.values())), 2)
        st.metric(
            label = "Moyenne lycée saisie",
            value = f"{moy_lycee} / 20",
            delta = f"{round(prediction - moy_lycee, 2)} points"
        )

    # ── Jauge visuelle ─────────────────────────────
    st.markdown("---")
    st.markdown("### 📈 Positionnement par rapport à la promotion")

    col4, col5 = st.columns(2)

    with col4:
        st.markdown("**Moyennes de référence (promotion 2023) :**")
        st.markdown(f"- Moyenne promotion : **11.94 / 20**")
        st.markdown(f"- Note prédite      : **{prediction} / 20**")
        ecart = round(prediction - 11.94, 2)
        if ecart >= 0:
            st.success(f"✅ {ecart} points au dessus de la moyenne")
        else:
            st.warning(f"⚠️ {abs(ecart)} points en dessous de la moyenne")

    with col5:
        st.markdown("**Top matières prédictives :**")
        st.markdown("1. 🧬 Sciences de la Vie et de la Terre")
        st.markdown("2. ⚗️ Physique Chimie")
        st.markdown("3. ➗ Mathématiques")

else:
    st.info("👈 Entrez les notes dans le panneau gauche et cliquez sur **Prédire** !")
    
    # ── Contexte du projet ─────────────────────────
    st.markdown("## 📌 À Propos")
    col1, col2, col3 = st.columns(3)
    with col1:
        st.metric("Élèves analysés", "86")
    with col2:
        st.metric("R² du modèle", "0.584")
    with col3:
        st.metric("RMSE", "2.316")