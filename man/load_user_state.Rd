% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/userstate.R
\name{load_user_state}
\alias{load_user_state}
\title{Load the user state from disk}
\usage{
load_user_state()
}
\value{
A list containing the user state. The default state includes the time last message
was displayed, the current lesson, and other preferences.
}
\description{
Retrieves user state data from a file. If the file does not exist or the specific \code{user_state}
variable is not found within the file, it returns a default state.
}
\keyword{internal}
