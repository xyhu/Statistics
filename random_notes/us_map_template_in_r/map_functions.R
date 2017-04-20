###################
#### Functions ####
###################


#### prepare for the community WAU ####
# input: the community by state data, and active users by state data
# output: the combined data of community and total active users by state and the percentage
com_prep = function(wau_statecom, wau_statect){
  colnames(wau_statecom) = c("state", "wau_com")
  colnames(wau_statect) = c("state", "metrics")
  
  wau_statecom2 <- merge(wau_statecom, wau_statect, by = "state")
  wau_statecom2$wau_Noncom <- with(wau_statecom2, metrics - wau_com)
  # community vs non community ratio
  wau_statecom2$wau_CNratio <- with(wau_statecom2, wau_com/wau_Noncom)
  # community percentage
  wau_statecom2$comPt <- with(wau_statecom2, round(wau_com*100/metrics, 1))
  wau_statecom3 = wau_statecom2[, c("state", "comPt")]
  colnames(wau_statecom3)[2] = "metrics"
  
  return(wau_statecom3)
}

### prepare for the platform comparison ####
# input: platform data with state labels and platform info
# output: platform count by state
plat_prep = function(wau_plat){
  wau_platCt = as.data.frame.matrix(table(wau_plat$state, wau_plat$platform))
  wau_platCt$state = row.names(wau_platCt)
  wau_platCt$ratio = wau_platCt$ios/wau_platCt$android
  
  return(wau_platCt)
}


#### prepare for the WAU changes ####
# input: active users count by state for the current time window and the previous one
# output: the percentage change by state
change_prep = function(wau_statect, wau_0statect){
  colnames(wau_statect) = c("state", "metrics")
  colnames(wau_0statect) = c("state", "metrics0")
  wau_change = merge(wau_statect, wau_0statect, by = "state")
  wau_change$change = with(wau_change, metrics - metrics0)
  wau_change$delta = with(wau_change, round(change*100/metrics0,1))
  
  return(wau_change)
}

#### prepare long and lat for labeling the state ####
# input:
# map: data frame containing the information to draw the map, from Create_USmapwithAK_HI.R
# wau_change: the percentage change by state matrix, from change_prep() has column state_wau0
# threshold: the threshold of count for labeling the state, default = 950, states with less than 950 active users are labeled
# output:st_annot: annoted states
annot = function(map, wau_change, threshold = 950){
  if (ncol(wau_change) == 2){
    colnames(wau_change) = c("state", "state_wau0")
  }
  st_annot = aggregate(map[,1:2],by=list(map$id), mean)
  colnames(st_annot)[1] = "state"
  # states WAU < 1000 (950, since above 950 can round to 1000)
  st_annot$annotName = st_annot$state
  st_more_1k =as.character(wau_change[which(wau_change$state_wau0 > threshold),"state"])
  st_annot[which(st_annot$state %in% st_more_1k), "annotName"] = NA
  
  return(st_annot)
}

#### Split by glow only, nurture only, and both glow and nurture ####
# input: glow, nurture, all data
# output: data frame with glow, nurture, all, both, glow only, nurture only
split_user = function(glow, nurture, all){
  result = merge(glow, nurture, by = "state")
  colnames(result)[2:3] = c("metric.glow", "metric.nurture")
  result = merge(result, all, by = "state")
  colnames(result)[4] = "metric"
  result$total = with(result, metric.glow + metric.nurture)
  result$both = with(result, total - metric)
  result$glow_only = with(result, metric.glow - both)
  result$nurture_only = with(result, metric.nurture - both)
  
  return(result)
}

#### sample size (active users state count) < 500
# input: dat: data with two columns: state, sample size
# input: target: the targeted data to be updated, two columns: state, metrics
# output: target: the replaced targeted data

replaceSmall = function(dat, target){
  colnames(dat) = c("state", "size")
  colnames(target) = c("state", "metrics")
  
  small_state = as.character(dat[which(dat$size < 500),"state"])
  target[which(target$state %in% small_state), "metrics"] = median(target$metrics)
  
  return(target)
}

#' ggplot2 Theme for Mapping. 
#' 
#' A ggplot2 theme with no background, gridlines, border, labels, or ticks.
#' 
#' @export
#' @seealso \code{\link[ggplot2]{theme}}
#' @importFrom ggplot2 theme_bw theme element_blank
#' @examples
#' \dontrun{
#' require("maps") 
#' states <- data.frame(map("state", plot=FALSE)[c("x","y")]) 
#' (usamap <- qplot(x, y, data=states, geom="path")) 
#' usamap + theme_map()
#' }
theme_map <- function() {
  theme_bw() +     
    theme(axis.title=element_blank(), 
          axis.text = element_blank(),
          axis.ticks = element_blank(),
          panel.grid = element_blank(),
          panel.border = element_blank()   
    )  
}

# ggplot for changes in percentage for each state
# It uses a palette that contrast the positive (purple) and negative (green) changes
# Inputs:
# dat: data to be plotted, must have a column called state, must have a column called delta (for changes in percentage)
# legendName: a string that will be used for name on the lengend
# mylimit: the limit of the lengend color bar, default as c(-10,10)
# mybreak: the breaks of the legend color bar, default as c(-10, -7.5, -5 , -2.5, 0, 2.5, 5, 7.5, 10)
# mytitle: the title of the plot
# fileName: the file name of the saved plot
# annot: TRUE/FALSE, whether to label some of the states, default as FALSE
# dat_annot: the data used for annotation of the states, must include a column for long, lat, and annotName
# 

gg_changePt = function(dat, legendName, mylimit = c(-10,10), 
                       mybreak = c(-10, -7.5, -5 , -2.5, 0, 2.5, 5, 7.5, 10),
                       mytitle, fileName, annot = FALSE, dat_annot){

  gg_change <- gg + geom_map(data=dat, map=map, aes(map_id=state, fill=metrics), size=0.15) +
                    scale_fill_gradientn(colours=rev(brewer.pal(n=6, name="PRGn")) 
                                         , na.value="#ffffff", name=legendName
                                         , limits = mylimit, breaks=mybreak) +
                    labs(title= mytitle) + 
                    theme_map() + 
                    theme(legend.position="right") + 
                    theme(plot.title=element_text(size=13)) 
                    
  if (annot){
    gg_change <- gg_change + geom_text(data = dat_annot, aes(long, lat, label= annotName), size=1.5, colour = "red")
  }

  ggsave(gg_change, file = fileName)

}


# ggplot for number, or percentage. Overall, the data plotted is positive numeric
# dat: data to be plotted, must have a column called state, must have a column called metrics (can be count, or percentage)
# legendName: a string that will be used for name on the lengend
# mytitle: the title of the plot
# fileName: the file name of the saved plot
# annot: TRUE/FALSE, whether to label some of the states, default as FALSE
# dat_annot: the data used for annotation of the states, must include a column for long, lat, and annotName
# 

gg_metrics = function(dat, legendName, mytitle,
                      fileName, annot = FALSE, dat_annot){
                      #,mylimit = c(25,65), 
                      #mybreak = c(25, 35, 45, 55, 65)
  if (ncol(dat) == 2){
    colnames(dat) = c("state", "metrics")
  }
  gg_met <- gg + geom_map(data=dat, map=map, aes(map_id=state, fill=metrics), size=0.15) +
                  scale_fill_gradientn(colours=brewer.pal(n=6, name="Purples") 
                                      , na.value="#ffffff", name= legendName) +
                                      #, limits = mylimit, breaks=mybreak) +
                  labs(title= mytitle) + 
                  theme_map() + 
                  theme(legend.position="right") + 
                  theme(plot.title=element_text(size=13))
  if (annot){
      gg_met <- gg_met + geom_text(data = dat_annot, aes(long, lat, label= annotName), size=1.5, colour = "red")
  }

  ggsave(gg_met, file = fileName)
 

}


# ggplot for log(ratio), 0 is at the middle, meaning the two compared in the ratio are equal
# It uses a palette that contrast the positive (purple) and negative (green) changes
# Inputs:
# dat: data to be plotted, must have a column called state, must have a column called ratio 
# legendName: a string that will be used for name on the lengend
# mylimit: the limit of the lengend color bar, default as c(-2,2)
# mybreak: the breaks of the legend color bar, default as c(-2, -1.5, -1, -0.5, 0, 0.5, 1, 1.5, 2)
# mytitle: the title of the plot
# fileName: the file name of the saved plot
# annot: TRUE/FALSE, whether to label some of the states, default as FALSE
# dat_annot: the data used for annotation of the states, must include a column for long, lat, and annotName
# 
gg_ratio = function(dat, legendName, mylimit = c(-2,2), 
                       mybreak = c(-2, -1.5, -1, -0.5, 0, 0.5, 1, 1.5, 2),
                       mytitle, fileName, annot = FALSE, dat_annot){

  gg_rt <- gg + geom_map(data=dat, map=map, aes(map_id=state, fill=log(ratio)), size=0.15) +
                    scale_fill_gradientn(colours=rev(brewer.pal(n=6, name="PRGn")) 
                                         , na.value="#ffffff", name=legendName
                                         , limits = mylimit, breaks=mybreak) +
                    labs(title= mytitle) + 
                    theme_map() + 
                    theme(legend.position="right") + 
                    theme(plot.title=element_text(size=13)) 
                    
  if (annot){
    gg_rt <- gg_rt + geom_text(data = dat_annot, aes(long, lat, label= annotName), size=1.5, colour = "red")
  }

  ggsave(gg_rt, file = fileName)

}
