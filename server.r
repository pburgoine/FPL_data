library(shiny)
library(bubbles)
library(dplyr)
library(shinySignals)

function(input, output) {
  
  urlfile<-'http://raw.githubusercontent.com/pburgoine/FPL_data/master/FPLdata1617.csv'
  dsin<-read.csv(urlfile)
  dsin$Color<-as.character(dsin$Color)
  
  keepCols <- reactive({c("Player","Team","Color","Text_Color",paste("GW",input$gameWeek,sep=""),paste("CAP",input$gameWeek,sep=""),paste("PLAY",input$gameWeek,sep=""))})

  
  dataset <- reactive({subset(dsin, !is.na(dsin[,5+input$gameWeek]) & dsin[,5+input$gameWeek]>=0 & (input$includeBench=="Include" | dsin[,81+input$gameWeek]=="Played") ,select=keepCols())})
  
  output$bubbles <- renderBubbles({

    
    bubbles(dataset()[,5],key=dataset()$Player,label=dataset()$Player,color=dataset()$Color, textColor = dataset()$Text_Color,tooltip=paste(paste(dataset()[,5],"Points"),dataset()[,7],dataset()[,6],sep='\n'))
  })
  
  output$mean<-renderText({
    
    paste("Gameweek Points:", sum(dataset()[,5]) - ifelse(input$gameWeek==8 | input$gameWeek==14,2,0), "(", input$includeBench, "bench )")
    
  })
  
  output$smalltext<-renderText({
    
    if(input$gameWeek==8) {"Aguero scored -2 this gameweek"} else if (input$gameWeek==14){"Aguero scored -2 & Amat scored -1 this gameweek"} else {" "}
    
  })
  
}