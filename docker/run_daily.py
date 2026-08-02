"""Run dbt once at startup and/or at a configured local time every day."""

from __future__ import annotations

import os
import shutil
import subprocess
import time
from datetime import datetime, timedelta
from pathlib import Path
from zoneinfo import ZoneInfo


PROJECT_DIR = Path("/app")
TARGET_DIR = PROJECT_DIR / "target"
PUBLISH_DIR = Path("/published-docs/current")
DOC_FILES = ("index.html", "manifest.json", "catalog.json")


def enabled(name: str, default: str = "false") -> bool:
    return os.getenv(name, default).strip().lower() in {"1", "true", "yes", "on"}


def run(command: list[str]) -> None:
    print(f"[{datetime.now().isoformat(timespec='seconds')}] Running: {' '.join(command)}", flush=True)
    subprocess.run(command, cwd=PROJECT_DIR, check=True)


def build_and_publish() -> None:
    target = os.getenv("DBT_TARGET", "prod")
    build = ["dbt", "build", "--target", target]
    if enabled("DBT_FULL_REFRESH"):
        build.append("--full-refresh")
    run(build)
    run(["dbt", "docs", "generate", "--target", target])

    PUBLISH_DIR.mkdir(parents=True, exist_ok=True)
    for filename in DOC_FILES:
        source = TARGET_DIR / filename
        if not source.is_file():
            raise FileNotFoundError(f"dbt docs did not create {source}")
        temporary = PUBLISH_DIR / f".{filename}.tmp"
        shutil.copy2(source, temporary)
        temporary.replace(PUBLISH_DIR / filename)
    print("Published dbt docs successfully.", flush=True)


def next_run() -> datetime:
    value = os.getenv("DBT_RUN_TIME", "07:00")
    try:
        hour, minute = (int(part) for part in value.split(":"))
        if not (0 <= hour <= 23 and 0 <= minute <= 59):
            raise ValueError
    except ValueError as error:
        raise ValueError("DBT_RUN_TIME must use 24-hour HH:MM format") from error

    timezone = ZoneInfo(os.getenv("TZ", "UTC"))
    now = datetime.now(timezone)
    scheduled = now.replace(hour=hour, minute=minute, second=0, microsecond=0)
    return scheduled if scheduled > now else scheduled + timedelta(days=1)


def attempt_run() -> None:
    try:
        build_and_publish()
    except Exception as error:
        print(f"dbt job failed: {error}", flush=True)


if __name__ == "__main__":
    if enabled("DBT_RUN_ON_START", "true"):
        attempt_run()

    while True:
        scheduled = next_run()
        delay = max(1, (scheduled - datetime.now(scheduled.tzinfo)).total_seconds())
        print(f"Next dbt run: {scheduled.isoformat()}", flush=True)
        time.sleep(delay)
        attempt_run()
