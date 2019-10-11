library(ggplot2)
library(tidyverse)
install.packages("lubridate")
library(lubridate)


options(stringsAsFactors = FALSE)
theme_set(theme_bw())


# setwd("C:/Users/Antoine Laurent/Google Drive/Stanford/Classes/MSE 231/HW1/MS-E-231")
# setwd("C:/Users/R510J/Desktop/Stanford/Courses/03 Fall 2019/MS&E 231/Homework/Homework 1/MS-E-231")


# Download Baby names
female_names=read.table('female_names.tsv.gz', header = T)
male_names=read.table('male_names.tsv.gz', header=T)

# We will only keep those with more than 2000 instances
colnames(male_names)=c("Name","Count","Year")
male_names$Name=tolower(male_names$Name)
male_names = group_by(male_names,Name) %>%
  summarize(Count = sum(Count)) %>%
  filter(Count > 2000)

colnames(female_names)=c("Name","Count","Year")
female_names$Name=tolower(female_names$Name)
female_names = group_by(female_names,Name) %>%
  summarize(Count = sum(Count)) %>%
  filter(Count > 2000)


### Import and clean tweet data
# 1.- Unfiltered
Unfiltered_tweets_raw=read.csv(file="data.csv",sep=",")
colnames(Unfiltered_tweets_raw)=c("Date","Time","TweetID","OriginalID")
Unfiltered_tweets <- mutate(Unfiltered_tweets_raw, Tweet_first_name = tolower(word(TweetID,1)), Original_first_name=tolower(word(OriginalID,1))) %>%
  filter(Date == "2019-10-07" | (Date == "2019-10-06" & Time > "21:30"))

# 2.- Filtered
Filtered_tweets_raw=read.csv(file="data_filtered.csv",sep=",")
colnames(Filtered_tweets_raw)=c("Date","Time","TweetID","OriginalID")
Filtered_tweets <- mutate(Filtered_tweets_raw, Tweet_first_name = tolower(word(TweetID,1)), Original_first_name=tolower(word(OriginalID,1)))


# Infer the gender from the name
# We will use the following function:
name2gen <- function(firstname) {
  lapply(firstname, function(firstname){
    name1=tolower(firstname)
    if ((name1 %in% male_names$Name) & !(name1 %in% female_names$Name )){
      return("M")
    } else if (!(name1 %in% male_names$Name) & (name1 %in% female_names$Name )){
      return("F")
    } else if ((name1 %in% male_names$Name) & (name1 %in% female_names$Name )){
      Focc=sum(female_names[which(female_names$Name==name1),2])
      Mocc=sum(male_names[which(male_names$Name==name1),2])
      Mproba=Mocc/(Mocc+Focc)
      if (Mproba>0.95){
        return("M")
      } else if (Mproba<0.05){
        return("F")
      } else{
        return(NA)
      }
    } else if (!(name1 %in% male_names$Name) & !(name1 %in% female_names$Name )){
      return(NA)
    }
    return(NA)
  })
  
}

# We now create two columns with the genders of the tweet and the original
# 1.- For unfiltered tweet data
df1=mutate(Unfiltered_tweets,TweetGender=name2gen(Unfiltered_tweets$Tweet_first_name),
           OriginalGender=name2gen(Unfiltered_tweets$Original_first_name))

# 2.- For filtered tweet data
df2=mutate(Filtered_tweets,TweetGender=name2gen(Filtered_tweets$Tweet_first_name),
           OriginalGender=name2gen(Filtered_tweets$Original_first_name))

# Convert the returned gender (list) into a factor
df1$TweetGender <- as.factor(unlist(df1$TweetGender))
df1$OriginalGender <- as.factor(unlist(df1$OriginalGender))
df2$TweetGender <- as.factor(unlist(df2$TweetGender))
df2$OriginalGender <- as.factor(unlist(df2$OriginalGender))



############################################################
#       Data analysis
##########################################################


##### Filter out the NAs in gender columns
Usable_unfiltered_1 = df1[complete.cases(df1[ , 7]),]
Usable_unfiltered_2 = Usable_unfiltered_1[complete.cases(Usable_unfiltered_1[ , 8]),]

Usable_filtered_1 = df2[complete.cases(df2[ , 7]),]
Usable_filtered_2 = Usable_filtered_1[complete.cases(Usable_filtered_1[ , 8]),]

##### Compute volume of tweets in each 15-minute interval in our data (by gender) and plot

### 1.- Unfiltered tweets
Volume_Tweets_unfiltered_raw <-  group_by(Usable_unfiltered_1, Time, TweetGender) %>%
  summarize(numTweets = n()) %>%
  arrange(Time)
# Now they are arranged by Time starting at 00:00, but we want it to start at 16:45, which
# is when the data started being collected
f_1 <- filter(Volume_Tweets_unfiltered_raw, Time > "21:30")
f_1$Time_astime = as.POSIXct(f_1$Time,format="%H:%M")
date(f_1$Time_astime) = "2019-10-06"

f_2 <- filter(Volume_Tweets_unfiltered_raw, Time < "21:30")
f_2$Time_astime = as.POSIXct(f_2$Time,format="%H:%M")
date(f_2$Time_astime) = "2019-10-07"

Volume_Tweets_unfiltered <- rbind(f_1, f_2)


Unfiltered_tweets_plot <- ggplot(data = Volume_Tweets_unfiltered) + 
  geom_line(mapping = aes(x=Time_astime, y=numTweets, group=TweetGender, color=TweetGender)) +
  labs(x= "Time", y = "Number of tweets per 15 minute interval", color="Gender")

ggsave(plot=Unfiltered_tweets_plot, file="Unfiltered_tweets_plot.pdf", width=8, height=5)


### 2.- Filtered tweets
Volume_Tweets_filtered_raw <-  group_by(Usable_filtered_1, Time, TweetGender) %>%
  summarize(numTweets = n()) %>%
  arrange(Time)
# Now they are arranged by Time starting at 00:00, but we want it to start at 16:45, which
# is when the data started being collected
f_1 <- filter(Volume_Tweets_filtered_raw, Time > "16:30")
f_1$Time_astime = as.POSIXct(f_1$Time,format="%H:%M")
date(f_1$Time_astime) = "2019-10-06"

f_2 <- filter(Volume_Tweets_filtered_raw, Time < "16:45")
f_2$Time_astime = as.POSIXct(f_2$Time,format="%H:%M")
date(f_2$Time_astime) = "2019-10-07"

Volume_Tweets_filtered <- rbind(f_1, f_2)

# Volume_Tweets_filtered$Time <- factor(Volume_Tweets_filtered$Time, levels = Volume_Tweets_filtered$Time)

Filtered_tweets_plot <- ggplot(data = Volume_Tweets_filtered) + 
  geom_line(mapping = aes(x=Time_astime, y=numTweets, group=TweetGender, color=TweetGender)) +
  labs(x= "Time", y = "Number of tweets per 15 minute interval", color="Gender")

ggsave(plot=Filtered_tweets_plot, file="Filtered_tweets_plot.pdf", width=8, height=5)



########################  
## Homophily analysis
########################

myvars <- c("Date","Time","TweetGender","OriginalGender")

## 1.- Unfiltered data
df_homo_unfiltered <- Usable_unfiltered_2[myvars]
df_homo_unfiltered$Retweet=paste(df_homo_unfiltered$TweetGender,df_homo_unfiltered$OriginalGender)
sum_homo_unfiltered <- table(df_homo_unfiltered$Retweet)
tot_homo_unfiltered=sum(sum_homo_unfiltered)


MM=sum_homo_unfiltered["M M"]
MF=sum_homo_unfiltered["M F"]
FM=sum_homo_unfiltered["F M"]
FF=sum_homo_unfiltered["F F"]



male_rt_ratio_unfiltered=(MM+MF)/tot_homo_unfiltered
# orig_male_unfiltered=MM+FM
homo_male_unfiltered=MM/(MM+FM)


female_rt_ratio_unfiltered=(FF+FM)/tot_homo_unfiltered
# orig_female_unfiltered=MM+FM
homo_female_unfiltered=FF/(MF+FF)



## 2.- Filtered data
df_homo_filtered <- Usable_filtered_2[myvars]
df_homo_filtered$Retweet=paste(df_homo_filtered$TweetGender,df_homo_filtered$OriginalGender)
sum_homo_filtered <- table(df_homo_filtered$Retweet)
tot_homo_filtered=sum(sum_homo_filtered)


MM=sum_homo_filtered["M M"]
MF=sum_homo_filtered["M F"]
FM=sum_homo_filtered["F M"]
FF=sum_homo_filtered["F F"]

male_rt_ratio_filtered=(MM+MF)/tot_homo_filtered
homo_male_filtered=MM/(MM+FM)

female_rt_ratio_filtered=(FF+FM)/tot_homo_filtered
homo_female_filtered=FF/(MF+FF)


#############


male_rt_ratio_unfiltered
homo_male_unfiltered

female_rt_ratio_unfiltered
homo_female_unfiltered

male_rt_ratio_filtered
homo_male_filtered

female_rt_ratio_filtered
homo_female_filtered
