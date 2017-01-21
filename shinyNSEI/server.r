library(shiny)
library(dplyr)

function(input, output) {

	get.buy.table <- function(entry.size,contract.size,price.start,stop.factor){

		slider <- entry.size * contract.size	
		buy.table <- data.frame()
		tab.line <- cbind(0,0,price.start+1,0)
		while (stop.factor - (tab.line[4] + tab.line[3] * tab.line[2]) >= 0 & tab.line[3] >= 0) {
			tab.line[1] <- tab.line[1] + 1
			tab.line[2] <- tab.line[2] + slider
			tab.line[3] <- tab.line[3] - 1
			tab.line[4] <- tab.line[4] + tab.line[3] * tab.line[2]
			res <- as.data.frame(tab.line) %>% setNames(c("Tranche","Quantity","Price","BuyCost"))
			buy.table <- rbind(buy.table, res)
		}
		return(buy.table)
	}


	output$BuyTable <- 
		renderDataTable(
			get.buy.table(
				input$trade.entry.size,
				input$contract.size,
				input$trade.entry.price,
				input$avail.capital
			),
		options = list(#lengthMenu = c(-1), 
			pageLength = 100))

}