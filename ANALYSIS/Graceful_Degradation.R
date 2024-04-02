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
  # geom_ribbon(aes(ymin=Reaction_Time-sd, ymax=Reaction_Time+sd, color=Model), size=.3, width=.002) +
  geom_ribbon(aes(ymin = Reaction_Time - sd, ymax = Reaction_Time + sd, fill = Model), alpha = 0.3) +  # Adjusted for fill and transparency
  ggtitle(paste("RT Comparison")) + 
  scale_x_continuous(breaks = seq(0, 0.15, 0.05), labels=c("Intact", format(seq(0.05, 0.15, 0.05), nsmall=2))) +
  ylim(0, 90) +
  labs(linetype ="", shape = "", colour = "") +
  labs(x = "Noise mean", y = "Mean recognition time (cycles)", title="", legend="") +
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
  geom_ribbon(aes(ymin = Accuracy - sd, ymax = Accuracy + sd, fill = Model), alpha = 0.3) +  # Adjusted for fill and transparency
  # geom_ribbon(aes(ymin=Accuracy-sd, ymax=Accuracy+sd, color=Model), size=.3, width=.002) +
  ggtitle("Accuracy Comparison") + 
  scale_x_continuous(breaks = seq(0, 0.15, 0.05), labels=c("Intact", format(seq(0.05, 0.15, 0.05), nsmall=2))) +
  ylim(0, 1) +
  labs(linetype ="", shape = "", colour = "") +
  labs(x = "Noise mean", y = "Mean accuracy", title="", legend="") +
  theme_bw() +
  theme(text = element_text(size=25),
        panel.background = element_blank(), 
        panel.grid.major = element_blank(),  #remove major-grid labels
        panel.grid.minor = element_blank(),  #remove minor-grid labels
        plot.background = element_blank(),
        legend.position=c(0.6,0.86),
        legend.key.width = unit(2, "cm")  # Adjust the width of the legend keys
  ) +
  guides(
#    linetype = guide_legend(keyheight = unit(10, "lines")),
    fill = FALSE
  )

#ggsave(paste(work_Dir, "Graphs/Graceful_Degradation/Graceful_Degradation.Accuracy.png", sep=""), plot=acc_Plot, width = 15, height = 15, dpi=300, units = "cm")


# Combine the two plots
#grid.arrange(acc_Plot, rt_Plot, ncol=2)

# Save the combined plots
ggsave(paste(work_Dir, "Graphs/Graceful_Degradation/fig10_Graceful_Degradation.Combined.png", sep=""), 
       grid.arrange(acc_Plot, rt_Plot, ncol=2),
       width = 36, height = 18, dpi=300, units = "cm")


# Now do by-item scatterplots
library(tidyverse)

# Read CSV file
idf <- read_csv("Results/Graceful_Degradation/graceful_degradation_by_item_results.csv", col_names=FALSE)
names(idf) = c('Run', 'model', 'word', 'noise', 'junk', 'rt')
# Clean the 'rt' column - ensure it's numeric and set as NA for non-numeric values
idf <- idf %>% mutate(rt = as.numeric(rt))

# Function to calculate accuracy, mean RT, and proportion correct
calculate_metrics <- function(data) {
  accuracy <- sum(!is.na(data$rt))
  mean_rt <- mean(data$rt, na.rm = TRUE)
  proportion_correct <- accuracy / nrow(data)
  return(data.frame(Accuracy = accuracy, Mean_RT = mean_rt, Proportion_Correct = proportion_correct))
}

# Apply the function for each combination of Run, model, and noise
results <- idf %>% 
  group_by(Run, model, noise) %>%
  nest() %>%
  mutate(Metrics = map(data, calculate_metrics)) %>%
  select(-data) %>%
  unnest(Metrics)

# Spread the data first
idf_spread <- idf %>%
  select(Run, model, word, noise, rt) %>%
  spread(key = model, value = rt) %>%
  filter(Run != 30 & noise < 0.2)

# Calculate valid (non-NA) trial counts for feedback and nofeedback
valid_trial_counts <- idf_spread %>%
  group_by(noise) %>%
  dplyr::summarise(fb_count = sum(!is.na(feedback)),
                   nofb_count = sum(!is.na(nofeedback)),
                   included = sum(!is.na(feedback) & !is.na(nofeedback))) # Count rows where both feedback and nofeedback are not NA

# Now, remove rows with any NAs in the feedback or nofeedback columns
idf_cleaned <- idf_spread %>%
  filter(!is.na(feedback) & !is.na(nofeedback))

# Calculate the proportion of cases where rt for feedback is less than rt for nofeedback for each noise level
proportions <- idf_cleaned %>%
  group_by(noise) %>%
  dplyr::summarize(fbProp = mean(feedback < nofeedback, na.rm = TRUE),
                   noProp = mean(feedback > nofeedback, na.rm = TRUE)) %>%
  ungroup()

meanrts <- idf_cleaned %>%
  filter(feedback > 0 & nofeedback > 0) %>%
  group_by(noise) %>%
  dplyr::summarise(
    mean_fb = mean(feedback, na.rm = TRUE),
    sem_fb = sd(feedback, na.rm = TRUE) / sqrt(sum(!is.na(feedback))),  # SEM for feedback
    mean_nofb = mean(nofeedback, na.rm = TRUE),
    sem_nofb = sd(nofeedback, na.rm = TRUE) / sqrt(sum(!is.na(nofeedback)))  # SEM for nofeedback
  ) %>%
  ungroup()


# Merge the proportions back to the cleaned data for plotting
idf_cleaned_with_proportions <- idf_cleaned %>%
  left_join(proportions, by = "noise") %>%
  left_join(valid_trial_counts, by = "noise")  %>%
  left_join(meanrts, by = "noise")

idf_15 <- idf_cleaned_with_proportions %>%
  filter(noise < 0.15)

# Create the plot with annotations for each noise level
plot_all <- ggplot(idf_15, aes(x = feedback, y = nofeedback, color=Run)) +
  geom_point( alpha = 0.5, size = 5) + # Make points small, grey, and transparent
  geom_abline(slope = 1, intercept = 0, linetype = "solid", color = "blue", size=1) + # Add a dashed identity line
  facet_wrap(~ noise, scales = "free", nrow = 5) + 
  geom_text(aes(
                label = paste0(
                              fb_count, " valid trials with FB\n",
                              nofb_count, " valid trials w/out FB\n",
                              included, " valid pairs\n", 
                              round(fbProp * 100, 0), "% faster with FB, ", 
                              round(noProp * 100, 0), "% w/out")),
            x = 62, y = 31, vjust = 1, hjust = 0, size = 3.5, fontface="plain", color='black',
            check_overlap = T) +
  # geom_hline(aes(yintercept = mean_nofb), color='red', linetype='dashed') + 
  # geom_vline(aes(xintercept = mean_fb), color='red', linetype='dashed') + 
  geom_point(aes(mean_fb, mean_nofb), color='pink',shape=22, size=5,fill='red',alpha=0.5) + 
  scale_x_continuous(limits = c(15, 100)) + # Set x-axis limits
  scale_y_continuous(limits = c(15, 100)) + # Set y-axis limits
  labs(x = "Recognition time (Feedback)", y = "Recognition time (No Feedback)") +
  theme_bw(base_size=22) #+
  # theme(panel.spacing = unit(1, "lines"))

print(plot_all)

ggsave(paste(work_Dir, "Graphs/Graceful_Degradation/fig11_Graceful_Degradation_Scatterplots_all.png", sep=""), 
       plot_all,
       width = 43, height = 60, dpi=300, units = "cm")

idf_one <- idf_15 %>%
  filter(Run == 1)
# Create the plot with annotations for each noise level
plot_one <- ggplot(idf_one, aes(x = feedback, y = nofeedback)) + #, color=Run)) +
  geom_point(color='black', alpha = 0.5, size = 5) + # Make points small, grey, and transparent
  geom_abline(slope = 1, intercept = 0, linetype = "solid", color = "blue", size=1) + # Add a dashed identity line
  facet_wrap(~ noise, scales = "free", nrow = 5) + 
  geom_text(aes(
    label = paste0(
      fb_count, " valid trials with FB\n",
      nofb_count, " valid trials w/out FB\n",
      included, " valid pairs\n", 
      round(fbProp * 100, 0), "% faster with FB, ", 
      round(noProp * 100, 0), "% w/out")),
    x = 62, y = 31, vjust = 1, hjust = 0, size = 3.5, fontface="plain", color='black',
    check_overlap = T) +
  # geom_hline(aes(yintercept = mean_nofb), color='red', linetype='dashed') + 
  # geom_vline(aes(xintercept = mean_fb), color='red', linetype='dashed') + 
  geom_point(aes(mean_fb, mean_nofb), color='pink',shape=22, size=5,fill='red',alpha=0.5) + 
  scale_x_continuous(limits = c(15, 100)) + # Set x-axis limits
  scale_y_continuous(limits = c(15, 100)) + # Set y-axis limits
  labs(x = "Recognition time (Feedback)", y = "Recognition time (No Feedback)") +
  theme_bw(base_size=22) #+
# theme(panel.spacing = unit(1, "lines"))

print(plot_one)

# so few data points at nofb x noise 0.15 it was not included in original plot; 
# remove it here
meanrts <- meanrts %>%
  mutate(
    mean_nofb = ifelse(noise == 0.15, NA, mean_nofb),
    sem_nofb = ifelse(noise == 0.15, NA, sem_nofb)
  )

rev_rt <- ggplot(meanrts, aes(x = noise)) +
  geom_ribbon(aes(ymin = mean_fb - sem_fb, ymax = mean_fb + sem_fb, fill = "Feedback"), alpha = 0.3, show.legend = FALSE) +
  geom_ribbon(aes(ymin = mean_nofb - sem_nofb, ymax = mean_nofb + sem_nofb, fill = "No Feedback"), alpha = 0.3, show.legend = FALSE) +
  geom_line(aes(y = mean_fb, color = "Feedback"), size = 0.5) +
  geom_line(aes(y = mean_nofb, color = "No Feedback"), linetype = 2, size = 0.5) +
  geom_point(aes(y = mean_fb, color = "Feedback", shape = "Feedback"), size = 5) +
  geom_point(aes(y = mean_nofb, color = "No Feedback", shape = "No Feedback"), size = 5) +
  scale_color_manual(values = c("Feedback" = "#F8766D", "No Feedback" = "#00BA38")) +
  scale_fill_manual(values = c("Feedback" = "#F8766D", "No Feedback" = "#00BA38"), guide = FALSE) +
  scale_shape_manual(values = c("Feedback" = 16, "No Feedback" = 17)) +
  scale_x_continuous(breaks = seq(0, 0.15, 0.05), labels = c("Intact", format(seq(0.05, 0.15, 0.05), nsmall = 2))) +
  ylim(0, 90) +
  labs(x = "Noise mean", y = "Mean recognition time (cycles)") +
  theme_bw() +
  theme(
    text = element_text(size = 25),
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    plot.background = element_blank(),
    legend.position = c(0.6, 0.86),
    legend.title = element_blank(),
    legend.key.width = unit(2, "cm")
  ) +
  guides(
    color = guide_legend(override.aes = list(shape = c(16, 17), linetype = c("solid", "dashed"))),
    shape = "none"  # Explicitly disable the shape legend
  )

# Print the revised plot
print(rev_rt)




ggsave(paste(work_Dir, "Graphs/Graceful_Degradation/fig13_Graceful_Degradation_rt_revised.png", sep=""), 
       rev_rt,
       width = 18, height = 18, dpi=300, units = "cm")

