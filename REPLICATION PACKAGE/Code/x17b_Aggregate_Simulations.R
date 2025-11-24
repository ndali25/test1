#-----------------------------------------------#
#    x17b_Aggregate_Simulations.R               #
#    Aggregate proportion of simulated alphas   #
#    and lambdas that fall in each quadrant     #
#    across forecasters.                        #
#-----------------------------------------------#

#--------------------- Beginning of Program -------------------------#

# Set working directory to input path (CHANGE FILEPATH BELOW) #
setwd(".../.../REPLICATION PACKAGE/Output/Simulations/Proportions/")
pfa_file_list <- list.files(path = ".", pattern = "pfa")
arps_file_list <- list.files(path = ".", pattern = "arps")

# PFA quadrant counts
df_pfa_count <- data.frame()
# PFA cumulative probabilities
df_pfa_prob <- data.frame()

for (file in pfa_file_list) {
  data <- read_excel(file)
  
  row_list1 <- list()
  row_list2 <- list()  
  
  input <- strsplit(as.String(file), split="[.]")[1]
  ID <- strsplit(input[[1]][1], split="[_]")[[1]][1]
  
  survey <- 0
  
  for (column in 1:6) {
    if (sum(data[,column]) != 0) {
      survey = survey + 1
    }
    else {
      # do nothing
    }
  }

  NE_tCount <- 1000*sum(data[2,])
  NW_tCount <- 1000*sum(data[1,])
  SW_tCount <- 1000*sum(data[3,])
  SE_tCount <- 1000*sum(data[4,])
  
  NE_cumProb <- sum(data[2,])
  NW_cumProb <- sum(data[1,])
  SW_cumProb <- sum(data[3,])
  SE_cumProb <- sum(data[4,])
  
  row_list1 <- c(ID, survey, NE_tCount, NW_tCount, SW_tCount, SE_tCount)
  df_pfa_count <- rbind(df_pfa_count, row_list1)
  
  row_list2 <- c(ID, survey, NE_cumProb, NW_cumProb, SW_cumProb, SE_cumProb)
  df_pfa_prob <- rbind(df_pfa_prob, row_list2)
}

# Set working directory to output path (CHANGE FILEPATH BELOW) #
setwd(".../.../REPLICATION PACKAGE/Output/Simulations/Aggregated/")

colnames(df_pfa_count) <- c("ID", "Survey", "NE", "NW", "SW", "SE")
out_name1 <- "pfa_Qcounts.xlsx"
write_xlsx(df_pfa_count, out_name1)

colnames(df_pfa_prob) <- c("ID", "Survey", "NE", "NW", "SW", "SE")
out_name2 <- "pfa_Qprobs.xlsx"
write_xlsx(df_pfa_prob, out_name2)

# Set working directory to input path (CHANGE FILEPATH BELOW) #
setwd(".../.../REPLICATION PACKAGE/Output/Simulations/Proportions/")

# ARPS quadrant counts
df_arps_count <- data.frame()
# ARPS cumulative probabilities
df_arps_prob <- data.frame()

for (file in arps_file_list) {
  data <- read_excel(file)
  
  row_list3 <- list()
  row_list4 <- list()  
  
  input <- strsplit(as.String(file), split="[.]")[1]
  ID <- strsplit(input[[1]][1], split="[_]")[[1]][1]
  
  survey <- 0
  
  for (column in 1:6) {
    if (sum(data[,column]) != 0) {
      survey = survey + 1
    }
    else {
      # do nothing
    }
  }
  
  NE_tCount <- 1000*sum(data[2,])
  NW_tCount <- 1000*sum(data[1,])
  SW_tCount <- 1000*sum(data[3,])
  SE_tCount <- 1000*sum(data[4,])
  
  NE_cumProb <- sum(data[2,])
  NW_cumProb <- sum(data[1,])
  SW_cumProb <- sum(data[3,])
  SE_cumProb <- sum(data[4,])
  
  row_list3 <- c(ID, survey, NE_tCount, NW_tCount, SW_tCount, SE_tCount)
  df_arps_count <- rbind(df_arps_count, row_list3)
  
  row_list4 <- c(ID, survey, NE_cumProb, NW_cumProb, SW_cumProb, SE_cumProb)
  df_arps_prob <- rbind(df_arps_prob, row_list4)
}

# Set working directory to output path (CHANGE FILEPATH BELOW) #
setwd(".../.../REPLICATION PACKAGE/Output/Simulations/Aggregated/")

colnames(df_arps_count) <- c("ID", "Survey", "NE", "NW", "SW", "SE")
out_name3 <- "arps_Qcounts.xlsx"
write_xlsx(df_arps_count, out_name3)

colnames(df_arps_prob) <- c("ID", "Survey", "NE", "NW", "SW", "SE")
out_name4 <- "arps_Qprobs.xlsx"
write_xlsx(df_arps_prob, out_name4)


