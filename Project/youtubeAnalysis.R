# videos analysis

library(ggplot2)
library(tidyverse)
library(dplyr)
library(MatchIt)
library(lubridate)
theme_set(theme_bw())


# setwd("C:/Users/Antoine Laurent/Google Drive/Stanford/Classes/MSE 231/Proyecto")
setwd("/Users/Arturo/Desktop/Stanford/Courses/03 Fall 2019/MS&E 231/Project/Code")

df=data.frame(read.csv("videosRandom.csv"))
df_channels=data.frame(read.csv("videoChannels.csv"))

##### Random videos #####
#create vector of sponsored T/F and add it ot the df
desc=df$description
is_sponsored=str_detect(desc,'sponsor|promo code|use my code|use the code|patroc|promot')
sum(is_sponsored)
df$sponsored <- is_sponsored

#adding columns for analysis
df$likes <- as.numeric(as.character(df$likes))
df$views <- as.numeric(as.character(df$views))
df$dislikes <- as.numeric(as.character(df$dislikes))
df$comments <- as.numeric(as.character(df$comments))

df$likes_dislikes=df$likes/df$dislikes
df$likes_views=df$likes/df$views
df$comments_views=df$comments/df$views

final = df[complete.cases(df), ] #remove rows with NAs
final=unique(final) # remove duplicates
final=final[which(final$dislikes>=5), ] #remove videos with very low views by making sure we don't have 0 dislikes and divide by zero later on

df_sponsored <- final[ which(final$sponsored==T), ]
df_not_sponsored <- final[ which(final$sponsored==F), ]

##### Channel videos #####
#create vector of sponsored T/F and add it ot the df
desc=df_channels$description
is_sponsored=str_detect(desc,'sponsor|promo code|use my code|use the code|patroc|promot')
sum(is_sponsored)
df_channels$sponsored <- is_sponsored

#adding columns for analysis
df_channels$likes <- as.numeric(as.character(df_channels$likes))
df_channels$views <- as.numeric(as.character(df_channels$views))
df_channels$dislikes <- as.numeric(as.character(df_channels$dislikes))
df_channels$comments <- as.numeric(as.character(df_channels$comments))

df_channels$likes_dislikes=df_channels$likes/df_channels$dislikes
df_channels$likes_views=df_channels$likes/df_channels$views
df_channels$comments_views=df_channels$comments/df_channels$views

final_channels = df_channels[complete.cases(df_channels), ] #remove rows with NAs
final_channels=unique(final_channels) # remove duplicates
final_channels=final_channels[which(final_channels$dislikes>=5), ] #remove videos with very low views by making sure we don't have 0 dislikes and divide by zero later on

df_sponsored_channels <- final_channels[ which(final_channels$sponsored==T), ]
df_not_sponsored_channels <- final_channels[ which(final_channels$sponsored==F), ]

# 
# #analysis
# hist(df_not_sponsored$likes_dislikes)
# hist(df_sponsored$likes_dislikes)
# 
# 
# quantile(df_not_sponsored$likes_dislikes, c(.05, .25, .5, .75, .95))
# quantile(df_sponsored$likes_dislikes, c(.05, .25, .5, .75, .95))
# # way better ratio for the sponsored videos
# 
# quantile(df_not_sponsored$likes_views, c(.05, .25, .5, .75, .95))*100
# quantile(df_sponsored$likes_views, c(.05, .25, .5, .75, .95))*100 #x100 for us to read
# #mean is 3x higher for sponsored videos
# 
# quantile(df_not_sponsored$comments_views, c(.05, .25, .5, .75, .95))*10000
# quantile(df_sponsored$comments_views, c(.05, .25, .5, .75, .95))*10000
# #mean is 4x higher for sponsored videos


# Plots Random
random1 <- ggplot(final, aes(x=likes_dislikes, fill=sponsored)) + geom_density(alpha=.3)+ xlim(c(0, 300)) + xlab("Likes/Dislikes Ratio") + ylab("Density") + scale_fill_discrete(name = "", labels = c("Not Sponsored", "Sponsored"))
ggsave(plot=random1, file="RandomLikesDislikes.pdf", width=8, height=5)

random2 <- ggplot(final, aes(x=likes_views, fill=sponsored)) + geom_density(alpha=.3)+ xlim(c(0, 0.2))+ xlab("Likes/Views Ratio") + ylab("Density") + scale_fill_discrete(name = "", labels = c("Not Sponsored", "Sponsored"))
ggsave(plot=random2, file="RandomLikesViews.pdf", width=8, height=5)

random3 <- ggplot(final, aes(x=comments_views, fill=sponsored)) + geom_density(alpha=.3) + xlim(c(0, 0.02))+ xlab("Comments/Views Ratio") + ylab("Density") + scale_fill_discrete(name = "", labels = c("Not Sponsored", "Sponsored"))
ggsave(plot=random3, file="RandomCommentsViews.pdf", width=8, height=5)


# Plots Channels
channels1 <- ggplot(final_channels, aes(x=likes_dislikes, fill=sponsored)) + geom_density(alpha=.3)+ xlim(c(0, 300)) + xlab("Likes/Dislikes Ratio") + ylab("Density") + scale_fill_discrete(name = "", labels = c("Not Sponsored", "Sponsored"))
ggsave(plot=channels1, file="ChannelsLikesDislikes.pdf", width=8, height=5)

channels2 <- ggplot(final_channels, aes(x=likes_views, fill=sponsored)) + geom_density(alpha=.3)+ xlim(c(0, 0.2))+ xlab("Likes/Views Ratio") + ylab("Density") + scale_fill_discrete(name = "", labels = c("Not Sponsored", "Sponsored"))
ggsave(plot=channels2, file="ChannelsLikesViews.pdf", width=8, height=5)

channels3 <- ggplot(final_channels, aes(x=comments_views, fill=sponsored)) + geom_density(alpha=.3) + xlim(c(0, 0.02))+ xlab("Comments/Views Ratio") + ylab("Density") + scale_fill_discrete(name = "", labels = c("Not Sponsored", "Sponsored"))
ggsave(plot=channels3, file="ChannelsCommentsViews.pdf", width=8, height=5)

##### MATCHING ANALYSIS #####
# Dates to date format
final_channels$date <- (as.Date(as.POSIXlt(final_channels$date), format = '%Y-%m-%dT%H:%M:%OS%z'))
# Duration to time format
final_channels$duration <- duration(as.character(final_channels$duration))

# Split the dataframe into 80 dataframes (one for each factor)
channelsList <- split(final_channels, final_channels$channelId)

# First channel
match.it <- matchit(sponsored ~ date + duration, data = channelsList[[80]], method = 'nearest', discard = "both", ratio = 1)
df.match <- rbind(df.match, match.data(match.it))
# df.match <- match.data(match.it)

write.csv(df.match,"matched_channels.csv")

# for(i in 2:80) {
#   # TODO: maybe change ratio? Only want those that are close enough...
#   match.it <- matchit(sponsored ~ date + duration, data = channelsList[[i]], method = 'nearest', discard = "both", ratio = 1)
#   df.match <- rbind(df.match, match.data(match.it))
# }

# Plots Matched
channels1 <- ggplot(df.match, aes(x=likes_dislikes, fill=sponsored)) + geom_density(alpha=.3)+ xlim(c(0, 300)) + xlab("Likes/Dislikes Ratio") + ylab("Density") + scale_fill_discrete(name = "", labels = c("Not Sponsored", "Sponsored"))
ggsave(plot=channels1, file="MatchedLikesDislikes.pdf", width=8, height=5)

channels2 <- ggplot(df.match, aes(x=likes_views, fill=sponsored)) + geom_density(alpha=.3)+ xlim(c(0, 0.2))+ xlab("Likes/Views Ratio") + ylab("Density") + scale_fill_discrete(name = "", labels = c("Not Sponsored", "Sponsored"))
ggsave(plot=channels2, file="MatchedLikesViews.pdf", width=8, height=5)

channels3 <- ggplot(df.match, aes(x=comments_views, fill=sponsored)) + geom_density(alpha=.3) + xlim(c(0, 0.02))+ xlab("Comments/Views Ratio") + ylab("Density") + scale_fill_discrete(name = "", labels = c("Not Sponsored", "Sponsored"))
ggsave(plot=channels3, file="MathcedCommentsViews.pdf", width=8, height=5)


##### TIME SERIES ANALYSIS #####
test_channel=final_channels$channelId[1000] #the number 1000 has 502 videos wow, sponsored from row 318 in Dec 2016
channel1_df=final_channels[ which(final_channels$channelId==test_channel), ]

channel1_df<-channel1_df[order(as.Date(as.POSIXlt(channel1_df$date), format = '%Y-%m-%dT%H:%M:%OS%z')),]
plot(channel1_df$sponsored)
plot(channel1_df$likes_dislikes)
line(channel1_df$likes_dislikes)

df_timeseries<-final_channels[order(as.Date(as.POSIXlt(final_channels$date), format = '%Y-%m-%dT%H:%M:%OS%z')),]
plot(df_timeseries$likes_dislikes)
line(df_timeseries$likes_dislikes)


# step 1: remove channels with less than min_vids videos
min_vids=350 #i get 33 channels like this
final_biggroups <- final_channels[final_channels$channelId %in% names(which(table(final_channels$channelId) > min_vids)), ]
#test--> sum(final_biggroups$channelId==final_biggroups$channelId[3254])
channels_vec <- as.vector(unique(final_biggroups$channelId))

# Code to plot and identify channels with clear switch dates - i manually change the value in first row from 1 to 33
test_channel=channels_vec[2] #the number 1000 has 502 videos wow, sponsored from row 318 in Dec 2016
channelunique_df=final_channels[ which(final_channels$channelId==test_channel), ]
channelunique_df<-channelunique_df[order(as.Date(as.POSIXlt(channelunique_df$date), format = '%Y-%m-%dT%H:%M:%OS%z')),]
plot(channelunique_df$sponsored)
plot(channelunique_df$likes_dislikes)
line(channelunique_df$likes_dislikes)

# Analysis of 7 chosen channels, which in channels_vec are indexes 2, 4, 10, 17, 18, 29, 30
final_channels<-final_channels[order(as.Date(as.POSIXlt(final_channels$date), format = '%Y-%m-%dT%H:%M:%OS%z')),]

channel_1 <- final_channels[ which(final_channels$channelId==channels_vec[2]), ] 
channel_2 <- final_channels[ which(final_channels$channelId==channels_vec[4]), ] 
channel_3 <- final_channels[ which(final_channels$channelId==channels_vec[10]), ] 
channel_4 <- final_channels[ which(final_channels$channelId==channels_vec[17]), ] 
channel_5 <- final_channels[ which(final_channels$channelId==channels_vec[18]), ] 
channel_6 <- final_channels[ which(final_channels$channelId==channels_vec[29]), ] 
channel_7 <- final_channels[ which(final_channels$channelId==channels_vec[30]), ] 

plot(channel_7$sponsored) 
channel_7$sponsored[210:230]

switch_indexes=c(318,132,122,296,88,100,214) #index of first switch to sponsored
size=40

# Likes/Dislikes
subset_1=channel_1$likes_dislikes[(switch_indexes[1]-size-1):(switch_indexes[1]+size)]
subset_2=channel_2$likes_dislikes[(switch_indexes[2]-size-1):(switch_indexes[2]+size)]
subset_3=channel_3$likes_dislikes[(switch_indexes[3]-size-1):(switch_indexes[3]+size)]
subset_4=channel_4$likes_dislikes[(switch_indexes[4]-size-1):(switch_indexes[4]+size)]
subset_5=channel_5$likes_dislikes[(switch_indexes[5]-size-1):(switch_indexes[5]+size)]
subset_6=channel_6$likes_dislikes[(switch_indexes[6]-size-1):(switch_indexes[6]+size)]
subset_7=channel_7$likes_dislikes[(switch_indexes[7]-size-1):(switch_indexes[7]+size)]
likesDislikes <- rowMeans(cbind(subset_1, subset_2, subset_3, subset_4, subset_5, subset_6, subset_7))

test_subset1=data.frame(likesDislikes)
test_subset1$ind = seq(1,82)
test_subset1$sponsor = c(rep(FALSE, 41), rep(TRUE, 41))


# Likes/Views
subset_1=channel_1$likes_views[(switch_indexes[1]-size-1):(switch_indexes[1]+size)]
subset_2=channel_2$likes_views[(switch_indexes[2]-size-1):(switch_indexes[2]+size)]
subset_3=channel_3$likes_views[(switch_indexes[3]-size-1):(switch_indexes[3]+size)]
subset_4=channel_4$likes_views[(switch_indexes[4]-size-1):(switch_indexes[4]+size)]
subset_5=channel_5$likes_views[(switch_indexes[5]-size-1):(switch_indexes[5]+size)]
subset_6=channel_6$likes_views[(switch_indexes[6]-size-1):(switch_indexes[6]+size)]
subset_7=channel_7$likes_views[(switch_indexes[7]-size-1):(switch_indexes[7]+size)]
likesViews <- rowMeans(cbind(subset_1, subset_2, subset_3, subset_4, subset_5, subset_6, subset_7))

test_subset2=data.frame(likesViews)
test_subset2$ind = seq(1,82)
test_subset2$sponsor = c(rep(FALSE, 41), rep(TRUE, 41))


# Comments/Views
subset_1=channel_1$comments_views[(switch_indexes[1]-size-1):(switch_indexes[1]+size)]
subset_2=channel_2$comments_views[(switch_indexes[2]-size-1):(switch_indexes[2]+size)]
subset_3=channel_3$comments_views[(switch_indexes[3]-size-1):(switch_indexes[3]+size)]
subset_4=channel_4$comments_views[(switch_indexes[4]-size-1):(switch_indexes[4]+size)]
subset_5=channel_5$comments_views[(switch_indexes[5]-size-1):(switch_indexes[5]+size)]
subset_6=channel_6$comments_views[(switch_indexes[6]-size-1):(switch_indexes[6]+size)]
subset_7=channel_7$comments_views[(switch_indexes[7]-size-1):(switch_indexes[7]+size)]
comments_views <- rowMeans(cbind(subset_1, subset_2, subset_3, subset_4, subset_5, subset_6, subset_7))

test_subset3=data.frame(comments_views)
test_subset3$ind = seq(1,82)
test_subset3$sponsor = c(rep(FALSE, 41), rep(TRUE, 41))


# plot(test_subset, pch=19)
# abline(v=size, col="green")
# abline(lm(test_subset[1:(size-1)] ~ 1), col='red', xlim=40)
# abline(lm(test_subset[(size+1):(2*size)] ~ 1), col='blue')

time_plot1 <- ggplot(data = test_subset1) + 
  geom_point(mapping = aes(x = ind, y = likesDislikes, color = sponsor)) + xlab("Launch Order") + ylab("Average Likes/Dislikes Ratio") +  scale_color_discrete(name = "", labels = c("Not Sponsored", "Sponsored")) +
  geom_smooth(data = filter(test_subset1, sponsor == FALSE), mapping = aes(x = ind, y = likesDislikes), method='lm', se = FALSE, color = "#F8766D") + 
  geom_smooth(data = filter(test_subset1, sponsor == TRUE), mapping = aes(x = ind, y = likesDislikes), method='lm', se = FALSE, color = "#00BFC4") + 
  geom_vline(xintercept = 41.5, linetype = "dotted")
ggsave(plot=time_plot1, file="TimeLikesDislikes.pdf", width=8, height=5)

time_plot2 <- ggplot(data = test_subset2) + 
  geom_point(mapping = aes(x = ind, y = likesViews, color = sponsor)) + xlab("Launch Order") + ylab("Average Likes/Views Ratio") +  scale_color_discrete(name = "", labels = c("Not Sponsored", "Sponsored")) +
  geom_smooth(data = filter(test_subset2, sponsor == FALSE), mapping = aes(x = ind, y = likesViews), method='lm', se = FALSE, color = "#F8766D") + 
  geom_smooth(data = filter(test_subset2, sponsor == TRUE), mapping = aes(x = ind, y = likesViews), method='lm', se = FALSE, color = "#00BFC4") + 
  geom_vline(xintercept = 41.5, linetype = "dotted")
ggsave(plot=time_plot2, file="TimeLikesViews.pdf", width=8, height=5)

time_plot3 <- ggplot(data = test_subset3) + 
  geom_point(mapping = aes(x = ind, y = comments_views, color = sponsor)) + xlab("Launch Order") + ylab("Average Comments/Views Ratio") +  scale_color_discrete(name = "", labels = c("Not Sponsored", "Sponsored")) +
  geom_smooth(data = filter(test_subset3, sponsor == FALSE), mapping = aes(x = ind, y = comments_views), method='lm', se = FALSE, color = "#F8766D") + 
  geom_smooth(data = filter(test_subset3, sponsor == TRUE), mapping = aes(x = ind, y = comments_views), method='lm', se = FALSE, color = "#00BFC4") + 
  geom_vline(xintercept = 41.5, linetype = "dotted")
ggsave(plot=time_plot3, file="TimeCommentsViews.pdf", width=8, height=5)

#Colors for sponsored vs non sponsored?


list_subsets <- list(subset_1,subset_2,subset_3,subset_4,subset_5,subset_6,subset_7)
results_means=c()
results_medians=c()
for (s in list_subsets) {
  a=100*(mean(s[(size+1):(2*size)])-mean(s[1:size]))/mean(s[1:size])
  b=100*(median(s[(size+1):(2*size)])-median(s[1:size]))/median(s[1:size])
  print(a)
  results_means<- c(results_means,a)
  results_medians<- c(results_medians,b)
}


# manual test
size=50
sp_minus=channel1_df[(317-size):317,"likes_dislikes"]
sp_plus=channel1_df[318:(318+size),"likes_dislikes"]
median(sp_minus)
median(sp_plus)
mean(sp_minus)
mean(sp_plus)
plot(channel1_df[(317-size):(318+size),"likes_dislikes"])
