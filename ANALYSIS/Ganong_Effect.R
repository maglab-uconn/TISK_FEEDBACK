library(tidyverse)
library(purrr)
library(ggplot2)
library(cowplot)

# Define the directory where the files are located
data_dir <- "Results/Ganong_Effect"

parse_file_info <- function(filename) {
  # Extracts the word_length part (e.g., p3, p4)
  word_length_part <- str_extract(filename, "p[3-9]")
  # Extracts the model type (feedback or nofeedback)
  model_type_part <- str_extract(filename, "feedback|nofeedback")
  
  # Extract the numeric position just before ".Raw.txt"
  position <- as.integer(str_extract(filename, "(?<=_)[0-9]+(?=\\.Raw\\.txt$)"))
  
  # Simplify model type naming
  model_type <- case_when(
    model_type_part == "feedback" ~ "Feedback",
    model_type_part == "nofeedback" ~ "No Feedback",
    TRUE ~ "Unknown"
  )
  
  list(word_length = word_length_part, model_type = model_type, position = position)
}

process_files <- function(data_dir) {
  # Initially list all files in the directory that end with "Raw.txt"
  all_files <- list.files(data_dir, pattern = "Raw\\.txt$", full.names = TRUE)
  
  # Filter out files containing 'original' in their names
  files <- all_files[!grepl("original", all_files)]
  
  # Continue with parsing file names and reading files...
  file_info <- map(files, ~parse_file_info(.x))
  
  df_list <- map2(files, file_info, ~{
    # Read the file, skipping the header and not showing column type messages
    df <- read_delim(.x, "\t", escape_double = FALSE, trim_ws = TRUE, col_names = FALSE, skip = 1, 
                     show_col_types = FALSE) %>%
      set_names(c("Step", "Word", "Nonword"))
    
    # Add metadata columns based on the updated structure
    mutate(df, word_length = .y$word_length, model_type = .y$model_type, position = .y$position)
  }) %>% bind_rows()
  
  # Calculate mean, standard deviation (sd), and standard error (se) for Word and Nonword
  df_summary <- df_list %>%
    group_by(word_length, position, Step, model_type) %>%
    summarise(
      Word_mean = mean(Word, na.rm = TRUE),
      Word_sd = sd(Word, na.rm = TRUE),
      Word_se = Word_sd / sqrt(n()),
      Nonword_mean = mean(Nonword, na.rm = TRUE),
      Nonword_sd = sd(Nonword, na.rm = TRUE),
      Nonword_se = Nonword_sd / sqrt(n()),
      .groups = 'drop'
    )

  return(df_summary)
}

plot_data <- function(df_summary, selected_length) {
  # Filter df_summary for the selected word_length
  df_filtered <- df_summary %>%
    filter(word_length == selected_length) %>%
    mutate(Position = paste("Position", position + 1)) # Adjust position for labeling
  
  # Generate the plot
  midpoint = max(df_filtered$Step + 1)/2
  p <- ggplot(df_filtered, aes(x = Step, y = Word_mean, group = model_type, color = model_type)) +
#    geom_ribbon(aes(ymin = Word_mean - Word_se, ymax = Word_mean + Word_se, fill = model_type), alpha = 0.2, show.legend = FALSE) +
    # geom_ribbon(aes(ymin = Word_mean - Word_se, ymax = Word_mean + Word_se, fill = model_type), alpha = 0.2, show.legend = FALSE) +
    geom_ribbon(aes(ymin = Word_mean - Word_se, ymax = Word_mean + Word_se, fill = model_type), alpha = 0.2, show.legend = FALSE, color = NA) +
    geom_line(aes(y = Word_mean, linetype = model_type)) + # Ensure consistent aesthetic mapping for lines
    geom_point(aes(y = Word_mean, shape = model_type), size = 5) + # Ensure consistent aesthetic mapping for points
    facet_wrap(~Position, nrow = 1, scales = "free_x") + # One row with columns per position
    labs(#title = paste("Data for word length", selected_length),
         x = "Continuum step (from nonword- to lexically-consistent endpoint)",
         y = "Predicted proportion of choices") +
    geom_vline(xintercept=(midpoint) , linetype="dashed", color='magenta') + 
    geom_hline(yintercept = .5, linetype = "dashed", color = 'magenta') + 
    theme_bw(base_size = 20) +
    theme(
      legend.position = c(.25,.7),
      legend.title = element_blank(), # Suppress legend title
      legend.key.size = unit(1, "cm"), # Adjust legend key size
      legend.box.background = element_blank(), 
      strip.text.x = element_text(angle = 0, hjust = 0.5), # Make facet labels horizontal
      panel.grid.major = element_line(color = "lightgrey", linetype = "dotted"), # Major gridlines
      panel.grid.minor = element_blank(), # Hide minor gridlines for clarity
      axis.text.x = element_text(angle = 0, hjust = 1) # Improve x axis label readability
    ) +
    scale_x_continuous(breaks = 1:max(df_filtered$Step)) #+ # Ensure x-axis ticks are as desired
    #scale_color_manual(values = c("Feedback" = "blue", "No Feedback" = "red") # Customize line colors

  print(p)
}


# Updated plot_data function to accept a prefix parameter
plot_data_word_nonword <- function(df_summary, selected_length) {
  # Filter df_summary for the selected prefix
  df_filtered <- df_summary %>%
    filter(word_length == selected_length) %>%
    mutate(Position = paste("Position", position + 1)) # Adjust position for labeling
  
  # Generate the plot with geom_ribbon for standard error
  p <- ggplot(df_filtered, aes(x = Step)) +
    geom_ribbon(aes(ymin = Word_mean - Word_se, ymax = Word_mean + Word_se, fill = "Word SE"), alpha = 0.2, show.legend = FALSE) +
    geom_ribbon(aes(ymin = Nonword_mean - Nonword_se, ymax = Nonword_mean + Nonword_se, fill = "Nonword SE"), alpha = 0.2, show.legend = FALSE) +
    geom_line(aes(y = Word_mean, color = "Word")) +
    geom_line(aes(y = Nonword_mean, color = "Nonword")) +
    facet_grid(rows = vars(model_type), cols = vars(Position), scales = "free_x", space = "free_x") +
    labs(x = "Continuum step (from nonword- to lexically-consistent endpoint)", y = "Predicted proportion of choices", color = "Phoneme Type", fill = "Type SE") +
    geom_vline(xintercept=((1 + max(df_filtered$Step)/2)) , linetype="dashed", color='magenta') + 
    geom_hline(yintercept=.5, linetype="dashed", color='magenta') + 
    theme_bw(base_size=20) +
    theme(legend.position = c(.05, .8), 
          legend.title = element_blank(), # Suppress legend title
          strip.text.x = element_text(angle = 0, hjust = 0.5), # Make facet labels horizontal
          #strip.text.y = element_text(angle = 270, hjust = 0.5), # Adjust for horizontal y strip text
          legend.key.size = unit(1, "cm"), # Adjust legend key size
          legend.box.background = element_blank(), # Move legend to top left
          legend.box.margin = margin(0, 0, 0, 0),
          panel.grid.major = element_line(color = "lightgrey", linetype = "dotted"), # Make major gridlines light grey
          panel.grid.minor = element_line(color = "lightgrey", linetype = "dotted") # Make minor gridlines light grey and dotted
    ) +
    scale_x_continuous(breaks = 1:7) # Ensure x-axis ticks are as desired
  
  #print(p)
}


# Remember to process the files first to generate df_summary
df_summary <- process_files(data_dir)


df_summary$Step = df_summary$Step + 1

#names(df_summary)

# To plot for p3 items
#plot_data(df_summary, "p3")
p4plot <- plot_data(df_summary, "p4")

ggsave("Graphs/Ganong_Effect/fig07_ganong.png", p4plot, width = 12, height=6)
print("Ganong plot saved to Graphs/Ganong_Effect/fig07_ganong.png")
# expsum <- plot_summs(resultsSD.Off.lt3D2LexCU, ci_level=0.5)
# expcoef <- plot_coefs(resultsSD.Off.lt3D2LexCU, ci_level=0.95)
#toc()
