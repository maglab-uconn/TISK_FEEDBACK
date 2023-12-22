work_Dir <- "."  #Insert the TISK dir
if (substr(work_Dir, nchar(work_Dir), nchar(work_Dir)) != "/") { work_Dir <- paste(work_Dir, "/", sep="") }

dir.create(file.path(work_Dir, "Graphs"), showWarnings = FALSE)
dir.create(file.path(paste(work_Dir, "Graphs", sep=""), "Ganong_Effect"), showWarnings = FALSE)

library(readr)
library(ggplot2)
library(reshape2)

feedback_Ganong_Result <- read_delim(paste(work_Dir, "Results/Ganong_Effect/Feedback.Ganong_effect.Raw.txt", sep=""), "\t", escape_double = FALSE, locale = locale(encoding = "UTF-8"), trim_ws = TRUE)
no_Feedback_Ganong_Result <- read_delim(paste(work_Dir, "Results/Ganong_Effect/No_Feedback.Ganong_effect.Raw.txt", sep=""), "\t", escape_double = FALSE, locale = locale(encoding = "UTF-8"), trim_ws = TRUE)
feedback_Ganong_Result$Model <- "Feedback"
no_Feedback_Ganong_Result$Model <- "No_Feedback"
ganong_Result <- rbind(feedback_Ganong_Result,no_Feedback_Ganong_Result)


melt_Ganong_Result <- melt(ganong_Result, id=c("Model", "Continuum_Step"))
split_Variable <- do.call(rbind, strsplit(as.character(melt_Ganong_Result$variable), "_"))
colnames(split_Variable) <- c("Word","Phoneme")
melt_Ganong_Result <- cbind(melt_Ganong_Result, split_Variable)
melt_Ganong_Result$Model <- factor(melt_Ganong_Result$Model, levels = c("No_Feedback", "Feedback"), labels = c("No_Feedback", "Feedback"))

#Word
word_Plot <- ggplot(data=melt_Ganong_Result, aes(x=Continuum_Step, y=value, shape=Phoneme, color=Phoneme)) +
  geom_point(size = 7) +
  geom_line(aes(linetype=Phoneme), size = 2) +
  facet_grid(Model ~ Word) +
  ylim(0, 1.0) +
  labs(linetype ="", shape = "", color = "") +
  labs(x = "Continuum step", y = "Activation", title="") +
  theme_bw() +
  theme(text = element_text(size=48),
        panel.background = element_blank(), 
        panel.grid.major = element_blank(),  #remove major-grid labels
        panel.grid.minor = element_blank(),  #remove minor-grid labels
        plot.background = element_blank(),
        legend.position = "bottom"
        )

#ggsave(paste(work_Dir, "Graphs/Ganong_Effect/Ganong_Effect.Word.png", sep=""), plot=word_Plot, width = 45, height = 32, dpi=300, units = "cm")


#Model
melt_Ganong_Result.Subset <- subset(melt_Ganong_Result, melt_Ganong_Result$Word != "Single")
model_Plot <- ggplot(data=melt_Ganong_Result.Subset, aes(x=Continuum_Step, y=value, shape=Phoneme, color=Phoneme)) +
  geom_point(size = 7) +
  geom_line(aes(linetype=Word), size = 2) +
  facet_grid(. ~ Model) +
  ylim(0, 1.0) +
  labs(linetype ="", shape = "", color = "") +
  labs(x = "Continuum step", y = "Activation", title="") +
  theme_bw() +
  theme(text = element_text(size=48),
        panel.background = element_blank(), 
        panel.grid.major = element_blank(),  #remove major-grid labels
        panel.grid.minor = element_blank(),  #remove minor-grid labels
        plot.background = element_blank(),
        legend.position = "bottom"
        )

#ggsave(paste(work_Dir, "Graphs/Ganong_Effect/Ganong_Effect.Model.png", sep=""), plot=model_Plot, width = 30, height = 20, dpi=300, units = "cm")



# Create a new column that combines the Word and Phoneme columns
melt_Ganong_Result.Subset$Word_Phoneme <- paste(melt_Ganong_Result.Subset$Phoneme, melt_Ganong_Result.Subset$Word, sep=" | ")

# Fix the names
library(dplyr)

melt_Ganong_Result.Subset <- melt_Ganong_Result.Subset %>%
  mutate(
    Word_Phoneme = case_when(
      Word_Phoneme == "s | bus" ~ "s | b^∫-b^s",
      Word_Phoneme == "S | bus" ~ "∫ | b^∫-b^s",
      Word_Phoneme == "s | rush" ~ "s | r^∫-r^s",
      Word_Phoneme == "S | rush" ~ "∫ | r^∫-r^s",
      TRUE ~ Word_Phoneme  # This line keeps all other values the same
    )
  )

summary(melt_Ganong_Result.Subset)
unique(melt_Ganong_Result.Subset$Word_Phoneme)


# Create the ggplot
# model_Plot <- ggplot(data=melt_Ganong_Result.Subset, aes(x=Continuum_Step, y=value)) +
#   geom_point(aes(shape=Word_Phoneme, color=Word_Phoneme), size = 7) +
#   geom_line(aes(linetype=Word, color=Word_Phoneme), size = 2) +
#   facet_grid(. ~ Model) +
#   ylim(0, 1.0) +
#   labs(linetype ="", shape = "", color = "") +
#   labs(x = "Continuum step", y = "Activation", title="") +
#   theme_bw() +
#   theme(text = element_text(size=48),
#         panel.background = element_blank(), 
#         panel.grid.major = element_blank(),  #remove major-grid labels
#         panel.grid.minor = element_blank(),  #remove minor-grid labels
#         plot.background = element_blank(),
#         legend.position = "bottom"
#   )
# 
# # Save the plot
# ggsave(paste(work_Dir, "Graphs/Ganong_Effect/Ganong_Effect.Model.png", sep=""), plot=model_Plot, width = 30, height = 20, dpi=300, units = "cm")

# Define custom linetypes and colors
custom_linetypes <- c("s | b^∫-b^s" = "solid", "∫ | b^∫-b^s" = "solid", "s | r^∫-r^s" = "solid", "∫ | r^∫-r^s" = "solid")
custom_colors <- c("s | b^∫-b^s" = "darkred", "∫ | b^∫-b^s" = "darkblue", "s | r^∫-r^s" = "red", "∫ | r^∫-r^s" = "blue")
custom_shapes <- c("s | b^∫-b^s" = 1, "∫ | b^∫-b^s" = 2, "s | r^∫-r^s" = 21, "∫ | r^∫-r^s" = 25)

# jitter
melt_Ganong_Result.Subset <- melt_Ganong_Result.Subset %>%
  mutate(Continuum_Step_Jittered = Continuum_Step + runif(n(), -0.025, 0.025))

# Create the ggplot
model_Plot <- ggplot(data=melt_Ganong_Result.Subset, aes(x=Continuum_Step_Jittered, y=value)) +
  geom_point(aes(shape=Word_Phoneme, color=Word_Phoneme, fill=Word_Phoneme), size = 7) +  # Added fill aesthetic
  geom_line(aes(linetype=Word_Phoneme, color=Word_Phoneme), size = 1) +
  facet_grid(. ~ Model) +
  ylim(0, 1.0) +
  labs(linetype ="", shape = "", color = "", fill="") +  # Added fill label
  labs(x = "Continuum step", y = "Activation", title="") +
  theme_bw() +
  theme(text = element_text(size=48),
        panel.background = element_blank(), 
        panel.grid.major = element_blank(),  #remove major-grid labels
        panel.grid.minor = element_blank(),  #remove minor-grid labels
        plot.background = element_blank(),
        legend.position = "bottom"
  ) +
  scale_linetype_manual(values = custom_linetypes) +
  scale_color_manual(values = custom_colors) + 
  scale_fill_manual(values = custom_colors) +  # Added fill scale
  scale_shape_manual(values = custom_shapes)


# Save the plot
ggsave(paste(work_Dir, "Graphs/Ganong_Effect/fig08_Ganong_Effect.Model.png", sep=""), plot=model_Plot, width = 40, height = 30, dpi=300, units = "cm")


