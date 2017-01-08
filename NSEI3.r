require(dplyr)
library(quantmod)
library(PerformanceAnalytics)
require(TTR)
dt <- read.csv("tmp.csv",header=F,stringsAsFactors=F)         

dt <- dt[-c(1,2),]
names(dt) <- c("Ticker","Date.Time","OPEN","HIGH","LOW","CLOSE","OPEN.INTEREST","VOLUME")

dt$Date <- strptime(dt$Date.Time,"%m-%d-%Y %H:%M")
dt$Date <- as.POSIXct(dt$Date)

library(lubridate)

trend.coef.before <- function(tdt, ldate)
{
t.1 <- tdt %>% filter(dt <= ldate)
if(nrow(t.1) > 0){
fit.1 <- glm(t.1$navg~t.1$dt)
return(as.numeric(coef(fit.1)[2]/abs(coef(fit.1)[2])))} else {return(0)}
}

trend.coef.after <- function(tdt, ldate)
{
t.1 <- tdt %>% filter(dt >= ldate)
if(nrow(t.1) > 0){
fit.1 <- glm(t.1$navg~t.1$dt)
return(as.numeric(coef(fit.1)[2]/abs(coef(fit.1)[2])))} else {return(0)}
}

trend.coef.between <- function(tdt, ldate1, ldate2)
{
t.1 <- tdt %>% filter(dt >= ldate1 & dt <= ldate2)
if(nrow(t.1) > 0){
fit.1 <- glm(t.1$navg~t.1$dt)
return(as.numeric(coef(fit.1)[2]/abs(coef(fit.1)[2])))} else {return(0)}
}

peak.diffs <- function(peaks,ltdt){
q.peaks <- data.frame()
for(i in 2:nrow(peaks)){
q.peaks <- rbind(q.peaks,abs(ltdt[i-1,]$navg - ltdt[i,]$navg))}
names(q.peaks) <- c("peaks")
return(q.peaks$peaks)
}
peak.pullback <- function(peaks,ltdt){
q.peaks <- data.frame()
for(i in 2:nrow(peaks)%/%2){
	row.ind <- (i-1)*2-1
q.peaks <- rbind(q.peaks,abs(ltdt[row.ind,]$navg - ltdt[row.ind + 1,]$navg))}
names(q.peaks) <- c("peaks")
return(q.peaks$peaks)
}

begdate <- min(dt$Date)
enddate <- max(dt$Date)
curdate <- floor_date(begdate,"day")
bd.enddate <- floor_date(enddate, "day")

Sys.time()

dt.examined <- dt %>% select(Date, OPEN, HIGH, LOW, CLOSE) %>% setNames(c("dt","no","nh","nl","nc")) %>% mutate(no = as.numeric(no), 
nh = as.numeric(nh), nl = as.numeric(nl), nc = as.numeric(nc), navg = (nh - nl)/2 + nl) %>% arrange(dt)


############################################################################


pb <- txtProgressBar(style = 3, min=0, max = as.numeric(diff(c(begdate, enddate))))
tstart <- Sys.time()

###################
# цикл по всем дням
n.empty <- 0
res <- data.frame()
while(curdate <= bd.enddate)
{

tdt <- dt.examined %>% filter(dt >= curdate & dt < curdate + 86400 - 1) %>% arrange(dt)

if(nrow(tdt) > 0){
# всякие переменные для одного дня

tdt.start.val <- tdt$navg[1]
tdt.end.val <- tdt$navg[length(tdt$navg)]

tdt.range <- range(tdt$navg)
tdt.sd <- sd(tdt$navg)
interday.diff <- diff(tdt$navg)
tdt.diff.range <- range(interday.diff)
tdt.move.up <- abs(max(tdt$navg) - mean(tdt$navg))
tdt.move.down <- abs(min(tdt$navg) - mean(tdt$navg))
tdt.mean <- mean(tdt$navg)
#tdt.jump.down <- abs(range(interday.diff)[1]) > tdt.sd
#tdt.jump.up <- abs(range(interday.diff)[2]) > tdt.sd

#tdt.max.jump.up <- abs(range(interday.diff)[2])
#tdt.max.jump.down <- abs(range(interday.diff)[1])

tdt.volatility <- tdt.sd/mean(tdt$navg)

######################################


fit <- glm(tdt$navg~tdt$dt)
co <- coef(fit)
tdt$lfit <- fit$fitted.values

################# 9

tdt <- tdt %>% mutate(l = (navg / lag(navg)-1))
vol <- data.frame()
nrow.tdt <- nrow(tdt)
sqrt.per <- sqrt((15.5-9.5)*60)
for(i in 2:nrow.tdt){
start.row <- (i - 1) * 5 + 1
end.row <- min(i * 5 + 1, nrow.tdt)
tmp.val <- sd(tdt[start.row:end.row,]$l)*sqrt.per
tmp <- cbind.data.frame(tdt[start.row + 2,]$dt,tmp.val) %>% setNames(c("dt","vol"))
vol <- rbind(vol, tmp)
}

sh <- vol[which.max(vol$vol),]

q.9.vol <- sh$vol
q.9.dt <- as.numeric(sh$dt - floor_date(sh$dt, "day"))

################# 9

################# 13-14

coef.sign.13.1 <- trend.coef.before(tdt, curdate + 12 * 3600)
coef.sign.13.2 <- trend.coef.after(tdt, curdate + 14 * 3600)
coef.sign.13.3 <- trend.coef.between(tdt, curdate + 12 * 3600, curdate + 14 * 3600)

q.13 <- ifelse(coef.sign.13.1 != coef.sign.13.3 & coef.sign.13.2 == coef.sign.13.3, 1, 0)
q.14 <- ifelse(coef.sign.13.1 != coef.sign.13.3 & coef.sign.13.2 != coef.sign.13.3, 1, 0)

################# 13-14

################# 15

coef.sign <- as.numeric(co[2]/abs(co[2]))

coef.sign.15.0 <- trend.coef.before(tdt, curdate + 12.5 * 3600)
coef.sign.15.1 <- trend.coef.before(tdt, curdate + 13.5 * 3600)
coef.sign.15.2 <- trend.coef.before(tdt, curdate + 14.5 * 3600)
coef.sign.15.3 <- trend.coef.before(tdt, curdate + 15.5 * 3600)

q.15.c <- ifelse(coef.sign.15.3 != coef.sign, 1, 0)
q.15.b <- ifelse(coef.sign.15.2 != coef.sign & q.15.c == 0, 1, 0)
q.15.a <- ifelse(coef.sign.15.1 != coef.sign & q.15.b == 0 & q.15.c == 0, 1, 0)
q.15.z <- ifelse(coef.sign.15.0 != coef.sign & q.15.b == 0 & q.15.c == 0 & q.15.a == 0, 1, 0)

################# 15

################# 17

coef.sign.17.0 <- trend.coef.before(tdt, curdate + 14.5 * 3600)
coef.sign.17.1 <- trend.coef.after(tdt, curdate + 15 * 3600)
coef.sign.17.2 <- trend.coef.after(tdt, curdate + 15.25 * 3600)
coef.sign.17.3 <- trend.coef.after(tdt, curdate + 15.5 * 3600)

trend.change <- coef.sign != coef.sign.17.0

q.17.a <- ifelse(trend.change & coef.sign.17.1 == coef.sign, 1, 0)
q.17.b <- ifelse(trend.change & coef.sign.17.1 == coef.sign & q.17.a == 0, 1, 0)
q.17.c <- ifelse(trend.change & coef.sign.17.1 == coef.sign & q.17.a == 0 & q.17.b == 0, 1, 0)

################# 17

################# 18,11,12

tdt <- tdt %>% mutate(updown = (navg - lfit)/abs(navg - lfit))
tdt.xts <- xts(tdt[,-1], order.by=tdt[,1])
diff.updown <- diff(tdt.xts$updown)

#11
peaks <- c(1,findPeaks(diff.updown),findValleys(diff.updown)) %>% as.data.frame%>% setNames(c("num")) %>% arrange(num)
q.11.pb.1 <- peak.pullback(peaks, tdt)
peaks <- c(findPeaks(diff.updown),findValleys(diff.updown),nrow(diff.updown)) %>% as.data.frame%>% setNames(c("num")) %>% arrange(num)
q.11.pb.2 <- peak.pullback(peaks, tdt)

peaks.q.11 <- c(findPeaks(tdt.xts$navg),findValleys(tdt.xts$navg)) %>% as.data.frame%>% setNames(c("num")) %>% arrange(num)
q.11.peaks <- peak.diffs(peaks.q.11,tdt)

#12
peaks.q12.hh <- findPeaks(tdt.xts$navg) %>% as.data.frame%>% setNames(c("num")) %>% arrange(num)
peaks.q12.ll <- findValleys(tdt.xts$navg) %>% as.data.frame%>% setNames(c("num")) %>% arrange(num)
q.12.peaks.ll <- peak.diffs(peaks.q12.ll,tdt)
q.12.peaks.hh <- peak.diffs(peaks.q12.hh,tdt)

#18
peaks <- c(1,findPeaks(diff.updown),findValleys(diff.updown),nrow(diff.updown)) %>% as.data.frame%>% setNames(c("num")) %>% arrange(num)
q.18 <- 0 
q.18.r <- 0
for(i in 2:nrow(peaks)){
t1 <- as.POSIXct(diff.updown[peaks[i-1,],])
t2 <- as.POSIXct(diff.updown[peaks[i,],])
val.t1 <- as.numeric(tdt.xts[t1]$navg)
val.t2 <- as.numeric(tdt.xts[t2]$navg)
q.18 <- max(q.18, as.numeric(t2-t1))
q.18.r <- max(q.18.r, abs(val.t1-val.t2))
}

################# 18

################# 19-20
# вообще хер пойми что хотел Сандип. возможно амплитуду прыжка. я могу только вычислить разницу между макс и мин до 12-30
# или разницу до линейной аппроксимации

local.tdt <- tdt %>% filter(dt <= curdate + 12.5 * 3600) %>% arrange(dt)
local.tdt.2 <- tdt %>% filter(dt > curdate + 12.5 * 3600) %>% arrange(dt)
local.tdt.3 <- local.tdt
r.local.tdt <- range(local.tdt$navg)
r.local.tdt.2 <- range(local.tdt.2$navg)

#минимум до 12-30 меньше чем после 12-30 и меньше чем начальный / аналогично для определения наличия максимума
local.min <- r.local.tdt[1] < tdt.start.val & r.local.tdt[1] < r.local.tdt.2[1]
local.max <- r.local.tdt[2] > tdt.start.val & r.local.tdt[2] > r.local.tdt.2[2]

q.19 <- 0
if(local.min){
local.tdt <- local.tdt %>% filter(navg == r.local.tdt[1]) %>% mutate(q.19 = abs(r.local.tdt[1] - lfit))
q.19 <- local.tdt[1,]$q.19}

if(local.max){
local.tdt <- local.tdt %>% filter(navg == r.local.tdt[2]) %>% mutate(q.19 = abs(r.local.tdt[2] - lfit))
q.19 <- local.tdt[1,]$q.19
}

q.20.5 <- 0
q.20.10 <- 0
q.20.15 <- 0
q.20.30 <- 0
q.20.45 <- 0
q.20.60 <- 0
if(local.min){
# нашли экстремум и когда он был
local.tdt <- local.tdt.3 %>% filter(navg == r.local.tdt[1])
extremum.dt <- local.tdt[1,]$dt
extremum.val <- local.tdt[1,]$navg

# теперь возмем отрезок с момента экстремума на час вперед
# так как это экстремум, явно график отыграет баллы - надо понять сколько
local.tdt <- tdt %>% filter(dt >= extremum.dt & dt <= extremum.dt + 3600) %>% arrange(dt) %>% mutate(fit.diff = abs(extremum.val - lfit))
q.20.5 <- local.tdt[5,]$fit.diff
q.20.10 <- local.tdt[10,]$fit.diff
q.20.15 <- local.tdt[15,]$fit.diff
q.20.30 <- local.tdt[30,]$fit.diff
q.20.45 <- local.tdt[45,]$fit.diff
q.20.60 <- local.tdt[60,]$fit.diff

}

if(local.max){
# нашли экстремум и когда он был
local.tdt <- local.tdt.3 %>% filter(navg == r.local.tdt[2])
extremum.dt <- local.tdt[1,]$dt
extremum.val <- local.tdt[1,]$navg

# теперь возьмем отрезок с момента экстремума на час вперед
# так как это экстремум, явно график отыграет баллы - надо понять сколько
local.tdt <- tdt %>% filter(dt >= extremum.dt & dt <= extremum.dt + 3600) %>% arrange(dt) %>% mutate(fit.diff = abs(extremum.val - lfit))
q.20.5 <- local.tdt[5,]$fit.diff
q.20.10 <- local.tdt[10,]$fit.diff
q.20.15 <- local.tdt[15,]$fit.diff
q.20.30 <- local.tdt[30,]$fit.diff
q.20.45 <- local.tdt[45,]$fit.diff
q.20.60 <- local.tdt[60,]$fit.diff

}

################# 19-20

################# 21-22

coef.sign.21.0 <- trend.coef.before(tdt, curdate + 14 * 3600)
coef.sign.21.1 <- trend.coef.after(tdt, curdate + 14.75 * 3600)
coef.sign.21.2 <- trend.coef.between(tdt, curdate + 14 * 3600, curdate + 14.75 * 3600)

trend.change <- coef.sign.21.0 != coef.sign.21.2

q.21.a <- ifelse(trend.change & coef.sign.21.1 == coef.sign.21.2, 1, 0)
q.22.a <- ifelse(trend.change & coef.sign.21.1 != coef.sign.21.2, 1, 0)
q.21.b <- 0
q.22.b <- 0

if(trend.change) 
{
local.tdt <- tdt %>% filter(dt >= curdate + 14 * 3600 & dt < curdate + 14.75 * 3600) %>% arrange(dt)
r.local.tdt <- range(local.tdt$navg)
q.21.b <- abs(diff(r.local.tdt))
q.22.b <- q.21.b
}

################# 21-22

################# 24, atr

tdt.xts <- tdt %>% select(dt,no,nh,nl,nc,navg,lfit) %>% setNames(c("dt","NIFTY.Open","NIFTY.High","NIFTY.Low","NIFTY.Close","NIFTY.Adjusted", "lfit"))
tdt.xts <- xts(tdt.xts[,-1], order.by=tdt[,1])

atr1 <- 0
atr2 <- 0
filt1 <- paste0(as.character(curdate+9.25*3600),"::",as.character(curdate+12.5*3600))
filt2 <- paste0(as.character(curdate+9.26*3600),"::",as.character(curdate+15.5*3600))
atr <- ATR(HLC(tdt.xts), n = 5)
atr1 <- mean(as.numeric(na.omit(atr[filt1]$atr)))
atr2 <- mean(as.numeric(na.omit(atr[filt2]$atr)))


q.24.a <- 0
q.24.b <- 0
sh <- seriesHi(tdt.xts)[1]
sl <- seriesLo(tdt.xts)[1]

if(as.POSIXct(sl) > curdate + 3600*14){
q.24.a <- 1
q.24.b <- abs(as.numeric(sh$lfit) - as.numeric(sh$NIFTY.Adjusted))}

if(as.POSIXct(sh) > curdate + 3600*14){
q.24.a <- 1
q.24.b <- abs(as.numeric(sh$lfit) - as.numeric(sh$NIFTY.Adjusted))}

################# 24


#tdt <- tdt %>% mutate(updown = (navg - lfit)/abs(navg - lfit))

t <- diff(tdt$updown) %>% as.data.frame %>% setNames(c("ndiff")) %>% mutate(up = ifelse(ndiff > 0,1,0), down = ifelse(ndiff < 0,1,0))
tdt.ups <- sum(t$up)
tdt.downs <- sum(t$down)

tdt.16 <- tdt %>% filter(dt >= curdate + 12.5 * 3600) %>% mutate(updown = (navg - lfit)/abs(navg - lfit))

t <- diff(tdt.16$updown) %>% as.data.frame %>% setNames(c("ndiff")) %>% mutate(up = ifelse(ndiff > 0,1,0), down = ifelse(ndiff < 0,1,0))
tdt.16.ups <- sum(t$up) - 1
tdt.16.downs <- sum(t$down) - 1

######################################

################# 10

q.10 <- 0
q.10.ll <- ifelse(tdt.start.val > tdt.end.val & as.numeric(co[2]) < 0,1,0)
q.10.hh <- ifelse(tdt.start.val < tdt.end.val & as.numeric(co[2]) > 0,1,0)
q.11 <- 0#mean(q.11.peaks$peaks)
q.12 <- 0

if(q.10.hh == 1){
if(min(tdt$navg) == tdt[1,]$navg & max(tdt$navg) == tdt[nrow(tdt),]$navg){q.10 <- 1}
if(tdt.downs == 1){q.10 <- 3}
if(tdt.downs == 2){q.10 <- 5}
if(tdt.downs == 4){q.10 <- 7}
q.11 <- mean(q.11.pb.1)
q.12 <- mean(q.12.peaks.hh)
}

if(q.10.ll == 1){
if(max(tdt$navg) == tdt[1,]$navg & min(tdt$navg) == tdt[nrow(tdt),]$navg){q.10 <- 2}
if(tdt.ups == 1){q.10 <- 4}
if(tdt.ups == 2){q.10 <- 6}
if(tdt.ups == 4){q.10 <- 8}
q.11 <- mean(q.11.pb.2)
q.12 <- mean(q.12.peaks.ll)
}
################# 10

################# 16

tdt.16.start.val <- tdt.16$navg[1]
tdt.16.end.val <- tdt.16$navg[length(tdt.16$navg)]

q.16 <- 0
q.16.ll <- ifelse(tdt.16.start.val > tdt.16.end.val & as.numeric(co[2]) < 0,1,0)
q.16.hh <- ifelse(tdt.16.start.val < tdt.16.end.val & as.numeric(co[2]) > 0,1,0)

if(q.16.hh){
if(min(tdt.16$navg) == tdt.16[1,]$navg & max(tdt.16$navg) == tdt.16[nrow(tdt.16),]$navg){q.16 <- 1}
if(tdt.16.downs == 1){q.16 <- 3}
if(tdt.16.downs == 2){q.16 <- 5}
if(tdt.16.downs == 4){q.16 <- 7}
}

if(q.16.ll){
if(max(tdt.16$navg) == tdt.16[1,]$navg & min(tdt.16$navg) == tdt.16[nrow(tdt.16),]$navg){q.16 <- 2}
if(tdt.16.ups == 1){q.16 <- 4}
if(tdt.16.ups == 2){q.16 <- 6}
if(tdt.16.ups == 4){q.16 <- 8}
}

################# 16


d <- cbind.data.frame(tdt.sd, curdate, tdt.start.val, 
tdt.end.val, tdt.diff.range[1], tdt.diff.range[2], 
tdt.volatility, q.13, q.14, q.15.a, q.15.b, q.15.c, q.15.z, 
q.17.a, q.17.b, q.17.c, tdt.ups, 
tdt.downs, mean(abs(interday.diff)),
q.21.a,q.21.b,q.22.a,q.22.b,q.24.a,q.24.b,
q.19,
q.20.5,
q.20.10,
q.20.15,
q.20.30,
q.20.45,
q.20.60,atr1,atr2,
q.9.vol,q.9.dt,q.18, q.18.r,q.10,q.16,q.11,q.12,tdt.move.down,tdt.mean,tdt.move.up) %>% setNames(nm = c("sd","day", 
"start.val", "end.val", "range.min", "range.max", 
"volatility", "q.13", "q.14", "q.15.a", "q.15.b","q.15.c", "q.15.z", 
"q.17.a", "q.17.b", "q.17.c", "tdt.ups", 
"tdt.downs", "mean.interday.diff","q.21.a","q.21.b","q.22.a","q.22.b",
"q.24.a","q.24.b",
"q.19",
"q.20.5",
"q.20.10",
"q.20.15",
"q.20.30",
"q.20.45",
"q.20.60","atr1","atr2",
"q.9.vol","q.9.dt","q.18","q.18.r","q.10","q.16","q.11","q.12",
"move.down","mean","move.up"))

res <- rbind(res, d)
}#есть данные за этот день
if(nrow(tdt) == 0){n.empty <- n.empty + 1}
curdate <- curdate + 86400
setTxtProgressBar(pb, as.numeric(diff(c(begdate, curdate))))
}

########################################################################

close(pb)
tend <- Sys.time()
cat("started: ", tstart, " / ended: ", tend," / ", diff(c(tstart, tend)), "\n")

res <- res %>% mutate(range.q2 = (start.val - end.val), abs.range.q2 = abs(range.q2))

#Q1
cat("Q1", "\n")
for(i in 1:40){
t <- res %>% filter(abs.range.q2 > 5 * i)
cat(5 * i, " points = ", 100 * nrow(t)/nrow(res), "%\n")
}

#Q2 v2
cat("Q2", "\n")
avg.sd <- sd(res$range.q2)
for(i in 1:4){
t <- res %>% filter(abs.range.q2 > .25 * i * avg.sd)
cat(.25 * i, " SD = ", 100 * nrow(t)/nrow(res), "%\n")}

#Q3
t <- res %>% filter(move.up > avg.sd)
cat("Q3 move up > 1 SD = ", nrow(t), "d.\n")
t <- res %>% filter(move.down > avg.sd)
cat("Q3 move down > 1 SD", nrow(t), "d.\n")

#Q4
t <- res %>% filter(move.up > avg.sd & move.down > avg.sd)
cat("Q4 up > 1 SD & down > 1 SD = ", nrow(t), "d.\n")

#Q5
t <- res %>% filter(move.up > avg.sd & move.down > 0.5 * avg.sd)
cat("Q5 up > 1 SD & down > 0.5 SD = ", nrow(t), "d.\n")

#Q6
t <- res %>% filter(move.up > 0.5 * avg.sd & move.down > avg.sd)
cat("Q6 up > 0.5 SD & down > 1 SD = ", nrow(t), "d.\n")

#Q7
t <- res %>% filter(move.up > 0.25 * avg.sd & move.down > avg.sd)
cat("Q7 up > 0.25 SD & down > 1 SD = ", nrow(t), "d.\n")

#Q8
t <- res %>% filter(move.up > avg.sd & move.down > 0.25 * avg.sd)
cat("Q8 up > 1 SD & down > 1 SD = ", nrow(t), "d.\n")

#Q9
sd.vol <- sd(res$q.9.vol)
vol.0.5 <- res %>% filter(q.9.vol > 0.25 * sd.vol & q.9.vol <= 0.5 * sd.vol)
vol.0.75 <- res %>% filter(q.9.vol > 0.5 * sd.vol & q.9.vol <= 0.75 * sd.vol)
vol.1 <- res %>% filter(q.9.vol > 0.75 * sd.vol & q.9.vol <= sd.vol)

clust.q9 <- function(vol){
	q.9.m <- 0
	for(i in 1:100){
		if((vol >= i * 0.01) & (vol < (i+1)*0.01) ){q.9.m <- i}}
		return(q.9.m)}
res$q.9.clust <- lapply(res$q.9.vol, clust.q9)

#Q10 / Q11
q.10 <- res %>% filter(q.10 == 1)
cat("q.10 1) ", nrow(q.10), "\n")
cat("q.11 1", mean(q.10$q.11), "\n")
cat("q.12 1", mean(q.10$q.12), "\n")

q.10 <- res %>% filter(q.10 == 2)
cat("q.10 2) ", nrow(q.10), "\n")
cat("q.11 2", mean(q.10$q.11), "\n")
cat("q.12 2", mean(q.10$q.12), "\n")

q.10 <- res %>% filter(q.10 == 3)
cat("q.10 3) ", nrow(q.10), "\n")
q.10 <- res %>% filter(q.10 == 4)
cat("q.10 4) ", nrow(q.10), "\n")
q.10 <- res %>% filter(q.10 == 5)
cat("q.10 5) ", nrow(q.10), "\n")
q.10 <- res %>% filter(q.10 == 6)
cat("q.10 6) ", nrow(q.10), "\n")
q.10 <- res %>% filter(q.10 == 7)
cat("q.10 7) ", nrow(q.10), "\n")
q.10 <- res %>% filter(q.10 == 8)
cat("q.10 8) ", nrow(q.10), "\n")

#q.12 <- res %>% filter(q.10 %in% c(1,2,3,4,5,6)) %>% mutate(q.12 = range.max - range.min)
#cat("q.12 ", mean(q.12$q.12))

cat("Q13", sum(res$q.13), "d.","\n")
cat("Q14", sum(res$q.13), "d.","\n")
cat("Q15 (<12:30)", sum(res$q.15.z), "d.","\n")
cat("Q15a", sum(res$q.15.a), "d.","\n")
cat("Q15b", sum(res$q.15.b), "d.","\n")
cat("Q15c", sum(res$q.15.c), "d.","\n")
cat("Q17a", sum(res$q.17.a), "d.","\n")
cat("Q17b", sum(res$q.17.b), "d.","\n")
cat("Q17c", sum(res$q.17.c), "d.","\n")

#Q18
cat("q.18 ", mean(res$q.18))
for(i in 1:40){
t <- res %>% filter(q.18.r > 5 * i)
cat(5 * i, " points = ", 100 * nrow(t)/nrow(res), "%\n")
}

#Q19
cat("Q19", "\n")
for(i in 1:40){
t <- res %>% filter(q.19 >= 5 * i)
cat(5 * i, " points = ", 100 * nrow(t)/nrow(res), "%\n")
}

#Q20
cat("Q20 05 min", mean(res$q.20.5), "pts.","\n")
cat("Q20 10 min", mean(res$q.20.10), "pts.","\n")
cat("Q20 15 min", mean(res$q.20.15), "pts.","\n")
cat("Q20 30 min", mean(res$q.20.30), "pts.","\n")
cat("Q20 45 min", mean(res$q.20.45), "pts.","\n")
cat("Q20 60 min", mean(res$q.20.60), "pts.","\n")

cat("Q21a", sum(res$q.21.a), "d.","\n")
cat("Q21b", mean(res$q.21.b), "pts.","\n")
cat("Q22a", sum(res$q.22.a), "d.","\n")
cat("Q22b", mean(res$q.22.b), "pts.","\n")


#Q23
#avg.intraday.range <- max(abs(median(res$range.min)), median(res$range.max))
#avg.sd <- median(res$sd)
for(i in 1:4){
t <- res %>% filter(range.q2 <= .25 * i * avg.sd)
cat("Q23", .25 * i, " SD = ", 100 * nrow(t)/nrow(res), "%\n")}

#Q24
cat("Q24a", sum(res$q.24.a), "d.","\n")
cat("Q24b", mean(res$q.24.b), "pts.","\n")

#ATR
atr1 <- mean(res$atr1)
atr2 <- mean(res$atr2)
cat("ATR: ", 100*abs(atr1-atr2)/max(atr1,atr2))