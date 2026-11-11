# CONCATENATION SCRIPT FOR SAM data -------------------------------

# author: Narendra Solanki (NS)
# last update: 30.06.2023 (NS)


# Adjustments if used for a new project ------------------------------------

# The following adjustments have to be made in the preprocessor script:                   
# 1. Set the path to the folder where the raw data of the SAM test is stored                
# 2. Enter the name of the lookup file (the corret file should be "lookup.genotype.csv" by default)          
# 3. Enter the START DATE and TIME of the FIRST dark phase in the correct format "YYYY-MM-DD HH:MM:SS"                          
# 4. Enter the name of the raw data file. It should contain the project name follwed by "-analytics", followed optional by a cohort and end with .xlsx
# 5. At the end of the script adjust the name of the output according to the current project.
# 6. Check the output.

# If you have raw data files from multiple cohorts adjust the name of the raw data file
# and the output and run the preprocessor again.


# 0. PREPARE WORKSPACE --------------------------------------------------------

# Empty workspace
rm(list = ls())

.libPaths(c(.libPaths(), "C:/R/library"))

# Libraries
library(tidyverse)
library(readxl)
library(readr)
library(lubridate)

# 1. Load relevant files ------------------------------------------------------

### 1. Change to folder in which the folders of the raw data are located
orig = choose.dir(default = "~/ID grid (SAM)/control data/data from behavior tests")
setwd(orig)

batch_name = str_split(orig, "[/,\\,\\\\]")[[1]]
project_name = batch_name[grep("6. Data from Behavioral Tests", batch_name)-1]
batch_name = batch_name[length(batch_name)]

getwd()

# 2. READ AND TRANSFORM DATA --------------------------------------------------
file_lookup = file.choose()   

lookup_genotype <- read.csv(paste(file_lookup, sep=",")) %>% 
  mutate(Animal = as.character(Animal))

# Cohort 2 = Normal Cycle
#lookup_genotype <- "lookup.genotype.csv" 

#lookup_genotype <- read.csv("lookup.genotype.csv", sep=",") %>% 

#divide lookup by cohort - here apparently only one cohort
# lookup_genotype_c1 = lookup_genotype %>% 
#   filter(cohort==1)
# lookup_genotype_c2 = lookup_genotype %>% 
#   filter(cohort==2)
  
# Here, enter the START DATE and TIME of the FIRST dark phase in the correct
# format "YYYY-MM-DD HH:MM:SS"
# Date can be found in sheet 'Distance Travelled' first row.
# Time point should be in the name of lookup.cycle: lookup.cycle.6pm.csv
# For time point 1
start_dark_t1 <- ymd_hms("2022-02-25 18:00:00")   # Cohort 2 = Normal Cycle

# Time point 1
file_data1 = file.choose()  
# Cohort 2 = Normal Cycle

data1 <- read_excel(file_data1) %>%    
  mutate(tp = 1) %>%
  mutate(DateTime = paste(Date, Time)) %>%
  mutate(DateTime = dmy_hms(DateTime)) %>%
  mutate(h_from_start = as.double(difftime(DateTime, start_dark_t1, units="hours"))) %>%
  # If the remainder of dividing h_from_start by 24 is under 12, it means the animal
  # is in dark phase (%% is modulo, remainder of division). 
  # ifelse(statement, value1, value2 takes on value1 if statement is TRUE, else it
  # takes on value2. 
  mutate(phase = ifelse(
    h_from_start %% 24 < 12, "d", "l"
  )) %>%
  #mutate(Animal = as.integer(Animal)) %>%
  #take only the first 3 digits of the animal, to get rid of the cage appendix.
  #mutate(Animal = substr(Animal, 1, 3)) %>%
  left_join(lookup_genotype, by = "Animal")
#  full_join(lookup_genotype, by = "Animal")

# For time point 2
start_dark_t2 <- ymd_hms("2022-04-01 18:00:00")   # Cohort 1 = Normal Cycle

# Time point 2
file_data2 = file.choose()  
# Cohort 1 = Normal Cycle

data2 <- read_excel(file_data2) %>% 
   mutate(tp = 2) %>%
   mutate(DateTime = paste(Date, Time)) %>%
   mutate(DateTime = dmy_hms(DateTime)) %>%
   mutate(h_from_start = as.double(difftime(DateTime, start_dark_t2, units="hours"))) %>%
#   # If the remainder of dividing h_from_start by 24 is under 12, it means the animal
#   # is in dark phase (%% is modulo, remainder of division). 
#   # ifelse(statement, value1, value2 takes on value1 if statement is TRUE, else it
#   # takes on value2. 
   mutate(phase = ifelse(
     h_from_start %% 24 < 12, "d", "l"
   )) %>%
#   mutate(Animal = as.integer(Animal)) %>%
  left_join(lookup_genotype, by = "Animal")
#   full_join(lookup_genotype, by = "Animal")

#check for duplicate IDs among cohorts and change them if present
dupl_IDs = intersect(data1$Animal, data2$Animal)  # NO DUBLICATES FOUND

#----------------
# ONLY KEEP DATA FROM DAY 2 to 6 (total 5 days)
#data1 <- data1 %>%
#  mutate(Date = lubridate::dmy(Date)) %>%
#  filter(Date >= as.Date("2022-02-26"),
#         Date <= as.Date("2022-03-02"))

#data2 <- data2 %>%
#  mutate(Date = lubridate::dmy(Date)) %>%
#  filter(Date >= as.Date("2022-04-02"),
#         Date <= as.Date("2022-04-06"))
#----------------

# FInalise DATA set and add col. for distance in meters
#data <- data1 %>% mutate(distance.m = Distance/1000)
 data <- bind_rows(data1, data2) %>% mutate(distance.m = Distance/1000)



# Add values for hours in experimental day
# Here, I take the variable h_from_start and divide it by 24. Then I use floor()
# to round it off to the closest smaller integer (example floor(5.45) = 5, 
# floor(6.99) = 6). Then I add 1 to make the first exp_day when h_from_start is
# from 0 to 23 equal to 1 instead of 0. 
data <- data %>%
  mutate(exp_day = floor(h_from_start/24) + 1,
         PI = batch_name)
#  mutate(exp_day = floor(h_from_start/24) + 1)

# Delete doubles
data <- data %>%
  #group_by(DateTime, Date, Time, h_from_start, exp_day, tp, id, genotype, phase) %>%
  group_by(DateTime, Date, Time, h_from_start, exp_day, tp, Animal, genotype, phase, PI, Sex) %>%
  summarise(
    distance.m = sum(distance.m), 
    Distance = sum(Distance), 
    Inside = sum(`Time inside`)
  ) %>%
  ungroup()
  
# 3. SAVE DATA --------------------------------------------------------------
write.csv(data, paste("PreProcessed_SAM_", batch_name, "_NS_", Sys.Date(), ".csv", sep=""))
