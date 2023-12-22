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
dir.create(file.path(paste(work_Dir, "Graphs", sep=""), "No_Feedback_Map"), showWarnings = FALSE)

library(readr)
library(ggplot2)
library(reshape2)

graceful_Degradation <- read_delim(paste(work_Dir, "Results/Graceful_Degradation/No_Feedback.PD.WW.Map.txt", sep=""), "\t", escape_double = FALSE, locale = locale(encoding = "UTF-8"), trim_ws = TRUE)

graceful_Degradation.Summary <- data_summary(graceful_Degradation, varname="Accuracy", groupnames=c("NPhone_Decay", "WtoW_Weight", "Noise_LOC"))

append_Data <- ddply(
  .data=graceful_Degradation,
  .(NPhone_Decay, WtoW_Weight), 
  summarize, 
  Mean_ACC=round(mean(Accuracy), 3)
)
append_Data = within(
  append_Data,
  {Fill = ifelse(append_Data$Mean_ACC > 0.5, "A", ifelse(append_Data$Mean_ACC > 0.4, "B", "C"))}
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


acc_Plot <- ggplot(data=graceful_Degradation.Summary) +
  geom_line(aes(x = Noise_LOC, y = Accuracy), colour="#000000") +
  facet_grid(NPhone_Decay ~ WtoW_Weight, switch="both") +
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
    aes(x= 0, y=0, fill = append_Data$Fill),
    xmin = -Inf, 
    xmax = Inf,
    ymin = -Inf,
    ymax = Inf,
    alpha = 0.3
  ) +
  labs(x="WtoW_Inhibition", y= "NPhone_Decay", title="") +
  scale_y_continuous(limits = c(0, 1), breaks=seq(0, 1, 0.25)) +
  scale_fill_manual(values = alpha(fill_Values, .3)) +
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

ggsave(filename = paste(work_Dir, "Graphs/No_Feedback_Map/figA3_No_Feedback_Map.png", sep=""), plot = acc_Plot, device = "png", width = 30, height = 30, units = "cm", dpi = 300)
