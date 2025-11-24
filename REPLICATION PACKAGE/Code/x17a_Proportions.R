#-----------------------------------------------#
#    x17a_Proportions.R                         #
#    Compute proportion of simulated alphas and #
#    lambdas that fall in each quadrant for     #
#    each forecaster.                           #
#-----------------------------------------------#

#--------------------- Beginning of Program -------------------------#

# Set working directory to input/output paths (CHANGE FILEPATH BELOW) #
setwd(".../.../REPLICATION PACKAGE/Output")
pfa_file_list <- list.files(path = "./Simulations/", pattern = "pfa")
arps_file_list <- list.files(path = "./Simulations/", pattern = "arps")
forecasters_pfa <- list()

for (file in pfa_file_list) {
    fpath <- paste("./Simulations/", file, sep = "")
    data <- read_excel(fpath, col_names = FALSE)
    colnames(data) = c("ID", "q1", "q2", "q3", "q4")
    forecasters_pfa <- c(forecasters_pfa, data$ID)
}

unique_forecasters_pfa <- unique(forecasters_pfa)
unique_forecasters_pfa <- sort.int(unlist(unique_forecasters_pfa))

forecasters_arps <- list()

for (file2 in arps_file_list) {
  f2path <- paste("./Simulations/", file2, sep = "")
  dat <- read_excel(f2path, col_names = FALSE)
  colnames(dat) = c("ID", "q1", "q2", "q3", "q4")
  forecasters_arps <- c(forecasters_arps, dat$ID)
}

unique_forecasters_arps <- unique(forecasters_arps)
unique_forecasters_arps <- sort.int(unlist(unique_forecasters_arps))

quadrant <- list('q1', 'q2', 'q3', 'q4')

for (pers in unique_forecasters_pfa) {
  df_out <- data.frame()
  for (q in quadrant) {
    q_list <- list()
    for (f in pfa_file_list) {
      fp <- paste("./Simulations/", f, sep = "")
      df <- read_excel(fp, col_names = FALSE)
      colnames(df) = c("ID", "q1", "q2", "q3", "q4")
      x <- which(df$ID==pers)
      if (pers %in% df$ID) {
        q_list <- c(q_list, (df[x, q]/1000))
      }
      else {
        q_list <- c(q_list, 0)
      }
    }
    q_list <- data.frame(q_list)
    colnames(q_list) <- c("gdp_Aroll","gdp_Broll","hicp_Aroll","hicp_Broll","urate_Aroll","urate_Broll")
    df_out <- rbind(df_out, q_list)
  }
  row.names(df_out) <- c("q1", "q2", "q3", "q4")
  print(df_out)
  out_name <- paste("./Simulations/Proportions/", pers, "_pfa.xlsx", sep="")
  write_xlsx(df_out, out_name)
}

for (pers in unique_forecasters_arps) {
  df_out <- data.frame()
  for (q in quadrant) {
    q_list <- list()
    for (f in arps_file_list) {
      fp <- paste("./Simulations/", f, sep = "")
      df <- read_excel(fp, col_names = FALSE)
      colnames(df) = c("ID", "q1", "q2", "q3", "q4")
      x <- which(df$ID==pers)
      if (pers %in% df$ID) {
        q_list <- c(q_list, (df[x, q]/1000))
      }
      else {
        q_list <- c(q_list, 0)
      }
    }
    q_list <- data.frame(q_list)
    colnames(q_list) <- c("gdp_Aroll","gdp_Broll","hicp_Aroll","hicp_Broll","urate_Aroll","urate_Broll")
    df_out <- rbind(df_out, q_list)
  }
  row.names(df_out) <- c("q1", "q2", "q3", "q4")
  print(df_out)
  out_name <- paste("./Simulations/Proportions/", pers, "_arps.xlsx", sep="")
  write_xlsx(df_out, out_name)
}


