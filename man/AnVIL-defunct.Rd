% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AnVIL-defunct.R
\name{AnVIL-defunct}
\alias{AnVIL-defunct}
\alias{repository_stats}
\alias{print.repository_stats}
\title{Defunct AnVIL functionality}
\usage{
repository_stats(
  version = BiocManager::version(),
  binary_base_url = BINARY_BASE_URL
)

\method{print}{repository_stats}(x, ...)
}
\arguments{
\item{version}{\code{character(1)} or \code{package_version} Bioconductor
version, e.g., "3.12".}

\item{binary_base_url}{\code{character(1)} host and base path for binary
package 'CRAN-style' repository; not usually required by the
end-user.}

\item{x}{the object returned by \code{repository_stats()}.}

\item{...}{additional arguments (not used).}
}
\value{
\code{repository_stats()} returns a list of class
\code{repository_stats} with the following fields:
\itemize{
\item container: character(1) container label, e.g.,
\code{bioconductor_docker}, or NA if not evaluated on a supported
container
\item bioconductor_version: \code{package_version} the
Bioconductor version provided by the user.
\item repository_exists: logical(1) TRUE if a binary repository
exists for the container and Bioconductor_Version version.
\item bioconductor_binary_repository: character(1) repository
location, if available, or NA if the repository does not exist.
\item n_software_packages: integer(1) number of software packages
in the Bioconductor source repository.
\item n_binary_packages: integer(1) number of binary packages
available. When a binary repository exists, this number is likely
to be larger than the number of source software packages, because
it includes the binary version of the source software packages, as
well as the (possibly CRAN) dependencies of the binary packages
\item n_binary_software_packages: integer(1) number of binary
packages derived from Bioconductor source packages. This number is
less than or equal to \code{n_software_packages}.
\item missing_binaries: integer(1) the number of Bioconductor
source software packages that are not present in the binary
repository.
\item out_of_date_binaries: integer(1) the number of Bioconductor
source software packages that are newer than their binary
counterpart. A newer source software package
might occur when the main Bioconductor build system has
updated a package after the most recent run of the binary
build system.
}
}
\description{
\verb{repository_stats():} summarize binary packages
compatible with the Bioconductor or Terra container in use.
}
\section{Functions}{
\itemize{
\item \code{print(repository_stats)}: Print a summary of package
availability in binary repositories.

}}
