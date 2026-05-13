from sqlalchemy import create_engine

# ── Credentials PostgreSQL local ───────────────────────
# Modifiez uniquement ce bloc
DB_USER     = "postgres"
DB_PASSWORD = "1234"   
DB_HOST     = "localhost"
DB_PORT     = "5432"
DB_NAME     = "bac_prediction"


def get_engine():
    """Retourne un engine SQLAlchemy connecté à PostgreSQL local."""
    url = (
        f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}"
        f"@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    )
    engine = create_engine(url)
    return engine