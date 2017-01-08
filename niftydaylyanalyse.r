res.sandeep <- read.csv('/Users/RvsL/Google Диск/2 - рабочее/17 - R/niftydayly20170106.csv', header=T, stringsAsFactors=F, sep = ";")
res.sandeep$date <- strptime(res.sandeep$Date, "%d.%m.%Y")
res.sandeep$date <- as.POSIXct(res.sandeep$date)
res.sandeep <- res.sandeep %>% select(date,Open,High,Low,Close) %>% setNames(c("date","Open","High","Low","Close"))%>% mutate(Open = as.numeric(Open),High = as.numeric(High),Low = as.numeric(Low),Close = as.numeric(Close))
res.sandeep <- res.sandeep %>% mutate(diff = High - Low)

res.join <- res %>% select(day, range.min, range.max, start.val, end.val)

res.join <- merge(res.join, res.sandeep, by.x = day, by.y = date)