# Contributing to claude-mux

Thanks for your interest in contributing. claude-mux is a single-author project with a small but growing user base. Contributions are welcome — bug fixes, features, translations, and platform support all add value.

## Reporting issues

Please use the GitHub issue templates:
- **Bug reports** — for things that aren't working
- **Feature requests** — for new functionality
- **Translation issues** — for translation errors or requests for new languages

Include claude-mux version (`claude-mux --version`), macOS version, and `~/Library/Logs/claude-mux.log` excerpt where relevant.

## Development setup

```bash
git clone https://github.com/pereljon/claude-mux.git
cd claude-mux
./install.sh
```

The script has two locations:
- **Repo**: `~/Claude/development/claude-mux/claude-mux` (version-controlled)
- **Installed**: `~/bin/claude-mux` (what actually runs)

Always edit the repo copy first. After making changes, deploy:

```bash
cp ~/Claude/development/claude-mux/claude-mux ~/bin/
```

## Testing

Before submitting changes:

1. **Bash syntax check**: `bash -n claude-mux`
2. **Manual smoke test**: run common commands (`-l`, `-L`, `--shutdown`, `--restart`, etc.) to verify nothing regressed
3. **Targeted test for the change**: confirm the behavior you added or fixed works in the relevant scenarios
4. **Dry-run check**: `claude-mux --dry-run` to confirm no unintended actions

For non-trivial changes, agree on a testing plan with the maintainer before writing code (see `CLAUDE.md` for detail).

## Code style

- Follow existing bash style and conventions in the script
- Functions are small, single-purpose, named with snake_case
- Prefer explicit over clever
- Comments explain *why*, not *what*

## Commit messages

Follow conventional commits format:

```
<type>: <short description>

<optional body>
```

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`

Examples:
- `feat: add --no-multi-coder flag for new projects`
- `fix: handle missing CLAUDE.md when creating symlinks`
- `docs: update CHANGELOG for v1.6`

## Versioning

claude-mux follows [Semantic Versioning](https://semver.org/):
- **Patch** (`1.5.0` → `1.5.1`): bug fixes, no behavior changes
- **Minor** (`1.5.0` → `1.6.0`): new features, backwards-compatible
- **Major** (`1.x` → `2.0`): breaking changes

The `VERSION=` line at the top of `claude-mux` is the source of truth. Bump it in the same PR as the change.

## Deprecation policy

When removing or significantly changing existing behavior:

1. **Deprecate first**: add a warning when the feature is used. Don't remove it yet.
2. **Wait at least one minor version** before removing. Two is preferred.
3. **Document the deprecation** in `CHANGELOG.md` under "Deprecated".
4. **Provide migration guidance** in the warning message and changelog.
5. **Remove in a later release**, documented under "Removed" in the changelog.

Example: `LAUNCHAGENT_MODE=batch` was deprecated in 1.4 and removed in 1.5; existing configs warn and fall back to `home`.

## Translations

claude-mux is translated into 12 languages. Translated READMEs live in `translations/`.

### Updating an existing translation

When `README.md` changes, the translations may go stale. Either:
- Update the affected sections in each translation file directly
- Or flag the translations for re-translation in the PR description so they can be batch-updated

For minor English wording tweaks, translations can lag and get refreshed during the next major change. For substantive changes (new features, restructuring), update translations as part of the same PR.

### Adding a new language

1. Pick the ISO 639-1 code (e.g., `pl` for Polish, `tr` for Turkish). Use `xx-YY` form only for regional variants where it matters (`pt-BR`, `zh-CN`).
2. Copy `translations/README.es.md` as a starting structure
3. Translate following the rules in `CLAUDE.md` "Translation standards" section
4. Add your language to the cross-linker in **all** translation files and in the root `README.md`
5. Submit a PR

### Translation standards

See `CLAUDE.md` "Translation standards" for the full rules. Quick summary:
- **Keep in English**: CLI flags, product names, status keywords, the injected system prompt block
- **Translate**: prose, headers, conversational labels (`You:`/`Claude:`), inline shell comments, descriptive table text
- **Path placeholders**: translate to local equivalents in Latin-script languages; keep ASCII in CJK / RTL / Cyrillic / Devanagari languages
- **No LLM-stereotype writing**: no em dashes, no "leverage", no "delve", etc.

## Pull request checklist

- [ ] Bash syntax check passes (`bash -n claude-mux`)
- [ ] Manual test of changed behavior
- [ ] `VERSION=` bumped if user-visible change
- [ ] `CHANGELOG.md` entry added under `[Unreleased]`
- [ ] `README.md` updated if commands or features changed
- [ ] `CLAUDE.md` updated if dev workflow changed
- [ ] Translations updated or flagged
- [ ] Commit message follows conventional commits format
