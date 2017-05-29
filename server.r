library(shiny)
library(ggplot2)
library(bubbles)
library(packcircles)

function(input, output) {
  
  urlfile<-'http://raw.githubusercontent.com/pburgoine/FPL_data/master/FPLdata1617.csv'
  dsin<-read.csv(urlfile)
  
  keepCols <- reactive({c("Player","Team","Color",paste("GW",input$gameWeek,sep=""),paste("CAP",input$gameWeek,sep=""),paste("PLAY",input$gameWeek,sep=""))})

  
  dataset <- reactive({subset(dsin,select=keepCols())})
  
  output$plot <- renderPlot({
    
    #p <- ggplot(dataset(), aes_string(x=dataset()$Player, y=dataset()[,3])) + geom_jitter()
    #p <- bubbles(value = dataset()[,3], label = dataset()$Player)
    # install.packages("packcircles")
    
    p <- circleProgressiveLayout(dataset()[,4])
    d <- circleLayoutVertices(p)
    
    h<-ggplot(d, aes(x, y)) + 
      geom_polygon(aes(group = id, fill = id), show.legend = FALSE) +
      geom_text(data = p, aes(x, y), label = paste(dataset()$Player,dataset()[,4],"points",sep=" ")) +
      scale_fill_distiller(palette = "Blues") +
      theme_void()
    print(h)
    
  }, height=700)
  
}