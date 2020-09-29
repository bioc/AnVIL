.DRS_MARTHA <- "https://us-central1-broad-dsde-prod.cloudfunctions.net/martha_v3"

.drs_is_uri <-
    function(source)
{
    .is_character(source) & grepl("drs://[^/]+", source)
}

#' @importFrom httr POST add_headers
.martha_v3 <-
    function(url, template)
{
    access_token <- .gcloud_access_token()
    headers <- add_headers(
        Authorization = paste("Bearer", access_token),
        "content-type" = "application/json"
    )
    body <- paste0('{ "url": "', url, '"}')
    response <- POST(.DRS_MARTHA, headers, body = body, encode="raw")
    .avstop_for_status(response, "DRS resolution")
    lst <- as.list(response)
    tbl <- as_tibble(lst[!vapply(lst, is.null, logical(1))])

    .tbl_with_template(tbl, template)
}


#' @rdname drs
#' @md
#'
#' @title Manipulate 'DRS' (Data Repository Service) URLs
#'
#' @description `drs_stat()` resolves zero or more DRS URLs to their
#'     google bucket location.
#'
#' @details `drs_stat()` uses the AnVIL 'pet' account associated with a
#'     runtime. The pet account is discovered by default when
#'     evaluated on an AnVIL runtime (e.g., in RStudio or a Jupyter
#'     notebook in the AnVIL), or can be found in the return value of
#'     `avruntimes()`.
#'
#' @param drs character() DRS URLs (beginning with 'drs://') to
#'     resources managed by the 'martha' DRS resolution server.
#'
#' @return `drs_stat()` returns a tbl with the following columns:
#'
#' - fileName: character() (resolver sometimes returns null).
#' - size: integer() (resolver sometimes returns null).
#' - contentType: character() (resolver sometimes returns null).
#' - gsUri: character() (resolver sometimes returns null).
#' - timeCreated: character() (the time created formatted using ISO
#'   8601; resolver sometimes returns null).
#' - timeUpdated: character() (the time updated formatted using ISO
#'   8601; resolver sometimes returns null).
#' - bucket: character() (resolver sometimes returns null).
#' - name: character() (resolver sometimes returns null).
#' - googleServiceAccount: list() (null unless the DOS url belongs to
#'   a Bond supported host).
#' - hashes: list() (contains the hashes type and their checksum
#'   value; if unknown. it returns null)
#'
#' @examples
#' drs_eg_hca <- paste0(
#'     "drs://drs.data.humancellatlas.org/",
#'     "4cf48dbf-cf09-452e-bb5b-fd016af0c747?version=2019-09-14T024754.281908Z"
#' )
#'
#' drs_eg_anvil <- c(
#'     "drs://dg.ANV0/975bd45f-f022-4fad-b9a2-3a00c3b8792c",
#'     "drs://dg.ANV0/00008531-03d7-418c-b3d3-b7b22b5381a0"
#' )
#'
#' if (gcloud_exists())
#'     # no pet account needed for HCA data
#'     drs_stat(drs_eg_hca)
#'
#' if (gcloud_exists() && startsWiith(gcloud_accout(), "pet-")) {
#'     ## from within AnVIL
#'     drs_stat(drs_eg_anvil)
#' }
#' @export
drs_stat <-
    function(source = character())
{
    stopifnot(
        `'source' must be DRS URIs, e.g., starting with "drs://"` =
            all(.drs_is_uri(source))
    )

    template <- list(
        fileName = character(),
        size = integer(),
        contentType = character(),
        gsUri = character(),
        timeCreated = character(),
        timeUpdated = character(),
        bucket = character(),
        name = character(),
        googleServiceAccount = list(),
        hashes = list()
    )


    response <- lapply(source, .martha_v3, template)
    tbl <- bind_rows(response)
    .tbl_with_template(tbl, template)
}

.drs_cp_simple <-
    function(tbl, destination, ...)
{
    if (!any(tbl$simple))
        return(NULL)

    gsUri <-
        tbl %>%
        filter(.data$simple) %>%
        pull(gsUri)
    gsutil_cp(gsUri, destination, ...)
}

.drs_cp_full <-
    function(tbl, destination, ...)
{
}

#' @rdname drs
#' @md
#'
#' @description `drs_cp()` copies 0 or more DRS URIs to a google
#'     bucket or local folder
#'
#' @param destination character(1) directory path in which to retrieve
#'     files.
#'
#' @return `drs_cp()` returns a tibble like `drs_stat()`, but with
#'     additional columns
#'
#' - simple: logical() value indicating whether resolution used a
#'   simple signed URL (`TRUE`) or auxilliary service account.
#' - destination: character() full path to retrieved object(s)
#'
#' @examples
#' if (gcloud_exists()) {
#'     tbl <- drs_cp(drs_eg_hca)
#'     readLines(tbl$destination, warn = FALSE)
#' }
#'
#' @export
drs_cp <-
    function(source, destination, ...)
{
    stopifnot(
        `'source' must be DRS URIs, e.g., starting with "drs://"` =
            all(.drs_is_uri(source)),
        `'destination' must be a google bucket or existing local directory` =
            .gsutil_is_uri(destination) || .is_local_directory(destination)
    )

    ## discover DRS information, including signed URL
    tbl <- drs_stat(source)
    tbl <-
        tbl %>%
        mutate(
            simple = lengths(.data$googleServiceAccount) == 0L,
            destination = file.path(destination, .data$fileName)
        )

    ## copy files to local directory
    .drs_cp_simple(tbl, destination, ...)
    .drs_cp_full(tbl, destination, ...)

    ## rename to file name in drs response
    file.rename(
        file.path(destination, basename(tbl$gsUri)),
        tbl$destination
    )

    tbl
}