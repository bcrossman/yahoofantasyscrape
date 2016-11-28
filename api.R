library(httr)
library(XML)
library(httpuv)

#store they key in the text files, or paste them in here.
consumer.key <- readChar("key.txt",nchars=1e6)
consumer.secret <- readChar("secret.txt",nchars=1e6)

#standard authorization steps from httr
yahoo<-oauth_endpoints("yahoo")
myapp <- oauth_app("yahoo_app", key = consumer.key, secret = consumer.secret)
token <- oauth1.0_token(yahoo, myapp,cache=F)

#this is specific to the game and league you want to pull from
game<-"mlb"  #last years Fantasy Baseball
leagueID <- "62586"  #my personal league

#getting transactions although the process works well for digging into most collections
response<-GET(paste("http://fantasysports.yahooapis.com/fantasy/v2/league/",game,".l.",leagueID,"/transactions",sep=""), config(token = token))
doc<-htmlParse(response)
root<-xmlRoot(doc)
xmlSize(root)
xmlSApply(root, xmlName)
xmlSApply(root, xmlSize)
body = xmlChildren(root)$body
xmlSize(body)
xmlSApply(body, xmlName)
xmlSApply(body, xmlSize)
fc = xmlChildren(body)$fantasy_content
xmlSize(fc)
xmlSApply(fc, xmlName)
xmlSApply(fc, xmlSize)
league = xmlChildren(fc)$league
xmlSize(league)
xmlSApply(league, xmlName)
xmlSApply(league, xmlSize)
tran = xmlChildren(league)$transactions
xmlSize(tran)
xmlSApply(tran, xmlName)
xmlSApply(tran, xmlSize)
library(plyr)
tran.df<-ldply(xmlToList(tran), data.frame)
View(tran.df)

#Pull all player rosters
rosters<-list()
for(i in 1:10){
  url<-paste("http://fantasysports.yahooapis.com/fantasy/v2/team/",game,".l.",leagueID,".t.",sep="")
  iurl<-paste(url,i,"/roster/players",sep="")
  response<-GET(iurl, config(token = token))
  doc<-htmlParse(response)
  root<-xmlRoot(doc)
  body = xmlChildren(root)$body
  fc = xmlChildren(body)$fantasy_content
  team = xmlChildren(fc)$team
  roster = xmlChildren(team)$roster
  players = xmlChildren(roster)$players
  players.df<-ldply(xmlToList(players), data.frame)
  players.df$team_name<-xmlValue(xmlChildren(team)$name)
  players.df2<-players.df[,c("name.ascii_first","name.ascii_last","team_name")]
  rosters[[i]]<-players.df2}

rosters.df<-do.call(rbind,rosters)
write.csv(rosters.df,"rosters.csv")
