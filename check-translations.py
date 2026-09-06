#!/usr/bin/env python3
"""Check each add-on's option translations against its schema.

Home Assistant looks up every configuration option in
``translations/<language>.yaml`` to label it in the add-on's UI. An option
added to ``config.yaml`` without a matching entry in ``translations/en.yaml``
shows up as a bare key, and a translation with a stale key is dead weight —
neither is something the Supervisor complains about, so check it here.

Usage: check-translations.py [addon-directory ...]

With no arguments every add-on in the repository is checked, so a new one
is covered the moment its directory exists.
"""

import pathlib
import sys

try:
    import yaml
except ImportError:  # pragma: no cover - depends on the environment
    sys.exit("PyYAML is required: pip install pyyaml")

SOURCE_LANGUAGE = "en"


def addon_dirs(root: pathlib.Path) -> list[pathlib.Path]:
    """Every add-on in the repository: a directory holding a config.yaml."""
    return sorted(p.parent for p in root.glob("*/config.yaml"))


def option_names(config: dict) -> set[str]:
    """Option keys the add-on accepts, from its schema."""
    return set(config.get("schema", {}))


def translated_names(translation: dict) -> set[str]:
    return set(translation.get("configuration", {}))


def check(addon: pathlib.Path) -> list[str]:
    config = yaml.safe_load((addon / "config.yaml").read_text())
    options = option_names(config)
    problems = []

    translations = sorted((addon / "translations").glob("*.yaml"))
    if not translations:
        return [f"{addon}/translations: no catalogues"]

    for path in translations:
        language = path.stem
        catalogue = yaml.safe_load(path.read_text()) or {}
        names = translated_names(catalogue)

        # English describes every option; other languages may lag behind,
        # and Home Assistant falls back to English for what is missing.
        if language == SOURCE_LANGUAGE:
            for missing in sorted(options - names):
                problems.append(f"{path}: option {missing!r} has no name or description")

        for unknown in sorted(names - options):
            problems.append(f"{path}: {unknown!r} is not an option in config.yaml")

        for option, fields in sorted(catalogue.get("configuration", {}).items()):
            for field in ("name", "description"):
                if not (fields or {}).get(field):
                    problems.append(f"{path}: option {option!r} has no {field}")

    return problems


def main() -> int:
    root = pathlib.Path(__file__).resolve().parent
    addons = [pathlib.Path(a) for a in sys.argv[1:]] or addon_dirs(root)
    if not addons:
        print(f"{root}: no add-ons found", file=sys.stderr)
        return 1

    problems = []
    for addon in addons:
        problems += check(addon)

    for problem in problems:
        print(problem, file=sys.stderr)
    if problems:
        return 1

    for addon in addons:
        print(f"{addon.name}/translations: option coverage ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
