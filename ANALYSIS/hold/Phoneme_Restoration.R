work_Dir <- "."  #Insert the TISK dir
if (substr(work_Dir, nchar(work_Dir), nchar(work_Dir)) != "/") { work_Dir <- paste(work_Dir, "/", sep="") }

dir.create(file.path(work_Dir, "Graphs"), showWarnings = FALSE)
dir.create(file.path(paste(work_Dir, "Graphs", sep=""), "Phoneme_Restoration"), showWarnings = FALSE)

library(readr)
library(ggplot2)
library(reshape2)

feedback_Phoneme_Restoration_Result <- read_delim(paste(work_Dir, "Results/Phoneme_Restoration/Feedback.Phoneme_Restoration.txt", sep=""), "\t", escape_double = FALSE, locale = locale(encoding = "UTF-8"), trim_ws = TRUE)
no_Feedback_Phoneme_Restoration_Result <- read_delim(paste(work_Dir, "Results/Phoneme_Restoration/No_Feedback.Phoneme_Restoration.txt", sep=""), "\t", escape_double = FALSE, locale = locale(encoding = "UTF-8"), trim_ws = TRUE)

feedback_Phoneme_Restoration_Result$Model <- "Feedback"
no_Feedback_Phoneme_Restoration_Result$Model <- "No_Feedback"

phoneme_Restoration_Result <- rbind(feedback_Phoneme_Restoration_Result, no_Feedback_Phoneme_Restoration_Result)


select_Noise_Value = c("0.0", "0.2", "0.4", "0.6", "0.8", "1.0", "Intact")
select_Check_Location = c(0, 3, 6)

phoneme_Restoration_Result.Subset <- subset(phoneme_Restoration_Result, phoneme_Restoration_Result$Noise %in% select_Noise_Value & phoneme_Restoration_Result$Location %in% select_Check_Location)
phoneme_Restoration_Result.Subset$Noise[phoneme_Restoration_Result.Subset$Noise == "0.0"] <- "Silence" 
phoneme_Restoration_Result.Subset$Noise <- factor(
  phoneme_Restoration_Result.Subset$Noise,
  levels = c("0.2", "0.4", "0.6", "0.8", "1.0", "Silence", "Intact"),
  labels = c("0.2", "0.4", "0.6", "0.8", "1.0", "Silence", "Intact")
  )
phoneme_Restoration_Result.Subset$Model <- factor(
  phoneme_Restoration_Result.Subset$Model,
  levels = c("No_Feedback", "Feedback"),
  labels = c("No Feedback", "Feedback")
  )

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




# Define a custom labeller function for the Location
custom_labeller_Location <- as_labeller(c(`0` = "Onset", `3` = "Medial", `6` = "Offset"))
# Custom colors and linetypes
custom_colors <- c("Silence" = "red", "Intact" = "blue", "0.2" = "grey20", "0.4" = "grey30", "0.6" = "grey40", "0.8" = "grey50", "1.0" = "grey60")
custom_linetypes <- c("Silence" = "dotted", "Intact" = "dashed", "0.2" = "solid", "0.4" = "solid", "0.6" = "solid", "0.8" = "solid", "1.0" = "solid")
custom_shapes <- c("Silence" = NA, "Intact" = NA, "0.2" = 16, "0.4" = 17, "0.6" = 18, "0.8" = 19, "1.0" = 20)  # Custom shapes

plot <- ggplot(data=phoneme_Restoration_Result.Subset, aes(x=Cycle, y=Activation, shape=Noise, linetype=Noise, color=Noise)) +
  geom_line(size = 2) +
  geom_point(data=phoneme_Restoration_Result.Subset[as.numeric(phoneme_Restoration_Result.Subset$Cycle) %% 9 == 0,], aes(size=Noise)) + 
  facet_grid(Model ~ Location, labeller = labeller(Model = label_value, Location = custom_labeller_Location)) +
  labs(linetype ="Noise", shape = "Noise", colour = "Noise") +
  labs(x = "Cycle", y = "Phoneme Activation", title="") +
  scale_x_continuous(breaks = (seq(0, 150, 20))) +
  ylim(0, 0.69) + 
  theme_bw() +
  theme(text = element_text(size=36),
        panel.background = element_blank(), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        plot.background = element_blank(),
        legend.position = "right",
        strip.text.x = element_text(size = 18, face = "bold"),
        strip.text.y = element_text(size = 18, face = "bold")
  ) +
  scale_color_manual(values = custom_colors) +  # Custom colors
  scale_linetype_manual(values = custom_linetypes) +  # Custom linetypes
  scale_shape_manual(values = custom_shapes) +  # Custom shapes
  scale_size_manual(values = c("Silence" = 5, "Intact" = 5, "0.2" = 7, "0.4" = 6, "0.6" = 5, "0.8" = 4, "1.0" = 3))  # Custom sizes

ggsave(paste(work_Dir, "Graphs/Phoneme_Restoration/fig10_Phoneme_Restoration.png", sep=""), plot=plot, width = 45, height = 32, dpi=300, units = "cm")
