---
title: "priogridR: Consistent conversion and utility functions for PRIO-GRID"
tags:
  - R
  - spatial data
  - geographic information systems
  - conflict research
  - reproducible research
authors:
  - name: Christian Oswald
    orcid: 0000-0001-8291-9544
    affiliation: "1"
affiliations:
  - name: "Center for Crisis Early Warning, University of the Bundeswehr Munich"
    index: 1
bibliography: paper.bib
---

# Summary

Many questions in conflict research, environmental analysis, public health,
and development require information from sources that use incompatible
geographic units. `priogridR` is an R package for converting common spatial
and geographically indexed data to PRIO-GRID and for performing recurring
grid-oriented data-management tasks. It provides a consistent interface for
raster, vector, point-event, NetCDF, and tabular inputs. It also supports cell
identification, grid geometries, validated panels, spatial neighborhoods,
weights, lags, distances, buffers, joins, output, and visualization. The
package builds on the official `priogrid` package for configurable grid
definitions and core raster transformations [@priogrid], while keeping
researchers' aggregation and missing-data choices explicit.

# Statement of need

Research using global grid-cell data repeatedly requires source-specific code
for spatial alignment, event aggregation, temporal indexing, area allocation,
and output formatting. These implementations are difficult to compare and can
silently differ in their treatment of coordinate reference systems, missing
observations, structural zeros, polygon overlap, and temporal intervals.
`priogridR` provides reusable and tested operations for these steps through a
coherent `pg_`-prefixed API. Its target users are researchers who combine
events, administrative units, remotely sensed surfaces, and other spatial
sources in PRIO-GRID analyses. The package reduces repeated implementation
work without concealing choices that can affect substantive conclusions.

# State of the field

PRIO-GRID provides a standardized global spatial structure widely used in
peace and conflict research [@tollefsen2012]. The official `priogrid` R package
collects and standardizes source data, manages metadata and citations, defines
configurable grids, and supplies supported raster transformations [@priogrid].
`priogridR` complements rather than replaces that infrastructure. Its focus is
the user-facing work that begins when researchers already have their own
rasters, vector features, event records, or geographically indexed tables and
need to convert, validate, combine, or analyze them consistently.

General spatial packages such as `sf` [@pebesma2018] and `terra` [@terra]
provide the underlying geometry and raster operations. Packages such as
`exactextractr` [@exactextractr] support precise raster summaries over polygon
geometries, while `spdep` [@spdep] provides extensive spatial-neighborhood and
spatial-statistics infrastructure. These packages are intentionally general.
They do not encode PRIO-GRID identifiers, configurable PRIO-GRID geometries,
cell-period validation, or the distinction between aggregation choices used
throughout PRIO-GRID research. `priogridR` connects these recurring tasks in a
single domain-specific workflow while returning ordinary R objects that remain
compatible with the broader spatial ecosystem.

Developing a separate convenience layer is preferable to duplicating the
official package's data-access and metadata systems. It allows `priogridR` to
specialize in transparent conversion and analysis helpers while delegating
authoritative grid definitions, official variables, and source citations to
`priogrid`.

# Functionality

The package converts raster layers, vector geometries, point events, NetCDF
variables, and tables linked to polygon geographies. Conversion behavior is
controlled by `priogrid::pg_config()` objects, allowing researchers to vary
spatial and temporal resolution without rewriting data-processing code. The
package also provides grid-index creation, reusable spatial neighborhoods and
weights, spatial lags, distances, buffer summaries, reproducible path
construction, output writing, and plot styling.

# Software design

The package is organized around three design choices. First, spatial and
temporal configuration is explicit. Functions accept `priogrid::pg_config()`
objects rather than embedding one fixed grid resolution or time scale. This
supports sensitivity analyses across grid specifications and avoids hidden
dependence on package-wide defaults.

Second, transformation rules are tied to the meaning of the input. Point
events can be counted or summarized, lines can be measured by length or
density, polygons can be transferred by overlap area, and rasters can use
aggregation or disaggregation rules appropriate to their measurement scale.
Missing observations are distinguished from meaningful zeros, and temporal
functions operate within cells and periods to prevent unintended leakage.

Third, outputs use familiar R classes. Conversion functions return data
frames, `terra::SpatRaster` objects, or lightweight combined result objects;
grid geometries use `sf`; and neighbor and weight structures remain
inspectable tables. This favors interoperability and auditability over a large
package-specific class hierarchy. Shared internal adapters isolate calls to
the official `priogrid` API, while validation helpers provide consistent
errors across public functions. Potentially expensive distance operations are
guarded against accidental all-global Cartesian calculations.

The package is tested with synthetic, offline fixtures so that behavior is
reproducible across operating systems and does not depend on changing remote
data. Documentation examples and vignettes use small configurable grids to
keep installation and continuous-integration checks practical.

# Quality assurance

The repository contains automated tests, worked vignettes, API documentation,
and continuous integration across current, development, and older R releases
on Linux, macOS, and Windows. Spatial operations explicitly validate grid
configuration, coordinate handling, metric calculations, and distinctions
between missing values and observed zeros.

# Research applications

The package is intended for reproducible spatial research using PRIO-GRID,
including conflict studies, environmental analysis, development research, and
other applications combining events, administrative data, and gridded
covariates.

# Research impact statement

PRIO-GRID is used across a large body of subnational research, and many
projects independently implement the same conversion, neighborhood, panel,
and output steps. `priogridR` turns those recurring steps into documented and
tested operations whose assumptions can be inspected and reported. This is
particularly useful for replication projects and collaborative research in
which data from several providers must be aligned consistently.

The project is currently in active pre-1.0 development. Evidence of impact at
this stage is therefore primarily community readiness rather than established
download or citation counts: the package provides versioned public releases,
a multi-platform continuous-integration matrix, executable examples, focused
vignettes, issue and contribution pathways, and a public development roadmap.
The expected near-term impact is improved reproducibility and reduced
duplication in research workflows that construct new PRIO-GRID variables or
analyze cell-level panels. Future impact will be assessed through external
issues and contributions, documented research applications, software
citations, and reuse in replication materials.

# AI usage disclosure

Development of `priogridR` has been assisted by OpenAI's ChatGPT and Codex.
These tools have supported code drafting and refactoring, test development,
documentation, troubleshooting, literature review, and discussion of package
design. All substantive design decisions remain the responsibility of the
software author. AI-assisted material is reviewed against the intended
statistical and spatial behavior and is validated through unit tests,
examples, vignette rebuilding, multi-platform continuous integration, and
`R CMD check`. The author remains responsible for the correctness,
maintenance, and scholarly claims of both the software and this paper.

# Acknowledgements

`priogridR` builds on the PRIO-GRID data structure [@tollefsen2012] and the
official `priogrid` R package [@priogrid].

# References

