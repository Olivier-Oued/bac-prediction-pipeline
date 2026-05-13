import pandas as pd
import chardet
from pathlib import Path

# ── Chemins ────────────────────────────────────────────
ROOT     = Path(__file__).resolve().parent.parent
DATA_DIR = ROOT / "01_data"


# ── Détection encodage ─────────────────────────────────
def detect_encoding(filepath: Path) -> str:
    with open(filepath, "rb") as f:
        raw = f.read(50_000)
    result   = chardet.detect(raw)
    encoding = result.get("encoding", "utf-8") or "utf-8"
    print(f"  Encodage détecté [{filepath.name}] : {encoding}")
    return encoding


# ── Lecture CSV ────────────────────────────────────────
def load_csv(filename: str) -> pd.DataFrame:
    path = DATA_DIR / filename

    if not path.exists():
        raise FileNotFoundError(f"Fichier introuvable : {path}")

    encoding = detect_encoding(path)

    # Détection séparateur automatique
    for sep in [",", ";", "\t"]:
        try:
            df_test = pd.read_csv(path, encoding=encoding, sep=sep, nrows=3)
            if df_test.shape[1] > 1:
                break
        except Exception:
            continue

    df = pd.read_csv(path, encoding=encoding, sep=sep, low_memory=False)
    print(f"  [{filename}] {df.shape[0]:,} lignes x {df.shape[1]} colonnes")
    return df


# ── Rapport qualité rapide ─────────────────────────────
def quality_check(df: pd.DataFrame, name: str):
    print(f"\n--- Qualité : {name} ---")
    print(f"  Colonnes   : {list(df.columns)}")
    print(f"  Doublons   : {df.duplicated().sum()}")
    print(f"  Nulls :")
    for col, n in df.isnull().sum().items():
        if n > 0:
            print(f"    {col:30s} : {n} ({n/len(df):.1%})")
    print(f"  Types :\n{df.dtypes.to_string()}")


# ── Point d'entrée ─────────────────────────────────────
if __name__ == "__main__":
    print("=" * 50)
    print("  INGESTION DES DONNÉES")
    print("=" * 50)

    df_lycee = load_csv("data_lycee.csv")
    df_bac   = load_csv("data_bac.csv")

    quality_check(df_lycee, "data_lycee")
    quality_check(df_bac,   "data_bac")

    print("\n OK - Ingestion terminée")
    print(" Prochaine étape : 03_etl/transform.py")
