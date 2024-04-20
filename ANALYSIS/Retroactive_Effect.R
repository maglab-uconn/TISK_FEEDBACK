
library(readr)
library(ggplot2)
library(tidyverse)

grid_arrange_shared_legend <- function(..., plotlist=NULL, ncol = length(list(...)) + length(plotlist), nrow = 1, position = c("bottom", "right", "none"))
{
  library(ggplot2)
  library(gridExtra)
  library(grid)
  
  plots <- c(list(...), plotlist)
  position <- match.arg(position)
  if(position== "bottom")
  {
    g <- ggplotGrob(plots[[1]] + theme(legend.position = "bottom"))$grobs  
  }
  else
  {
    g <- ggplotGrob(plots[[1]] + theme(legend.position = "left"))$grobs  
  }
  
  if("guide-box" %in% sapply(g, function(x) x$name))
  {
    legend <- g[[which(sapply(g, function(x) x$name) == "guide-box")]]
    lheight <- sum(legend$height)
    lwidth <- sum(legend$width)
  }
  else
  {
    position = "none"
  }
  gl <- lapply(plots, function(x) x + theme(legend.position="none"))
  gl <- c(gl, ncol = ncol, nrow = nrow)
  combined <- switch(position,
                     "bottom" = arrangeGrob(do.call(arrangeGrob, gl),
                                            legend,
                                            ncol = 1,
                                            heights = unit.c(unit(1, "npc") - lheight, lheight)),
                     "right" = arrangeGrob(do.call(arrangeGrob, gl),
                                           legend,
                                           ncol = 2,
                                           widths = unit.c(unit(1, "npc") - lwidth, lwidth)),
                     "none" = arrangeGrob(do.call(arrangeGrob, gl)))
  
  grid.newpage()
  grid.draw(combined)
  
  # return gtable invisibly
  invisible(combined)
}


work_Dir <- "."  #Insert the TISK dir
if (substr(work_Dir, nchar(work_Dir), nchar(work_Dir)) != "/") { work_Dir <- paste(work_Dir, "/", sep="") }

dir.create(file.path(work_Dir, "Graphs"), showWarnings = FALSE)
dir.create(file.path(paste(work_Dir, "Graphs", sep=""), "Retroactive_Effect"), showWarnings = FALSE)


feedback_Retroactive_Effect_Result <- read_delim(paste(work_Dir, "Results/Retroactive_Effect/Feedback.Retroactive_Effect.txt", sep=""), "\t", escape_double = FALSE, locale = locale(encoding = "UTF-8"), trim_ws = TRUE)
no_Feedback_Retroactive_Effect_Result <- read_delim(paste(work_Dir, "Results/Retroactive_Effect/No_Feedback.Retroactive_Effect.txt", sep=""), "\t", escape_double = FALSE, locale = locale(encoding = "UTF-8"), trim_ws = TRUE)

# feedback_Retroactive_Effect_Result <- feedback_Retroactive_Effect_Result#[-2:-5]
# no_Feedback_Retroactive_Effect_Result <- no_Feedback_Retroactive_Effect_Result#[-2:-5]



# Add 'model' column to feedback_Retroactive_Effect_Result
feedback_Retroactive_Effect_Result <- feedback_Retroactive_Effect_Result %>%
  mutate(model = 'Feedback')

# Add 'model' column to no_Feedback_Retroactive_Effect_Result
no_Feedback_Retroactive_Effect_Result <- no_Feedback_Retroactive_Effect_Result %>%
  mutate(model = 'No feedback')

combined_Retroactive_Effect_Result <- bind_rows(feedback_Retroactive_Effect_Result, no_Feedback_Retroactive_Effect_Result)
combined_Retroactive_Effect_Result <- combined_Retroactive_Effect_Result %>%
  dplyr::rename(
    `p:plug` = `/p/|pl^g`,
    `b:plug` = `/b/|pl^g`,
    `p:blush` = `/p/|bl^S`,
    `b:blush` = `/b/|bl^S`,
    `p:#lug` = `/p/|#l^g`,
    `b:#lug` = `/b/|#l^g`,
    `p:#lush` = `/p/|#l^S`,
    `b:#lush` = `/b/|#l^S`,
    `Model` = `model`
  )

# View the first few rows of the modified combined data frame
head(combined_Retroactive_Effect_Result)
long_Retroactive_Effect_Result <- combined_Retroactive_Effect_Result %>%
  pivot_longer(
    cols = starts_with("p:") | starts_with("b:"),
    names_to = c("Phoneme", "Input"),
    names_sep = ":",
    values_to = "value"
  ) %>%
  mutate(Context = stringr::str_replace(Input, "^(.)", "_")) %>%
  mutate(
    Ambiguity = if_else(stringr::str_detect(Input, "^[pb]"), "Intact", "Ambiguous"),
    Condition = paste0(Phoneme, ':', Ambiguity)
  )

# View the first few rows of the transformed data frame
head(long_Retroactive_Effect_Result)


###### HERE

long_Retroactive_Effect_Result$Ambiguity <- factor(long_Retroactive_Effect_Result$Ambiguity, 
                                                   levels = c("Intact", "Ambiguous"))

# Assuming long_Retroactive_Effect_Result has been prepared as per your previous instructions
# Define custom settings for the plot based on Condition and Ambiguity

# Custom colors for Conditions - adjust as needed
custom_colors <- c("p" = "purple", "b" = "black")

# Assuming Ambiguity has two levels - Intact and Ambiguous for custom line types
custom_linetypes <- c("Intact" = "solid", "Ambiguous" = "dashed")

# If you're plotting points or need specific shapes, adjust this accordingly
# Custom shapes, if applicable
custom_shapes <- c("p" = 16, "b" = 17)  # Example shapes for phonemes

# Adjusting plot code based on provided structure
xplot <- ggplot(long_Retroactive_Effect_Result, aes(x = Cycle, y = value, color = Phoneme, group = Condition)) +
  geom_line(aes(linetype = Ambiguity)) +  # Draw lines for each condition, styled by Ambiguity
  geom_text(data = long_Retroactive_Effect_Result %>% filter(as.numeric(Cycle) %% 10 == 0), 
            aes(label = ifelse(grepl("p", Condition), "p", "b")), 
            size = 6, check_overlap = FALSE, 
            position = position_jitter(width = 1.5, height = 0.0)) +
  facet_grid(Model ~ Context) +  # Facets for Model and Context
  scale_colour_manual(values = custom_colors) +
  scale_linetype_manual(values = custom_linetypes) +
  scale_shape_manual(values = custom_shapes) +  # If using geom_point
  labs(x = "Cycle", y = "Activation", color = "Condition", linetype = "Ambiguity") +
  theme_bw() +
  theme(
    text = element_text(size = 30),
    panel.background = element_blank(), 
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    plot.background = element_blank(),
    legend.position = c(0.3,0.8),
    strip.text.x = element_text(face = "bold"),
    strip.text.y = element_text(face = "bold"),
    legend.title = element_blank(),
    legend.key.width = unit(2, "cm")  # Adjust the width of the legend keys
  ) +
  guides(
    color = guide_none(),  # Do not show color in legend
    shape = guide_none(),  # Do not show shape in legend (if used)
    linetype = guide_legend(override.aes = list(color = "black"), keyheight = unit(3, "lines"))
  )
# Note: Modify `custom_colors`, `custom_linetypes`, and `custom_shapes` based on your dataset specifics

ggsave("Graphs/Retroactive_Effect/fig08_retroactive_effect.png", xplot, width = 12, height=12)

print("Saved figure to Graphs/Retroactive_Effect/fig08_retroactive_effect.png")

