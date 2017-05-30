library(shiny)
library(bubbles)
library(dplyr)
library(shinySignals)
#dataset <- diamonds

fluidPage(
  
  tags$head(includeScript("google-analytics.js")),
  titlePanel("My FPL Data 2016/17"),
  
  sidebarPanel(
    
    sliderInput('gameWeek', 'Gameweek', min=1, max=38,
                value=1, step=1, round=0),
    selectInput('includeBench', 'Bench', c("Include","Exclude"))
  ),
  
  mainPanel(
    bubblesOutput("bubbles", width = "100%"),
    verbatimTextOutput('mean'),
    verbatimTextOutput('smalltext')
  )
)
