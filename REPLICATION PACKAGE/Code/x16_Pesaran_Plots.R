#-----------------------------------------------#
#    x16_Pesaran_Plots.R                        #
#    Figures 2, 3, 6, 7, 7A, 8, 8A, and 13      #
#-----------------------------------------------#

#--------------------- Beginning of Program -------------------------#

# Figure 2 #
# Set working directory to input path (CHANGE FILEPATH BELOW) #
setwd(".../.../REPLICATION PACKAGE/Data/Ready/")
df <- read_excel("./avg_fp_vals.xlsx")

gdpA <- df[, c(1,2,3,4)]
gdpB <- df[, c(1,2,5,6)]
hicpA <- df[, c(1,2,7,8)]
hicpB <- df[, c(1,2,9,10)]
urateA <- df[, c(1,2,11,12)]
urateB <- df[, c(1,2,13,14)]

# Clean input data #
names(gdpA)[names(gdpA) == "tgdate"] <- "date"
names(gdpA)[names(gdpA) == "gdpAroll_pfa"] <- "mean_pfa"
names(gdpA)[names(gdpA) == "gdpAroll_arps"] <- "mean_arps"

names(gdpB)[names(gdpB) == "tgdate"] <- "date"
names(gdpB)[names(gdpB) == "gdpBroll_pfa"] <- "mean_pfa"
names(gdpB)[names(gdpB) == "gdpBroll_arps"] <- "mean_arps"

names(hicpA)[names(hicpA) == "tgdate"] <- "date"
names(hicpA)[names(hicpA) == "hicpAroll_pfa"] <- "mean_pfa"
names(hicpA)[names(hicpA) == "hicpAroll_arps"] <- "mean_arps"

names(hicpB)[names(hicpB) == "tgdate"] <- "date"
names(hicpB)[names(hicpB) == "hicpBroll_pfa"] <- "mean_pfa"
names(hicpB)[names(hicpB) == "hicpBroll_arps"] <- "mean_arps"

names(urateA)[names(urateA) == "tgdate"] <- "date"
names(urateA)[names(urateA) == "urateAroll_pfa"] <- "mean_pfa"
names(urateA)[names(urateA) == "urateAroll_arps"] <- "mean_arps"

names(urateB)[names(urateB) == "tgdate"] <- "date"
names(urateB)[names(urateB) == "urateBroll_pfa"] <- "mean_pfa"
names(urateB)[names(urateB) == "urateBroll_arps"] <- "mean_arps"

# Set working directory to output path (CHANGE FILEPATH BELOW) #
setwd(".../.../REPLICATION PACKAGE/Output/Figures/")

# This is included in the graph but not in the rest of the analysis. 
# See ${ready}\new_accuracymeasuresv3_gdpAroll_w2009q1.dta and/or 
# ${code}/x06_Drop_Low_Counts.do for more details.
gdpA$mean_pfa[43] <- as.numeric(2.175846) # Value for 2009Q1

gdpA_pfa <- ggplot(gdpA, aes(x=date, y=mean_pfa)) +
  geom_rect(data=gdpA, mapping=aes(xmin= gdpA$date[38], xmax= gdpA$date[42], ymin=0, ymax=6), fill='gray85', alpha=0.1) +
  geom_rect(data=gdpA, mapping=aes(xmin= gdpA$date[52], xmax= gdpA$date[57], ymin=0, ymax=6), fill='gray85', alpha=0.1) +
  geom_line(color = 'red4', size = 0.5) +
  ggtitle('GDP Growth point forecasts') +
  ylim(0,6) +
  ylab(expression(bar(FP[t]))) +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=8), axis.title = element_blank())

hicpA_pfa <- ggplot(hicpA, aes(x=date, y=mean_pfa)) +
  geom_rect(data=gdpA, mapping=aes(xmin= hicpA$date[38], xmax= hicpA$date[42], ymin=0, ymax=3), fill='gray85', alpha=0.1) +
  geom_rect(data=gdpA, mapping=aes(xmin= hicpA$date[52], xmax= hicpA$date[57], ymin=0, ymax=3), fill='gray85', alpha=0.1) +
  geom_line(color = 'red4', size = 0.5) +
  ggtitle('Inflation point forecasts') +
  ylim(0,3) +
  ylab(expression(bar(FP[t]))) +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=8), axis.title = element_blank())

urateA_pfa <- ggplot(urateA, aes(x=date, y=mean_pfa)) +
  geom_rect(data=gdpA, mapping=aes(xmin= urateA$date[38], xmax= urateA$date[42], ymin=0, ymax=2), fill='gray85', alpha=0.1) +
  geom_rect(data=gdpA, mapping=aes(xmin= urateA$date[52], xmax= urateA$date[57], ymin=0, ymax=2), fill='gray85', alpha=0.1) +
  geom_line(color = 'red4', size = 0.5) +
  ggtitle('Unemployment point forecasts') +
  ylim(0,2) +
  ylab(expression(bar(FP[t]))) +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=8), axis.title = element_blank())

gdpA_arps <- ggplot(gdpA, aes(x=date, y=mean_arps)) +
  geom_rect(data=gdpA, mapping=aes(xmin= gdpA$date[38], xmax= gdpA$date[42], ymin=0, ymax=1), fill='gray85', alpha=0.1) +
  geom_rect(data=gdpA, mapping=aes(xmin= gdpA$date[52], xmax= gdpA$date[57], ymin=0, ymax=1), fill='gray85', alpha=0.1) +
  geom_line(color = 'red4', size = 0.5) +
  ggtitle('GDP Growth density forecasts') +
  ylim(0,1) +
  ylab(expression(bar(FP[t]))) +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=8), axis.title = element_blank())

hicpA_arps <- ggplot(hicpA, aes(x=date, y=mean_arps)) +
  geom_rect(data=hicpA, mapping=aes(xmin= hicpA$date[38], xmax= hicpA$date[42], ymin=0, ymax=0.7), fill='gray85', alpha=0.1) +
  geom_rect(data=hicpA, mapping=aes(xmin= hicpA$date[52], xmax= hicpA$date[57], ymin=0, ymax=0.7), fill='gray85', alpha=0.1) +
  geom_line(color = 'red4', size = 0.5) +
  ggtitle('Inflation density forecasts') +
  ylim(0,0.7) +
  ylab(expression(bar(FP[t]))) +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=8), axis.title = element_blank())

urateA_arps <- ggplot(urateA, aes(x=date, y=mean_arps)) +
  geom_rect(data=urateA, mapping=aes(xmin= urateA$date[38], xmax= urateA$date[42], ymin=0, ymax=0.4), fill='gray85', alpha=0.1) +
  geom_rect(data=urateA, mapping=aes(xmin= urateA$date[52], xmax= urateA$date[57], ymin=0, ymax=0.4), fill='gray85', alpha=0.1) +
  geom_line(color = 'red4', size = 0.5) +
  ggtitle('Unemployment density forecasts') +
  ylim(0,0.4) +
  ylab(expression(bar(FP[t]))) +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=8), axis.title = element_blank())

figure2 <- ggarrange(gdpA_pfa, hicpA_pfa, urateA_pfa, gdpA_arps, hicpA_arps, urateA_arps, ncols = 3, nrows = 2)
figure2 <- annotate_figure(figure2, top = text_grob("Average Forecast Performance: One-Year-Ahead Forecasts", face = "bold", size = 10))
ggsave(filename="figure2.jpg",
       plot = figure2,
       device = NULL,
       path = "./",
       width = 8.5,
       height = 11,
       units = "in",
       dpi = 300)



# Figure 3 #
gdpB_pfa <- ggplot(gdpB, aes(x=date, y=mean_pfa)) +
  geom_rect(data=gdpA, mapping=aes(xmin= gdpB$date[38], xmax= gdpB$date[42], ymin=0, ymax=8), fill='gray85', alpha=0.1) +
  geom_rect(data=gdpA, mapping=aes(xmin= gdpB$date[52], xmax= gdpB$date[57], ymin=0, ymax=8), fill='gray85', alpha=0.1) +
  geom_line(color = 'red4', size = 0.5) +
  ggtitle('GDP Growth point forecasts') +
  ylim(0,8) +
  ylab(expression(bar(FP[t]))) +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=8), axis.title = element_blank())

hicpB_pfa <- ggplot(hicpB, aes(x=date, y=mean_pfa)) +
  geom_rect(data=gdpA, mapping=aes(xmin= hicpB$date[38], xmax= hicpB$date[42], ymin=0, ymax=3), fill='gray85', alpha=0.1) +
  geom_rect(data=gdpA, mapping=aes(xmin= hicpB$date[52], xmax= hicpB$date[57], ymin=0, ymax=3), fill='gray85', alpha=0.1) +
  geom_line(color = 'red4', size = 0.5) +
  ggtitle('Inflation point forecasts') +
  ylim(0,3) +
  ylab(expression(bar(FP[t]))) +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=8), axis.title = element_blank())

urateB_pfa <- ggplot(urateB, aes(x=date, y=mean_pfa)) +
  geom_rect(data=gdpA, mapping=aes(xmin= urateB$date[38], xmax= urateB$date[42], ymin=0, ymax=4), fill='gray85', alpha=0.1) +
  geom_rect(data=gdpA, mapping=aes(xmin= urateB$date[52], xmax= urateB$date[57], ymin=0, ymax=4), fill='gray85', alpha=0.1) +
  geom_line(color = 'red4', size = 0.5) +
  ggtitle('Unemployment point forecasts') +
  ylim(0,4) +
  ylab(expression(bar(FP[t]))) +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=8), axis.title = element_blank())

gdpB_arps <- ggplot(gdpB, aes(x=date, y=mean_arps)) +
  geom_rect(data=gdpA, mapping=aes(xmin= gdpB$date[38], xmax= gdpB$date[42], ymin=0, ymax=0.8), fill='gray85', alpha=0.1) +
  geom_rect(data=gdpA, mapping=aes(xmin= gdpB$date[52], xmax= gdpB$date[57], ymin=0, ymax=0.8), fill='gray85', alpha=0.1) +
  geom_line(color = 'red4', size = 0.5) +
  ggtitle('GDP Growth density forecasts') +
  ylim(0,0.8) +
  ylab(expression(bar(FP[t]))) +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=8), axis.title = element_blank())

hicpB_arps <- ggplot(hicpB, aes(x=date, y=mean_arps)) +
  geom_rect(data=gdpA, mapping=aes(xmin= hicpB$date[38], xmax= hicpB$date[42], ymin=0, ymax=1), fill='gray85', alpha=0.1) +
  geom_rect(data=gdpA, mapping=aes(xmin= hicpB$date[52], xmax= hicpB$date[57], ymin=0, ymax=1), fill='gray85', alpha=0.1) +
  geom_line(color = 'red4', size = 0.5) +
  ggtitle('Inflation density forecasts') +
  ylim(0,1) +
  ylab(expression(bar(FP[t]))) +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=8), axis.title = element_blank())

urateB_arps <- ggplot(urateB, aes(x=date, y=mean_arps)) +
  geom_rect(data=gdpA, mapping=aes(xmin= urateB$date[38], xmax= urateB$date[42], ymin=0, ymax=0.6), fill='gray85', alpha=0.1) +
  geom_rect(data=gdpA, mapping=aes(xmin= urateB$date[52], xmax= urateB$date[57], ymin=0, ymax=0.6), fill='gray85', alpha=0.1) +
  geom_line(color = 'red4', size = 0.5) +
  ggtitle('Unemployment density forecasts') +
  ylim(0,0.6) +
  ylab(expression(bar(FP[t]))) +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=8), axis.title = element_blank())

figure3 <- ggarrange(gdpB_pfa, hicpB_pfa, urateB_pfa, gdpB_arps, hicpB_arps, urateB_arps, ncols = 3, nrows = 2)
figure3 <- annotate_figure(figure3, top = text_grob("Average Forecast Performance: One-Year/One-Year Forward Forecasts", face = "bold", size = 10))
ggsave(filename="figure3.jpg",
       plot = figure3,
       device = NULL,
       path = "./",
       width = 8.5,
       height = 11,
       units = "in",
       dpi = 300)



# Figure 6 #
# Set working directory to input path (CHANGE FILEPATH BELOW) #
setwd(".../.../REPLICATION PACKAGE/Data/Ready/")
gdpA <- read_excel("./fp_and_dis_gdpAroll.xls")
gdpB <- read_excel("./fp_and_dis_gdpBroll.xls")
hicpA <- read_excel("./fp_and_dis_hicpAroll.xls")
hicpB <- read_excel("./fp_and_dis_hicpBroll.xls")
urateA <- read_excel("./fp_and_dis_urateAroll.xls")
urateB <- read_excel("./fp_and_dis_urateBroll.xls")

# Set working directory to output path (CHANGE FILEPATH BELOW) #
setwd(".../.../REPLICATION PACKAGE/Output/Figures/")

g1 <- ggplot(gdpA, aes(x=rel_dis, y=rel_fp)) +
  geom_point(color = "steelblue") +
  geom_smooth(method=lm, se=FALSE, color = 'red4', size = 0.5) +
  ggtitle("1-year-ahead GDP Growth") +
  xlab("Average Relative Disagreement") +
  ylab("Average Relative Forecast Performance") +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=13), axis.title=element_text(size=8)) +
  stat_cor(cor.coef.name = "r", aes(label = ..r.label..), label.x = 0)

g2 <- ggplot(gdpB, aes(x=rel_dis, y=rel_fp)) +
  geom_point(color = "steelblue") +
  geom_smooth(method=lm, se=FALSE, color = 'red4', size = 0.5) +
  ggtitle("1-year/1-year forward GDP Growth") +
  xlab("Average Relative Disagreement") +
  ylab("Average Relative Forecast Performance") +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=13), axis.title=element_text(size=8)) +
  stat_cor(cor.coef.name = "r", aes(label = ..r.label..), label.x = 0)

g3 <- ggplot(hicpA, aes(x=rel_dis, y=rel_fp)) +
  geom_point(color = "steelblue") +
  geom_smooth(method=lm, se=FALSE, color = 'red4', size = 0.5) +
  ggtitle("1-year-ahead Inflation") +
  xlab("Average Relative Disagreement") +
  ylab("Average Relative Forecast Performance") +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=13), axis.title=element_text(size=8)) +
  stat_cor(cor.coef.name = "r", aes(label = ..r.label..), label.x = 0)

g4 <- ggplot(hicpB, aes(x=rel_dis, y=rel_fp)) +
  geom_point(color = "steelblue") +
  geom_smooth(method=lm, se=FALSE, color = 'red4', size = 0.5) +
  ggtitle("1-year/1-year forward Inflation") +
  xlab("Average Relative Disagreement") +
  ylab("Average Relative Forecast Performance") +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=13), axis.title=element_text(size=8)) +
  stat_cor(cor.coef.name = "r", aes(label = ..r.label..), label.x = 0)

g5 <- ggplot(urateA, aes(x=rel_dis, y=rel_fp)) +
  geom_point(color = "steelblue") +
  geom_smooth(method=lm, se=FALSE, color = 'red4', size = 0.5) +
  ggtitle("1-year-ahead Unemployment") +
  xlab("Average Relative Disagreement") +
  ylab("Average Relative Forecast Performance") +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=13), axis.title=element_text(size=8)) +
  stat_cor(cor.coef.name = "r", aes(label = ..r.label..), label.x = 0)

g6 <- ggplot(urateB, aes(x=rel_dis, y=rel_fp)) +
  geom_point(color = "steelblue") +
  geom_smooth(method=lm, se=FALSE, color = 'red4', size = 0.5) +
  ggtitle("1-year/1-year forward Unemployment") +
  xlab("Average Relative Disagreement") +
  ylab("Average Relative Forecast Performance") +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=13), axis.title=element_text(size=8)) +
  stat_cor(cor.coef.name = "r", aes(label = ..r.label..), label.x = 0)

figure6 <- ggarrange(g1, g2, g3, g4, g5, g6, ncol = 2, nrow = 3)
figure6 <- annotate_figure(figure6, top = text_grob("Disagreement and Forecast Performance: Point Forecasts", face = "bold", size = 13))
ggsave(filename="figure6.jpg",
       plot = figure6,
       device = NULL,
       path = "./",
       width = 8.5,
       height = 11,
       units = "in",
       dpi = 300)



# Figure 7 #
# Set working directory to input path (CHANGE FILEPATH BELOW) #
setwd(".../.../REPLICATION PACKAGE/Data/Ready/")

selected_forecasters <- read_excel("./selected_gdp_forecasters.xls")
selected_forecasters_wide <- pivot_wider(selected_forecasters, names_from = variable, values_from = point_fcast_accuracy_abs)
colnames(selected_forecasters_wide) <- c("mean_pfa", "point_fcast1", "point_fcast0", "point_fcast2", "point_fcast3")

# Set working directory to output path (CHANGE FILEPATH BELOW) #
setwd(".../.../REPLICATION PACKAGE/Output/Figures/")

f0 <- ggplot(selected_forecasters_wide, aes(x = mean_pfa, y = point_fcast1)) +
  geom_point(size = 1, color = "orange") +
  geom_smooth(method=lm, se=FALSE, color = "black", size = 0.5) +
  xlab(expression(bar(FP[t]))) +
  ylab(expression(FP[t]^i)) +
  scale_y_continuous(breaks = c(0, 1, 2, 3, 4, 5, 6), limits = c(0, 6.5)) +
  scale_x_continuous(breaks = c(0, 1, 2, 3, 4, 5, 6), limits = c(0, 6)) +
  ggtitle(expression(paste("   ", alpha, " < 0 , ", lambda, " > 1"))) +
  theme_classic() + 
  theme(plot.title = element_text(hjust = 0.5, size=13),
        axis.title.x = element_text(size=10),
        axis.title.y = element_text(size=10),
        axis.text.x = element_text(size=8),
        axis.text.y = element_text(size=8)) +
  stat_cor(aes(label = ..rr.label..), label.x = 0.0425, label.y = 2)

f1 <- ggplot(selected_forecasters_wide, aes(x = mean_pfa, y = point_fcast0)) +
  geom_point(size = 1, color = "blue") +
  geom_smooth(method=lm, se=FALSE, color = "black", size = 0.5) +
  xlab(expression(bar(FP[t]))) +
  ylab(expression(FP[t]^i)) +
  scale_y_continuous(breaks = c(0, 1, 2, 3, 4, 5, 6), limits = c(0, 6.5)) +
  scale_x_continuous(breaks = c(0, 1, 2, 3, 4, 5, 6), limits = c(0, 6)) +
  ggtitle(expression(paste("   ", alpha, " > 0 , ", lambda, " > 1"))) +
  theme_classic() + 
  theme(plot.title = element_text(hjust = 0.5, size=13),
        axis.title.x = element_text(size=10),
        axis.title.y = element_text(size=10),
        axis.text.x = element_text(size=8),
        axis.text.y = element_text(size=8)) +
  stat_cor(aes(label = ..rr.label..), label.x = 0.0425, label.y = 3)

f2 <- ggplot(selected_forecasters_wide, aes(x = mean_pfa, y = point_fcast2)) +
  geom_point(size = 1, color = "purple") +
  geom_smooth(method=lm, se=FALSE, color = "black", size = 0.5) +
  xlab(expression(bar(FP[t]))) +
  ylab(expression(FP[t]^i)) +
  scale_y_continuous(breaks = c(0, 1, 2, 3, 4, 5, 6), limits = c(0, 6.5)) +
  scale_x_continuous(breaks = c(0, 1, 2, 3, 4, 5, 6), limits = c(0, 6)) +
  ggtitle(expression(paste("   ", alpha, " < 0 , ", lambda, " < 1"))) +
  theme_classic() + 
  theme(plot.title = element_text(hjust = 0.5, size=13),
        axis.title.x = element_text(size=10),
        axis.title.y = element_text(size=10),
        axis.text.x = element_text(size=8),
        axis.text.y = element_text(size=8)) +
  stat_cor(aes(label = ..rr.label..), label.x = 0.0425, label.y = 2)

f3 <- ggplot(selected_forecasters_wide, aes(x = mean_pfa, y = point_fcast3)) +
  geom_point(size = 1, color = "red") +
  geom_smooth(method=lm, se=FALSE, color = "black", size = 0.5) +
  xlab(expression(bar(FP[t]))) +
  ylab(expression(FP[t]^i)) +
  scale_y_continuous(breaks = c(0, 1, 2, 3, 4, 5, 6), limits = c(0, 6.5)) +
  scale_x_continuous(breaks = c(0, 1, 2, 3, 4, 5, 6), limits = c(0, 6)) +
  ggtitle(expression(paste("   ", alpha, " > 0 , ", lambda, " < 1"))) +
  theme_classic() + 
  theme(plot.title = element_text(hjust = 0.5, size=13),
        axis.title.x = element_text(size=10),
        axis.title.y = element_text(size=10),
        axis.text.x = element_text(size=8),
        axis.text.y = element_text(size=8)) +
  stat_cor(aes(label = ..rr.label..), label.x = 0.0425, label.y = 2)

figure7 <- ggarrange(f0, f1, f2, f3, ncol = 2, nrow = 2)
text <- paste("Forecast Performance and Fitted Regression Lines",
              "1-year ahead GDP Growth", sep = "\n")
figure7 <- annotate_figure(figure7, top = text_grob(text, face = "bold", size = 16))

selected_forecasters_wide_sub <- subset(selected_forecasters_wide, mean_pfa <= 3)

f0_sub <- ggplot(selected_forecasters_wide, aes(x = mean_pfa, y = point_fcast1)) +
  geom_point(size = 1, color = "orange") +
  geom_smooth(method=lm, se=FALSE, color = "black", size = 0.5) +
  xlab(expression(bar(FP[t]))) +
  ylab(expression(FP[t]^i)) +
  scale_y_continuous(breaks = c(0, 0.5, 1, 1.5, 2, 2.5, 3), limits = c(0, 3)) +
  scale_x_continuous(breaks = c(0, 0.5, 1, 1.5, 2, 2.5, 3), limits = c(0, 3)) +
  ggtitle(expression(paste("   ", alpha, " < 0 , ", lambda, " > 1"))) +
  theme_classic() + 
  theme(plot.title = element_text(hjust = 0.5, size=13),
        axis.title.x = element_text(size=10),
        axis.title.y = element_text(size=10),
        axis.text.x = element_text(size=8),
        axis.text.y = element_text(size=8)) +
  ggplot2::annotate("text", x = 0.3, y = 2, label = expression(paste(R^2, " = 0.91")))

f1_sub <- ggplot(selected_forecasters_wide, aes(x = mean_pfa, y = point_fcast0)) +
  geom_point(size = 1, color = "blue") +
  geom_smooth(method=lm, se=FALSE, color = "black", size = 0.5) +
  xlab(expression(bar(FP[t]))) +
  ylab(expression(FP[t]^i)) +
  scale_y_continuous(breaks = c(0, 0.5, 1, 1.5, 2, 2.5, 3), limits = c(0, 3)) +
  scale_x_continuous(breaks = c(0, 0.5, 1, 1.5, 2, 2.5, 3), limits = c(0, 3)) +
  ggtitle(expression(paste("   ", alpha, " > 0 , ", lambda, " > 1"))) +
  theme_classic() + 
  theme(plot.title = element_text(hjust = 0.5, size=13),
        axis.title.x = element_text(size=10),
        axis.title.y = element_text(size=10),
        axis.text.x = element_text(size=8),
        axis.text.y = element_text(size=8)) +
  ggplot2::annotate("text", x = 0.3, y = 2, label = expression(paste(R^2, " = 0.75")))

f2_sub <- ggplot(selected_forecasters_wide, aes(x = mean_pfa, y = point_fcast2)) +
  geom_point(size = 1, color = "purple") +
  geom_smooth(method=lm, se=FALSE, color = "black", size = 0.5) +
  xlab(expression(bar(FP[t]))) +
  ylab(expression(FP[t]^i)) +
  scale_y_continuous(breaks = c(0, 0.5, 1, 1.5, 2, 2.5, 3), limits = c(0, 3)) +
  scale_x_continuous(breaks = c(0, 0.5, 1, 1.5, 2, 2.5, 3), limits = c(0, 3)) +
  ggtitle(expression(paste("   ", alpha, " < 0 , ", lambda, " < 1"))) +
  theme_classic() + 
  theme(plot.title = element_text(hjust = 0.5, size=13),
        axis.title.x = element_text(size=10),
        axis.title.y = element_text(size=10),
        axis.text.x = element_text(size=8),
        axis.text.y = element_text(size=8)) +
  ggplot2::annotate("text", x = 0.3, y = 2, label = expression(paste(R^2, " = 0.58")))

f3_sub <- ggplot(selected_forecasters_wide, aes(x = mean_pfa, y = point_fcast3)) +
  geom_point(size = 1, color = "red") +
  geom_smooth(method=lm, se=FALSE, color = "black", size = 0.5) +
  xlab(expression(bar(FP[t]))) +
  ylab(expression(FP[t]^i)) +
  scale_y_continuous(breaks = c(0, 0.5, 1, 1.5, 2, 2.5, 3), limits = c(0, 3)) +
  scale_x_continuous(breaks = c(0, 0.5, 1, 1.5, 2, 2.5, 3), limits = c(0, 3)) +
  ggtitle(expression(paste("   ", alpha, " > 0 , ", lambda, " < 1"))) +
  theme_classic() + 
  theme(plot.title = element_text(hjust = 0.5, size=13),
        axis.title.x = element_text(size=10),
        axis.title.y = element_text(size=10),
        axis.text.x = element_text(size=8),
        axis.text.y = element_text(size=8)) +
  ggplot2::annotate("text", x = 0.3, y = 2, label = expression(paste(R^2, " = 0.86")))

figure7_trunc <- ggarrange(f0_sub, f1_sub, f2_sub, f3_sub, ncol = 2, nrow = 2)
text <- paste("Forecast Performance and Fitted Regression Lines",
              "1-year ahead GDP Growth", sep = "\n")
figure7_trunc <- annotate_figure(figure7_trunc, top = text_grob(text, face = "bold", size = 16))
figure7_trunc

ggsave(filename="figure7.jpg",
       plot = figure7_trunc,
       device = NULL,
       path = "./",
       width = 10.5,
       height = 7.5,
       units = "in",
       dpi = 300)

ggsave(filename="figure7a.jpg",
       plot = figure7,
       device = NULL,
       path = "./",
       width = 10.5,
       height = 7.5,
       units = "in",
       dpi = 300)



# Figure 8 #
# Set working directory to input path (CHANGE FILEPATH BELOW) #
setwd(".../.../REPLICATION PACKAGE/Data/Ready/")
df <- read_excel("./avg_fp_vals.xlsx")

gdpA <- df[, c(1,2,3,4)]
gdpB <- df[, c(1,2,5,6)]
hicpA <- df[, c(1,2,7,8)]
hicpB <- df[, c(1,2,9,10)]
urateA <- df[, c(1,2,11,12)]
urateB <- df[, c(1,2,13,14)]

# Clean input data #
names(gdpA)[names(gdpA) == "tgdate"] <- "date"
names(gdpA)[names(gdpA) == "gdpAroll_pfa"] <- "mean_pfa"
names(gdpA)[names(gdpA) == "gdpAroll_arps"] <- "mean_arps"

names(gdpB)[names(gdpB) == "tgdate"] <- "date"
names(gdpB)[names(gdpB) == "gdpBroll_pfa"] <- "mean_pfa"
names(gdpB)[names(gdpB) == "gdpBroll_arps"] <- "mean_arps"

names(hicpA)[names(hicpA) == "tgdate"] <- "date"
names(hicpA)[names(hicpA) == "hicpAroll_pfa"] <- "mean_pfa"
names(hicpA)[names(hicpA) == "hicpAroll_arps"] <- "mean_arps"

names(hicpB)[names(hicpB) == "tgdate"] <- "date"
names(hicpB)[names(hicpB) == "hicpBroll_pfa"] <- "mean_pfa"
names(hicpB)[names(hicpB) == "hicpBroll_arps"] <- "mean_arps"

names(urateA)[names(urateA) == "tgdate"] <- "date"
names(urateA)[names(urateA) == "urateAroll_pfa"] <- "mean_pfa"
names(urateA)[names(urateA) == "urateAroll_arps"] <- "mean_arps"

names(urateB)[names(urateB) == "tgdate"] <- "date"
names(urateB)[names(urateB) == "urateBroll_pfa"] <- "mean_pfa"
names(urateB)[names(urateB) == "urateBroll_arps"] <- "mean_arps"

# Set working directory to output path (CHANGE FILEPATH BELOW) #
setwd(".../.../REPLICATION PACKAGE/Output/Figures/")

# These are the alpha and lambda coefficients for selected forecasters. 
# See ${regressions}\alpha_lambda_sheet.xlsx for more details.
f22  <- c(-0.06565374, 0.914717)
f36 <- c(0.1065583, 1.05182)
f37 <- c(-0.1409987, 1.096985)
f85 <- c(0.1134764, 0.7915496)

flist <- list(f37, f36, f22, f85)
FP_vals <- data.frame(gdpA$mean_pfa)
FP_vals <- na.omit(FP_vals)

# 0 - SE, 1 - NE, 2 - NW, 3 - SW

count = 0
for (i in flist) {
  alpha = i[1]
  lambda = i[2]
  FP_vals[as.character(count)] <- with(FP_vals, gdpA.mean_pfa*lambda + alpha)
  count = count +1
}

df <- as.data.frame(FP_vals)
meltR <- melt(df, id = "gdpA.mean_pfa")

figure8 <- ggplot(meltR, aes(x = gdpA.mean_pfa, y = value, group = variable, colour = variable)) +
  geom_line(size = 1) +
  geom_segment(x=0.41, y=-1, xend=0.41, yend=0.3125, color='grey', linetype='dashed', size=0.5) +
  geom_segment(x=0.54, y=-1, xend=0.54, yend=0.5444, color='black', linetype='dashed', size=0.5) +
  geom_segment(x=0.83, y=-1, xend=0.83, yend=0.773, color='grey', linetype='dashed', size=0.5) +
  geom_segment(x=1.45, y=-1, xend=1.45, yend=1.4538, color='black', linetype='dashed', size=0.5) +
  geom_segment(x=1.45, y=-1, xend=1.45, yend=1.2647, color='grey', linetype='dashed', size=0.5) +
  geom_segment(x=5.48, y=-1, xend=5.48, yend=5.872, color='grey', linetype='dashed', size=0.5) +
  geom_segment(x=0, y=0, xend=5.7281770, yend=5.7281770, color='black', size=0.5) +
  xlab(expression(bar(FP[t]))) +
  ylab(expression(hat(FP[t])^i)) +
  labs(caption = "Grey dashed lines depict crossings of individual forecast performance profiles.
       Black dashed lines depict crossings of individual forecast performance profiles with consensus forecast performance.") +
  scale_y_continuous(breaks = c(0, 1, 2, 3, 4, 5, 6)) +
  scale_x_continuous(breaks = c(0, 0.41, 0.54, 0.83, 1.45, 2, 3, 4, 5, 5.48, 6)) +
  ggtitle("Estimated Forecast Performance Profiles with Crossings", subtitle = "1-year ahead GDP Growth") +
  theme_classic() + 
  theme(plot.title = element_text(hjust = 0.5, size=20), plot.subtitle = element_text(hjust = 0.5, size=16),
        axis.title.x = element_text(size=16),
        axis.title.y = element_text(size=16),
        axis.text.x = element_text(size=7),
        axis.text.y = element_text(size=8)) +
  theme(legend.position = "bottom", legend.direction = "vertical",
        legend.background = element_rect(color = "black"), legend.title = element_blank(),
        legend.text = element_text(size=14)) +  
  scale_color_manual(labels = c(expression(paste("   ", alpha, " < 0 , ", lambda, " > 1")), expression(paste("   ", alpha, " > 0 , ", lambda, " > 1")), 
                                expression(paste("   ", alpha, " < 0 , ", lambda, " < 1")), expression(paste("   ", alpha, " > 0 , ", lambda, " < 1"))), 
                     values = c("orange", "blue", "purple", "red")) +
  guides(col=guide_legend(nrow=2, byrow=TRUE))
figure8 <- figure8 + ggplot2::annotate("text", x = 5.82, y = 5.73, label = "45°")

df_trunc <- subset(df, gdpA.mean_pfa <= 3)
meltR_trunc <- melt(df_trunc, id = "gdpA.mean_pfa")

figure8_trunc <- ggplot(meltR_trunc, aes(x = gdpA.mean_pfa, y = value, group = variable, colour = variable)) +
  geom_line(size = 1) +
  geom_segment(x=0.4134, y=-1, xend=0.4134, yend=0.3125, color='grey', linetype='dashed', size=0.5) +
  geom_segment(x=0.5444, y=-1, xend=0.5444, yend=0.5444, color='black', linetype='dashed', size=0.5) +
  geom_segment(x=0.8332, y=-1, xend=0.8332, yend=0.773, color='grey', linetype='dashed', size=0.5) +
  geom_segment(x=1.4538, y=-1, xend=1.4538, yend=1.4538, color='black', linetype='dashed', size=0.5) +
  geom_segment(x=1.4544, y=-1, xend=1.4544, yend=1.2647, color='grey', linetype='dashed', size=0.5) +
  geom_segment(x=0, y=0, xend=2.6382100, yend=2.6382100, color='black', size=0.5) +
  xlab(expression(bar(FP[t]))) +
  ylab(expression(hat(FP[t])^i)) +
  labs(caption = "Grey dashed lines depict crossings of individual forecast performance profiles.
       Black dashed lines depict crossings of individual forecast performance profiles with consensus forecast performance.") +
  scale_y_continuous(breaks = c(0, 0.5, 1, 1.5, 2, 2.5, 3), limits = c(0, 3)) +
  scale_x_continuous(breaks = c(0, 0.41, 0.54, 0.83, 1.45, 2, 2.5, 3), limits = c(0, 3)) +
  ggtitle("Estimated Forecast Performance Profiles with Crossings", subtitle = "1-year ahead GDP Growth") +
  theme_classic() + 
  theme(plot.title = element_text(hjust = 0.5, size=20), plot.subtitle = element_text(hjust = 0.5, size=16),
        axis.title.x = element_text(size=16),
        axis.title.y = element_text(size=16),
        axis.text.x = element_text(size=8),
        axis.text.y = element_text(size=8)) +
  theme(legend.position = "bottom", legend.direction = "vertical",
        legend.background = element_rect(color = "black"), legend.title = element_blank(),
        legend.text = element_text(size=14)) +  
  scale_color_manual(labels = c(expression(paste("   ", alpha, " < 0 , ", lambda, " > 1")), expression(paste("   ", alpha, " > 0 , ", lambda, " > 1")), 
                                expression(paste("   ", alpha, " < 0 , ", lambda, " < 1")), expression(paste("   ", alpha, " > 0 , ", lambda, " < 1"))), 
                     values = c("orange", "blue", "purple", "red")) +
  guides(col=guide_legend(nrow=2, byrow=TRUE))
figure8_trunc <- figure8_trunc + ggplot2::annotate("text", x = 2.70, y = 2.64, label = "45°")

ggsave(filename="figure8.jpg",
       plot = figure8_trunc,
       device = NULL,
       path = "./",
       width = 8.5,
       height = 11,
       units = "in",
       dpi = 300)

ggsave(filename="figure8a.jpg",
       plot = figure8,
       device = NULL,
       path = "./",
       width = 10.5,
       height = 7.5,
       units = "in",
       dpi = 300)



# Figure 13 #
# Set working directory to input path (CHANGE FILEPATH BELOW) #
setwd(".../.../REPLICATION PACKAGE/Data/Ready/")
df <- read_excel("./avg_adj_fp_vals.xlsx")

gdpA <- df[, c(1,2,3)]
gdpB <- df[, c(1,4,5)]
hicpA <- df[, c(1,6,7)]
hicpB <- df[, c(1,8,9)]
urateA <- df[, c(1,10,11)]
urateB <- df[, c(1,12,13)]

# Clean input data #
names(gdpA)[names(gdpA) == "gdpAroll_adj_pfa"] <- "mean_adj_pfa"
names(gdpA)[names(gdpA) == "gdpAroll_adj_arps"] <- "mean_arps"
names(gdpB)[names(gdpB) == "gdpBroll_adj_pfa"] <- "mean_adj_pfa"
names(gdpB)[names(gdpB) == "gdpBroll_adj_arps"] <- "mean_adj_arps"
names(hicpA)[names(hicpA) == "hicpAroll_adj_pfa"] <- "mean_adj_pfa"
names(hicpA)[names(hicpA) == "hicpAroll_adj_arps"] <- "mean_adj_arps"
names(hicpB)[names(hicpB) == "hicpBroll_adj_pfa"] <- "mean_adj_pfa"
names(hicpB)[names(hicpB) == "hicpBroll_adj_arps"] <- "mean_adj_arps"
names(urateA)[names(urateA) == "urateAroll_adj_pfa"] <- "mean_adj_pfa"
names(urateA)[names(urateA) == "urateAroll_adj_arps"] <- "mean_adj_arps"
names(urateB)[names(urateB) == "urateBroll_adj_pfa"] <- "mean_adj_pfa"
names(urateB)[names(urateB) == "urateBroll_adj_arps"] <- "mean_adj_arps"

gdpA <- na.omit(gdpA)
gdpB <- na.omit(gdpB)
hicpA <- na.omit(hicpA)
hicpB <- na.omit(hicpB)
urateA <- na.omit(urateA)
urateB <- na.omit(urateB)

c1_dat <- na.omit(merge(hicpA, hicpB, by = "person", all=TRUE))
c3_dat <- na.omit(merge(gdpA, urateA, by = "person", all=TRUE))
c4_dat <- na.omit(merge(gdpB, urateB, by = "person", all=TRUE))
c5_dat <- na.omit(merge(gdpA, hicpA, by = "person", all=TRUE))

# Set working directory to output path (CHANGE FILEPATH BELOW) #
setwd(".../.../REPLICATION PACKAGE/Output/Figures/")

c1 <- ggplot(c1_dat, aes(x=mean_adj_pfa.x, y=mean_adj_pfa.y)) +
  geom_point(color = "steelblue") +
  geom_smooth(method=lm, se=FALSE, color = 'red4', size = 0.5) +
  ggtitle("1-year-ahead and 1-year/1-year forward inflation PFA") +
  xlab("1-year ahead") +
  ylab("1-year/1-year forward") +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=10), axis.title=element_text(size=10)) +
  stat_cor(cor.coef.name = "r", aes(label = ..r.label..), label.x = 0)

c2 <- ggplot(c1_dat, aes(x=mean_adj_arps.x, y=mean_adj_arps.y)) +
  geom_point(color = "steelblue") +
  geom_smooth(method=lm, se=FALSE, color = 'red4', size = 0.5) +
  ggtitle("1-year-ahead and 1-year/1-year forward inflation ARPS") +
  xlab("1-year ahead") +
  ylab("1-year/1-year forward") +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=10), axis.title=element_text(size=10)) +
  stat_cor(cor.coef.name = "r", aes(label = ..r.label..), label.x = 0)

c3 <- ggplot(c3_dat, aes(x=mean_adj_pfa.y, y=mean_adj_pfa.x)) +
  geom_point(color = "steelblue") +
  geom_smooth(method=lm, se=FALSE, color = 'red4', size = 0.5) +
  ggtitle("GDP/unemployment at 1-year-ahead horizon PFA") +
  xlab("Unemployment") +
  ylab("GDP Growth") +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=10), axis.title=element_text(size=10)) +
  stat_cor(cor.coef.name = "r", aes(label = ..r.label..), label.x = 0, label.y = 0.12)

c4 <- ggplot(c4_dat, aes(x=mean_adj_pfa.y, y=mean_adj_pfa.x)) +
  geom_point(color = "steelblue") +
  geom_smooth(method=lm, se=FALSE, color = 'red4', size = 0.5) +
  ggtitle("GDP/unemployment 1-year/1-year forward horizon PFA") +
  xlab("Unemployment") +
  ylab("GDP Growth") +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=10), axis.title=element_text(size=10)) +
  stat_cor(cor.coef.name = "r", aes(label = ..r.label..), label.x = 0)

c5 <- ggplot(c5_dat, aes(x=mean_adj_pfa.y, y=mean_adj_pfa.x)) +
  geom_point(color = "steelblue") +
  geom_smooth(method=lm, se=FALSE, color = 'red4', size = 0.5) +
  ggtitle("GDP/inflation at 1-year-ahead horizon PFA") +
  xlab("Inflation") +
  ylab("GDP Growth") +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=10), axis.title=element_text(size=10)) +
  stat_cor(cor.coef.name = "r", aes(label = ..r.label..), label.x = 0)

figure13 <- ggarrange(c1, c2, c3, c4, c5, c3, ncol = 2, nrow = 3)
figure13 <- annotate_figure(figure13, top = text_grob("Forecast Performance Comparisons: Data Type, Target Variables, and Horizons", face = "bold", size = 10))
ggsave(filename="figure13.jpg",
       plot = figure13,
       device = NULL,
       path = "./",
       width = 8.5,
       height = 11,
       units = "in",
       dpi = 300)


