### VIEWER SOFTWARE PREPROCESSING SCRIPT --------------------------------------

# author: Narendra Solanki (NS)
# last update: 06.11.2023


# !! PLEASE READ THE HOW TO BEFORE RUNNING THIS SCRIPT !! #


# The following code concatenates all raw data (multiple files) obtained with 
# the Biobserve Viewer software from one folder to one dataframe called data. 
#
# When running the code, you will be asked to select the folder that contains
# the raw data. After this, the script will concatenate all .xls files in the 
# folder that end in aaaXX.xls, with XX being numbers that corresponds to the 
# animal ID. 
#
# The script saves both a csv and an xlsx file in the directory:
# .../6. Data from Behavioral Tests/analysis
#
# These pre-processed files can be used to analyze the data afterwards. This 
# script does not add or remove any data from the raw data and can be used 
# for any raw Biobserve Viewer data stored in different folders. 

# Contents:
# 0. Libraries are loaded
# 1. The right folder is selected (by you)
# 2. All raw data is concatenated
# 3. The data is stored

### NOW, just press "Source" (top right of this window) 
### select the data to pre-process (the pop up window can be hidden behind RStudio)



### 0. LIBRARIES --------------------------------------------------------------

# Empty global environment
rm(list = ls())

# Load necessary packages
library(tidyverse)
library(readxl)
library(lubridate)
library(reader)



### 1. SELECT THE RIGHT FOLDER ------------------------------------------------

### Here, you will be asked to select the folder in a pop-up.
#directory = choose.dir(getwd())

directory = "~/AOCF-Behavioral Tests/Barnes Maze test/control data/group data/gr1/Test/xls/"

# Here, we set the directory to the chosen folder
setwd(directory)

# Technical: this is meant to change the directory from having double back-
# slashes to having one forward slash (may vary per computer)
directory = getwd()

# Here we decide what name to save the file under
dir_parts = str_split(directory, "[/,\\,\\\\]")[[1]]
save_name = c(dir_parts[(grep("Barnes Maze test", dir_parts))], dir_parts[(grep("Barnes Maze test", dir_parts)+3)])
save_name <- paste(save_name, collapse = "_")

### 2. SELECT THE RAW DATA FILES ----------------------------------------------

# An empty vector is created in which we will store the locations of the raw
# data files
raw_files <-  c()

# We list the files in the current folder. If they already have a XX.xls ending,
# and thus are raw data files, they are added to the vector raw_files
list_files = list.files(pattern = "*\\d.xls")
raw_files = c(raw_files, list_files)

# The folders within the selected directory are listed 
list_directories = list.dirs()

# We loop through the directories to see if they contain raw data files. When 
# this is the case, they are added to the vector raw_file
# list.dirs() always has one folder called ".", so when there is more than one folder,
# it should be checked whether there is raw data in the folder
if (length(list_directories) > 1) {
  # Loop through folders
  for (i in c(1:length(list_directories))) {
    folder = list_directories[i]
    # Set that folder as working directory
    setwd(folder)
    # List all raw data files.
    list_files = list.files(pattern = "*\\d.xls")
    # If there are more than 1 raw data files, add them to the raw_files vector
    if (length(list_files > 1)) {
      path_to_file = paste(folder,"/",list_files,sep="")
      raw_files = c(raw_files, path_to_file)
    }
    # Set directory back to the chosen directory
    setwd(directory)
  }
}


### 3. DATA CONCATENATION -----------------------------------------------------

# List all xls files in the directory that end with XX.xls, with XX being 
# numbers
list_files = raw_files

# Create an empty table in which all the data will be concatenated
data = as_tibble(data.frame())

# Loop over all xlsx files in the directory 
for (i in c(1:(length(list_files)))) {
  # Extract animal number and experimental condition from name of xls file
  file_name = list_files[i]
  
  file_add = as_tibble(file_name) %>% 
    rename(file_name = value) 
  file_column = tibble()
  
  # Read in the raw data Excel file and skip the first rows and select the 
  # needed columns
  
  # Attach the zone names to the column names and include a row that has the zone names for each animal
  raw_file = read_excel(list_files[i], skip = 15)
  general_colnames <- c(raw_file[1, ])
  zones <- grep(pattern = "^Zone:", colnames(raw_file))
  for (m in 1:(length(zones)-10)){
    for (k in 1:11){
      raw_file[1, zones[m]+k-1] = paste(raw_file[1, zones[m]+k-1], strsplit(colnames(raw_file)[zones[m]], ": ")[[1]][2])
    }
  }
  colnames(raw_file) <- general_colnames

  # The number of rows of the added animal+condition table should correspond 
  # to the data
  for (j in c(1:nrow(raw_file))){
    file_column = bind_rows(file_column, file_add)
  }
  
  # To the raw data, the columns containing animal ID and filename
  raw_file = bind_cols(raw_file, file_column)
  
  # Bind the data of the current xls file to the data dataframe
  data = bind_rows(data, raw_file)
  
}

# Some columns are renamed
data = data %>%
  rename(
    no = `No.`,
    run_time = `Run time`, 
    date = Date,
    time = Time
  ) %>%
  
  # Here, just empty rows are deleted. The raw data comes with an empty row 
  # between the per minute and summed data. This row is deleted here. So for 
  # every xls file, one row is deleted.
  filter(!is.na(no)) %>%
  
  # Here we change the format of some time/date columns
  mutate(
    # run_time = format(as.POSIXct(run_time, tz = "CET", origin = "1970-01-01"), format = "%M:%S"),
    
    run_time = as.POSIXct(run_time, format = "%H:%M:%S", tz = "CET"),
    run_time = format(run_time, format = "%M:%S"),
    # run_time = convertToDateTime(run_time, tz = "CET"), # WORKS
    time = substring(time, 12, 19),
    date = as.numeric(date),
    date = as.Date(date, origin = "1899-12-30")
    #date = ymd(date)
  )
#mutate(
# run_time = format(run_time, format = "%M:%S"),
#time = substring(time, 12, 19),
#date = ymd(date)
#)


### 4. SAVE THE DATA ----------------------------------------------------------

# Set the working directory to the 6. Data from Behavioral Tests folder of the data 
setwd(directory)
dir_parts = str_split(getwd(), "[/,\\,\\\\]")[[1]]
path = dir_parts[1:grep("6. Data from Behavioral Tests", dir_parts)]
path = paste(path, collapse = "/")
setwd(path)

# In the 6. Data from Behavorial Tests, the folder "analysis" is created. If it
# already exists nothing happens
dir.create("analysis/", showWarnings = FALSE)
setwd("analysis")

# Find the name of the project to create a folder within the analysis folder
project = dir_parts[grep("6. Data from Behavioral Tests", dir_parts)+1]
dir.create(project, showWarnings = FALSE)
setwd(project)


# Save the data file that contains all information as CSV
write.csv(data, paste(save_name,'_',Sys.Date(),'.csv', sep=""), 
          row.names = FALSE)

### Save the data as an Excel file. Should this not work, refer to the HOW TO ###
library(rJava)
library(xlsx)
write.xlsx(data, paste(save_name,"_",Sys.Date(),'.xlsx', sep=""), 
           col.names = TRUE, row.names = TRUE)
