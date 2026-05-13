import pandas as pd
import sys
from pathlib import Path

# ── Chemins ────────────────────────────────────────────
ROOT     = Path(__file__).resolve().parent.parent
DATA_DIR = ROOT / "01_data"
OUT_DIR  = ROOT / "output"
OUT_DIR.mkdir(exist_ok=True)

sys.path.insert(0, str(ROOT / "02_ingestion"))
from ingest import load_csv


# ── Transformation data_lycee ──────────────────────────
def transform_lycee(df: pd.DataFrame) -> pd.DataFrame:
    print("\n--- Transformation data_lycee ---")
    df = df.copy()

    # Suppression colonne index inutile
    df = df.drop(columns=["Unnamed: 0"], errors="ignore")
    print("  Unnamed: 0 supprimée")

    # Nettoyage espaces sur les colonnes texte
    for col in ["level", "class", "semester", "subject", "evaluation"]:
        df[col] = df[col].str.strip()

    # Unification doublon semestre
    df["semester"] = df["semester"].replace({
        "Premiere semestre"  : "Premier semestre",
        "Premier  semestre"  : "Premier semestre",
        "Deuxième  semestre" : "Deuxième semestre",
    })
    print(f"  Semestres unifiés : {df['semester'].unique().tolist()}")

    # Suppression des 160 lignes sans note
    avant = len(df)
    df = df.dropna(subset=["mark"])
    print(f"  Lignes supprimées (mark null) : {avant - len(df)}")

    # Renommage colonnes
    df = df.rename(columns={
        "code"      : "student_code",
        "class"     : "class_name",
        "evaluation": "eval_type",
    })

    print(f"  Résultat : {df.shape[0]:,} lignes x {df.shape[1]} colonnes")
    return df


# ── Transformation data_bac ────────────────────────────
def transform_bac(df: pd.DataFrame) -> pd.DataFrame:
    print("\n--- Transformation data_bac ---")
    df = df.copy()

    # Suppression colonne index inutile
    df = df.drop(columns=["Unnamed: 0"], errors="ignore")
    print("  Unnamed: 0 supprimée")

    # Nettoyage espaces
    for col in ["level", "subject", "evaluation"]:
        df[col] = df[col].str.strip()

    # Nettoyage saut de ligne dans subject
    df["subject"] = df["subject"].str.replace(r"\n", " ", regex=True).str.strip()

    # Conversion mark : "18,50" → 18.50
    df["mark"] = (
        df["mark"]
        .astype(str)
        .str.replace(",", ".", regex=False)
        .str.strip()
    )
    df["mark"] = pd.to_numeric(df["mark"], errors="coerce")
    print(f"  mark converti en float : min={df['mark'].min()} max={df['mark'].max()}")

    # Renommage colonnes
    df = df.rename(columns={
        "code"      : "student_code",
        "level"     : "bac_level",
        "evaluation": "eval_type",
    })

    print(f"  Résultat : {df.shape[0]:,} lignes x {df.shape[1]} colonnes")
    return df


# ── Point d'entrée ─────────────────────────────────────
if __name__ == "__main__":
    print("=" * 50)
    print("  TRANSFORMATION ETL")
    print("=" * 50)

    df_lycee = transform_lycee(load_csv("data_lycee.csv"))
    df_bac   = transform_bac(load_csv("data_bac.csv"))

    # Sauvegarde CSV nettoyés
    df_lycee.to_csv(OUT_DIR / "lycee_clean.csv", index=False)
    df_bac.to_csv(OUT_DIR   / "bac_clean.csv",   index=False)

    print("\n  Fichiers sauvegardés dans output/")
    print("  lycee_clean.csv")
    print("  bac_clean.csv")
    print("\n OK - Transformation terminée")
    print(" Prochaine étape : 03_etl/load_postgres.py")