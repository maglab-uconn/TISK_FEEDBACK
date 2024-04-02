#!/usr/bin/env Rscript
#setwd("/Users/jmagnuson/Dropbox/MAGNUSON/MODELS/TRACE_FEEDBACK_PRJ_2015/recovering_makeable_trace_2016.10.22/ctrace-maglab-gk.wrk/SCRIPTS")
library(optparse)
library(stringr)
library(tidyverse)
library(ggplot2)

option_list = list(
  make_option(c("-e", "--exclude"), action="store", default=NA, type='character',
              help="data file"),
  make_option(c("-f", "--file"), action="store", default=NA, type='character',
              help="data file"),
  make_option(c("-t", "--title"), action="store", default="", type='character',
              help="plot title"),
  make_option(c("-x", "--xlab"), action="store", default="Time (processing cycles)", type='character',
              help="x axis label"),
  make_option(c("-y", "--ylab"), action="store", default="Activation", type='character',
              help="y axis label"),
  make_option(c("-l", "--lowery"), action="store", default=NA, type='double',
              help="Y axis lower limit"),
  make_option(c("-u", "--uppery"), action="store", default=NA, type='double',
              help="Y axis upper limit"),
  make_option(c("-d", "--downsample"), action="store", default=1, type='integer',
              help="downsample time steps"),
  make_option(c("-a", "--aggregated"), action="store", default=0, type='integer',
              help="means you have trace data that is already aggregated")
)

# for setting breaks for figures and keeping them all multiples of 0.1
find_nearest_tenth <- function(number) {
  ceiling(number * 10) / 10
}

opt = parse_args(OptionParser(option_list=option_list))
ylabel = opt$y
xlabel = opt$x
infile = opt$f
ptitle = opt$t
downsample = opt$d
excludes = str_split(opt$e, pattern = ",", simplify = TRUE)
upperbound = opt$u
lowerbound = opt$l
tracemode = 0
if(opt$a){ tracemode = 1}


outfile = paste0(infile, "_timePlot", ".png")
outfile_dat = paste0(infile, "_timePlot", ".csv")

cat(paste("data file", opt$f,", plot title", opt$t, ",xlabel",opt$x, ", ylabel", opt$y, "\n\n"))

if(tracemode){
  data <- read.table(infile, header = FALSE, sep = "\t")
  # Rename the columns
  colnames(data) <- c("Time", "Junk", "lexicon", "Feedback", "Noise", "Category", "Activation")
  
  
  # Reduce to necessary columns and add 'fake' SEM column
  grouped_data <- data %>%
    select(Time, Category, Activation) %>%
    mutate(SEM = 0) %>%  # Adding a column with all zeros cause we don't have item-level data
    filter(Category %in% c("Target", "Cohort", "Rhyme", "Unrelated"))

  grouped_data$Category <- factor(grouped_data$Category, levels = c("Target", "Cohort", "Rhyme", "Unrelated"))
  
} else { 
  
  # Load your data
  data <- read.table(infile, header = TRUE, sep = "\t")

  # Okay, the Category data includes cases where an item did not have any competitors
  # in a particular category (e.g., if there were no rhymes, the Rhyme row for that 
  # item is all zeros.) We need to remove those cases or else we badly underestimate 
  # mean competition when the competitor type is valid. 
  
  # Remove rows where columns 3-102 are all zeros
  data <- data[rowSums(select(data, 3:102) != 0) > 0, ]
  
  # Filtering the data based on the 2nd column (Category)
  filtered_data <- data %>% 
    filter(Category %in% c("Target", "Cohort", "Rhyme", "Other"))
  
  # Renaming 'Other' to 'Unrelated' in the Category column
  filtered_data <- filtered_data %>%
    mutate(Category = ifelse(Category == "Other", "Unrelated", Category))
  
  # Assuming 'excludes' is a vector of items to exclude from the first column
  #excludes <- c("st^did", "triti") # Replace with actual items to exclude
  filtered_data <- filtered_data[!(filtered_data[[1]] %in% excludes), ]
  
  # Reshaping the data for plotting
  long_data <- pivot_longer(filtered_data, cols = starts_with("X"), 
                            names_to = "Time", values_to = "Activation",
                            names_prefix = "X")
  
  # Parsing TimeStep to integer
  long_data$Time <- as.integer(long_data$Time)
  
  # Converting Category to a factor and specifying the order of levels
  long_data$Category <- factor(long_data$Category, levels = c("Target", "Cohort", "Rhyme", "Unrelated"))
  
  # Calculating mean and standard error
  grouped_data <- long_data %>% 
    group_by(Category, Time) %>% 
    summarise(Mean = mean(Activation), SEM = sd(Activation) / sqrt(n()))
  
  # Renaming 'Mean' to 'Activation'
  grouped_data <- grouped_data %>% 
    rename(Activation = Mean)
}
# Plotting with ggplot2
# ggplot(grouped_data, aes(x = TimeStep, y = Mean, group = Category, color = Category)) +
#   geom_line() +
#   geom_ribbon(aes(ymin = Mean - SEM, ymax = Mean + SEM), alpha = 0.2) +
#   labs(title = "Activation Over Time by Category", x = "Time Step", y = "Activation Level") +
#   theme_minimal()

shapeValues  = c(16, 15,  17, 20)
colorValues = c("black", # target
                "red", # cohort
                "blue", # rhyme
                "grey") # unrelated
#(breaks = seq(from = <minimum_value>, to = <maximum_value>, by = 0.1))

if(!is.na(upperbound)){
  theplot = ggplot(filter(grouped_data, Time %% downsample == 0), aes(x=Time, y=Activation, colour=Category, shape=Category)) +
    geom_line() + 
    geom_point(size=2) +
    geom_ribbon(aes(ymin = Activation - SEM, ymax = Activation + SEM), alpha = 0.2, colour=NA) +
    scale_shape_manual(values=shapeValues) +
    scale_colour_manual(values=colorValues) +
    scale_y_continuous(limits=c(lowerbound, upperbound), 
                       breaks = seq(from=find_nearest_tenth(lowerbound),
                                    to=find_nearest_tenth(upperbound-0.1), by=0.1)) + 
    theme(panel.background = element_rect(colour="black", fill="white"),
        axis.text.x = element_text(size=20, face="plain", colour="black"),
        axis.text.y = element_text(size=20, face="plain", colour="black"),
        axis.title.x = element_text(size=20, face="bold", colour="black", vjust=-.4),
        axis.title.y = element_text(size=20, face="bold", colour="black", vjust=1),
        strip.text.x = element_text(size =20),
        title=element_text(size=20),
        legend.text = element_text(size = 15), 
        legend.background = element_rect(fill="white", colour="black"),
        legend.key = element_blank(), legend.title=element_blank(),
        legend.position=c(0.18,0.75),
	plot.title = element_text(hjust = 0.5, margin = margin(b = -25)),
        panel.grid.major = element_line(size = 0.5, linetype = 'dotted', colour = "lightgrey"), 
        panel.grid.minor = element_line(size = 0.5, linetype = 'dotted', colour = "lightgrey")) + 
    xlab(xlabel) + ylab(ylabel) + ggtitle(ptitle)
} else { 
  theplot = ggplot(filter(grouped_data, Time %% downsample == 0), aes(x=Time, y=Activation, colour=Category, shape=Category)) +
    geom_line() + 
    geom_point(size=2) +
    geom_ribbon(aes(ymin = Activation - SEM, ymax = Activation + SEM), alpha = 0.2, colour=NA) +
    scale_shape_manual(values=shapeValues) +
    scale_colour_manual(values=colorValues) +
    theme(panel.background = element_rect(colour="black", fill="white"),
        axis.text.x = element_text(size=20, face="plain", colour="black"),
        axis.text.y = element_text(size=20, face="plain", colour="black"),
        axis.title.x = element_text(size=20, face="bold", colour="black", vjust=-.4),
        axis.title.y = element_text(size=20, face="bold", colour="black", vjust=1),
        strip.text.x = element_text(size =20),
        title=element_text(size=20),
        legend.text = element_text(size = 15), 
        legend.background = element_rect(fill="white", colour="black"),
        legend.key = element_blank(), legend.title=element_blank(),
        legend.position=c(0.18,0.75),
	plot.title = element_text(hjust = 0.5, margin = margin(b = -23)),
        panel.grid.major = element_line(size = 0.5, linetype = 'dotted', colour = "lightgrey"), 
        panel.grid.minor = element_line(size = 0.5, linetype = 'dotted', colour = "lightgrey")) + 
    xlab(xlabel) + ylab(ylabel) + ggtitle(ptitle)
}
#theplot
ggsave(outfile, width=6,height=7.5)
# Save the grouped_data as a CSV file
# Assuming 'grouped_data' is your final data frame

# Convert from long to wide format
wide_data <- pivot_wider(grouped_data, names_from = Category, values_from = Activation)

# Drop the SEM column
wide_data <- select(wide_data, -SEM)

# Save the wide format data as a CSV file
write.csv(wide_data, file = outfile_dat, row.names = FALSE)