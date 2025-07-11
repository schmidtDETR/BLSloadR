% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_salt.R
\name{get_salt}
\alias{get_salt}
\title{Download State Alternative Labor Market Measures (SALT) Data}
\usage{
get_salt(
  only_states = TRUE,
  geometry = FALSE,
  show_warnings = TRUE,
  return_diagnostics = FALSE
)
}
\arguments{
\item{only_states}{Logical. If TRUE (default), includes only state-level data.
If FALSE, includes sub-state areas like New York City where available.}

\item{geometry}{Logical. If TRUE, uses tigris::states() to download shapefiles for the states 
to include in the data. If FALSE (default), only returns data table.}

\item{show_warnings}{Logical. If TRUE (default), displays download warnings 
and diagnostics. If FALSE, suppresses warning output.}

\item{return_diagnostics}{Logical. If TRUE, returns a bls_data_collection object
with full diagnostics. If FALSE (default), returns just the data table.}
}
\value{
By default, returns a data.table with CES data. If return_diagnostics = TRUE,
  returns a bls_data_collection object containing data and comprehensive diagnostics.
  The function also adds derived measures and quartile comparisons across states.
}
\description{
This function downloads detailed alternative unemployment measures data from BLS,
including U-1 through U-6 measures. The data provides a more comprehensive view
of labor market conditions beyond the standard unemployment rate (U-3).
}
\examples{
\dontrun{
# Download state-level SALT data
salt_data <- get_salt()

# Include sub-state areas
salt_all <- get_salt(only_states = FALSE)

# View latest U-6 rates by state
latest <- salt_df[date == max(date), .(state, u6)]
latest[order(-u6)]

# Download and display ratio of job losers to not job losers by state
get_salt(geometry = TRUE) |>
 dplyr::filter(date == max(date)) |> # To use only most current date
  ggplot2::ggplot() +
   ggplot2::geom_sf(ggplot2::aes(fill = losers_notlosers_ratio))

# Get full diagnostic object if needed
data_with_diagnostics <- get_salt(return_diagnostics = TRUE)
print_bls_warnings(data_with_diagnostics)
}

}
