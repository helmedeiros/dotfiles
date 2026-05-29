# Lint patterns template

The cross-cutting PII / employer-name lint guards in `test/lint/lint_test.bats` read patterns from `~/.dot-secrets/lint/pii-patterns.sh` rather than hardcoding employer names in public test source.

Copy `pii-patterns.sh.example` into your `~/.dot-secrets/lint/` directory:

```sh
mkdir -p ~/.dot-secrets/lint
cp pii-patterns.sh.example ~/.dot-secrets/lint/pii-patterns.sh
$EDITOR ~/.dot-secrets/lint/pii-patterns.sh
```

Populate `PII_PATTERNS` with `<regex>::<description>` pairs covering each substring you want kept out of the public repo. The lint test fails if any of those regexes match in any tracked file outside `test/`.

When the file is missing or the array is empty, the PII lint test is skipped with a note — useful on machines that have no .dot-secrets configured (e.g. fresh forks).
