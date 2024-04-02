library(readr)
library(ggplot2)
library(reshape2)
library(tidyverse)

#rm(list=ls())

work_Dir <- "."  #Insert the TISK dir
if (substr(work_Dir, nchar(work_Dir), nchar(work_Dir)) != "/") { work_Dir <- paste(work_Dir, "/", sep="") }

dir.create(file.path(work_Dir, "Graphs"), showWarnings = FALSE)
dir.create(file.path(paste(work_Dir, "Graphs", sep=""), "Phoneme_Restoration"), showWarnings = FALSE)


phoneme_Restoration_Result <- read_delim(paste(work_Dir, "Results/Phoneme_Restoration/Phoneme_Restoration.txt", sep=""), "\t", escape_double = FALSE, locale = locale(encoding = "UTF-8"), trim_ws = TRUE)
# feedback_Phoneme_Restoration_Result <- read_delim(paste(work_Dir, "Results/Phoneme_Restoration/Feedback.Phoneme_Restoration.txt", sep=""), "\t", escape_double = FALSE, locale = locale(encoding = "UTF-8"), trim_ws = TRUE)
# no_Feedback_Phoneme_Restoration_Result <- read_delim(paste(work_Dir, "Results/Phoneme_Restoration/No_Feedback.Phoneme_Restoration.txt", sep=""), "\t", escape_double = FALSE, locale = locale(encoding = "UTF-8"), trim_ws = TRUE)

select_Noise_Value = c("0.0", "0.2", "0.3", "0.4", "0.8", "Intact")
select_Check_Location = c(0, 1, 2, 3)

phoneme_Restoration_Result.Subset <- subset(phoneme_Restoration_Result, phoneme_Restoration_Result$Noise %in% select_Noise_Value & phoneme_Restoration_Result$Location %in% select_Check_Location)
phoneme_Restoration_Result.Subset$Noise[phoneme_Restoration_Result.Subset$Noise == "0.0"] <- "Silence" 
phoneme_Restoration_Result.Subset$Noise <- factor(
  phoneme_Restoration_Result.Subset$Noise,
  levels = c("Intact", "0.8", "0.4", "0.3", "0.2", "Silence"),
  labels = c("Intact", "0.8", "0.4", "0.3", "0.2", "Silence")
  )
phoneme_Restoration_Result.Subset$Model <- factor(
  phoneme_Restoration_Result.Subset$Model,
  levels = c("No_Feedback", "Feedback"),
  labels = c("No Feedback", "Feedback")
  )

pr_result_subset <- phoneme_Restoration_Result.Subset %>%
  group_by(Model, Location, Noise, Cycle) %>%
  summarise(
    Act = mean(Activation, na.rm = TRUE),
    SE = sd(Activation, na.rm = TRUE) / sqrt(n())
  ) %>%
  ungroup()

# plot <- ggplot(data=phoneme_Restoration_Result.Subset, aes(x=Cycle, y=Activation, shape=Noise, linetype=Noise, color=Noise)) +
#   geom_line(size = 2) +
#   geom_point(data=phoneme_Restoration_Result.Subset[as.numeric(phoneme_Restoration_Result.Subset$Cycle) %% 10 == 0,], size = 5) + 
#   facet_grid(Model ~ Location) +
#   labs(linetype ="Noise", shape = "Noise", colour = "Noise") +
#   labs(x = "Cycle", y = "Phoneme Activation", title="") +
#   scale_x_continuous(breaks = (seq(0, 99, 10))) +
#   ylim(0, 1) + 
#   theme_bw() +
#   theme(text = element_text(size=36),
#         panel.background = element_blank(), 
#         panel.grid.major = element_blank(),  #remove major-grid labels
#         panel.grid.minor = element_blank(),  #remove minor-grid labels
#         plot.background = element_blank(),
#         legend.position = "bottom",
#         strip.text.x = element_blank()
#         )
# 
# ggsave(paste(work_Dir, "Graphs/Phoneme_Restoration/Phoneme_Restoration.png", sep=""), plot=plot, width = 45, height = 32, dpi=300, units = "cm")


pr_result_subset$Activation = pr_result_subset$Act
pr_result_subsetb = subset(pr_result_subset, Cycle < 71)
# Define a custom labeller function for the Location
custom_labeller_Location <- as_labeller(c(`0` = "Position 1", `1` = "Position 2", `2` = "Position 3", `3` = "Position 4"))
# Custom colors and linetypes
custom_colors <- c("Silence" = "red", "Intact" = "blue", "0.2" = "grey60", "0.3" = "grey40", "0.4" = "grey20", "0.8" = "black")
custom_linetypes <- c("Silence" = "dotted", "Intact" = "dashed", "0.3" = "solid", "0.2" = "solid", "0.4" = "solid", "0.8" = "solid")
custom_shapes <- c("Silence" = NA, "Intact" = NA, "0.3" = 16, "0.2" = 17, "0.4" = 18, "0.8" = 15)  # Custom shapes

xdata = pr_result_subsetb
xplot <- ggplot(data=xdata, aes(x=Cycle, y=Activation, shape=Noise, linetype=Noise, color=Noise)) +
  geom_line(size = 1) +
  geom_point(data=xdata[as.numeric(xdata$Cycle) %% 5 == 0,], aes(size=Noise)) + 
#  geom_ribbon(aes(ymin = Activation - SE, ymax = Activation + SE, fill = Noise), alpha = 0.2, show.legend = FALSE, color=NA) +
  geom_ribbon(aes(ymin = Activation - SE, ymax = Activation + SE, fill = Noise), alpha = 0.2, color = NA, show.legend=FALSE) +
  facet_grid(Model ~ Location, labeller = labeller(Model = label_value, Location = custom_labeller_Location)) +
  labs(linetype ="Noise", shape = "Noise", colour = "Noise") +
  labs(x = "Cycle", y = "Phoneme activation", title="") +
  scale_x_continuous(breaks = (seq(0, 150, 20))) +
  ylim(0, 0.69) + 
  theme_bw() +
  theme(text = element_text(size=36),
        panel.background = element_blank(), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        plot.background = element_blank(),
        legend.position = "right",
        legend.title = element_blank(), # Suppress legend title
        strip.text.x = element_text(size = 18, face = "bold"),
        strip.text.y = element_text(size = 18, face = "bold")
  ) +
  scale_color_manual(values = custom_colors) +  # Custom colors
  scale_fill_manual(values = custom_colors) +  # Custom colors
  scale_linetype_manual(values = custom_linetypes) +  # Custom linetypes
  scale_shape_manual(values = custom_shapes )  +  # Custom shapes
  scale_size_manual(values = c("Silence" = 5, "Intact" = 5, "0.2" = 3, "0.3" = 5, "0.4" = 5, "0.8" = 4))  # Custom sizes

#xplot
#ggsave(paste(work_Dir, "Graphs/Phoneme_Restoration/fig10_Phoneme_Restoration.png", sep=""), plot=plot, width = 45, height = 32, dpi=300, units = "cm")

ggsave("Graphs/Phoneme_Restoration/fig10_Phoneme_Restoration.png", xplot, width = 18, height=9)

print("Saved figure to Graphs/Phoneme_Restoration/fig10_Phoneme_Restoration.png")
