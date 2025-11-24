#-----------------------------------------------#
#    x14_Quadrant_Scatterplots.R                #
#    Figures 1, 4, and 5                        #
#-----------------------------------------------#

#--------------------- Beginning of Program -------------------------#

# Figure 1 #
# Set working directory to output path (CHANGE FILEPATH BELOW) #
setwd(".../.../REPLICATION PACKAGE/Output/Figures/")

p <- ggplot()+lims(x=c(-1,1), y=c(0,2)) +
  theme_minimal()+geom_vline(xintercept=0, color="red2", linetype="dotdash") + 
  geom_hline(yintercept=1, color="red2", linetype="dotdash") +
  xlab(expression(paste("Intercepts (", alpha, ")"))) +
  ylab(expression(paste("Slopes (", lambda, ")"))) +
  theme(panel.border = element_rect(colour = 'black',fill=NA,size=1), text=element_text(family="arial"))

p_aug <- p + 
  ggplot2::annotate("text", x=-0.5, y=1.5, label=expression(paste(alpha<0, ", ", lambda>1))) +
  ggplot2::annotate("text", x=0.5,  y=1.5, label=expression(paste(alpha>0, ", ", lambda>1))) +
  ggplot2::annotate("text", x=-0.5, y=0.5, label=expression(paste(alpha<0, ", ", lambda<1))) +
  ggplot2::annotate("text", x=0.5,  y=0.5, label=expression(paste(alpha>0, ", ", lambda<1)))

ggsave(filename="figure1.jpg",
       plot = p_aug,
       device = NULL,
       path = "./",
       width = 8.5,
       height = 11,
       units = "in",
       dpi = 300)



# Figure 4 #
# Set working directory to input path (CHANGE FILEPATH BELOW) #
setwd(".../.../REPLICATION PACKAGE/Output/Regressions/")
data <- read_excel("./alpha_lambda_sheet.xlsx")

# Set working directory to output path (CHANGE FILEPATH BELOW) #
setwd(".../.../REPLICATION PACKAGE/Output/Figures/")

a <- data[8, 2:3]
b <- data[15, 2:3]
c <- data[16, 2:3]
d <- data[25, 2:3]

p1 <- ggplot(data, aes(x=pfa_gdp_aroll_alpha, y=pfa_gdp_aroll_lambda)) +
  geom_point(color = "grey") +
  geom_smooth(method=lm, se=FALSE, color = 'black', size = 0.5) +
  ggtitle("1-year ahead GDP Growth") +
  geom_vline(xintercept=0, color="red2", linetype="dashed") + 
  geom_hline(yintercept=1, color="red2", linetype="dashed") +
  geom_point(data=a, colour='purple') +
  geom_point(data=b, colour='blue') +
  geom_point(data=c, colour='orange') +
  geom_point(data=d, colour='red') +
  xlim(-0.2,0.4) +
  scale_y_continuous(breaks=c(0.6,0.8,1,1.2,1.4), limits=c(0.55,1.4)) +
  xlab(expression(paste("Intercepts (", alpha, ")"))) +
  ylab(expression(paste("Slopes (", lambda, ")"))) +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=10)) +
  stat_cor(aes(label = paste("'r = '", ..r.., sep = " ")), label.x = 0.28, label.y = 1.15)

p2 <- ggplot(data, aes(x=pfa_gdp_broll_alpha, y=pfa_gdp_broll_lambda)) +
  geom_point(color = "grey") +
  geom_smooth(method=lm, se=FALSE, color = 'black', size = 0.5) +
  ggtitle("1-year/1-year forward GDP Growth") +
  geom_vline(xintercept=0, color="red2", linetype="dashed") + 
  geom_hline(yintercept=1, color="red2", linetype="dashed") +
  xlim(-0.2,0.4) +
  scale_y_continuous(breaks=c(0.6,0.8,1,1.2,1.4), limits=c(0.55,1.4)) +
  xlab(expression(paste("Intercepts (", alpha, ")"))) +
  ylab(expression(paste("Slopes (", lambda, ")"))) +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=10)) +
  stat_cor(aes(label = paste("'r = '", ..r.., sep = " ")), label.x = 0.28, label.y = 1.15)

p3 <- ggplot(data, aes(x=pfa_hicp_aroll_alpha, y=pfa_hicp_aroll_lambda)) +
  geom_point(color = "grey") +
  geom_smooth(method=lm, se=FALSE, color = 'black', size = 0.5) +
  ggtitle("1-year ahead Inflation") +
  geom_vline(xintercept=0, color="red2", linetype="dashed") + 
  geom_hline(yintercept=1, color="red2", linetype="dashed") +
  xlim(-0.2,0.4) +
  scale_y_continuous(breaks=c(0.6,0.8,1,1.2,1.4), limits=c(0.55,1.4)) +
  xlab(expression(paste("Intercepts (", alpha, ")"))) +
  ylab(expression(paste("Slopes (", lambda, ")"))) +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=10)) +
  stat_cor(aes(label = paste("'r = '", ..r.., sep = " ")), label.x = 0.28, label.y = 1.15)

p4 <- ggplot(data, aes(x=pfa_hicp_broll_alpha, y=pfa_hicp_broll_lambda)) +
  geom_point(color = "grey") +
  geom_smooth(method=lm, se=FALSE, color = 'black', size = 0.5) +
  ggtitle("1-year/1-year forward Inflation") +
  geom_vline(xintercept=0, color="red2", linetype="dashed") + 
  geom_hline(yintercept=1, color="red2", linetype="dashed") +
  xlim(-0.2,0.4) +
  scale_y_continuous(breaks=c(0.6,0.8,1,1.2,1.4), limits=c(0.55,1.4)) +
  xlab(expression(paste("Intercepts (", alpha, ")"))) +
  ylab(expression(paste("Slopes (", lambda, ")"))) +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=10)) +
  stat_cor(aes(label = paste("'r = '", ..r.., sep = " ")), label.x = 0.28, label.y = 1.15)

p5 <- ggplot(data, aes(x=pfa_urate_aroll_alpha, y=pfa_urate_aroll_lambda)) +
  geom_point(color = "grey") +
  geom_smooth(method=lm, se=FALSE, color = 'black', size = 0.5) +
  ggtitle("1-year ahead Unemployment") +
  geom_vline(xintercept=0, color="red2", linetype="dashed") + 
  geom_hline(yintercept=1, color="red2", linetype="dashed") +
  xlim(-0.2,0.4) +
  scale_y_continuous(breaks=c(0.6,0.8,1,1.2,1.4), limits=c(0.55,1.4)) +
  xlab(expression(paste("Intercepts (", alpha, ")"))) +
  ylab(expression(paste("Slopes (", lambda, ")"))) +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=10)) +
  stat_cor(aes(label = paste("'r = '", ..r.., sep = " ")), label.x = 0.28, label.y = 1.15)

p6 <- ggplot(data, aes(x=pfa_urate_broll_alpha, y=pfa_urate_broll_lambda)) +
  geom_point(color = "grey") +
  geom_smooth(method=lm, se=FALSE, color = 'black', size = 0.5) +
  ggtitle("1-year/1-year forward Unemployment") +
  geom_vline(xintercept=0, color="red2", linetype="dashed") + 
  geom_hline(yintercept=1, color="red2", linetype="dashed") +
  xlim(-0.2,0.4) +
  scale_y_continuous(breaks=c(0.6,0.8,1,1.2,1.4), limits=c(0.55,1.4)) +
  xlab(expression(paste("Intercepts (", alpha, ")"))) +
  ylab(expression(paste("Slopes (", lambda, ")"))) +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=10)) +
  stat_cor(aes(label = paste("'r = '", ..r.., sep = " ")), label.x = 0.28, label.y = 1.15)

figure4 <- ggarrange(p1, p2, p3, p4, p5, p6, ncol = 2, nrow = 3)
figure4 <- annotate_figure(figure4, top = text_grob("Estimated Parameter Pairings: Point Forecasts", face = "bold", size = 10))

ggsave(filename="figure4.jpg",
       plot = figure4,
       device = NULL,
       path = "./",
       width = 8.5,
       height = 11,
       units = "in",
       dpi = 300)



# Figure 5 #
a1 <- ggplot(data, aes(x=arps_gdp_aroll_alpha, y=arps_gdp_aroll_lambda)) +
  geom_point(color = "steelblue") +
  geom_smooth(method=lm, se=FALSE, color = 'black', size = 0.5) +
  ggtitle("1-year ahead GDP Growth") +
  geom_vline(xintercept=0, color="red2", linetype="dashed") + 
  geom_hline(yintercept=1, color="red2", linetype="dashed") +
  xlim(-0.06,0.1) +
  ylim(0.6,1.4) +
  xlab(expression(paste("Intercepts (", alpha, ")"))) +
  ylab(expression(paste("Slopes (", lambda, ")"))) +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=10)) +
  stat_cor(aes(label = paste("'r = '", ..r.., sep = " ")), label.x = 0.07, label.y = 1.1)

a2 <- ggplot(data, aes(x=arps_gdp_broll_alpha, y=arps_gdp_broll_lambda)) +
  geom_point(color = "steelblue") +
  geom_smooth(method=lm, se=FALSE, color = 'black', size = 0.5) +
  ggtitle("1-year/1-year forward GDP Growth") +
  geom_vline(xintercept=0, color="red2", linetype="dashed") + 
  geom_hline(yintercept=1, color="red2", linetype="dashed") +
  xlim(-0.06,0.1) +
  ylim(0.6,1.4) +
  xlab(expression(paste("Intercepts (", alpha, ")"))) +
  ylab(expression(paste("Slopes (", lambda, ")"))) +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=10)) +
  stat_cor(aes(label = paste("'r = '", ..r.., sep = " ")), label.x = 0.07, label.y = 1.1)

a3 <- ggplot(data, aes(x=arps_hicp_aroll_alpha, y=arps_hicp_aroll_lambda)) +
  geom_point(color = "steelblue") +
  geom_smooth(method=lm, se=FALSE, color = 'black', size = 0.5) +
  ggtitle("1-year ahead Inflation") +
  geom_vline(xintercept=0, color="red2", linetype="dashed") +
  geom_hline(yintercept=1, color="red2", linetype="dashed") +
  xlim(-0.06,0.1) +
  ylim(0.6,1.4) +
  xlab(expression(paste("Intercepts (", alpha, ")"))) +
  ylab(expression(paste("Slopes (", lambda, ")"))) +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=10)) +
  stat_cor(aes(label = paste("'r = '", ..r.., sep = " ")), label.x = 0.07, label.y = 1.1)

a4 <- ggplot(data, aes(x=arps_hicp_broll_alpha, y=arps_hicp_broll_lambda)) +
  geom_point(color = "steelblue") +
  geom_smooth(method=lm, se=FALSE, color = 'black', size = 0.5) +
  ggtitle("1-year/1-year forward Inflation") +
  geom_vline(xintercept=0, color="red2", linetype="dashed") + 
  geom_hline(yintercept=1, color="red2", linetype="dashed") +
  xlim(-0.06,0.1) +
  ylim(0.6,1.4) +
  xlab(expression(paste("Intercepts (", alpha, ")"))) +
  ylab(expression(paste("Slopes (", lambda, ")"))) +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=10)) +
  stat_cor(aes(label = paste("'r = '", ..r.., sep = " ")), label.x = 0.07, label.y = 1.1)

a5 <- ggplot(data, aes(x=arps_urate_aroll_alpha, y=arps_urate_aroll_lambda)) +
  geom_point(color = "steelblue") +
  geom_smooth(method=lm, se=FALSE, color = 'black', size = 0.5) +
  ggtitle("1-year ahead Unemployment") +
  geom_vline(xintercept=0, color="red2", linetype="dashed") + 
  geom_hline(yintercept=1, color="red2", linetype="dashed") +
  xlim(-0.06,0.1) +
  ylim(0.6,1.4) +
  xlab(expression(paste("Intercepts (", alpha, ")"))) +
  ylab(expression(paste("Slopes (", lambda, ")"))) +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=10)) +
  stat_cor(aes(label = paste("'r = '", ..r.., sep = " ")), label.x = 0.07, label.y = 1.1)

a6 <- ggplot(data, aes(x=arps_urate_broll_alpha, y=arps_urate_broll_lambda)) +
  geom_point(color = "steelblue") +
  geom_smooth(method=lm, se=FALSE, color = 'black', size = 0.5) +
  ggtitle("1-year/1-year forward Unemployment") +
  geom_vline(xintercept=0, color="red2", linetype="dashed") + 
  geom_hline(yintercept=1, color="red2", linetype="dashed") +
  xlim(-0.06,0.1) +
  ylim(0.6,1.4) +
  xlab(expression(paste("Intercepts (", alpha, ")"))) +
  ylab(expression(paste("Slopes (", lambda, ")"))) +
  theme_classic() + theme(plot.title = element_text(hjust = 0.5, size=10)) +
  stat_cor(aes(label = paste("'r = '", ..r.., sep = " ")), label.x = 0.07, label.y = 1.1)

figure5 <- ggarrange(a1, a2, a3, a4, a5, a6, ncol = 2, nrow = 3)
figure5 <- annotate_figure(figure5, top = text_grob("Estimated Parameter Pairings: Density Forecasts", face = "bold", size = 10))

ggsave(filename="figure5.jpg",
       plot = figure5,
       device = NULL,
       path = "./",
       width = 8.5,
       height = 11,
       units = "in",
       dpi = 300)


