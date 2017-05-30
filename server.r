library(shiny)
library(bubbles)
library(dplyr)
library(shinySignals)

function(input, output) {
  
  urlfile<-'http://raw.githubusercontent.com/pburgoine/FPL_data/master/FPLdata1617.csv'
  dsin<-read.csv(urlfile)
  dsin$Color<-as.character(dsin$Color)
  
  keepCols <- reactive({c("Player","Team","Color",paste("GW",input$gameWeek,sep=""),paste("CAP",input$gameWeek,sep=""),paste("PLAY",input$gameWeek,sep=""))})

  
  dataset <- reactive({subset(dsin, !is.na(dsin[,5+input$gameWeek]),select=keepCols())})
  
  output$bubbles <- renderBubbles({

    
    bubbles(dataset()[,4],key=dataset()$Player,label=dataset()$Player,color=dataset()$Color,tooltip=paste(paste(dataset()[,4],"Points"),dataset()[,6],dataset()[,5],sep='\n'))
  })
  
}