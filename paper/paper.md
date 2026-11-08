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

`priogridR` is an R package for transferring common spatial and geographically
indexed data formats to PRIO-GRID and for performing recurring grid-oriented
tasks. It provides a consistent public interface for raster, vector,
point-event, NetCDF, and tabular inputs while relying on the official
`priogrid` package for configurable grid definitions and core raster
transformations [@priogrid].

# Statement of need

Research using global grid-cell data repeatedly requires source-specific code
for spatial alignment, event aggregation, temporal indexing, area allocation,
and output formatting. These implementations are difficult to compare and can
silently differ in their treatment of coordinate reference systems, missing
observations, structural zeros, polygon overlap, and temporal intervals.
`priogridR` provides reusable and tested operations for these steps through a
small `pg_`-prefixed API.

# Functionality

The package converts raster layers, vector geometries, point events, NetCDF
variables, and tables linked to polygon geographies. Conversion behavior is
controlled by `priogrid::pg_config()` objects, allowing researchers to vary
spatial and temporal resolution without rewriting data-processing code. The
package also provides grid-index creation, reusable spatial neighborhoods and
weights, spatial lags, distances, buffer summaries, reproducible path
construction, output writing, and plot styling.

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

# Acknowledgements

`priogridR` builds on the PRIO-GRID data structure [@tollefsen2012] and the
official `priogrid` R package [@priogrid].

# References

