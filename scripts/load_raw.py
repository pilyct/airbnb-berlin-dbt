"""Load the Inside Airbnb Berlin files into the `raw` schema of a DuckDB file.

Run from the repo root:  python scripts/load_raw.py
Every source column is loaded as VARCHAR (raw = exactly what the file said).
Three metadata columns are added: _source_file, _scrape_date, _loaded_at.
"""
import argparse
import datetime
from pathlib import Path

import duckdb

TABLES = {
    "listings": "listings.csv.gz",
    "reviews": "reviews.csv.gz",
    "neighbourhoods": "neighbourhoods.csv",
}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--db", default="airbnb_berlin.duckdb", help="DuckDB file to write")
    parser.add_argument("--raw-dir", default="data/raw", help="folder with the downloaded files")
    parser.add_argument("--scrape-date", default="2026-09-19", help="scrape date in the download URL (YYYY-MM-DD)")
    args = parser.parse_args()

    scrape_date = datetime.date.fromisoformat(args.scrape_date)
    raw_dir = Path(args.raw_dir)

    missing = [f for f in TABLES.values() if not (raw_dir / f).exists()]
    if missing:
        raise SystemExit(f"Missing files in {raw_dir}: {', '.join(missing)}")

    con = duckdb.connect(args.db)
    con.execute("create schema if not exists raw")

    for table, filename in TABLES.items():
        con.execute(
            f"""
            create or replace table raw.{table} as
            select
                * exclude (filename),
                filename as _source_file,
                ?::date as _scrape_date,
                current_timestamp as _loaded_at
            from read_csv(?, all_varchar = true, filename = true)
            """,
            [scrape_date, str(raw_dir / filename)],
        )
        rows = con.execute(f"select count(*) from raw.{table}").fetchone()[0]
        print(f"raw.{table}: {rows:,} rows")

    con.close()


if __name__ == "__main__":
    main()
