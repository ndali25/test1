#-----------------------------------------------#
#    x17c_Simulation_Barplots.R                 #
#    Figures 11 and 12                          #
#-----------------------------------------------#

#--------------------- Beginning of Program -------------------------#

# Set working directory to input path (CHANGE FILEPATH BELOW) #
setwd(".../.../REPLICATION PACKAGE/Output/Simulations/Aggregated")

data <- read_excel("./pfa_Qprobs.xlsx")
data$Survey <- as.numeric(data$Survey)
data$NE <- as.numeric(data$NE)
data$NW <- as.numeric(data$NW)
data$SE <- as.numeric(data$SE)
data$SW <- as.numeric(data$SW)
data$NE_prop <- data$NE/data$Survey
data$NW_prop <- data$NW/data$Survey
data$SE_prop <- data$SE/data$Survey
data$SW_prop <- data$SW/data$Survey
clean_data <- na.omit(data)
clean_data <- subset(clean_data, select = -c(NE, NW, SE, SW))
colnames(clean_data) <- c("ID", "Survey", "NE", "NW", "SE", "SW")
temp <- clean_data[,1:2]
clean_data <- clean_data[,3:6]
clean_data$max_val <- do.call('pmax', clean_data)
final_data <- cbind(temp, clean_data)
split <- split(final_data, final_data$Survey)

plot_df <- data.frame(cbind(split$'6'$ID, split$'6'$max_val))
colnames(plot_df) <- c("ID", "max_val")
plot_df$max_val <- as.numeric(as.character(plot_df$max_val))

# Barplot
pfa_bar <- plot_df %>%
  ggplot(aes(fct_rev(fct_reorder(ID,max_val)),max_val)) +
  geom_bar(stat='identity', fill='steelblue') +
  ggtitle("Highest Aggregate Percentage in a Quadrant: Point Forecasts") +
  ylim(0, 0.9) +
  labs(x="Forecaster ID", y="Percent")+
  geom_hline(yintercept=0.5, color="red") +
  theme_classic() + theme(plot.title = element_text(hjust=0.5))


  
data2 <- read_excel("./arps_Qprobs.xlsx")
data2$Survey <- as.numeric(data2$Survey)
data2$NE <- as.numeric(data2$NE)
data2$NW <- as.numeric(data2$NW)
data2$SE <- as.numeric(data2$SE)
data2$SW <- as.numeric(data2$SW)
data2$NE_prop <- data2$NE/data2$Survey
data2$NW_prop <- data2$NW/data2$Survey
data2$SE_prop <- data2$SE/data2$Survey
data2$SW_prop <- data2$SW/data2$Survey
clean_data2 <- na.omit(data2)
clean_data2 <- subset(clean_data2, select = -c(NE, NW, SE, SW))
colnames(clean_data2) <- c("ID2", "Survey", "NE", "NW", "SE", "SW")
temp2 <- clean_data2[,1:2]
clean_data2 <- clean_data2[,3:6]
clean_data2$max_val2 <- do.call('pmax', clean_data2)
final_data2 <- cbind(temp2, clean_data2)
split2 <- split(final_data2, final_data2$Survey)

plot_df2 <- data.frame(cbind(split2$'6'$ID, split2$'6'$max_val2))
colnames(plot_df2) <- c("ID2", "max_val2")
plot_df2$max_val2 <- as.numeric(as.character(plot_df2$max_val2))

# Barplot
arps_bar <- plot_df2 %>%
  ggplot(aes(fct_rev(fct_reorder(ID2,max_val2)),max_val2)) +
  geom_bar(stat='identity', fill='steelblue') +
  ggtitle("Highest Aggregate Percentage in a Quadrant: Density Forecasts") +
  ylim(0, 1) +
  labs(x="Forecaster ID", y="Percent")+
  geom_hline(yintercept=0.5, color="red") +
  theme_classic() + theme(plot.title = element_text(hjust=0.5))



# Set working directory to output path (CHANGE FILEPATH BELOW) #
setwd(".../.../REPLICATION PACKAGE/Output/Figures/")

ggsave(filename="figure11.jpg",
       plot = pfa_bar,
       device = NULL,
       path = ".",
       width = 8.5,
       height = 11,
       units = "in",
       dpi = 300)

ggsave(filename="figure12.jpg",
       plot = arps_bar,
       device = NULL,
       path = ".",
       width = 8.5,
       height = 11,
       units = "in",
       dpi = 300)
