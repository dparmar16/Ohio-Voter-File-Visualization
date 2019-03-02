#Clear directory
rm(list=ls())

#Set directory to import data from
setwd("C:/Users/Divya Parmar's PC/Documents/Ohio-Voter-Files")


library("lubridate")
library("dplyr")
library("caTools")
library("descr")

#Ohio voter file for individual level data
#From Ohio Secretary of State website
#https://www6.sos.state.oh.us/ords/f?p=VOTERFTP:CONG:::#congDistFiles
#Set path to import voter files
download_base = ".\\DATA\\CONGRESSIONAL_DISTRICT_"

#Decide the columns I need from Ohio voter files
col_to_import = c("SOS_VOTERID","COUNTY_ID","DATE_OF_BIRTH", "RESIDENTIAL_ZIP",
                  "REGISTRATION_DATE","VOTER_STATUS","PARTY_AFFILIATION",
                  "CONGRESSIONAL_DISTRICT","STATE_SENATE_DISTRICT",
                  "PRIMARY.03.15.2016","GENERAL.11.08.2016","GENERAL.11.07.2017",
                  "PRIMARY.05.08.2018","GENERAL.11.06.2018")




number_of_files = 16 #one file for each Congressional district in Ohio
for (x in 1:number_of_files){
  print(x)
  print(Sys.time())
  # if the merged dataset doesn't exist, create it
  if (!exists("dataset")){
    dataset <- read.csv(paste(paste(download_base,x,sep = ""),".txt",sep=""), header=TRUE, sep=",")
    print(typeof(dataset))
    dataset <- as.data.frame(dataset[,col_to_import])
    print(typeof(dataset))
    print('first dataset loaded')
    print(print(Sys.time()))
    
  }
  
  # if the merged dataset does exist, append to it
  else {
    temp_dataset <-read.csv(paste(paste(download_base,x,sep = ""),".txt",sep = ""), header=TRUE, sep=",")
    print('temp created')
    print(print(Sys.time()))
    temp_dataset <- as.data.frame(temp_dataset[,col_to_import])
    print(typeof(temp_dataset))
    print('temp columns reduced')
    print(print(Sys.time()))
    dataset<-rbind(dataset, temp_dataset)
    print(typeof(dataset))
    print('row bind complete')
    print(print(Sys.time()))
    rm(temp_dataset)
    print('temp deleted')
    print(print(Sys.time()))
  }
}

#Create zip code column to join to income data
dataset$zipcode <- dataset$RESIDENTIAL_ZIP

#Import income data file from IRS
#SOI Tax Stats - Individual Income Tax Statistics - 2016 ZIP Code Data (SOI)
#https://www.irs.gov/statistics/soi-tax-stats-individual-income-tax-statistics-2016-zip-code-data-soi
zipdata <- read.csv(".\\Data\\16zpallagi.csv", header=TRUE, sep=",")

#Create dataframe of Congressional representation
#From Wikipedia's info on Congressional delegation from Ohio
#https://en.wikipedia.org/wiki/United_States_congressional_delegations_from_Ohio#2013%E2%80%932023:_16_seats
congressmembers <- data.frame("congress_district"= c(1:16),
                              "congressperson_party"=toupper(c("r","r","d","r","r","r","r","r","d","r","d","r","d","r","r","r")))

#Create dataframe of state senator representation
#From Wikipedia's info on 132nd Ohio General Assembly
#https://en.wikipedia.org/wiki/132nd_Ohio_General_Assembly
state_senators <- data.frame("state_district"=c(1:33),
                             "state_senator_party"=c("R","R","R","R","R","R","R","R","D","R","D","R","R","R","D","R",
                                                     "R","R","R","R","D","R","D","R","D","R","R","D","R","R","R","D","D"))


#Need to manipulate raw income data get avg income by zip code
zipagg <- zipdata %>%
  group_by(zipcode) %>%
  filter(zipcode != 0) %>%
  summarise(total_returns = sum(N1), total_income = sum(A02650*1000)) %>%
  mutate(avg_income = as.numeric(total_income/total_returns)) %>%
  select(zipcode, avg_income)


#Merge voter level data with zip code income data
combined <- merge(x=dataset, y=zipagg, by.x="zipcode", by.y = "zipcode", all.x = TRUE)

#Merge voter level data with congressional representation
combined <- merge(x=combined, y=congressmembers, by.x = "CONGRESSIONAL_DISTRICT" , by.y = "congress_district", all.x = TRUE)

#Merge voter level data with state senator representation
combined <- merge(x=combined, y=state_senators,  by.x = "STATE_SENATE_DISTRICT", by.y = "state_district", all.x = TRUE)

#Get voter's age using lubridate
combined$age <- as.duration(combined$DATE_OF_BIRTH %--% "2018-11-06") / dyears(1)

#Get how long voter has been registered to vote using lubridate
combined$registration_years <- as.duration(combined$REGISTRATION_DATE %--% "2018-11-06") / dyears(1)

#identified parties with: unique(combined$GENERAL.11.08.2016)
#identified non-voters with: unique(combined$GENERAL.11.08.2016) == ""
#Create column of voting history in four elections prior to 2018 midterms
combined$voting_last_four <- ifelse(combined$PRIMARY.03.15.2016 == "", 0, 1) +
  ifelse(combined$GENERAL.11.08.2016 == "", 0, 1) +
  ifelse(combined$GENERAL.11.07.2017 == "", 0, 1) +
  ifelse(combined$PRIMARY.05.08.2018 == "", 0, 1)

#Create column for voting flag in 2018 midterms
combined$voted_2018_general_flag <- ifelse(combined$GENERAL.11.06.2018 == "", 0, 1)

#Create income rounded column for cleaner analysis
combined$income_rounded <- round(combined$avg_income/1000)

#Create age rounded column for cleaner analysis
combined$age_rounded <- round(combined$age)

#Final output is visualized here:
#https://public.tableau.com/profile/divya.parmar#!/vizhome/OhioVoterBreakout/Crosstable?publish=yes
