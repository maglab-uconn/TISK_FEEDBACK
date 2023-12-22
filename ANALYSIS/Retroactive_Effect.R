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

library(readr)
library(ggplot2)
library(reshape2)

feedback_Retroactive_Effect_Result <- read_delim(paste(work_Dir, "Results/Retroactive_Effect/Feedback.Retroactive_Effect.txt", sep=""), "\t", escape_double = FALSE, locale = locale(encoding = "UTF-8"), trim_ws = TRUE)
no_Feedback_Retroactive_Effect_Result <- read_delim(paste(work_Dir, "Results/Retroactive_Effect/No_Feedback.Retroactive_Effect.txt", sep=""), "\t", escape_double = FALSE, locale = locale(encoding = "UTF-8"), trim_ws = TRUE)

feedback_Retroactive_Effect_Result <- feedback_Retroactive_Effect_Result[-2:-5]
no_Feedback_Retroactive_Effect_Result <- no_Feedback_Retroactive_Effect_Result[-2:-5]

melt_Feedback_Retroactive_Effect <- melt(feedback_Retroactive_Effect_Result, id="Cycle")
melt_No_Feedback_Retroactive_Effect <- melt(no_Feedback_Retroactive_Effect_Result, id="Cycle")

no_Feedback_Graph <- ggplot(data=melt_No_Feedback_Retroactive_Effect, aes(x=Cycle, y=value, shape=variable, colour=variable)) +
  geom_line(data=melt_No_Feedback_Retroactive_Effect, aes(linetype=variable)) +
  geom_point(data=melt_No_Feedback_Retroactive_Effect[as.numeric(melt_No_Feedback_Retroactive_Effect$Cycle) %% 10 == 0,], aes(shape=variable), size = 3) + 
  labs(linetype ="Pattern", shape = "Pattern", colour = "Pattern") +
  labs(x = "Cycle", y = "Activation of /p/ or /b/", title=paste("No feedback")) +
  scale_x_continuous(breaks = (seq(0, 99, 10))) +
  ylim(0, 0.4) +
  scale_linetype_manual(labels=c("/p/ | #l^g", "/b/ | #l^g", "/p/ | #l^S", "/b/ | #l^S"), values=c("solid", "dashed", "solid", "dashed")) +
  scale_shape_manual(labels=c("/p/ | #l^g", "/b/ | #l^g", "/p/ | #l^S", "/b/ | #l^S"), values=c(2,17,5,18)) +
  scale_colour_manual(labels=c("/p/ | #l^g", "/b/ | #l^g", "/p/ | #l^S", "/b/ | #l^S"), values=c("red","blue","red","blue")) +
  theme_bw() +
  theme(text = element_text(size=25),
        panel.background = element_blank(), 
        panel.grid.major = element_blank(),  #remove major-grid labels
        panel.grid.minor = element_blank(),  #remove minor-grid labels
        plot.background = element_blank(),
        legend.key.height=unit(2,"line"))


feedback_Graph <- ggplot(data=melt_Feedback_Retroactive_Effect, aes(x=Cycle, y=value, shape=variable, colour=variable)) +
  geom_line(data=melt_Feedback_Retroactive_Effect, aes(linetype=variable)) +
  geom_point(data=melt_Feedback_Retroactive_Effect[as.numeric(melt_Feedback_Retroactive_Effect$Cycle) %% 10 == 0,], aes(shape=variable), size = 3) + 
  labs(linetype ="Pattern", shape = "Pattern", colour = "Pattern") +
  labs(x = "Cycle", y = "Activation of /p/ or /b/", title=paste("Feedback")) +
  scale_x_continuous(breaks = (seq(0, 99, 10))) +
  ylim(0, 0.4) +
  scale_linetype_manual(labels=c("/p/ | #l^g", "/b/ | #l^g", "/p/ | #l^S", "/b/ | #l^S"), values=c("solid", "dashed", "solid", "dashed")) +
  scale_shape_manual(labels=c("/p/ | #l^g", "/b/ | #l^g", "/p/ | #l^S", "/b/ | #l^S"), values=c(2,17,5,18)) +
  scale_colour_manual(labels=c("/p/ | #l^g", "/b/ | #l^g", "/p/ | #l^S", "/b/ | #l^S"), values=c("red","blue","red","blue")) +
  theme_bw() +
  theme(text = element_text(size=25),
        panel.background = element_blank(), 
        panel.grid.major = element_blank(),  #remove major-grid labels
        panel.grid.minor = element_blank(),  #remove minor-grid labels
        plot.background = element_blank(),
        legend.key.height=unit(2,"line"))

png(paste(work_Dir, "Graphs/Retroactive_Effect/fig09_Retroactive_Effect.png", sep=""), width = 33, height = 15, res =300, units = "cm")
grid_arrange_shared_legend(no_Feedback_Graph, feedback_Graph, ncol = 2, nrow = 1, position="right")
dev.off()

