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
dir.create(file.path(paste(work_Dir, "Graphs", sep=""), "Feedback_Map"), showWarnings = FALSE)

library(readr)
library(ggplot2)
library(reshape2)

ganong_Effect <- read_delim(paste(work_Dir, "Results/Ganong_Effect/Feedback.FE.FI.Map.txt", sep=""), "\t", escape_double = FALSE, locale = locale(encoding = "UTF-8"), trim_ws = TRUE)
graceful_Degradation <- read_delim(paste(work_Dir, "Results/Graceful_Degradation/Feedback.FE.FI.Map.txt", sep=""), "\t", escape_double = FALSE, locale = locale(encoding = "UTF-8"), trim_ws = TRUE)

ganong_Effect.Summary <- data_summary(ganong_Effect, varname="rush_Size", groupnames=c("Feedback_Excitation", "Feedback_Inhibition", "Continuum_Step"))
graceful_Degradation.Summary <- data_summary(graceful_Degradation, varname="Accuracy", groupnames=c("Feedback_Excitation", "Feedback_Inhibition", "Noise_LOC"))

append_Data1 <- ddply(
  .data=ganong_Effect,
  .(Feedback_Inhibition, Feedback_Excitation), 
  summarize, 
  Max_Effect_Size=max(rush_Size),
  Min_Effect_Size=min(rush_Size)
)
append_Data2 <- ddply(
  .data=graceful_Degradation,
  .(Feedback_Inhibition, Feedback_Excitation), 
  summarize, 
  Mean_ACC=round(mean(Accuracy), 3)
)

#append_Data <- merge(append_Data1, append_Data2, by=c("Feedback_Inhibition", "Feedback_Excitation"))
append_Data <- join(append_Data1, append_Data2, by=c("Feedback_Inhibition", "Feedback_Excitation"))

append_Data = within(
  append_Data, 
  {Fill = ifelse(append_Data$Mean_ACC > 0.5, "A", ifelse(append_Data$Mean_ACC > 0.4, "B", "C"))}
  )
append_Data = within(
  append_Data,
  {Border = ifelse(append_Data$Max_Effect_Size > 0.15 & !append_Data$Min_Effect_Size < 0.0, "A", "B")}
  )


fill_Values = c()
if (any(append_Data$Fill %in% "A"))
{
  fill_Values[[length(fill_Values) + 1]] <- "yellow"
}
if (any(append_Data$Fill %in% "B"))
{
  fill_Values[[length(fill_Values) + 1]] <- "purple"
}
if (any(append_Data$Fill %in% "C"))
{
  fill_Values[[length(fill_Values) + 1]] <- "white"
}



result_Plot <- ggplot()+#data=graceful_Degradation.Summary, aes(x = Noise_LOC, y = Accuracy)) +
  geom_line(data=graceful_Degradation.Summary, aes(x = Noise_LOC, y = Accuracy), linetype="solid") +
  geom_line(data=ganong_Effect.Summary, aes(x=Continuum_Step / 40, y=(rush_Size - min(rush_Size))/(max(rush_Size) - min(rush_Size))), linetype="dashed") +
  facet_grid(Feedback_Inhibition ~ Feedback_Excitation, switch="both") +
  geom_text(
    data=append_Data,
    aes(x= max(graceful_Degradation.Summary$Noise_LOC) * .75, y=0.9, label=Mean_ACC),
    colour="black",
    inherit.aes=FALSE,
    parse=FALSE,
    size=3
  ) +
  geom_rect(
    data=append_Data,
    aes(x= 0, y=0, fill = append_Data$Fill, color=append_Data$Border, size= append_Data$Border),
    xmin = -Inf, 
    xmax = Inf,
    ymin = -Inf,
    ymax = Inf,
    alpha = 0.3
  ) +
  labs(x="Feedback Excitation", y= "Feedback Inhibition", title="") +
  scale_y_continuous(limits = c(0, 1)) +
  scale_fill_manual(values = alpha(fill_Values, .3)) +
  scale_colour_manual(values=c("red","black")) +
  scale_size_manual(values=c(2, 0.5)) +
  theme_bw() +
  theme(text = element_text(size=20),
        panel.background = element_blank(),
        panel.grid.major = element_blank(),  #remove major-grid labels
        panel.grid.minor = element_blank(),  #remove minor-grid labels
        plot.background = element_blank(),
        plot.title = element_text(hjust = 0.5),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),#element_text(size=10),
        axis.ticks=element_blank(),
        legend.position = "none"
  )

ggsave(filename = paste(work_Dir, "Graphs/Feedback_Map/figA1_Feedback_Map.png", sep=""), plot = result_Plot, device = "png", width = 30, height = 30, units = "cm", dpi = 300)
