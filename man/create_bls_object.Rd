% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_bls_object.R
\name{create_bls_object}
\alias{create_bls_object}
\title{Create a BLS data object with diagnostics}
\usage{
create_bls_object(
  data,
  downloads,
  data_type = "BLS",
  processing_steps = character(0)
)
}
\arguments{
\item{data}{The processed data (data.table/data.frame)}

\item{downloads}{List of download results from fread_bls()}

\item{data_type}{Character string describing the type of BLS data (e.g., "CES", "JOLTS", "CPS")}

\item{processing_steps}{Character vector describing processing steps applied}
}
\value{
A bls_data_collection object
}
\description{
Create a BLS data object with diagnostics
}
