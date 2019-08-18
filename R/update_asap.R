#' update asap
#'
#' @param what what to do (an R expression)
#' @param to where to update ( shoul be a reactiveVal )
#'
#' @return
#' @export
#'
#' @importFrom shiny reactiveVal
#' @import future
#' @import promises
update_asap <- function(what, to = reactiveVal()){
  
  future({
    # Sys.sleep(5)
    what
  }) %...>%
    to() %...!%
    (function(e){
      to(NULL)
      warning(e)
    })
  
}