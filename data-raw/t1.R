library(shiny)
library(future)
library(promises)
plan(multisession)

ui <- fluidPage(
  column(6, plotOutput("one")),
  column(6, plotOutput("two"))
)

server <- function(input, output, session) {
  
  output$one <- renderPlot({
    x <- future({
      Sys.sleep(10);
      iris
      
    }) %...>%
      plot()
    x
  })
  
  output$two <- renderPlot({
    plot(airquality)
  })
  
}

shinyApp(ui, server)