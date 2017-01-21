get.buy.table <- function(entry.size,contract.size,price.start,stop.factor){
slider <- entry.size * contract.size	
buy.table <- data.frame()
tab.line <- cbind(0,0,price.start,0)
while (stop.factor - tab.line[4] >= 0 & tab.line[3] >= 0) {print(tab.line[3])
tab.line[1] <- tab.line[1] + 1
tab.line[2] <- tab.line[2] + slider
tab.line[3] <- tab.line[3] - 1
tab.line[4] <- tab.line[4] + tab.line[3] * tab.line[2]
res <- as.data.frame(tab.line) %>% setNames(c("Tranche","Quantity","Price","BuyCost"))
buy.table <- rbind(buy.table, res)
}
return(buy.table)
}

