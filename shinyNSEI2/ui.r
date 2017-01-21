library(shiny)
library(ggplot2)  # for the diamonds dataset

# 1	Available Capital	Range - 100000 to 10000000
# 2	Capital at Risk	% - of (1)
# 3	Contract Size	Natural Numbers - 1 onwards.. But no 0
# 4	Recent High 	Number with 2 decimals
# 5	Expected Rise from the Low	% 
# 6	Trade Entry Price	Number with 2 decimals
# 7	Trade Entry Size	Natural Numbers - 1 onwards.. But no 0
# 8	Expected Pullback Points	Number with 2 decimals - The program has to accept either Points or Percentage
# 9	Expected Pullback Percentage	Number with 2 decimals - The program has to accept either Points or Percentage
# 9	Scaling in Price Differential	Number with 2 decimals

fluidPage(
  title = 'Position sizing calculator',
  sidebarLayout(
    sidebarPanel(
    
# 1	Available Capital	Range - 100000 to 10000000
	sliderInput("avail.capital", label = h3("Available Capital: "), min = 100000, 
        max = 1000000, value = 100000),	
# 	selectInput(inputId = "avail_capital",
# 	  label = "Available Capital:",
# 	  choices = c(100000, 200000, 300000, 400000, 500000, 600000, 70000, 800000, 900000, 1000000),
# 	  selected = 100000),

# 2	Capital at Risk	% - of (1)
	sliderInput("capital.at.risk", label = h3("Capital at Risk	%: "), min = 0, 
        max = 100, value = 10),	
# 3	Contract Size	Natural Numbers - 1 onwards.. But no 0
    numericInput("contract.size", label = h3("Contract Size: "), value = 10),
# 4	Recent High 	Number with 2 decimals
    numericInput("recent.high", label = h3("Recent High: "), value = 4500),
# 5	Expected Rise from the Low	% 
	sliderInput("expected.rise.from.low", label = h3("Expected Rise from the Low %: "), min = 0, 
        max = 100, value = 10),	
# 6	Trade Entry Price	Number with 2 decimals
    numericInput("trade.entry.price", label = h3("Trade Entry Price: "), value = 10),
# 7	Trade Entry Size	Natural Numbers - 1 onwards.. But no 0
    numericInput("trade.entry.size", label = h3("Trade Entry Size: "), value = 10),
# 8	Expected Pullback Points	Number with 2 decimals - The program has to accept either Points or Percentage
    numericInput("expected.pullback.pts", label = h3("Expected Pullback Points: "), value = 10),
# 9	Expected Pullback Percentage	Number with 2 decimals - The program has to accept either Points or Percentage
	sliderInput("expected.pullback.percent", label = h3("Expected Pullback Percentage %: "), min = 0, 
        max = 100, value = 10),	
# 9	Scaling in Price Differential	Number with 2 decimals
    numericInput("scalingin.price.diff", label = h3("Scaling in Price Differential: "), value = 10),
	
# 	checkboxInput(inputId = "individual_obs",
# 	  label = strong("Show individual observations"),
# 	  value = FALSE),
# 
# 	checkboxInput(inputId = "density",
# 	  label = strong("Show density estimate"),
# 	  value = FALSE),
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

# shinyUI(bootstrapPage(
# 
#   selectInput(inputId = "n_breaks",
#       label = "Number of bins in histogram (approximate):",
#       choices = c(10, 20, 35, 50),
#       selected = 20),
# 
#   checkboxInput(inputId = "individual_obs",
#       label = strong("Show individual observations"),
#       value = FALSE),
# 
#   checkboxInput(inputId = "density",
#       label = strong("Show density estimate"),
#       value = FALSE),
# 
#   plotOutput(outputId = "main_plot", height = "300px"),
# 
#   # Display this only if the density is shown
#   conditionalPanel(condition = "input.density == true",
#     sliderInput(inputId = "bw_adjust",
#         label = "Bandwidth adjustment:",
#         min = 0.2, max = 2, value = 1, step = 0.2)
#   )
# 
# ))

