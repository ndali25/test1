#-----------------------------------------------#
#    x15_Simulation_Scatterplots.R              #
#    Figures 9 and 10                           #
#-----------------------------------------------#

#--------------------- Beginning of Program -------------------------#

# Input data (CHANGE FILEPATHS BELOW) #
setwd(".../.../REPLICATION PACKAGE/Output/Regressions/")
estimates <- read_excel("./alpha_lambda_sheet.xlsx")
setwd(".../.../REPLICATION PACKAGE/Output/Simulations/")
file_list <- list.files(path = "./Individual Forecasters/")

# Set up data frames #
gAp <- data.frame()
gBp <- data.frame()
gAa <- data.frame()
gBa <- data.frame()

hAp <- data.frame()
hBp <- data.frame()
hAa <- data.frame()
hBa <- data.frame()

uAp <- data.frame()
uBp <- data.frame()
uAa <- data.frame()
uBa <- data.frame()

# Read in files and separate #
for (file in file_list) {
  if (grepl('gdp_Aroll_pfa', file, fixed = TRUE)) {
    print(paste("./Individual Forecasters/", file, sep=""))
    simulations <- read_excel(paste("./Individual Forecasters/", file, sep=""), col_names=FALSE)
    colnames(simulations) <- c("alpha", "lambda")
    gAp <- rbind(gAp, simulations)
    colnames(gAp) <- c("alpha", 'lambda')
  }
  else if (grepl('gdp_Broll_pfa', file, fixed = TRUE)) {
    print(paste("./Individual Forecasters/", file, sep=""))
    simulations <- read_excel(paste("./Individual Forecasters/", file, sep=""), col_names=FALSE)
    colnames(simulations) <- c("alpha", "lambda")
    gBp <- rbind(gBp, simulations)
    colnames(gBp) <- c("alpha", 'lambda')
  }
  else if (grepl('gdp_Aroll_arps', file, fixed = TRUE)) {
    print(paste("./Individual Forecasters/", file, sep=""))
    simulations <- read_excel(paste("./Individual Forecasters/", file, sep=""), col_names=FALSE)
    colnames(simulations) <- c("alpha", "lambda")
    gAa <- rbind(gAa, simulations)
    colnames(gAa) <- c("alpha", 'lambda')
  }
  else if (grepl('gdp_Broll_arps', file, fixed = TRUE)) {
    print(paste("./Individual Forecasters/", file, sep=""))
    simulations <- read_excel(paste("./Individual Forecasters/", file, sep=""), col_names=FALSE)
    colnames(simulations) <- c("alpha", "lambda")
    gBa <- rbind(gBa, simulations)
    colnames(gBa) <- c("alpha", 'lambda')
  }
  else if (grepl('hicp_Aroll_pfa', file, fixed = TRUE)) {
    print(paste("./Individual Forecasters/", file, sep=""))
    simulations <- read_excel(paste("./Individual Forecasters/", file, sep=""), col_names=FALSE)
    colnames(simulations) <- c("alpha", "lambda")
    hAp <- rbind(hAp, simulations)
    colnames(hAp) <- c("alpha", 'lambda')
  }
  else if (grepl('hicp_Broll_pfa', file, fixed = TRUE)) {
    print(paste("./Individual Forecasters/", file, sep=""))
    simulations <- read_excel(paste("./Individual Forecasters/", file, sep=""), col_names=FALSE)
    colnames(simulations) <- c("alpha", "lambda")
    hBp <- rbind(hBp, simulations)
    colnames(hBp) <- c("alpha", 'lambda')
  }
  else if (grepl('hicp_Aroll_arps', file, fixed = TRUE)) {
    print(paste("./Individual Forecasters/", file, sep=""))
    simulations <- read_excel(paste("./Individual Forecasters/", file, sep=""), col_names=FALSE)
    colnames(simulations) <- c("alpha", "lambda")
    hAa <- rbind(hAa, simulations)
    colnames(hAa) <- c("alpha", 'lambda')
  }
  else if (grepl('hicp_Broll_arps', file, fixed = TRUE)) {
    print(paste("./Individual Forecasters/", file, sep=""))
    simulations <- read_excel(paste("./Individual Forecasters/", file, sep=""), col_names=FALSE)
    colnames(simulations) <- c("alpha", "lambda")
    hBa <- rbind(hBa, simulations)
    colnames(hBa) <- c("alpha", 'lambda')
  }
  else if (grepl('urate_Aroll_pfa', file, fixed = TRUE)) {
    print(paste("./Individual Forecasters/", file, sep=""))
    simulations <- read_excel(paste("./Individual Forecasters/", file, sep=""), col_names=FALSE)
    colnames(simulations) <- c("alpha", "lambda")
    uAp <- rbind(uAp, simulations)
    colnames(uAp) <- c("alpha", 'lambda')
  }
  else if (grepl('urate_Broll_pfa', file, fixed = TRUE)) {
    print(paste("./Individual Forecasters/", file, sep=""))
    simulations <- read_excel(paste("./Individual Forecasters/", file, sep=""), col_names=FALSE)
    colnames(simulations) <- c("alpha", "lambda")
    uBp <- rbind(uBp, simulations)
    colnames(uBp) <- c("alpha", 'lambda')
  }
  else if (grepl('urate_Aroll_arps', file, fixed = TRUE)) {
    print(paste("./Individual Forecasters/", file, sep=""))
    simulations <- read_excel(paste("./Individual Forecasters/", file, sep=""), col_names=FALSE)
    colnames(simulations) <- c("alpha", "lambda")
    uAa <- rbind(uAa, simulations)
    colnames(uAa) <- c("alpha", 'lambda')
  }
  else if (grepl('urate_Broll_arps', file, fixed = TRUE)) {
    print(paste("./Individual Forecasters/", file, sep=""))
    simulations <- read_excel(paste("./Individual Forecasters/", file, sep=""), col_names=FALSE)
    colnames(simulations) <- c("alpha", "lambda")
    uBa <- rbind(uBa, simulations)
    colnames(uBa) <- c("alpha", 'lambda')
  }
}



# Figure 9 #
# Set working directory to output path (CHANGE FILEPATH BELOW) #
setwd(".../.../REPLICATION PACKAGE/Output/Figures/")

p1 <- ggplot(gAp, aes(x=alpha, y=lambda)) +
  geom_point(color = 'gray') +
  geom_point(data=estimates, aes(x=pfa_gdp_aroll_alpha, y=pfa_gdp_aroll_lambda), color = 'black') +
  geom_hline(yintercept = 1, linetype='dashed', color='red') +
  geom_vline(xintercept = 0, linetype='dashed', color='red') +
  xlim(-0.4,0.6) +
  ylim(0.4,1.7) +
  xlab(expression(paste("Intercepts (", alpha, ")"))) +
  ylab(expression(paste("Slopes (", lambda, ")"))) +
  ggtitle('1-year Ahead GDP Growth') +
  theme_classic() + 
  theme(plot.title = element_text(hjust = 0.5, size=10), plot.subtitle = element_text(hjust = 0.5, size=10)) +
  theme(legend.position = "bottom", legend.direction = "vertical",
        legend.background = element_rect(color = "black"), legend.title = element_blank())
  
p2 <- ggplot(gBp, aes(x=alpha, y=lambda)) +
  geom_point(color = 'gray') +
  geom_point(data=estimates, aes(x=pfa_gdp_broll_alpha, y=pfa_gdp_broll_lambda), color = 'black') +
  geom_hline(yintercept = 1, linetype='dashed', color='red') +
  geom_vline(xintercept = 0, linetype='dashed', color='red') +
  xlim(-0.4,0.6) +
  ylim(0.4,1.7) +
  xlab(expression(paste("Intercepts (", alpha, ")"))) +
  ylab(expression(paste("Slopes (", lambda, ")"))) +
  ggtitle('1-year/1-year Forward GDP Growth') +
  theme_classic() + 
  theme(plot.title = element_text(hjust = 0.5, size=10), plot.subtitle = element_text(hjust = 0.5, size=10)) +
  theme(legend.position = "bottom", legend.direction = "vertical",
        legend.background = element_rect(color = "black"), legend.title = element_blank())

p3 <- ggplot(hAp, aes(x=alpha, y=lambda)) +
  geom_point(color = 'gray') +
  geom_point(data=estimates, aes(x=pfa_hicp_aroll_alpha, y=pfa_hicp_aroll_lambda), color = 'black') +
  geom_hline(yintercept = 1, linetype='dashed', color='red') +
  geom_vline(xintercept = 0, linetype='dashed', color='red') +
  xlim(-0.6,0.6) +
  ylim(0.4,1.7) +
  xlab(expression(paste("Intercepts (", alpha, ")"))) +
  ylab(expression(paste("Slopes (", lambda, ")"))) +
  ggtitle('1-year Ahead Inflation') +
  theme_classic() + 
  theme(plot.title = element_text(hjust = 0.5, size=10), plot.subtitle = element_text(hjust = 0.5, size=10)) +
  theme(legend.position = "bottom", legend.direction = "vertical",
        legend.background = element_rect(color = "black"), legend.title = element_blank())

p4 <- ggplot(hBp, aes(x=alpha, y=lambda)) +
  geom_point(color = 'gray') +
  geom_point(data=estimates, aes(x=pfa_hicp_broll_alpha, y=pfa_hicp_broll_lambda), color = 'black') +
  geom_hline(yintercept = 1, linetype='dashed', color='red') +
  geom_vline(xintercept = 0, linetype='dashed', color='red') +
  xlim(-0.6,0.6) +
  ylim(0.4,1.7) +
  xlab(expression(paste("Intercepts (", alpha, ")"))) +
  ylab(expression(paste("Slopes (", lambda, ")"))) +
  ggtitle('1-year/1-year Forward Inflation') +
  theme_classic() + 
  theme(plot.title = element_text(hjust = 0.5, size=10), plot.subtitle = element_text(hjust = 0.5, size=10)) +
  theme(legend.position = "bottom", legend.direction = "vertical",
        legend.background = element_rect(color = "black"), legend.title = element_blank())

p5 <- ggplot(uAp, aes(x=alpha, y=lambda)) +
  geom_point(color = 'gray') +
  geom_point(data=estimates, aes(x=pfa_urate_aroll_alpha, y=pfa_urate_aroll_lambda), color = 'black') +
  geom_hline(yintercept = 1, linetype='dashed', color='red') +
  geom_vline(xintercept = 0, linetype='dashed', color='red') +
  xlim(-0.6,1) +
  ylim(0.0,2.0) +
  xlab(expression(paste("Intercepts (", alpha, ")"))) +
  ylab(expression(paste("Slopes (", lambda, ")"))) +
  ggtitle('1-year Ahead Unemployment') +
  theme_classic() + 
  theme(plot.title = element_text(hjust = 0.5, size=10), plot.subtitle = element_text(hjust = 0.5, size=10)) +
  theme(legend.position = "bottom", legend.direction = "vertical",
        legend.background = element_rect(color = "black"), legend.title = element_blank())

p6 <- ggplot(uBp, aes(x=alpha, y=lambda)) +
  geom_point(color = 'gray') +
  geom_point(data=estimates, aes(x=pfa_urate_broll_alpha, y=pfa_urate_broll_lambda), color = 'black') +
  geom_hline(yintercept = 1, linetype='dashed', color='red') +
  geom_vline(xintercept = 0, linetype='dashed', color='red') +
  xlim(-0.6,1) +
  ylim(0.0,2.0) +
  xlab(expression(paste("Intercepts (", alpha, ")"))) +
  ylab(expression(paste("Slopes (", lambda, ")"))) +
  ggtitle('1-year/1-year Forward Unemployment') +
  theme_classic() + 
  theme(plot.title = element_text(hjust = 0.5, size=10), plot.subtitle = element_text(hjust = 0.5, size=10)) +
  theme(legend.position = "bottom", legend.direction = "vertical",
        legend.background = element_rect(color = "black"), legend.title = element_blank())

figure9 <- ggarrange(p1, p2, p3, p4, p5, p6, ncol = 2, nrow = 3)
figure9 <- annotate_figure(figure9,
                top = text_grob("Estimated and Simulated Parameter Pairings: Point Forecasts", color='black', size=14),
                bottom = text_grob("Note: Black dots are estimated values and grey dots are simulated values from the estimated joint distributions.", color='black',size=8))
ggsave(filename="figure9.jpg",
       plot = figure9,
       device = NULL,
       path = "./",
       width = 8.5,
       height = 11,
       units = "in",
       dpi = 300)



# Figure 10 #
a1 <- ggplot(gAa, aes(x=alpha, y=lambda)) +
  geom_point(color = 'gray') +
  geom_point(data=estimates, aes(x=arps_gdp_aroll_alpha, y=arps_gdp_aroll_lambda), color = 'black') +
  geom_hline(yintercept = 1, linetype='dashed', color='red') +
  geom_vline(xintercept = 0, linetype='dashed', color='red') +
  xlim(-0.4,0.6) +
  ylim(0.4,1.7) +
  xlab(expression(paste("Intercepts (", alpha, ")"))) +
  ylab(expression(paste("Slopes (", lambda, ")"))) +
  ggtitle('1-year Ahead GDP Growth') +
  theme_classic() + 
  theme(plot.title = element_text(hjust = 0.5, size=10), plot.subtitle = element_text(hjust = 0.5, size=10)) +
  theme(legend.position = "bottom", legend.direction = "vertical",
        legend.background = element_rect(color = "black"), legend.title = element_blank())

a2 <- ggplot(gBa, aes(x=alpha, y=lambda)) +
  geom_point(color = 'gray') +
  geom_point(data=estimates, aes(x=arps_gdp_broll_alpha, y=arps_gdp_broll_lambda), color = 'black') +
  geom_hline(yintercept = 1, linetype='dashed', color='red') +
  geom_vline(xintercept = 0, linetype='dashed', color='red') +
  xlim(-0.4,0.6) +
  ylim(0.4,1.7) +
  xlab(expression(paste("Intercepts (", alpha, ")"))) +
  ylab(expression(paste("Slopes (", lambda, ")"))) +
  ggtitle('1-year/1-year Forward GDP Growth') +
  theme_classic() + 
  theme(plot.title = element_text(hjust = 0.5, size=10), plot.subtitle = element_text(hjust = 0.5, size=10)) +
  theme(legend.position = "bottom", legend.direction = "vertical",
        legend.background = element_rect(color = "black"), legend.title = element_blank())

a3 <- ggplot(hAa, aes(x=alpha, y=lambda)) +
  geom_point(color = 'gray') +
  geom_point(data=estimates, aes(x=arps_hicp_aroll_alpha, y=arps_hicp_aroll_lambda), color = 'black') +
  geom_hline(yintercept = 1, linetype='dashed', color='red') +
  geom_vline(xintercept = 0, linetype='dashed', color='red') +
  xlim(-0.6,0.6) +
  ylim(0.4,1.7) +
  xlab(expression(paste("Intercepts (", alpha, ")"))) +
  ylab(expression(paste("Slopes (", lambda, ")"))) +
  ggtitle('1-year Ahead Inflation') +
  theme_classic() + 
  theme(plot.title = element_text(hjust = 0.5, size=10), plot.subtitle = element_text(hjust = 0.5, size=10)) +
  theme(legend.position = "bottom", legend.direction = "vertical",
        legend.background = element_rect(color = "black"), legend.title = element_blank())

a4 <- ggplot(hBa, aes(x=alpha, y=lambda)) +
  geom_point(color = 'gray') +
  geom_point(data=estimates, aes(x=arps_hicp_broll_alpha, y=arps_hicp_broll_lambda), color = 'black') +
  geom_hline(yintercept = 1, linetype='dashed', color='red') +
  geom_vline(xintercept = 0, linetype='dashed', color='red') +
  xlim(-0.6,0.6) +
  ylim(0.4,1.7) +
  xlab(expression(paste("Intercepts (", alpha, ")"))) +
  ylab(expression(paste("Slopes (", lambda, ")"))) +
  ggtitle('1-year/1-year Forward Inflation') +
  theme_classic() + 
  theme(plot.title = element_text(hjust = 0.5, size=10), plot.subtitle = element_text(hjust = 0.5, size=10)) +
  theme(legend.position = "bottom", legend.direction = "vertical",
        legend.background = element_rect(color = "black"), legend.title = element_blank())

a5 <- ggplot(uAa, aes(x=alpha, y=lambda)) +
  geom_point(color = 'gray') +
  geom_point(data=estimates, aes(x=arps_urate_aroll_alpha, y=arps_urate_aroll_lambda), color = 'black') +
  geom_hline(yintercept = 1, linetype='dashed', color='red') +
  geom_vline(xintercept = 0, linetype='dashed', color='red') +
  xlim(-0.6,1) +
  ylim(0.0,2.0) +
  xlab(expression(paste("Intercepts (", alpha, ")"))) +
  ylab(expression(paste("Slopes (", lambda, ")"))) +
  ggtitle('1-year Ahead Unemployment') +
  theme_classic() + 
  theme(plot.title = element_text(hjust = 0.5, size=10), plot.subtitle = element_text(hjust = 0.5, size=10)) +
  theme(legend.position = "bottom", legend.direction = "vertical",
        legend.background = element_rect(color = "black"), legend.title = element_blank())

a6 <- ggplot(uBa, aes(x=alpha, y=lambda)) +
  geom_point(color = 'gray') +
  geom_point(data=estimates, aes(x=arps_urate_broll_alpha, y=arps_urate_broll_lambda), color = 'black') +
  geom_hline(yintercept = 1, linetype='dashed', color='red') +
  geom_vline(xintercept = 0, linetype='dashed', color='red') +
  xlim(-0.6,1) +
  ylim(0.0,2.0) +
  xlab(expression(paste("Intercepts (", alpha, ")"))) +
  ylab(expression(paste("Slopes (", lambda, ")"))) +
  ggtitle('1-year/1-year Forward Unemployment') +
  theme_classic() + 
  theme(plot.title = element_text(hjust = 0.5, size=10), plot.subtitle = element_text(hjust = 0.5, size=10)) +
  theme(legend.position = "bottom", legend.direction = "vertical",
        legend.background = element_rect(color = "black"), legend.title = element_blank())

figure10 <- ggarrange(a1, a2, a3, a4, a5, a6, ncol = 2, nrow = 3)
figure10 <- annotate_figure(figure10,
                           top = text_grob("Estimated and Simulated Parameter Pairings: Density Forecasts", color='black', size=14),
                           bottom = text_grob("Note: Black dots are estimated values and grey dots are simulated values from the estimated joint distributions.", color='black',size=8))
ggsave(filename="figure10.jpg",
       plot = figure10,
       device = NULL,
       path = "./",
       width = 8.5,
       height = 11,
       units = "in",
       dpi = 300)


