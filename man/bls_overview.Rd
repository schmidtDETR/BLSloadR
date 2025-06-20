\name{bls_overview}
\alias{bls_overview}
\title{Display BLS Dataset Overview}
\usage{
bls_overview(
  series_id,
  display_method = "viewer",
  base_url = "https://download.bls.gov/pub/time.series"
)
}
\arguments{
\item{series_id}{Character string. The BLS series identifier (e.g., "ln", "sm", "la")}

\item{display_method}{Character string. How to display the overview: 
"viewer" (default), "console", "help", or "popup"}

\item{base_url}{Character string. Base URL for BLS data (default uses official BLS site)}
}
\value{
Invisibly returns the text content of the overview file.
}
\description{
Fetches and displays the overview text file for a BLS dataset using proper
headers to avoid 403 errors from the BLS server. The overview files contain
important information about the dataset structure, variable definitions,
and data collection methodology.
}
\details{
This function retrieves the plain text overview file (e.g., ln.txt, cu.txt) 
associated with each BLS time series dataset. These files provide essential 
documentation including:

\itemize{
\item Dataset description and scope
\item Variable definitions and codes
\item Data collection methodology
\item File structure information
\item Contact information and references
}

The function uses the same HTTP headers as \code{\link{fread_bls}} to ensure
reliable access to BLS servers. Multiple display methods are available to
suit different workflows:

\itemize{
\item \strong{viewer}: Displays formatted HTML in RStudio's Viewer pane (default)
\item \strong{console}: Prints formatted text directly to the R console
\item \strong{help}: Displays help documentation-style HTML in the Viewer pane
\item \strong{popup}: Shows content in a dialog box (RStudio only)
}
}
\examples{
\dontrun{
# Display labor force statistics overview in viewer pane
bls_overview("ln")

# Display consumer price index overview in console
bls_overview("cu", display_method = "console")

# Display average price data overview as help-style page
bls_overview("ap", display_method = "help")

# Store the content while displaying
content <- bls_overview("sm")  # State and Metro Area Employment
}
}
\seealso{
\code{\link{fread_bls}} for downloading BLS time series data files
}