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

## Decisions
- **Reporting grain:** district (12), not neighbourhood (137).
- **Host size bands:** 1, 2-4, 5-9, 10+ listings per host. Counts (listings / hosts): 1: 6,630 / 6,630; 2-4: 2,393 / 985; 5-9: 1,416 / 223; 10+: 1,937 / 85.
- **Definitions live in staging** (`stg_listings`), marts only aggregate.
- **Valid registration:** only `license_type = 'registration number'` counts as valid. `legal entity`, `private individual`, `other` and `missing` do not. `exempt` (75 listings) is not counted as valid either, since there is no number to check.
- **Malformed registration numbers** (typos such as `01-Z-NA-OO4O70-15`) are not counted as valid. They sit in `other` (41 listings).
- **Raw license text is dropped in staging.** It is read for the `case when` but never selected, because it can contain names of private individuals.
- **No dimensional layer:** two aggregate tables answer the questions, so no facts or dimensions.

## Data notes
- `registration number` is a format check only (`NN/A/AA/NNNNNN-NN`, the whole value). It does not confirm that the number exists in the Berlin register.
- 4 listings (2 `legal entity`, 2 `private individual`) contain a registration-format number inside template text. They are counted as not valid because the rule needs the whole value to be a number. Too few to move a district share visibly.
- `calculated_host_listings_count` equals the number of rows per `host_id` for every host (0 mismatches), so it counts Berlin listings only.

## Architecture and decisions
TODO: DAG screenshot, grain of each model, decisions and trade-offs.

## Challenges and lessons learned
TODO
