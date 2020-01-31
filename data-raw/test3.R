library(shiny)
library(promises)
library(future)
library(asap)
library(DT)
plan(multisession)


ui <- fluidPage(
  selectInput("dataset",label = "dataset",choices = c("mtcars","iris","cars")),
  column(6, plotOutput("one")),
  column(6, plotOutput("two")),
  column(6, DTOutput("table1")),
  column(6, plotOutput("four"))
)

server <- function(input, output, session) {
  
  
  data <- reactiveValues()
  
  observeEvent( input$dataset ,ignoreInit = TRUE, {
  data$dataset <- get(input$dataset)

  update_asap(what = ~{
      Sys.sleep(15);
    iris},to = tableau)
  })
  
  
  
  plotiris <- reactiveVal()
  plotiris(NULL)
  
  update_asap(what = ~{
    Sys.sleep(2);
    iris},to = plotiris)
  
  output$one <- renderPlot({
    req(plotiris())
    plot(plotiris())
  })
  
  output$two <- renderPlot({
    plot(airquality)
  })
  
  tableau <- reactiveVal()
  tableau(NULL)
  
  update_asap(what = ~{
    Sys.sleep(5);
    mtcars},to = tableau)
  
  
  
  output$table1 <- DT::renderDT({
    req(tableau())
    tableau()
  })
  
  output$four <- renderPlot({
    plot(cars)
  })
}

shinyApp(ui, server)
