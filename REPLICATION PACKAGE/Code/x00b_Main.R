#-----------------------------------------------#
#    x00b_Main.R                                #
#    Run all .R files                           #
#-----------------------------------------------#

#--------------------- Beginning of Program -------------------------#

# clean global environment of any pre-existing files and variables #
rm(list=ls(all.names = TRUE))

# install and load required libraries #
check.packages <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg))
    install.packages(new.pkg, dependencies = TRUE)
  suppressMessages(sapply(pkg, require, character.only = TRUE))
}

load_packages <- c("ggplot2", "readxl", "tidyr", "tidyverse", "writexl", "stringr", "NLP",
                   "ggpubr", "reshape2", "patchwork", "haven")
check.packages(load_packages)

library(readxl)
library(tidyverse)
library(writexl)
library(stringr)
library(NLP)
library(ggplot2)
library(ggpubr)
library(reshape2)
library(patchwork)

# set seed #
set.seed(12345)

# set working directory #
current_dir <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(current_dir)



# Figures 1, 4, and 5 #
setwd(current_dir)
source("x14_Quadrant_Scatterplots.R") # change filepaths @ lines 10, 38, and 42

# Figures 9 and 10 #
setwd(current_dir)
source("x15_Simulation_Scatterplots.R") # change filepaths @ lines 9, 11, and 122

# Figures 2, 3, 6, 7, 7A, 8, 8A, and 13 #
setwd(current_dir)
source("x16_Pesaran_Plots.R") # change filepaths @ lines 10, 46, 190, 199,
                              #                          270, 277, 442, 478,
                              #                          590, and 627

# proportion of simulated alphas/lambdas that fall in each quadrant #
setwd(current_dir)
source("x17a_Proportions.R") # change filepath @ line 11

# aggregate proportions across forecasters #
setwd(current_dir)
source("x17b_Aggregate_Simulations.R") # change filepaths @ lines 11, 58, 69, and 114

# Figures 11 and 12 #
setwd(current_dir)
source("x17c_Simulation_Barplots.R") # change filepaths @ lines 9 and 82

# Switch to x00c_Main.m #
