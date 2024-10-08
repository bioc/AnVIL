% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/drs.R
\name{drs-deprecated}
\alias{drs-deprecated}
\alias{drs_stat}
\alias{drs_access_url}
\alias{drs_cp}
\title{DRS (Data Repository Service) URL management}
\usage{
drs_stat(source = character(), region = "US")

drs_access_url(source = character(), region = "US")

drs_cp(source, destination, ..., overwrite = FALSE)
}
\arguments{
\item{source}{character() DRS URLs (beginning with 'drs://') to
resources managed by the 'martha' DRS resolution server.}

\item{region}{character(1) Google cloud 'region' in which the DRS
resource is located. Most data is located in \code{"US"} (the
default); in principle \code{"auto"} allows for discovery of
the region, but sometimes fails. Regions are enumerated at
\url{https://cloud.google.com/storage/docs/locations#available-locations}.}

\item{destination}{\code{character(1)}, google cloud bucket or local
file system destination path.}

\item{...}{additional arguments, passed to \code{gsutil_cp()} for file
copying.}

\item{overwrite}{logical(1) indicating that source \code{fileName}s
present in \code{destination} should downloaded again.}
}
\value{
\code{drs_stat()} returns a tbl with the following columns:
\itemize{
\item fileName: character() (resolver sometimes returns null).
\item size: integer() (resolver sometimes returns null).
\item contentType: character() (resolver sometimes returns null).
\item gsUri: character() (resolver sometimes returns null).
\item timeCreated: character() (the time created formatted using ISO
8601; resolver sometimes returns null).
\item timeUpdated: character() (the time updated formatted using ISO
8601; resolver sometimes returns null).
\item bucket: character() (resolver sometimes returns null).
\item name: character() (resolver sometimes returns null).
\item googleServiceAccount: list() (null unless the DOS url belongs to
a Bond supported host).
\item hashes: list() (contains the hashes type and their checksum
value; if unknown. it returns null)
}

\code{drs_access_url()} returns a vector of https URLs
corresponding to the vector of DRS URIs provided as inputs to
the function.

\code{drs_cp()} returns a tibble like \code{drs_stat()}, but with
additional columns
\itemize{
\item simple: logical() value indicating whether resolution used a
simple signed URL (\code{TRUE}) or auxilliary service account.
\item destination: character() full path to retrieved object(s)
}
}
\description{
\code{drs_stat()} resolves zero or more DRS URLs to their
google bucket location.

\code{drs_access_url()} returns a vector of 'signed' URLs
that allow access to restricted resources via standard https
protocols.

\code{drs_cp()} copies 0 or more DRS URIs to a google
bucket or local folder
}
\details{
\code{drs_stat()} sends requests in parallel to the DRS server,
using 8 forked processes (by default) to speed up queries. Use
\code{options(mc.cores = 16L)}, for instance, to set the number of
processes to use.

\code{drs_stat()} uses the AnVIL 'pet' account associated with a
runtime. The pet account is discovered by default when evaluated on
an AnVIL runtime (e.g., in RStudio or a Jupyter notebook in the
AnVIL), or can be found in the return value of \code{avruntimes()}.

Errors reported by the DRS service are communicated to the user,
but can be cryptic. The DRS service itself is called
'martha'. Errors mentioning martha might commonly involve a
mal-formed DRS uri. Martha uses a service called 'bond' to
establish credentials with registered third party entities such as
Kids First. Errors mentioning bond might involve absence of
credentials, within Terra, to access the resource; check that, in
the Terra / AnVIL graphical user interface, the user profiles
'External Entities' includes the organization to which the DRS uri
is being resolved.
}
\examples{
drs <- c(
    vcf = "drs://dg.ANV0/6f633518-f2de-4460-aaa4-a27ee6138ab5",
    tbi = "drs://dg.ANV0/4fb9e77f-c92a-4deb-ac90-db007dc633aa"
)

library(AnVILGCP)
if (gcloud_exists() && startsWith(gcloud_account(), "pet-")) {
    ## from within AnVIL
    tbl <- drs_stat(uri)
    urls <- drs_access_url(uri)
    ## library(VariantAnnotation)
    ## vcffile <- VcfFile(urls[["vcf"]], urls[["tbi"]])
    ##
    ## header <- scanVcfHeader(vcffile)
    ## meta(header)[["contig"]]
}

}
