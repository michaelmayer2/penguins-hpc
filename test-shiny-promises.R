library(promises)
library(future)
#library(future.batchtools)
library(shiny)

options(shiny.deepstacktrace = FALSE)

future::plan(multicore)

msg <- function(...) {
  message(Sys.getpid(), ": ", ...)
}

single_promise <- function(item) {
  promises::future_promise({
    # Do work in a `future` worker
    msg("Starting promise: ", item)
    Sys.sleep(2)
    msg("Finished promise: ", item)
    item
  },globals=list(item=item,msg=msg),
  packages=c("base"),
  lazy = TRUE,
  earlySignal=FALSE) %...>% {
    # Do something with the result in the main worker
    # such as update the progress bar
    result <- .
    msg("Update progress bar for item: ", item, ". Received result: ", result)
    result
  }
  msg("Created promise: ", item)
}

create_promises <- function(count) {
  for (item in seq_len(count)) {
    prom<-promises::future_promise({
      # Do work in a `future` worker
      msg("Starting promise: ", item)
      Sys.sleep(2)
      msg("Finished promise: ", item)
      item
    },globals=list(item=item,msg=msg),
    packages=c("base"),
    lazy = TRUE,
    earlySignal=FALSE) %...>% {
      # Do something with the result in the main worker
      # such as update the progress bar
      result <- .
      msg("Update progress bar for item: ", item, ". Received result: ", result)
      result
      incProgress(1)
    }
    msg("Created promise: ", item)
    prom
    incProgress(1)
  }
}

ui <- fluidPage(
  plotOutput("plot")
)

server <- function(input, output, session) {
  output$plot <- renderPlot({
    n <- 4
    withProgress(message = "Creating promises...", max = n, {
      create_promises(n)
    })
    plot(cars)
  })
}

shinyApp(ui, server)
