library(ggplot2)
library(tidyverse)
options(stringsAsFactors = FALSE)
theme_set(theme_bw())


setwd("C:/Users/Antoine Laurent/Google Drive/Stanford/Classes/MSE 231/HW1/MS-E-231")


#load names yob file
female_names=read.table('female_names.tsv', header = T)
male_names=read.table('male_names.tsv', header=T)

colnames(male_names)=c("Name","Count","Year")
male_names$Name=tolower(male_names$Name)

colnames(female_names)=c("Name","Count","Year")
female_names$Name=tolower(female_names$Name)

### Organize raw data
Lucas_df=read.csv(file="data.csv",sep=",")
colnames(Lucas_df)=c("Date","Time","TweetID","OriginalID")

#TODO - Small data must be random!
small_data=Lucas_df[sample(nrow(Lucas_df),50000),]
df_first_names <- mutate(small_data, Tweet_first_name = tolower(word(TweetID,1)), Original_first_name=tolower(word(OriginalID,1)))


# Infer the gender from the name
# We will use the following function: TODO - change function name
#as a function:
name2gen2 <- function(firstname) {
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
df2=mutate(df_first_names,TweetGender=name2gen2(df_first_names$Tweet_first_name),
           OriginalGender=name2gen2(df_first_names$Original_first_name))

# Convert the returned gender (list) into a factor
df2$TweetGender <- as.factor(unlist(df2$TweetGender))
df2$OriginalGender <- as.factor(unlist(df2$OriginalGender))





###########################################################
#       Data analysis
##########################################################

data <- df2

N=length(data[,1])
Nfemale=sum(data$TweetGender=="F", na.rm=T)
Nmale=sum(data$TweetGender=="M", na.rm=T)

### Filter out the NAs in gender columns
data_OKgen = data[complete.cases(data[ , 7]),]
data_OKgen2 = data_OKgen[complete.cases(data_OKgen[ , 8]),]


### Compute volume of tweets in each 15-minute interval in our data (by gender)
Volume_Tweets <-  group_by(data_OKgen, Time, TweetGender) %>%
  summarize(numTweets = n()) %>%
  arrange(Time)

ggplot(data = Volume_Tweets) + 
  geom_line(mapping = aes(x=Time, y=numTweets, group=TweetGender, color=TweetGender))




#############
#  Annex
#############

# Alternative syntax (but same method) to obtain the genders
df_first_names$Tweet_gender = df_first_names$Tweet_first_name #just to get same length and format



##### from name to gender
#as a function:
name2gen <- function(firstname) {
  thisguy=""
  name1=tolower(firstname)
  if ((name1 %in% male_names$Name) & !(name1 %in% female_names$Name )){
    thisguy="M"
  } else if (!(name1 %in% male_names$Name) & (name1 %in% female_names$Name )){
    thisguy="F"
  } else if ((name1 %in% male_names$Name) & (name1 %in% female_names$Name )){
    Focc=female_names[which(female_names$Name==name1),3]
    Mocc=male_names[which(male_names$Name==name1),3]
    Mproba=Mocc/(Mocc+Focc)
    if (Mproba>0.95){
      thisguy="M"
    } else if (Mproba<0.05){
      thisguy="F"
    } else{
      thisguy=NA
    }
  } else if (!(name1 %in% male_names$Name) & !(name1 %in% female_names$Name )){
    thisguy=NA
  }
  return(thisguy)
}


i=1
while (i<length(df_first_names$Tweet_gender)){
  df_first_names$Tweet_gender[i] <- name2gen(df_first_names$Tweet_first_name[i])
  df_first_names$Original_gender[i] <- name2gen(df_first_names$Original_first_name[i])
  i=i+1
}


# ORIGINAL LOGIC TO INFER GENDER

### determine gender from name as string
name1="Peter"

# return M or F if at least 95% sure, or NA otherwise
thisguy=""
name1=tolower(name1)
if ((name1 %in% male_names$Name) & !(name1 %in% female_names$Name )){
  thisguy="M"
} else if (!(name1 %in% male_names$Name) & (name1 %in% female_names$Name )){
  thisguy="F"
} else if ((name1 %in% male_names$Name) & (name1 %in% female_names$Name )){
  Focc=female_names[which(female_names$Name==name1),3]
  Mocc=male_names[which(male_names$Name==name1),3]
  Mproba=Mocc/(Mocc+Focc)
  if (Mproba>0.95){
    thisguy="M"
  } else if (Mproba<0.05){
    thisguy="F"
  } else{
    thisguy=NA
  }
} else if (!(name1 %in% male_names$Name) & !(name1 %in% female_names$Name )){
  thisguy=NA
}


data=df_first_name

N=length(data[,1])
Nfemale=sum(data$Tweet_gender=="F", na.rm=T)
Nmale=sum(data$Tweet_gender=="M", na.rm=T)

### Filter out the NAs in gender columns
data_OKgen = data[complete.cases(data[ , 7]),]
data_OKgen2 = data_OKgen[complete.cases(data_OKgen[ , 8]),]
