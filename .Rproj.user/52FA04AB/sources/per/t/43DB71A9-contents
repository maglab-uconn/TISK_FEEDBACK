#+++++++++++++++++++++++++
# Function to calculate the mean and the standard deviation
# for each group
#+++++++++++++++++++++++++
# data : a data frame
# varname : the name of a column containing the variable
#to be summariezed
# groupnames : vector of column names to be used as
# grouping variables
data_summary <- function(data, varname, groupnames){
  require(plyr)
  summary_func <- function(x, col){
    c(mean = mean(x[[col]], na.rm=TRUE),
      sd = sd(x[[col]], na.rm=TRUE))
  }
  data_sum<-ddply(data, groupnames, .fun=summary_func,
                  varname)
  data_sum <- rename(data_sum, c("mean" = varname))
  return(data_sum)
}

work_Dir <- "."  #Insert the TISK dir
if (substr(work_Dir, nchar(work_Dir), nchar(work_Dir)) != "/") { work_Dir <- paste(work_Dir, "/", sep="") }

dir.create(file.path(work_Dir, "Graphs"), showWarnings = FALSE)
dir.create(file.path(paste(work_Dir, "Graphs", sep=""), "Graceful_Degradation"), showWarnings = FALSE)

library(readr)
library(ggplot2)
library(reshape2)
library(gridExtra)
library(grid)
library(tidyverse)

feedback_Graceful_Degradation <- read_delim(paste(work_Dir, "Results/Graceful_Degradation/Feedback.Graceful_Degradation.txt", sep=""), "\t", escape_double = FALSE, locale = locale(encoding = "UTF-8"), trim_ws = TRUE)
no_Feedback_Graceful_Degradation <- read_delim(paste(work_Dir, "Results/Graceful_Degradation/No_Feedback.Graceful_Degradation.txt", sep=""), "\t", escape_double = FALSE, locale = locale(encoding = "UTF-8"), trim_ws = TRUE)
original_Graceful_Degradation <- read_delim(paste(work_Dir, "Results/Graceful_Degradation/Original.Graceful_Degradation.txt", sep=""), "\t", escape_double = FALSE, locale = locale(encoding = "UTF-8"), trim_ws = TRUE)
feedback_Graceful_Degradation$Model <- "Feedback"
no_Feedback_Graceful_Degradation$Model <- "No feedback (optimized)"
original_Graceful_Degradation$Model <- "No feedback (original)"
graceful_Degradation <- rbind(feedback_Graceful_Degradation, no_Feedback_Graceful_Degradation, original_Graceful_Degradation) %>%
  mutate(Reaction_Time = if_else(Accuracy < 0.01, NA_real_, Reaction_Time))


summary_graceful_Degradation_RT <- data_summary(graceful_Degradation, varname="Reaction_Time", groupnames=c("Model", "Noise_LOC"))
rt_Plot <- ggplot(data=summary_graceful_Degradation_RT, aes(x = Noise_LOC, y = Reaction_Time, group=Model)) +
  geom_point(aes(shape=Model, color=Model), size = 5) +
  geom_line(aes(linetype=Model, group=Model, color=Model)) +
  geom_errorbar(aes(ymin=Reaction_Time-sd, ymax=Reaction_Time+sd, color=Model), size=.3, width=.002) +
  ggtitle(paste("RT Comparison")) + 
  scale_x_continuous(breaks = seq(0, 0.15, 0.05), labels=c("Intact", format(seq(0.05, 0.15, 0.05), nsmall=2))) +
  ylim(0, 90) +
  labs(linetype ="", shape = "", colour = "") +
  labs(x = "Noise Mean", y = "Mean recognition time (cycles)", title="", legend="") +
  theme_bw() +
  theme(text = element_text(size=25),
        panel.background = element_blank(), 
        panel.grid.major = element_blank(),  #remove major-grid labels
        panel.grid.minor = element_blank(),  #remove minor-grid labels
        plot.background = element_blank(),
        legend.position="none" #c(0.3,0.82)
        )

#ggsave(paste(work_Dir, "Graphs/Graceful_Degradation/Graceful_Degradation.RT.png", sep=""), plot=rt_Plot, width = 15, height = 15, dpi=300, units = "cm")


summary_graceful_Degradation_Accuracy <- data_summary(graceful_Degradation, varname="Accuracy", groupnames=c("Model", "Noise_LOC"))
acc_Plot <- ggplot(data=summary_graceful_Degradation_Accuracy, aes(x = Noise_LOC, y = Accuracy, group=Model)) +
  geom_point(aes(shape=Model, color=Model), size = 5) +
  geom_line(aes(linetype=Model, group=Model, color=Model)) +
  geom_errorbar(aes(ymin=Accuracy-sd, ymax=Accuracy+sd, color=Model), size=.3, width=.002) +
  ggtitle("Accuracy Comparison") + 
  scale_x_continuous(breaks = seq(0, 0.15, 0.05), labels=c("Intact", format(seq(0.05, 0.15, 0.05), nsmall=2))) +
  ylim(0, 1) +
  labs(linetype ="", shape = "", colour = "") +
  labs(x = "Noise Mean", y = "Mean accuracy", title="", legend="") +
  theme_bw() +
  theme(text = element_text(size=25),
        panel.background = element_blank(), 
        panel.grid.major = element_blank(),  #remove major-grid labels
        panel.grid.minor = element_blank(),  #remove minor-grid labels
        plot.background = element_blank(),
        legend.position=c(0.7,0.82)
        )

#ggsave(paste(work_Dir, "Graphs/Graceful_Degradation/Graceful_Degradation.Accuracy.png", sep=""), plot=acc_Plot, width = 15, height = 15, dpi=300, units = "cm")


# Combine the two plots
#grid.arrange(acc_Plot, rt_Plot, ncol=2)

# Save the combined plots
ggsave(paste(work_Dir, "Graphs/Graceful_Degradation/fig11_Graceful_Degradation.Combined.png", sep=""), 
       grid.arrange(acc_Plot, rt_Plot, ncol=2),
       width = 40, height = 30, dpi=300, units = "cm")
