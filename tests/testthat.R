library(testthat)

# Isolate priogrid's process-global disk cache from caches created and removed
# while R CMD build installs the package and builds its vignettes. Without this
# isolation, later tests can inherit a destroyed cache on CI runners.
priogridR_test_user_dir <- file.path(tempdir(), "priogridR-test-user")
priogridR_test_config_dir <- file.path(priogridR_test_user_dir, "config")
priogridR_test_cache_dir <- file.path(priogridR_test_user_dir, "cache")
dir.create(priogridR_test_config_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(priogridR_test_cache_dir, recursive = TRUE, showWarnings = FALSE)

Sys.setenv(
  HOME = priogridR_test_user_dir,
  XDG_CONFIG_HOME = priogridR_test_config_dir,
  XDG_CACHE_HOME = priogridR_test_cache_dir,
  APPDATA = priogridR_test_config_dir,
  LOCALAPPDATA = priogridR_test_cache_dir,
  R_USER_CONFIG_DIR = priogridR_test_config_dir,
  R_USER_CACHE_DIR = priogridR_test_cache_dir
)

library(priogridR)

test_check("priogridR")

