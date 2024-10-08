#' @name localize-deprecated
#'
#' @title Copy packages, folders, or files to or from google buckets
#'
#' @description `r lifecycle::badge("deprecated")`\cr
#'     `localize()`: recursively synchronizes files from a
#'     Google storage bucket (`source`) to the local file system
#'     (`destination`). This command acts recursively on the `source`
#'     directory, and does not delete files in `destination` that are
#'     not in `source.
#'
#' @param source `character(1)`, a google storage bucket or local file
#'     system directory location.
#'
#' @param destination `character(1)`, a google storage bucket or local
#'     file system directory location.
#'
#' @param dry `logical(1)`, when `TRUE` (default), return the
#'     consequences of the operation without actually performing the
#'     operation.
#'
#' @return `localize()`: exit status of function `gsutil_rsync()`.
#'
#' @export
localize <-
    function(source, destination, dry = TRUE)
{
    stopifnot(
        .gsutil_is_uri(source),
        isScalarCharacter(destination), dir.exists(destination),
        isScalarLogical(dry)
    )
    .life_cycle(
        newpackage = "AnVILGCP",
        title = "localize"
    )
    if (dry)
        warning("use 'dry = FALSE' to localize source / destination")

    ## FIXME: return destination paths of copied files
    gsutil_rsync(
        source, destination, delete = FALSE, recursive = TRUE, dry = dry
    )
}

#' @name localize-deprecated
#'
#' @description `delocalize()`: synchronize files from a local file
#'     system (`source`) to a Google storage bucket
#'     (`destination`). This command acts recursively on the `source`
#'     directory, and does not delete files in `destination` that are
#'     not in `source`.
#'
#' @param unlink `logical(1)` remove (unlink) the file or directory
#'     in `source`. Default: `FALSE`.
#'
#' @return `delocalize()`: exit status of function `gsutil_rsync()`
#'
#' @export
delocalize <-
    function(source, destination, unlink = FALSE, dry = TRUE)
{
    stopifnot(
        isScalarCharacter(source), file.exists(source),
        .gsutil_is_uri(destination),
        isScalarLogical(unlink),
        isScalarLogical(dry)
    )
    .life_cycle(
        newpackage = "AnVILGCP",
        title = "localize"
    )
    if (dry)
        warning("use 'dry = FALSE' to delocalize source / destination")

    ## sync and optionally remove source
    result <- gsutil_rsync(
        source, destination, delete = FALSE, recursive = TRUE, dry = dry
    )
    if (!dry && unlink)
        unlink(source, recursive=TRUE)
    result
}
