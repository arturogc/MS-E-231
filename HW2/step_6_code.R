library(ggplot2)
library(tidyverse)
library(dplyr)
#options(stringsAsFactors = FALSE)


setwd("C:/Users/Antoine Laurent/Google Drive/Stanford/Classes/MSE 231/HW2")


#### split date and hour into 2 columns in precip dataframe
#formats in the output
#yyyy-mm-dd
# number between 0 and 23 included
df_precip=read.csv("nyc_precipitation.csv")
df_precip=separate(data = df_precip, col = DATE, into = c("Date", "Time"), sep = " ")
df_precip$Time <- as.numeric(substr(df_precip$Time, 0, 2))
df_precip$Date=as.Date(df_precip$Date, "%Y%m%d")

#### join precip column to step  5 output


#######################
#    with AWS
#######################

out0=read.table("Outputs/part-00000")
out1=read.table("Outputs/part-00001")
out2=read.table("Outputs/part-00002")
out3=read.table("Outputs/part-00003")
out4=read.table("Outputs/part-00004")
out5=read.table("Outputs/part-00005")
out6=read.table("Outputs/part-00006")

outf=rbind(out0,out1,out2,out3,out4,out5,out6)

######################
######################



# change step 5 output names to "Date" and "Time"
#x=read.table("aggregate.tsv")    use x=outf instead
x=outf
names(x)=c("date", "hour", "drivers_onduty", "t_onduty", "t_occupied", "n_pass", "n_trip", "n_mile", "earnings")
y=select(df_precip, "Date", "Time", "HPCP")
names(y) <- c("date", "hour", "precip")

x$date=as.Date(x$date)
y$date=as.Date(y$date)

# match hour meaning between both data frames
# basically -1h every row for y (rain data)

#change hour
i=1
for (h in y$hour) {
  y$hour[i] = h-1
  i=i+1
}

#change day
i=1
for (h in y$hour) {
  if (y$hour[i] == -1){
    y$hour[i] = 23
    y$date[i] = y$date[i]-1
  }
  i=i+1
}


# join with all earnings data

df_final=merge(x, y, by=intersect(names(x), names(y)), all.x=T) #Returns only the rows in which x has matching keys in y.
df_final=df_final[,c(1,2,10,3,4,5,6,7,8,9)]
df_final$precip <- ifelse(is.na(df_final$precip),0,df_final$precip)

# to be rigourous, we should remove the last hour since all y values there will be NA so 0
remove_length=sum(df_final$date==max(df_final$date) & df_final$hour==23)
df_final=df_final[1:(length(df_final$date)-remove_length),]






###################################################

#####                STEP 7                   #####

###################################################

df_7=df_final
#group by hour
df_7=df_7[,2:10]


df_grouped=aggregate(df_7[, 2:9], list(df_7$hour), mean)
colnames(df_grouped)[colnames(df_grouped)=="Group.1"] <- "hour"

########## PLOTS ######################

# create variables for analysis
var_names <- colnames(df_grouped)
for(i in var_names) {
  assign(i, df_grouped[[i]])
}
pct_onduty = t_onduty / drivers_onduty

### pct_onduty
plot(hour,pct_onduty, type="b", col="blue", lwd=5, xlab="hour", ylab="% time on duty per driver", main="Time on duty per hour")

### drivers_onduty
plot(hour,drivers_onduty, type="b", col="blue", lwd=5, xlab="hour", ylab="Number of drivers on duty", main="Average number of drivers on duty per hour")

#par(new=TRUE)
### earnings / pct_onduty --> re-check the logic
plot(hour,earnings/(pct_onduty*drivers_onduty), type="b", col="green", lwd=5, xlab="hour", ylab="Earnings", main="Average earnings per hour when on duty")

### earnings /  ---> wait nah we have to consider the % on duty
plot(hour,earnings/drivers_onduty, type="b", col="green", lwd=5, xlab="hour", ylab="Earnings", main="Average earnings per hour when on duty")
