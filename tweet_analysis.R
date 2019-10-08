library(ggplot2)
library(tidyverse)
options(stringsAsFactors = FALSE)


setwd("C:/Users/Antoine Laurent/Google Drive/Stanford/Classes/MSE 231/HW1")

#load names yob file
names_file=read.delim("yob1990.txt",header=FALSE, sep=",")
colnames(names_file)=c("Name","Gender","Occ")
names_file$Name=tolower(names_file$Name)


#split in 2 data frames
male_names=filter(names_file,Gender=="M")
female_names=filter(names_file,Gender=="F")


### Organize raw data
Lucas_df=read.csv(file="data.csv",sep=",")
colnames(Lucas_df)=c("Date","Time","TweetID","OriginalID")

small_data=Lucas_df[1:50000,]
df_first_names <- mutate(small_data, Tweet_first_name = tolower(word(TweetID,1)), Original_first_name=tolower(word(OriginalID,1)))
# TRY TO ADD A COLUMN AND APPLY THE FUNCTION LINE BY LINE ON THE FIRST NAME
df_first_names$Tweet_gender=df_first_names$Tweet_first_name #just to get same length and format


i=1
while (i<length(df_first_names$Tweet_gender)){
  df_first_names$Tweet_gender[i] <- name2gen(df_first_names$Tweet_first_name[i])
  df_first_names$Original_gender[i] <- name2gen(df_first_names$Original_first_name[i])
  i=i+1
}


df2=mutate(df_first_names,TweetGender=name2gen2(df_first_names$Tweet_first_name),
           OriginalGender=name2gen2(df_first_names$Original_first_name))



### determine gender from name as string
name1="Peter"


#### from name to gender
#as a function:
name2gen2 <- function(firstname) {
  lapply(firstname, function(firstname){
    name1=tolower(firstname)
    if ((name1 %in% male_names$Name) & !(name1 %in% female_names$Name )){
      return("M")
    } else if (!(name1 %in% male_names$Name) & (name1 %in% female_names$Name )){
      return("F")
    } else if ((name1 %in% male_names$Name) & (name1 %in% female_names$Name )){
      Focc=female_names[which(female_names$Name==name1),3]
      Mocc=male_names[which(male_names$Name==name1),3]
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


#Add first_names <- mutate(data_from_Lucas, first_name = tolower(word(username,1)))


female_names[which(female_names$Name==name1),3]


###########################################################
#       Data analysis
##########################################################

data=df_first_names

N=length(data[,1])
Nfemale=sum(data$Tweet_gender=="F", na.rm=T)
Nmale=sum(data$Tweet_gender=="M", na.rm=T)

### Filter out the NAs in gender columns
data_OKgen = data[complete.cases(data[ , 7]),]
data_OKgen2 = data_OKgen[complete.cases(data_OKgen[ , 8]),]