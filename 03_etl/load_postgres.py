import pandas as pd
import sys
from pathlib import Path
from sqlalchemy import text

# ── Chemins ────────────────────────────────────────────
ROOT       = Path(__file__).resolve().parent.parent
OUT_DIR    = ROOT / "output"
SCHEMA_SQL = ROOT / "04_database" / "schema.sql"

sys.path.insert(0, str(ROOT / "03_etl"))
from db_connection import get_engine

# ── Schéma PostgreSQL cible ────────────────────────────
PG_SCHEMA = "bac"


# ── Exécution du schéma SQL ────────────────────────────
def apply_schema(engine):
    print("\n  Application du schéma SQL...")
    sql = SCHEMA_SQL.read_text(encoding="utf-8")

    with engine.connect() as conn:
        for statement in sql.split(";"):
            stmt = statement.strip()
            if stmt and not stmt.startswith("--"):
                conn.execute(text(stmt))
        conn.commit()
    print(f"  Schéma '{PG_SCHEMA}' créé : tables + index + vue OK")


# ── Chargement d'une table ─────────────────────────────
def load_table(df: pd.DataFrame, table_name: str, engine):
    df.to_sql(
        name      = table_name,
        schema    = PG_SCHEMA,      # <-- cible le schéma 'bac'
        con       = engine,
        if_exists = "append",
        index     = False,
        chunksize = 1000,
    )
    print(f"  Table 'bac.{table_name}' chargée : {len(df):,} lignes")


# ── Point d'entrée ─────────────────────────────────────
if __name__ == "__main__":
    print("=" * 50)
    print("  CHARGEMENT POSTGRESQL LOCAL")
    print("=" * 50)

    # Vérification fichiers nettoyés
    lycee_path = OUT_DIR / "lycee_clean.csv"
    bac_path   = OUT_DIR / "bac_clean.csv"

    if not lycee_path.exists() or not bac_path.exists():
        print("ERREUR : Lancer d'abord 03_etl/transform.py")
        sys.exit(1)

    df_lycee = pd.read_csv(lycee_path)
    df_bac   = pd.read_csv(bac_path)

    print(f"\n  lycee_clean : {df_lycee.shape[0]:,} lignes")
    print(f"  bac_clean   : {df_bac.shape[0]:,} lignes")

    # Connexion
    print("\n  Connexion à PostgreSQL...")
    engine = get_engine()

    with engine.connect() as conn:
        conn.execute(text("SELECT 1"))
        print("  Connexion OK")

    # 1. Appliquer le schéma
    apply_schema(engine)

    # 2. Charger les données
    print("\n  Chargement des données...")
    load_table(df_lycee, "lycee_notes", engine)
    load_table(df_bac,   "bac_results", engine)

    # 3. Vérification
    print("\n  Vérification :")
    with engine.connect() as conn:
        for table in ["lycee_notes", "bac_results"]:
            n = conn.execute(
                text(f"SELECT COUNT(*) FROM bac.{table}")
            ).scalar()
            print(f"    bac.{table:20s} : {n:,} lignes en base")

    print("\n OK - Chargement PostgreSQL terminé")
    print(" Prochaine étape : 03_etl/migrate_azure.py")