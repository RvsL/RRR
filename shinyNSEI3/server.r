library(shiny)
library(ggplot2)

function(input, output) {

  v1 <- rnorm(25)
  v2 <- rnorm(25)
  v3 <- rnorm(25)
  v4 <- rnorm(25)
  df1 <- cbind.data.frame(v1, v2, v3, v4)

  v1 <- rnorm(25)
  v2 <- rnorm(25)
  v3 <- rnorm(25)
  v4 <- rnorm(25)
  df2 <- cbind.data.frame(v1, v2, v3, v4)

  v1 <- rnorm(25)
  v2 <- rnorm(25)
  v3 <- rnorm(25)
  v4 <- rnorm(25)
  df3 <- cbind.data.frame(v1, v2, v3, v4)

  names(df1) <- c("tranche","qty","price","buy cost")
  names(df2) <- c("tranche","qty","price","buy cost")
  names(df3) <- c("tranche","qty","price","buy cost")
 
  output$mytable1 <- DT::renderDataTable({
    DT::datatable(df1, options = list(orderClasses = TRUE))
  })

  output$mytable2 <- DT::renderDataTable({
    DT::datatable(df2, options = list(orderClasses = TRUE))
  })

  output$mytable3 <- DT::renderDataTable({
    DT::datatable(df3, options = list(orderClasses = TRUE))
  })

}