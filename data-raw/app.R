library(shiny)

ui <- fluidPage(
  column(6, plotOutput("one")),
  column(6, plotOutput("two"))
)

server <- function(input, output, session) {
  
  output$one <- renderPlot({
    Sys.sleep(2)
    plot(iris)
  })
  
  output$two <- renderPlot({
    plot(airquality)
  })
  
}

shinyApp(ui, server)