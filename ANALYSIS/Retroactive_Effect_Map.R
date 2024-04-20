rm(list = ls(all.names = TRUE))

# Load necessary libraries
library(dplyr)
library(readr)
library(tidyr)
library(ggplot2)

# Load the data from the tab-delimited file
# Replace 'Results/Retroactive_Effect/Retro.FE.FI.Map.txt' with the path to your file
data <- read_tsv('Results/Retroactive_Effect/Retro.FE.FI.Map.txt')

# Define patterns
p_con_intact <- "/p/\\|pl\\^g"
b_con_intact <- "/b/\\|bl\\^S"
b_incon_intact <- "/b/\\|pl\\^g"
p_incon_intact <- "/p/\\|bl\\^S"

p_con_amb <- "/p/\\|#l\\^g"
b_con_amb <- "/b/\\|#l\\^S"
b_incon_amb <- "/b/\\|#l\\^g"
p_incon_amb <- "/p/\\|#l\\^S"

# Pivot the data longer, then create 'phone', 'type', and 'con' columns
long_data <- data %>%
  pivot_longer(cols = `/p/|pl^g`:`/b/|#l^S`, names_to = "Item", values_to = "value") %>%
  mutate(
    phone = substr(Item, 2, 2), # Extracts the second character from 'Item'
    type = case_when(
      grepl(paste0(p_con_intact, "|", b_con_intact, "|", b_incon_intact, "|", p_incon_intact), Item) ~ "intact",
      grepl(paste0(p_con_amb, "|", b_con_amb, "|", b_incon_amb, "|", p_incon_amb), Item) ~ "ambiguous",
      TRUE ~ NA_character_
    ),
    con = case_when(
      grepl(paste0(p_con_intact, "|", b_con_intact), Item) | grepl(paste0(p_con_amb, "|", b_con_amb), Item) ~ "consistent",
      grepl(paste0(b_incon_intact, "|", p_incon_intact), Item) | grepl(paste0(b_incon_amb, "|", p_incon_amb), Item) ~ "inconsistent",
      TRUE ~ NA_character_
    )
  )

# Group the data by Feedback_Excitation, Feedback_Inhibition, Cycle, Item, phone, type, and con
grouped_data <- long_data %>%
  group_by(Feedback_Excitation, Feedback_Inhibition, Cycle, type, con)

# Calculate the mean for each group
summarized_data <- grouped_data %>%
  summarise(mean = mean(value, na.rm = TRUE)) %>%
  ungroup()

# Combine 'type' and 'con' into a single grouping variable for plotting
summarized_data <- summarized_data %>%
  mutate(type_con = paste(type, con, sep = ","))

summary(summarized_data)
unique(summarized_data$type_con)
##################################################################################################################################
# Now find cases that meet criteria for being reasonable simulations of Retroactive Effect
# Cases where ambiguous,consistent - ambiguous,inconsistent are > threshold at cycle 50 AND
#             intact,inconsistent < min_reasonable
cyc = 80
# Filter for relevant data
diff_data_base <- summarized_data %>%
  filter(Cycle == cyc, type_con %in% c("ambiguous,consistent", "ambiguous,inconsistent"))

# Compute the difference directly within each group
diff_data <- diff_data_base %>%
  group_by(Feedback_Excitation, Feedback_Inhibition) %>%
  summarise(diff_ambig = mean(mean[type_con == "ambiguous,consistent"], na.rm = TRUE) - 
              mean(mean[type_con == "ambiguous,inconsistent"], na.rm = TRUE),
            .groups = 'drop') # Drop the grouping

head(diff_data)

# Filter for relevant data
in_in_data <- summarized_data %>%
  filter(Cycle == cyc, type_con %in% c("intact,inconsistent"))

# Compute the difference directly within each group
in_in <- in_in_data %>%
  group_by(Feedback_Excitation, Feedback_Inhibition) %>%
  summarise(in50 = mean(mean[type_con == "intact,inconsistent"], na.rm = TRUE),
            .groups = 'drop') # Drop the grouping

plot(hist(in_in$in50, breaks=20))
in_in[in_in$in50 > 0.05,]
plot(hist(diff_data$diff_ambig, breaks=40))
##################################################################################################################################


# Join your main data with the 'facet_colors' to assign colors to each row
sd_constraints <- summarized_data %>%
  left_join(diff_data, by = c("Feedback_Excitation" = "Feedback_Excitation", 
                                 "Feedback_Inhibition" = "Feedback_Inhibition")) %>%
  left_join(in_in, by = c("Feedback_Excitation" = "Feedback_Excitation", 
                          "Feedback_Inhibition" = "Feedback_Inhibition"))

sd_constraints$fcolor = NA



dathresh = 0.05
inthresh = 0.05

nrow(sd_constraints[sd_constraints$diff_ambig > dathresh, ])
nrow(sd_constraints[sd_constraints$in50 < inthresh, ])

good_re = "lightyellow"
good_gd = "#E9FDE0"#"#CFFDBC"#"#9FE2BF"
sd_constraints <- sd_constraints %>%
  dplyr::mutate(fcolor = if_else(diff_ambig > dathresh & in50 < inthresh, good_re, fcolor))


# Now set a green fill for cases that were 'good' in Graceful Degradation & Ganong (Fig A1)

# Update gd_good to 'green' based on specified conditions
sd_constraints <- sd_constraints %>%
  dplyr::mutate(gdcolor = case_when(
    fcolor == good_re & Feedback_Inhibition == -0.04 & Feedback_Excitation %in% c(0.07, 0.08) ~ good_gd,
    fcolor == good_re & Feedback_Inhibition == -0.05 & Feedback_Excitation %in% c(0.08, 0.09, 0.10) ~ good_gd,
    fcolor == good_re & Feedback_Inhibition == -0.06 & Feedback_Excitation %in% c(0.09, 0.10, 0.11) ~ good_gd,
    fcolor == good_re & Feedback_Inhibition == -0.07 & Feedback_Excitation %in% c(0.10, 0.11, 0.12, 0.13) ~ good_gd,
    fcolor == good_re & Feedback_Inhibition == -0.08 & Feedback_Excitation %in% c(0.11, 0.12, 0.13, 0.14) ~ good_gd,
    fcolor == good_re & Feedback_Inhibition == -0.09 & Feedback_Excitation %in% c(0.11, 0.12, 0.13, 0.14, 0.15) ~ good_gd,
    fcolor == good_re & Feedback_Inhibition == -0.10 & Feedback_Excitation %in% c(0.11, 0.12, 0.13, 0.14, 0.15) ~ good_gd,
    fcolor == good_re & Feedback_Inhibition == -0.11 & Feedback_Excitation %in% c(0.11, 0.12, 0.13, 0.14, 0.15) ~ good_gd,
    fcolor == good_re & Feedback_Inhibition == -0.12 & Feedback_Excitation %in% c(0.10, 0.11, 0.12, 0.13, 0.14, 0.15) ~ good_gd,
    fcolor == good_re & Feedback_Inhibition == -0.13 & Feedback_Excitation %in% c(0.12, 0.13, 0.14, 0.15) ~ good_gd,
    fcolor == good_re & Feedback_Inhibition == -0.14 & Feedback_Excitation == 0.15 ~ good_gd#,
#    TRUE ~ gd_good # Preserve existing gd_good values where conditions do not apply
  ))

sd_constraints <- sd_constraints %>%
  dplyr::mutate(shade = coalesce(gdcolor, fcolor))



# Plotting with corrected manual specifications for a single legend
plot <- ggplot(sd_constraints, aes(x = Cycle, y = mean, group = type_con)) +
  geom_rect(data = subset(sd_constraints, !is.na(shade)),
            aes(xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf, fill = shade),
            inherit.aes = FALSE, alpha = 0.3) +
  scale_fill_identity() +
  geom_line(aes(linetype = type_con, color = type_con), linewidth=1) + # Correctly map color aesthetic
  geom_point(data = summarized_data %>% filter(Cycle %in% c(80)),
             aes(shape = type_con, color = type_con, size = type_con)) + # Correctly map color aesthetic for points
  facet_grid(Feedback_Inhibition ~ Feedback_Excitation, switch="both") +
  
  # Corrected manual aesthetics
  scale_color_manual(values = c("intact,consistent" = "#5D3A9B",    
                                "intact,inconsistent" = "#E66100",  
                                "ambiguous,consistent" = "#1A85FF",  
                                "ambiguous,inconsistent" = "#DC3220"), 
                     name = "Type and Consistency") +
  scale_shape_manual(values = c("intact,consistent" = 15,    # Filled square
                                "intact,inconsistent" = 16,  # Filled circle
                                "ambiguous,consistent" = 0,  # Open square
                                "ambiguous,inconsistent" = 1), # Open circle
                     name = "Type and Consistency") +
  scale_size_manual(values = c("intact,consistent" = 0,    # Filled square
                                "intact,inconsistent" = 0,  # Filled circle
                                "ambiguous,consistent" = 2.5,  # Open square
                                "ambiguous,inconsistent" = 2.5), # Open circle
                     name = "Type and Consistency") +
  scale_linetype_manual(values = c("intact,consistent" = "solid",    # Solid for intact
                                   "intact,inconsistent" = "solid",  # Solid for intact
                                   "ambiguous,consistent" = "solid",  # Dashed for ambiguous
                                   "ambiguous,inconsistent" = "solid"), # Dashed for ambiguous
                        name = "Type and Consistency") +
  
  labs(x="Feedback Excitation", y= "Feedback Inhibition", title="") +
  scale_y_continuous(limits = c(0, 1)) +
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
        legend.position = "bottom",
        legend.title = element_blank(), # Remove legend title
        legend.text = element_text(size = 12), # Optional: Adjust legend text size
        legend.direction = "horizontal") + # Display legend items horizontally
  guides(color = guide_legend(title = "", override.aes = list(size = 3)), # No title, adjust size
         linetype = guide_legend(title = ""),
         shape = guide_legend(title = ""),
         size = guide_legend(title = ""))
plot

ggsave(filename = "Graphs/Retroactive_Map/figA2_Retroactive_Map.png", 
       plot = plot, device = "png", width = 30, height = 30, units = "cm", dpi = 300)
