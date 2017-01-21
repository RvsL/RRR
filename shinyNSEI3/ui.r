fluidPage(
  title = 'Position sizing calculator',
  sidebarLayout(
    sidebarPanel(

	  br(),
	  fluidRow(
		column(4,
		# 1	Available Capital	Range - 100000 to 10000000
			sliderInput("avail.capital", label = h4("Available Capital: "), min = 100000, 
				max = 1000000, value = 100000, step = 1000, round = 0)	
		),
		column(4,
		# 3	Contract Size	Natural Numbers - 1 onwards.. But no 0
			numericInput("contract.size", label = h4("Contract Size: "), value = 10)
		),
		column(4,
		# 7	Trade Entry Size	Natural Numbers - 1 onwards.. But no 0
			numericInput("trade.entry.size", label = h4("Trade Entry Size: "), value = 10)
		)
	  ),
	  fluidRow(
		column(4,
# 		  hr(),
# 		  verbatimTextOutput('out1'),
		# 2	Capital at Risk	% - of (1)
			sliderInput("capital.at.risk", label = h4("Capital at Risk	%: "), min = 0, 
				max = 100, value = 10)	
		),
		column(4,
# 		  hr(),
# 		  verbatimTextOutput('out2'),
		# 4	Recent High 	Number with 2 decimals
			numericInput("recent.high", label = h4("Recent High: "), value = 4500)
		),
		column(4,
# 		  hr(),
# 		  verbatimTextOutput('out3'),
		# 8	Expected Pullback Points	Number with 2 decimals - The program has to accept either Points or Percentage
			numericInput("expected.pullback.pts", label = h4("Expected Pullback Points: "), value = 10)
		)
	  ),
	  fluidRow(
		column(4,
# 		  hr(),
# 		  verbatimTextOutput('out4'),
		# 5	Expected Rise from the Low	% 
			sliderInput("expected.rise.from.low", label = h4("Expected Rise from the Low %: "), min = 0, 
				max = 100, value = 10)
		),
		column(4,
# 		  hr(),
# 		  verbatimTextOutput('out5'),
		# 6	Trade Entry Price	Number with 2 decimals
			numericInput("trade.entry.price", label = h4("Trade Entry Price: "), value = 10)
		),
		column(4,
# 		  hr(),
# 		  verbatimTextOutput('out6'),
		# 8	Expected Pullback Points	Number with 2 decimals - The program has to accept either Points or Percentage
			numericInput("expected.pullback.pts", label = h4("Expected Pullback Points: "), value = 10)
		)
	  ),
	  fluidRow(
		column(4,
# 		  hr(),
# 		  verbatimTextOutput('out4'),
		# 9	Expected Pullback Percentage	Number with 2 decimals - The program has to accept either Points or Percentage
			sliderInput("expected.pullback.percent", label = h4("Expected Pullback Percentage %: "), min = 0, 
				max = 100, value = 10)
		),
		column(4,
# 		  hr(),
# 		  verbatimTextOutput('out5'),
		# 9	Scaling in Price Differential	Number with 2 decimals
			numericInput("scalingin.price.diff", label = h4("Scaling in Price Differential: "), value = 10)
		),
		column(4,
# 		  hr(),
# 		  verbatimTextOutput('out5'),
		# 9	Scaling in Price Differential	Number with 2 decimals
			numericInput("scalingout.price.diff", label = h4("Scaling out Price Differential: "), value = 10)
		)
	  ),
	  fluidRow(
		column(4,
		# 1	Available Capital	Range - 100000 to 10000000
			sliderInput("avail.capital", label = h4("Slippage / Brokerage Factor: "), min = 0, 
				max = 100, value = 50, step = 1, round = 0)	
		)
	  ),


# 	fluidRow(
# 		column(5,
# 		# 1	Available Capital	Range - 100000 to 10000000
# 			sliderInput("avail.capital", label = h4("Available Capital: "), min = 100000, 
# 				max = 1000000, value = 100000, step = 1000, round = 0),	
# 		# 2	Capital at Risk	% - of (1)
# 			sliderInput("capital.at.risk", label = h4("Capital at Risk	%: "), min = 0, 
# 				max = 100, value = 10),	
# 		# 5	Expected Rise from the Low	% 
# 			sliderInput("expected.rise.from.low", label = h4("Expected Rise from the Low %: "), min = 0, 
# 				max = 100, value = 10),	
# 		# 9	Expected Pullback Percentage	Number with 2 decimals - The program has to accept either Points or Percentage
# 			sliderInput("expected.pullback.percent", label = h4("Expected Pullback Percentage %: "), min = 0, 
# 				max = 100, value = 10)	
# 		),
# 		column(4, offset = 1,
# 		# 3	Contract Size	Natural Numbers - 1 onwards.. But no 0
# 			numericInput("contract.size", label = h4("Contract Size: "), value = 10),
# 		# 4	Recent High 	Number with 2 decimals
# 			numericInput("recent.high", label = h4("Recent High: "), value = 4500),
# 		# 6	Trade Entry Price	Number with 2 decimals
# 			numericInput("trade.entry.price", label = h4("Trade Entry Price: "), value = 10)
# 		),
# 		column(5,
# 		# 7	Trade Entry Size	Natural Numbers - 1 onwards.. But no 0
# 			numericInput("trade.entry.size", label = h4("Trade Entry Size: "), value = 10),
# 		# 8	Expected Pullback Points	Number with 2 decimals - The program has to accept either Points or Percentage
# 			numericInput("expected.pullback.pts", label = h4("Expected Pullback Points: "), value = 10),
# 		# 9	Scaling in Price Differential	Number with 2 decimals
# 			numericInput("scalingin.price.diff", label = h4("Scaling in Price Differential: "), value = 10)
# 		)
# 	  ),
    

	  conditionalPanel(
		'input.dataset === "mtcars"',
		helpText('Click the column header to sort a column.')
	  )
    ),
    mainPanel(
      tabsetPanel(
        id = 'dataset',
        tabPanel('first table', DT::dataTableOutput('mytable1')),
        tabPanel('second table', DT::dataTableOutput('mytable2')),
        tabPanel('third table', DT::dataTableOutput('mytable3'))
      )
    )
    
  )
)

