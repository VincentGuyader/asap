#' update asap
#'
#' @param what what to do (an R function)
#' @param to where to update ( shoul be a reactiveVal )
#'
#' @return
#' @export
#'
#' @importFrom shiny reactiveVal
#' @import future
#' @import promises
#' @importFrom purrr as_mapper
update_asap <- function(what, to = reactiveVal()){
  # browser()
  future({
    # Sys.sleep(5)
    purrr::as_mapper(what)()
  }) %...>%
    to() %...!%
    (function(e){
      to(NULL)
      warning(e)
    })
  
}