library(shiny)
# library(ggplot2)

function(input, output) {

	get.buy.table <- function(entry.size,contract.size,price.start,stop.factor){
	
	  slider <- entry.size * contract.size	
	  buy.table <- data.frame()
	  tab.line <- cbind(0,0,price.start,0)
	  while (stop.factor - tab.line[4] >= 0 & tab.line[4] >= 0) {
	  tab.line[1] <- tab.line[1] + 1
	  tab.line[2] <- tab.line[2] + slider
	  tab.line[3] <- tab.line[3] - 1
	  tab.line[4] <- tab.line[4] + tab.line[3] * tab.line[2]
	  res <- as.data.frame(tab.line) %>% setNames(c("Tranche","Quantity","Price","BuyCost"))
	  buy.table <- rbind(buy.table, res)
	  }
	  return(buy.table)
	}

  #buy.table <- reactive({get.buy.table(input$trade.entry.size,input$contract.size,input$trade.entry.price,input$avaliable.capital)})
#   entry.size 	<- reactive({input$trade.entry.size})
#   contract.size <- reactive({input$contract.size})
#   price.start 	<- reactive({input$trade.entry.price})
#   stop.factor 	<- reactive({input$avaliable.capital})

#   entry.size 	<- as.numeric(input$trade.entry.size)
#   contract.size <- as.numeric(input$contract.size)
#   price.start 	<- as.numeric(input$trade.entry.price)
#   stop.factor 	<- as.numeric(input$avaliable.capital)

#   entry.size 	<- reactive({as.numeric(input$trade.entry.size)})
#   contract.size <- reactive({as.numeric(input$contract.size)})
#   price.start 	<- reactive({as.numeric(input$trade.entry.price)})
#   stop.factor 	<- reactive({as.numeric(input$avaliable.capital)})
# 
#   buy.table <- get.buy.table(entry.size,contract.size,price.start,stop.factor)
  


  v1 <- rnorm(25)
  v2 <- rnorm(25)
  v3 <- rnorm(25)
  v4 <- rnorm(25)
  df2 <- cbind.data.frame(v1, v2, v3, v4)
  df1 <- df2

  names(df2) <- c("Tranche","Quantity","Price","BuyCost")
#   names(df3) <- c("tranche","qty","price","buy cost")

	output$mytable1 <- renderTable({

		entry.size 		<- input$trade.entry.size
		contract.size 	<- input$contract.size
		price.start 	<- input$trade.entry.price
		stop.factor 	<- input$avail.capital

# 		print(entry.size)
# 		print(contract.size)
# 		print(price.start)
# 		print(stop.factor)

		slider <- entry.size * contract.size	
		buy.table <- data.frame()
		tab.line <- cbind(0,0,price.start,0)
		while (stop.factor - tab.line[4] >= 0 & tab.line[3] >= 0) {
		tab.line[1] <- tab.line[1] + 1
		tab.line[2] <- tab.line[2] + slider
		tab.line[3] <- tab.line[3] - 1
		tab.line[4] <- tab.line[4] + tab.line[3] * tab.line[2]
		res <- as.data.frame(tab.line) %>% setNames(c("Tranche","Quantity","Price","BuyCost"))
		buy.table <- rbind(buy.table, res)
		}
		
# 		buy.table <- get.buy.table(input$trade.entry.size,input$contract.size,input$trade.entry.price,input$avail.capital)
# 		print(buy.table)
		DT::datatable(buy.table)

	})
 
#   output$mytable1 <- DT::renderDataTable({
#     #DT::datatable(df1, options = list(orderClasses = TRUE))
#     DT::datatable(df1)
#   })


}