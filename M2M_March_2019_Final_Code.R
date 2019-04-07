#Load in required packages
library(dplyr)
library(ggplot2)
library(gmodels)

#Check that combined dataframe has all the data we need
head(combined)

#Get 2016 age for each voter
combined$age_in_2016 <- combined$age_rounded - 2
combined$voted_2016_general_flag <- ifelse(combined$GENERAL.11.08.2016 == "X", 1, 0)

#Create age buckets for 2016 and 2018
#18-29, 30-44, 45-64, 65+
#Buckets from here:
#https://www.census.gov/newsroom/blogs/random-samplings/2017/05/voting_in_america.html
combined$age_bucket_2016 <- case_when(
  (combined$age_in_2016 >= 18 & combined$age_in_2016 <= 29) ~ '18-29',
  (combined$age_in_2016 >= 30 & combined$age_in_2016 <= 44) ~ '30-44',
  (combined$age_in_2016 >= 45 & combined$age_in_2016 <= 64) ~ '45-64',
  (combined$age_in_2016 >= 65) ~ '65+',
  combined$age_in_2016 < 18 | is.na(combined$age_in_2016) | !is.numeric(combined$age_in_2016) ~ 'Other'
)

combined$age_bucket_2018 <- case_when(
  (combined$age_rounded >= 18 & combined$age_rounded <= 29) ~ '18-29',
  (combined$age_rounded >= 30 & combined$age_rounded <= 44) ~ '30-44',
  (combined$age_rounded >= 45 & combined$age_rounded <= 64) ~ '45-64',
  (combined$age_rounded >= 65) ~ '65+',
  combined$age_rounded < 18 | is.na(combined$age_rounded) | !is.numeric(combined$age_rounded) ~ 'Other'
)

combined$zip_code_income_bucket <- case_when(
  (combined$income_rounded <= 49) ~ '<50k',
  (combined$income_rounded >= 50 & combined$income_rounded <= 99) ~ '50-99',
  (combined$income_rounded >= 100) ~ '100k+',
  combined$income_rounded <= 0 | is.na(combined$income_rounded) | !is.numeric(combined$income_rounded) ~ 'Other'
)

#CrossTab for voting by age bucket in 2016 and 2018
CrossTable(combined$age_bucket_2016, combined$voted_2016_general_flag) #48%, 65%, 79%, 86%
CrossTable(combined$age_bucket_2018, combined$voted_2018_general_flag) #32%, 46%, 66%, 77%

c(32, 46, 66, 77)/c(48,65, 79, 86)

df_age_turnout <- data.frame(c('18-29','30-44','45-64','65+','18-29','30-44','45-64','65+'), 
                             c('2016','2016','2016','2016','2018','2018','2018','2018'),
                             c(48,65, 79, 86,32, 46, 66, 77))
names(df_age_turnout) = c('age_group','election_year','turnout')
ggplot(df_age_turnout, aes(fill=election_year, x=age_group, y=turnout)) + 
  geom_bar(position="dodge", stat="identity") +
  labs(x="Age Group", y="Voter Turnout (percentage)", title="Voter Turnout by Election Year and Age Group")

#CrossTab for voting by income bucket in 2016 and 2018
CrossTable(combined$zip_code_income_bucket, combined$voted_2016_general_flag) #64%, 73%, 76% 
CrossTable(combined$zip_code_income_bucket, combined$voted_2018_general_flag) #51%, 61%, 68%

c(51, 61, 68)/c(64, 73, 76)

df_income_turnout <- data.frame(c('<50k','50-100k','100k+','<50k','50-100k','100k+'), 
                             c('2016','2016','2016','2018','2018','2018'),
                             c(64, 73, 76,51, 61, 68))
names(df_income_turnout) = c('income_group','election_year','turnout')
ggplot(df_income_turnout, aes(fill=election_year, x=income_group, y=turnout)) + 
  geom_bar(position="dodge", stat="identity") +
  labs(x="Income Group", y="Voter Turnout (percentage)", title="Voter Turnout by Election Year and Income Group")



#CrossTab for voting by Congressional district in 2016 vs 2018
CrossTable(combined$CONGRESSIONAL_DISTRICT, combined$voted_2016_general_flag)$prop.r
CrossTable(combined$CONGRESSIONAL_DISTRICT, combined$voted_2018_general_flag)$prop.r

cong_district_voting_2016 <- CrossTable(combined$CONGRESSIONAL_DISTRICT, combined$voted_2016_general_flag)$prop.r
cong_district_voting_2018 <- CrossTable(combined$CONGRESSIONAL_DISTRICT, combined$voted_2018_general_flag)$prop.r

cong_district_voting_2018/cong_district_voting_2016

cong_voting_ratio <- cong_district_voting_2018/cong_district_voting_2016

#Ohio data from here:
#https://www.census.gov/mycd/?st=39&cd=01
ohio_congressional_district_median_income <- c(59.719, 57.083, 47.123, 52.370,
                                               56.835, 47.067, 54.045, 58.295,
                                               43.182, 51.208, 35.954, 71.853,
                                               45.177, 67.163, 66.694, 66.504)

ohio_voting_change_and_income <- cbind(cong_voting_ratio, ohio_congressional_district_median_income)
ohio_voting_change_and_income <- as.data.frame(ohio_voting_change_and_income)
names(ohio_voting_change_and_income) <- c("not_voting", "voting", "median_income")
ggplot(data=as.data.frame(ohio_voting_change_and_income), aes(x=median_income, y=voting)) + 
  geom_point() + 
  geom_text(label=1:16, nudge_x = 0.75, nudge_y = 0.002, check_overlap = TRUE) +
  geom_smooth(method="lm") +
  labs(x="Median Income of Congressional District (thousands of dollars)", 
       y="Ratio of Voter Turnout in 2018 vs 2016",
       title="Voter Turnout Ratio of Midterms versus General By Congressional District")
