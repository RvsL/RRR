fluidPage(
  title = 'Position sizing calculator',
  sidebarLayout(
    sidebarPanel(

	  br(),
	  fluidRow(
		column(12,
		# 1	Available Capital	Range - 100000 to 10000000
			sliderInput("avail.capital", label = h4("Available Capital: "), min = 100000, 
				max = 10000000, value = 100000, step = 5000, round = 0)	
		)
	  ),
	  fluidRow(
		column(4,
		# 2	Capital at Risk	% - of (1)
			sliderInput("capital.at.risk", label = h4("Capital at Risk	%: "), min = 0, 
				max = 100, value = 10)	
		),
		column(4,
		# 4	Recent High 	Number with 2 decimals
			numericInput("recent.high", label = h4("Recent High: "), value = 4500, min = 1, max = NA, step = 0.01)
		),
		column(4,
		# 8	Expected Pullback Points	Number with 2 decimals - The program has to accept either Points or Percentage
			numericInput("expected.pullback.pts", label = h4("Expected Pullback Points: "), value = 10)
		)
	  ),
	  fluidRow(
		column(4,
#  		  verbatimTextOutput('out4'),
		# 5	Expected Rise from the Low	% 
			sliderInput("expected.rise.from.low", label = h5("Expected Rise from the Low %: "), min = 0, 
				max = 100, value = 10)
		),
		column(4,
		# 6	Trade Entry Price	Number with 2 decimals
			numericInput("trade.entry.price", label = h4("Trade Entry Price: "), value = 10)
		),
		column(4,
		# 8	Expected Pullback Points	Number with 2 decimals - The program has to accept either Points or Percentage
			numericInput("expected.pullback.pts", label = h4("Expected Pullback Points: "), value = 10)
		)
	  ),
	  fluidRow(
		column(4,
		# 9	Expected Pullback Percentage	Number with 2 decimals - The program has to accept either Points or Percentage
			sliderInput("expected.pullback.percent", label = h5("Expected Pullback Percentage %:"), min = 0, 
				max = 100, value = 10)
		),
		column(4,
		# 9	Scaling in Price Differential	Number with 2 decimals
			numericInput("scalingin.price.diff", label = h4("Scaling in Price Differential: "), value = 10)
		),
		column(4,
		# 11	Scaling out Price Differential	Number with 2 decimals
			numericInput("scalingout.price.diff", label = h4("Scaling out Price Differential: "), value = 10)
		)
	  ),
	  fluidRow(
		column(4,
		# 13	Slippage / Brokerage Factor	% to be applied to final output of Profits/Breakeven. Meaning this has to be reduced from the Net Profit.
			sliderInput("slippage.factor", label = h4("Slippage / Brokerage Factor: "), min = 0, 
				max = 100, value = 50, step = 1, round = 0)	
		),
		column(4,
		# 3	Contract Size	Natural Numbers - 1 onwards.. But no 0
			numericInput("contract.size", label = h4("Contract Size: "), value = 10, min = 1, max = NA, step = 1)
		),
		column(4,
		# 7	Trade Entry Size	Natural Numbers - 1 onwards.. But no 0
			numericInput("trade.entry.size", label = h4("Trade Entry Size: "), value = 10, min = 1, max = NA, step = 1)
		)
	  )
    ),
    mainPanel(
      tabsetPanel(
        id = 'dataset',
         tabPanel('first table', DT::dataTableOutput('mytable1'))
#         tabPanel('second table', DT::dataTableOutput('mytable2')),
#         tabPanel('third table', DT::dataTableOutput('mytable3'))
      )
    )
    
  )
)

