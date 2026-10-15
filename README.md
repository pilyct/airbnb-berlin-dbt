# Berlin Short-Term Rentals: dbt + DuckDB

> Status: setup done, modeling in progress.

## Business problem
TODO (milestone 1): 3 business questions and 2 target metrics, written by me.

## Data
Berlin extracts from [Inside Airbnb](https://insideairbnb.com/get-the-data/), scrape of 2026-09-19.
Licensed under [CC BY 4.0](http://creativecommons.org/licenses/by/4.0/). Attribution: Inside Airbnb.

## Stack
dbt Core 1.12 + dbt-duckdb, DuckDB (a single local file, no credentials), Python 3.

## Setup (macOS / zsh)
```bash
git clone <this repo> && cd airbnb-berlin-dbt
python3 -m venv .venv && source .venv/bin/activate
python -m pip install -r requirements.txt
cp profiles.yml.example profiles.yml   # local dbt profile, gitignored

mkdir -p data/raw
D=https://data.insideairbnb.com/germany/be/berlin/2026-09-19
curl -L -o data/raw/listings.csv.gz  $D/data/listings.csv.gz
curl -L -o data/raw/reviews.csv.gz   $D/data/reviews.csv.gz
curl -L -o data/raw/neighbourhoods.csv $D/visualisations/neighbourhoods.csv

python scripts/load_raw.py   # creates airbnb_berlin.duckdb with schema `raw`
dbt debug                    # run dbt from the repo root
```

## Project layout
```
scripts/load_raw.py        raw files -> DuckDB schema `raw` (all VARCHAR + metadata columns)
models/staging/airbnb/     sources + staging models (views)
models/marts/              business-facing models (tables)
profiles.yml.example       DuckDB connection template (copy to profiles.yml)
```

## Architecture and decisions
TODO: DAG screenshot, grain of each model, decisions and trade-offs.

## Challenges and lessons learned
TODO
