Jouons un peu avec shiny a async

Shiny gere les traitements asynchrones depuis la version 1.1 (https://blog.rstudio.com/2018/06/26/shiny-1-1-0/)
Mais en l'état, et moyennant quelque incantations avec les packages {futur} et {promise} l'asynchronisme n'etait observable que dans le cas ou plusieurs utilisateurs différents se connectaient à l'application.

Cela étant précisé, tachons de faire de l'asynchrone au sein d'une même session utilisateur



Le probleme :
  
  lisons et analysons le code suivant :
  
  library(shiny)

ui <- fluidPage(
  column(6, plotOutput("one")),
  column(6, plotOutput("two"))
)

server <- function(input, output, session) {
  
  output$one <- renderPlot({
    Sys.sleep(10)
    plot(iris)
  })
  
  output$two <- renderPlot({
    plot(airquality)
  })
  
}

shinyApp(ui, server)

Si vous le lancez 
( ce que je vous encourage à faire pour bien vous rendre compte), vous verrez une page blanche
pendant 10 secondes avant de voir surgir en meme temps les 2 graphique one et two.

bien que le `renderPlot` two soit pret quasi instantanément shiny attend que tous les render aient terminé avant d'affiché quoi que ce soit... ce qui n'est pas tres agréable en terme d'expérience utilisateur.

Ne serait il pas génial d'afficher les graphique au fur et à mesure qu'ils sont disponibles ?

la solution :
  
Plusieurs approchent sont à priori possibles pour gerer  ce cas, mais ce n'est pas trivial non plus. L'idée est d'utiliser le couple  {futur} + {promise} pour "détacher" les calculs de la session de l'utilisateur. Mais cela ne suffit pas car en fonction des approche le renderPlot attendra la résolution du futur ou ne sera jamais notifié que celui ci est pret.

voici 2 approches non concluantes : 




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
    message('salut')
    x <- future({
      Sys.sleep(10);
      iris

    }) %...>%
      plot()
    message("je suis la")
    
    req(isTruthy(future::resolved(x)))
    message("banana")
    # Sys.sleep(15)
    # plot(iris)
    x
  })
  
  output$two <- renderPlot({
    plot(airquality)
  })
  
}

shinyApp(ui, server)



 

La solution :

library(shiny)
library(future)
library(promises)
library(asap) # remotes::install_github("VincentGuyader/asap")
plan(multisession)

ui <- fluidPage(
  column(6, plotOutput("one")),
  column(6, plotOutput("two"))
)

server <- function(input, output, session) {
  
  plotiris <- reactiveVal()
  plotiris(NULL)
  
  update_asap(what = ~{
    Sys.sleep(10);
    iris},to = plotiris)
  
  output$one <- renderPlot({
    req(plotiris())
    plot(plotiris())
  })
  
  output$two <- renderPlot({
    plot(airquality)
  })
  
}

shinyApp(ui, server)


L'idée est de déporter la sortie du future dans une reactiveVal, ainsi le renderPlot est resolu aussitot, puis mis a jour des que asap::update_asap s'en chargé de mettre à jour la reactiveVal.


C'est un peu tricky, mais pour l'heure nous n'avons pas trouvé d'autre solution.

L'idée serait d'avoir un 

  output$one <- renderPlot(async=TRUE,{
    Sys.sleep(15)
    plot(iris)
  })


une idée ?



