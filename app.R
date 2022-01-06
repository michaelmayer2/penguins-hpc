#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

plot_it <- function(res,bins) {
  library(cowplot)
  library(ggplot2)
  
  intercept <- ggplot(as.data.frame(res), aes(x=`(Intercept)`)) + geom_histogram(bins=bins)
  
  xind <- ggplot(as.data.frame(res), aes(x=`x[ind, 1]`)) + geom_histogram(bins=bins)
  
  plot_grid(intercept,xind, labels = "AUTO")
}

compute <- function(trials) {
  # Setting options for clustermq (can also be done in .Rprofile)
  options(
    clustermq.scheduler = "slurm",
    clustermq.template = "slurm.tmpl" # if using your own template
  )
  
  # Loading libraries
  library(clustermq)
  library(foreach)
  library(palmerpenguins)
  
  # Register parallel backend to foreach
  register_dopar_cmq(n_jobs=2, memory=1024, log_worker=TRUE, chunk_size=trials/10)
  
  # Our dataset 
  x<-penguins[c(4,1)]
  
  # Number of trials to simulate
  trials <- trials
  
  # Main loop
  foreach(i=1:trials,.combine=rbind) %dopar% {
    ind <- sample(344, 344, replace=TRUE)
    result1 <- glm(x[ind,2]~x[ind,1], family=binomial(logit))
    coefficients(result1)
  }
}

library(shiny)

# logify from https://stackoverflow.com/questions/30502870/shiny-slider-on-logarithmic-scale
# logifySlider javascript function
JS.logify <-
  "
// function to logify a sliderInput
function logifySlider (sliderId, sci = false) {
  if (sci) {
    // scientific style
    $('#'+sliderId).data('ionRangeSlider').update({
      'prettify': function (num) { return ('10<sup>'+num+'</sup>'); }
    })
  } else {
    // regular number style
    $('#'+sliderId).data('ionRangeSlider').update({
      'prettify': function (num) { return (Math.pow(10, num)); }
    })
  }
}"

# call logifySlider for each relevant sliderInput
JS.onload <-
  "
// execute upon document loading
$(document).ready(function() {
  // wait a few ms to allow other scripts to execute
  setTimeout(function() {
    // include call for each slider
    logifySlider('trials', sci = false)
  }, 5)})
"

# Define UI for application that draws a histogram
ui <- fluidPage(
    tags$head(tags$script(HTML(JS.logify))),
    tags$head(tags$script(HTML(JS.onload))),
    
    # Application title
    titlePanel("Penguins"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
      sidebarPanel(
      
            sliderInput("trials",
                        "Number of Trials:",
                        min = 2,
                        max = 6,
                        value = 2, 
                        step=0.5
                        ),
            sliderInput("bins",
                        "Number of bins:",
                        min = 10,
                        max = 200,
                        value = 50)
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("distPlot")
        )
    )
)



# Define server logic required to draw a histogram
server <- function(input, output) {
  
    output$distPlot <- renderPlot({
      isolate(observeEvent(input$trials, {
        cat("Running", 10^input$trials, "trials\n")
        res <- compute(10^input$trials)
        plot_it(res,input$bins)
      }))
      isolate(observeEvent(input$bins, {
        cat("Running", input$bins, "bins\n")
        plot_it(res,input$bins)
      }))
      
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
