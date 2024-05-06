#' Determine the file path for storing user state
#'
#' This function computes the path to the file used for storing user state information.
#' It ensures the directory exists, creating it if necessary.
#'
#' @return A string containing the path to the file where user state is or will be stored.
#' @keywords internal
#' @export
user_state_file <- function() {
  r_user_dir <- normalizePath("~/.training-r-intro", winslash = "/")
  if (!dir.exists(r_user_dir)) {
    dir.create(r_user_dir, recursive = TRUE, showWarnings = FALSE)
  }
  file.path(r_user_dir, "user_state.RData")
}

#' Load the user state from disk
#'
#' Retrieves user state data from a file. If the file does not exist or the specific `user_state`
#' variable is not found within the file, it returns a default state.
#'
#' @return A list containing the user state. The default state includes the time last message
#'         was displayed, the current lesson, and other preferences.
#' @keywords internal
#' @export
load_user_state <- function() {
  state_path <- user_state_file()
  if (file.exists(state_path)) {
    load(state_path)
    if (exists("user_state")) {
      return(user_state)
    }
  }
  # Return default state if file does not exist or `user_state` not found
  list(last_message_displayed = Sys.time() - 24*3600, # 24 hours ago
       current_lesson = NULL,
       other_preferences = list())
}

#' Save the user state to disk
#'
#' Persists the current state of the user, such as lesson progress and preferences, to a file
#' on disk.
#'
#' @param user_state A list representing the user state to be saved.
#' @keywords internal
#' @export
save_user_state <- function(user_state) {
  state_path <- user_state_file()
  save(user_state, file = state_path)
}

#' Set parameters in the user state
#'
#' Updates specific parameters within the user state. It first loads the current state,
#' modifies it based on provided arguments, and saves the updated state back to disk.
#'
#' @param ... Named arguments where each name is the user state variable to update, and
#'            the corresponding value is the new value for that variable.
#'
#' @keywords internal
#' @export
set_user_state <- function(...) {
  dots <- list(...)
  if (any(names(dots) == "")) {
    stop("All arguments must be named.")
  }
  user_state <- load_user_state()
  for (name in names(dots)) {
    value <- dots[[name]]
    # Add here any specific validation for name or value as needed
    user_state[[name]] <- value
  }
  save_user_state(user_state)
}

#' Retrieve a parameter from the user state
#'
#' Accesses a specific parameter from the user state by name. If the parameter is not
#' found, it returns `NULL`.
#'
#' @param name The name of the parameter to retrieve from the user state.
#'
#' @return The value of the specified parameter, or `NULL` if it does not exist.
#' @keywords internal
#' @export
get_user_state <- function(name) {
  user_state <- load_user_state()
  if(!name %in% names(user_state)) return(NULL)
  user_state[[name]]
}

