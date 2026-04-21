# wowcompare-simc-data

Per-class [SimulationCraft](https://github.com/simulationcraft/simc) `spell_query` XML,
refreshed daily by CI. Consumed by [wow-compare](https://github.com/peavers/wow-compare)'s
gatherer service to populate the `spell_metadata_overrides` table with authoritative
cooldowns, GCDs, mana costs, and class/spec metadata.

## What's in here

```
data/
  .metadata          # simc_sha, generated_at, wow_patch
  deathknight.xml    # one file per class — all 13
  ...
tools/simc-extract/
  Dockerfile         # builds simc from a pinned commit on the midnight branch
  extract.sh         # runs spell_query for every class
.github/workflows/
  refresh.yml        # daily cron — builds, extracts, commits to main
```

## How refresh works

1. `.github/workflows/refresh.yml` fires on a daily cron (06:00 UTC) or via
   `workflow_dispatch`. The dispatch form takes an optional `simc_sha` to pin
   a specific simc commit; blank means latest `midnight`.
2. The workflow docker-builds the extractor, runs it, and commits the resulting
   `data/*.xml` + `data/.metadata` straight to `main`. No PR — the content is
   100% machine-generated.
3. The gatherer service in wow-compare reads `data/*` from
   `raw.githubusercontent.com` on its own schedule and writes the parsed rows
   into the database.

## Running the extractor locally

```
docker build -t wow-simc-extract --build-arg SIMC_SHA=<sha> tools/simc-extract
mkdir -p out
docker run --rm -v "$(pwd)/out:/out" wow-simc-extract
ls out/
```

Outputs 13 XMLs plus `.metadata`. Blank `SIMC_SHA` defaults to whatever is
baked into the Dockerfile.

## Why a separate repo

Keeps the wow-compare app repo free of multi-MB daily churn, lets the extraction
workflow live on a free GitHub-hosted runner, and makes the dataset's history
inspectable without scrolling past application commits. The dataset is
essentially a dependency — versioning it separately matches that.
