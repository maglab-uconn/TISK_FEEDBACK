library(grDevices)


my.pairscor <- function (data, classes = "", hist = TRUE, smooth = TRUE, 
                         cex.points = .5, col.hist = "darkgrey", 
                         col.points = "blue", rsize=2, psize=2, ramp=1.5) 
{

  R2exp <- expression(R^2)
  panel.hist <- function(x, ...) {
    usr <- par("usr")
    on.exit(par(usr))
    par(usr = c(usr[1:2], 0, 1.5))
    h <- hist(x, plot = FALSE)
    breaks <- h$breaks
    nB <- length(breaks)
    y <- h$counts
    y <- y/max(y)
    rect(breaks[-nB], 0, breaks[-1], y, ...)
  }
  pairscor.lower <- function(x, y, ...) {
    usr <- par("usr")
    on.exit(par(usr))
    par(usr = c(0, 1, 0, 1))
    m = cor.test(x, y)
    r = round(m$estimate, 2)
    rr = round((m$estimate^2), 2)
    p = round(m$p.value, 4)
    pval = m$p.value
    
    rrp = vector('expression',2)
    rrp[1] = substitute(expression(italic(R)^2 == MYVALUE), 
                        list(MYVALUE = format(rr,dig=4)))[2]
    rp = vector('expression',2)
    rp[1] = substitute(expression(italic(r) == MYVALUE), 
                       list(MYVALUE = format(r,dig=4)))[2]
    
    #format(round(x, 2), nsmall = 2)
    pp = vector('expression',2)
    if(pval >= 0.0001){
      pp[1] = substitute(expression(italic(p) == MYVALUE), 
                         list(MYVALUE = format(round(pval,4), nsmall=2)))[2]
    } else { 
      pp[1] = substitute(expression(italic(p) <  MYVALUE), 
                         list(MYVALUE = "0.0001") )[2]
    }
    rtxt = rp
    r2txt = rrp
    ptxt = pp
    options(warn = -1)
    m2 = cor.test(x, y, method = "spearman")
    r2 = round(m2$estimate, 2)
    rr2 = round((m2$estimate^2), 2)
    p2 = round(m2$p.value, 4)
    rtxt2 = paste0("r=", r2,  ", ", R2exp, "=", rr2)
    ptxt2 = paste("p =", p2)
    options(warn = 0)
    tcol="red"
    # here is where the r report size is scaled according to magnitude
    rmag = .05 + abs(r)
    if(abs(r) > 0.5){ rmag = rmag * ramp}
    text(0.5, 0.75, rtxt, col = "black", cex=rsize + rmag)
    text(0.5, 0.5, r2txt, col = "black", cex=psize)
    text(0.5, 0.25, ptxt, col = "black", cex=psize)
    tcol="black"
    colfunc <- colorRampPalette(c("grey","limegreen","blue", "red", "magenta","purple"))
    tcols = colfunc(100)
    tcol = tcols[as.integer(abs(r)*100)+1]
  }
  panel.smooth2 = function(x, y, col = par("col"), bg = NA, 
                           pch = par("pch"), cex = 1, span = 1/10, iter = 3, ...) {
    #points(x, y, pch = pch, col = col, cex = cex)
    points(x, y, pch = pch, col = col, cex = cex)
    ok <- is.finite(x) & is.finite(y)
    if (any(ok)) {
      lines(stats::lowess(x[ok], y[ok], f = span, iter = iter), 
            col = "purple", ...)
      abline(lm(y[ok] ~ x[ok]), col="red",  ...)
    }
  }
  if (hist == TRUE) {
    if (smooth == TRUE) {
      pairs(data, diag.panel = panel.hist, lower.panel = pairscor.lower, 
            upper.panel = panel.smooth2, col =col.points, 
            cex = cex.points)
    }
  }
  else {
    if (smooth == TRUE) {
      pairs(data, lower.panel = pairscor.lower, upper.panel = panel.smooth2, 
            col = 		, cex = cex.points)
    }
    else {
      pairs(data, lower.panel = pairscor.lower)
    }
  }
}