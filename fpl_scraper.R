
#install.packages("rvest")
library(rvest)





###############################################

#Function to scrape site
fplscraper <- function(gameweek){
  url_week = paste("http://fantasy.premierleague.com/a/team/1537030/event/", gameweek, sep="")
  
  # render HTML from the site with phantomjs
 repeat{ 
  writeLines(sprintf("var page = require('webpage').create();
                     page.open('%s', function () {
                     console.log(page.content); //page source
                     phantom.exit();
                     });", url_week), con="scrape.js")

  system("phantomjs scrape.js > scrape.html")
  
  # extract the content you need
  html_week = read_html("scrape.html")
  
  # check extract worked properly
  if(length(html_week %>% html_nodes("#ismr-pos1") %>% html_nodes(".ism-element__name") %>% html_text()>0)) break
  print("Extract failed...retrying")
}
  
  print("Record extracted")
  return(html_week)
  
}

###################################################################

#Function to search extract data from specific gameweek
calc_points <- function(fpl_data){
  
  players = c(1:15)
  Players_Names = c()
  Players_Points = c()
  Players_Team = c()
  Players_Captain = c()
  Players_Played = c()
  
  for (player in players){
  
  player_pos <- paste("#ismr-pos", player,sep="")
  player_name <- as.character(fpl_data %>% html_nodes(player_pos) %>% html_nodes(".ism-element__name") %>% html_text())
  player_data <- as.numeric(fpl_data %>% html_nodes(player_pos) %>% html_nodes(".ism-element__data") %>% html_text())
  player_shirt <- fpl_data %>% html_nodes(player_pos) %>% html_nodes(".ism-element__shirt")
  player_team <- as.character(html_attr(player_shirt, "title"))
  player_cap = fpl_data %>% html_nodes(player_pos) %>% html_nodes(".ism-element__control--captain") %>% html_nodes(".ism-element__icon")
  player_captain = as.character(html_attr(player_cap, "title"))
  if (length(player_captain)==0){player_captain = NA}
  player_played = "Blank"
  if (player<12) {player_played <- "Played"} else {player_played <- "Benched"}
  
  Players_Names = c(Players_Names,player_name)
  Players_Points = c(Players_Points,player_data)
  Players_Team = c(Players_Team,player_team)
  Players_Captain = c(Players_Captain,player_captain)
  Players_Played = c(Players_Played,player_played)
  
  }
  
  df <- list(Players_Names,Players_Points,Players_Team,Players_Captain,Players_Played)
  return(df)
}


###################################################################


#Function to bind all our gameweeks into one final data set

data_merge <- function(fpl_data){
  
  all_players = c()
  for (gw in c(1:38)) {
    all_players = c(all_players, paste(all_gw[[gw]][[1]],all_gw[[gw]][[3]],sep=";"))
  }
  
  unique_players = unique(all_players)
  result = matrix(NA,nrow = length(unique_players), ncol = 116)  
  
  
  unique_names = strsplit(unique_players,';',fixed=TRUE)
  
  split_names = gsub(";.*", "", unique_players)
  split_teams = gsub(".*;", "", unique_players)
  

  final_data = data.frame(result)
  
  names(final_data) <- c("Player", "Team", paste0("GW", 1:38),paste0("CAP", 1:38),paste0("PLAY", 1:38))
  final_data$Player <- split_names
  final_data$Team <- split_teams
  
  for(ngw in c(1:38)){
    
    match_indexes = match(all_gw[[ngw]][[1]],split_names)
    
    for (matches in c(1:15)){
      final_data[[2+ngw]][match_indexes[matches]] = all_gw[[ngw]][[2]][matches]
      final_data[[40+ngw]][match_indexes[matches]] = all_gw[[ngw]][[4]][matches]
      final_data[[78+ngw]][match_indexes[matches]] = all_gw[[ngw]][[5]][matches]
    }
    
    
  }
  


  return(final_data)
  #return(match_indexes)
}

 
 
###################################################################

#Call our functions
gameweeks <- c(1:38)
gameweek_data<- lapply(gameweeks,fplscraper)
all_gw<-lapply(gameweek_data,calc_points)
final_dataset<-data_merge(all_gw)


#Save to csv
write.csv(final_dataset, file = "FPLdata1617.csv",fileEncoding = "UTF-8")