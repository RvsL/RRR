library(maps)
library(leaflet)
library(rjson)
                    
freegeoip <- function(ip, format = ifelse(length(ip)==1,'list','dataframe'))
 {
     if (1 == length(ip))
     {
         # a single IP address
         require(rjson)
         url <- paste(c("http://freegeoip.net/json/", ip), collapse='')
         ret <- fromJSON(readLines(url, warn=FALSE))
         if (format == 'dataframe')
             ret <- data.frame(t(unlist(ret)))
         return(ret)
     } else {
         ret <- data.frame()
         for (i in 1:length(ip))
         {
             r <- freegeoip(ip[i], format="dataframe")
             ret <- rbind(ret, r)
         }
         return(ret)
     }
 }   

tr <- read.csv("/Users/RvsL/Google Диск/2 - рабочее/17 - R/traceroute.csv",header=F,stringsAsFactors=F,sep=" ")
ip <- tr %>% filter(V5 != "") %>% select(V5)
ip <- gsub("\\(|\\)","",ip$V5)
geoip <- freegeoip(ip)
                    
world <- map("world", fill = TRUE, plot = FALSE)
leaflet(data=world) %>% 
   addTiles() %>% 
   addCircleMarkers(geoip$longitude, geoip$latitude, 
                    color = '#ff0000', popup=ip)  
