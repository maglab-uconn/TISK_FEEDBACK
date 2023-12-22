library(reshape)
library(ggplot2)
library(scales)
library(foreach)
library(gridExtra)

readSfeat <- function(filename,label,timesteps=200,maxX=66) {
  if(label == ""){ label <- filename}
  sfeat <- as.data.frame(fread(filename))[,c(2,4,6,8,10,12,14,16,18)]
  sfeat$feat <- rep(c("gPOW","fVOC","eDIF","dACU","cGRD","bVOI","aBUR"),timesteps)
  sfeat$slice <- sort(rep(seq(1,timesteps),7))
  colnames(sfeat) = c(seq(9,1),"feat","slice")
  sfeat<-sfeat[,c(11,10,seq(1,9))]
  sfeat$slice <- sfeat$slice - 1
  sfeat$name <- label
  sfeat.m <- melt(sfeat[sfeat$slice<maxX & sfeat$slice>0,],id=c("slice","feat","name"), variable_name="fval")
  sfeat.m$fvalXfeat<- paste0(sfeat.m$feat,sfeat.m$fval)
  sfeat.m$fvalXfeat <- factor(sfeat.m$fvalXfeat)
  return(sfeat.m)
}

readInput <- function(filename,label,maxX=66) {
  if(label == ""){ 
    filefields<-unlist(strsplit(filename,split="_"))
    label <- filefields[1]
  }
  sfeat <- as.data.frame(fread(filename))
  sfeat$feat<- c(rep("gPOW",9),rep("fVOC",9),rep("eDIF",9),rep("dACU",9),rep("cGRD",9),rep("bVOI",9),rep("aBUR",9))
  colnames(sfeat) = c("Step", "oldFeat", "Level", seq(1,maxX),"Feat")
  sfeat<-sfeat[,c((maxX+4),3,seq(4,(3+maxX)))]
#  sfeat$slice <- sfeat$slice - 1
  sfeat$Name <- label
  sfeat.m <- melt(sfeat, id=c("Feat", "Level", "Name"), variable_name="Slice")
#  sfeat.m <- melt(sfeat[sfeat$slice<maxX & sfeat$slice>0,],id=c("slice","feat","name"), variable_name="fval")
  names(sfeat.m)[5] = "fval"
  sfeat.m$featXlevel<- paste0(sfeat.m$Feat,sfeat.m$Level)
  sfeat.m$featXlevel <- factor(sfeat.m$featXlevel)
  return(sfeat.m)
}

plotInput <- function(sfeat.m,simple=TRUE){ # say simple=F to remove legend, labels, etc.
  sfeat.map <- ggplot(sfeat.m, aes(Slice,featXlevel)) + geom_tile(aes(fill=fval), colour="white")
  if(simple){
    sfeat.map + scale_fill_gradient(low="white", high="black") +
      geom_hline(yintercept=c(-0.5,9.5,18.5,27.5,36.5,45.5,54.5,63.5),colour="grey",lty=2)
  } else {
    sfeat.map + scale_fill_gradient(low="white", high="black") +
      theme(
        plot.background = element_blank()
        ,panel.grid.major = element_blank()
        ,panel.grid.minor = element_blank()
        #    ,panel.border = element_blank()
        ,panel.background = element_blank()
        ,legend.position="none"
        ,axis.title.x=element_blank()
        ,axis.title.y=element_blank()
        #    ,panel.border=element_rect(size=1)
      )  + geom_hline(yintercept=c(-0.5,9.5,18.5,27.5,36.5,45.5,54.5,63.5),colour="grey",lty=2) + 
      geom_hline(yintercept=c(-0.5,63.5),colour="black") + 
      geom_vline(xintercept=c(0.5,47.5),colour="black") + 
      scale_y_discrete(expand=c(0,0),
                       breaks=c(4.5,13.5,22.5,31.5,39.5,48.5,57.5),
                       labels=c("BUR","VOI","GRD","ACU","DIF","VOC","POW")) +
      scale_x_continuous(expand=c(0,0),breaks=c()) 
  }
}

plotSfeat <- function(sfeat.m,simple=TRUE){ # say simple=F to remove legend, labels, etc.
  sfeat.map <- ggplot(sfeat.m, aes(slice,fvalXfeat)) + geom_tile(aes(fill=value), colour="white")
  if(simple){
    sfeat.map + scale_fill_gradient(low="white", high="black") +
      geom_hline(yintercept=c(-0.5,9.5,18.5,27.5,36.5,45.5,54.5,63.5),colour="grey",lty=2)
  } else {
    sfeat.map + scale_fill_gradient(low="white", high="black") +
      theme(
        plot.background = element_blank()
        ,panel.grid.major = element_blank()
        ,panel.grid.minor = element_blank()
        #    ,panel.border = element_blank()
        ,panel.background = element_blank()
        ,legend.position="none"
        ,axis.title.x=element_blank()
        ,axis.title.y=element_blank()
        #    ,panel.border=element_rect(size=1)
      )  + geom_hline(yintercept=c(-0.5,9.5,18.5,27.5,36.5,45.5,54.5,63.5),colour="grey",lty=2) + 
      geom_hline(yintercept=c(-0.5,63.5),colour="black") + 
      geom_vline(xintercept=c(0.5,47.5),colour="black") + 
      scale_y_discrete(expand=c(0,0),
                       breaks=c(4.5,13.5,22.5,31.5,39.5,48.5,57.5),
                       labels=c("BUR","VOI","GRD","ACU","DIF","VOC","POW")) +
      scale_x_continuous(expand=c(0,0),breaks=c()) 
  }
}

facetPlotSfeats <- function(sfeat,simple=false,nc=3,simp=T){
  #  sfeatFacet <- ggplot(sfeat, aes(slice,fvalXfeat)) + geom_tile(aes(fill=value), colour="white") +
  sfeatFacet <- plotSfeat(sfeat,simple=simp) +
    facet_wrap(~name,ncol=nc) + scale_fill_gradient(low="white", high="black") 
  return(sfeatFacet)  
}

facetPlotInputs <- function(sfeat,simple=false,nc=3,simp=T){
  #  sfeatFacet <- ggplot(sfeat, aes(slice,fvalXfeat)) + geom_tile(aes(fill=value), colour="white") +
  sfeatFacet <-  plotInput(sfeat,simple=simp) +
    facet_wrap(~Name,ncol=nc) + scale_fill_gradient(low="white", high="black") 
  return(sfeatFacet)  
}

readManySfeats <- function(filelist){
  sfeats <- data.frame()
  foreach(ii=filelist)%do%{
    print(paste("### Reading", ii))
    sfeats<- rbind(sfeats, readSfeat(ii,ii))

  }
  return(sfeats)
}

readManyInputs <- function(filelist){
  sfeats <- data.frame()
  foreach(ii=filelist)%do%{
    print(paste("### Reading", ii))
    sfeats<- rbind(sfeats, readInput(ii,ii))
  }
  return(sfeats)
}

# Multiple plot function, from http://www.cookbook-r.com/Graphs/Multiple_graphs_on_one_page_(ggplot2)/
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  require(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}

pagePlotter = function (aPlotList,filename = "filename.pdf",wid=8.5,hei=11,plotsPerPage=9) {
  pdf(filename,width=wid,height=hei) # width = 14 inches
  i = 1
  plot = list() 
  for (n in seq(1,length(aPlotList))) {
    print(paste("# Plotting plot ",n))
    ### process data for plotting here ####
    plot[[i]] = aPlotList[[n]]
    if (i %% plotsPerPage == 0) { ## print 9 plots on a page
      print (do.call(grid.arrange,  plot))
      plot = list() # reset plot 
      i = 0 # reset index
    }
    i = i + 1
  }
  if (length(plot) != 0) {  ## capture remaining plots that have not been written out
    do.call(grid.arrange,  plot)
    #print (do.call(grid.arrange,  plot))
  }
  dev.off()
}
  
pagePlotter.ncols = function (aPlotList,filename = "filename.pdf",wid=8.5,hei=11,plotsPerPage=9,ncols=1,nrows=5) {
  pdf(filename,width=wid,height=hei) # width = 14 inches
  i = 1
  plot = list() 
  for (n in seq(1,length(aPlotList))) {
    print(paste("# Plotting plot ",n))
    ### process data for plotting here ####
    plot[[i]] = aPlotList[[n]]
    if (i %% plotsPerPage == 0) { ## print 9 plots on a page
      print (do.call(grid.arrange(ncol=ncols,nrow=nrows),  plot))
      plot = list() # reset plot 
      i = 0 # reset index
    }
    i = i + 1
  }
  if (length(plot) != 0) {  ## capture remaining plots that have not been written out
    print (do.call(grid.arrange(ncol=ncols,nrow=nrows),  plot))
  }
  dev.off()
}

  
  
  
  
  