# Contributing to priogridR

Thank you for considering a contribution.

## Reporting bugs

Before opening an issue, please search existing issues. A useful bug report
includes:

* a minimal reproducible example;
* the expected and observed behavior;
* the output of `sessionInfo()`;
* relevant spatial reference-system and PRIO-GRID configuration information;
* small, shareable example data when possible.

Please do not post confidential or restricted data.

## Proposing features

Open a feature request describing the research workflow, the desired public
interface, and why existing functions do not cover the use case. Public
functions should begin with `pg_` and use snake case.

## Pull requests

1. Create a focused branch from `main`.
2. Add or update tests for behavioral changes.
3. Document exported functions with roxygen2.
4. Update `NEWS.md` for user-visible changes.
5. Run:

```r
devtools::document()
devtools::test()
devtools::check()
```

Pull requests should leave `R CMD check --as-cran` without errors, warnings,
or significant notes. Do not edit generated `NAMESPACE` or `man/` files by
hand; regenerate them with `devtools::document()`.

## Style

Use two spaces for indentation, explicit namespace calls such as
`terra::rast()`, and descriptive argument names. Avoid changing the working
directory or writing outside locations explicitly selected by the user.

## Code of conduct

Participation in this project is governed by `CODE_OF_CONDUCT.md`.

