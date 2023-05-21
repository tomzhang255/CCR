library(shiny)
library(shinydashboard)
library(rhandsontable)
library(shinyjs)

source("ccr.R", local = TRUE)
source("helpers.R", local = TRUE)


ui <- dashboardPage(
  dashboardHeader(title = "CCR"),
  dashboardSidebar(
    useShinyjs(),
    br(),
    fileInput("d_file", label = "User Data File", accept = c("csv", "xls", "xlsx")),
    uiOutput("d_col_ui"),
    hr(),
    fileInput("q_file", label = "Questionnaire File", accept = c("csv", "xls", "xlsx")),
    uiOutput("q_col_ui"),
    hr(),
    actionButton("calc", label = "Calculate",
                 width = "87%", class = "btn-success", style = "color: white; border-color: white"),
    actionButton("download", label = "Download Result",
                 width = "87%", class = "btn-warning", style = "color: white; border-color: white"),
    conditionalPanel("false", downloadButton("download_hidden"))  # always hidden
  ),
  dashboardBody(
    fluidRow(
      box(title = "User Data Preview", rHandsontableOutput("d_preview")),
      box(title = "Questionnaire Preview", rHandsontableOutput("q_preview"))
    ),
    br(),
    fluidRow(
      box(title = "Result", rHandsontableOutput("result_hot"), width = 10),
      box(numericInput("res_rows", label = "Display rows", value = 5, min = 1, step = 1), width = 2)),
    fluidRow(box(title = "Console", verbatimTextOutput("console"),
                 tags$head(tags$style("#console{overflow-y:scroll; max-height: 150px;}")),
                 width = 12, height = 213))
  ),
  skin = "yellow",
)

server <- function(input, output) {
  values <- reactiveValues()

  output$d_col_ui <- renderUI({
    render_select_col_ui(input$d_file, "d_col", "User Data Column", values, "d_data")
  })

  output$q_col_ui <- renderUI({
    render_select_col_ui(input$q_file, "q_col", "Questionnaire Column", values, "q_data")
  })

  output$d_preview <- renderRHandsontable({
    render_hot(head(values$d_data, 10), input$d_col)
  })

  output$q_preview <- renderRHandsontable({
    render_hot(head(values$q_data, 10), input$q_col)
  })

  calc_reactive <- eventReactive(input$calc, {
    # first make sure all inputs are not null
    if (is.null(input$d_file) | is.null(input$q_file)) {
      output$console <- renderPrint("Please upload both files")
      stop()
    }

    showNotification("Calculating; please wait...", type = "message")

    tryCatch({
      console_text <- capture.output(res <- ccr_wrapper(values$d_data, input$d_file$name, input$d_col,
                                                        values$q_data, input$q_file$name, input$q_col),
                                     type = "message")
    }, error = function(e) {
      output$console <- renderPrint(e)
      stop()
    })

    output$console <- renderPrint(console_text)

    values$res <- res

    return(rhandsontable(head(res, input$res_rows), height = 150))
  })

  output$result_hot <- renderRHandsontable({
    calc_reactive()
  })

  # using an extra layer in order to check result availability before download
  observeEvent(input$download, {
    if (is.null(values$res)) {
      showNotification("No result available", type = "error")
    } else {
      runjs("$('#download_hidden')[0].click();")
    }
  })

  output$download_hidden <- downloadHandler(
    filename = function() { "ccr_result.csv" },
    content = function(file) {
      write_csv(values$res, file)
    }
  )
}

shinyApp(ui, server)
