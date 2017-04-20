## use ggmap
library(ggplot2)
library(ggmap)
library(mapproj)

setwd("your directory")

source("Map_functions.R")
source("Create_USmapwithAK_HI.R")

#############################
###### Output File Names ####
#############################
saveDate = "2015NOV17"
win4wk = "2015/09/20-10/17 vs. 2015/10/18 - 11/14"
file_wau_change = paste0("outputs/au4wk_change_", saveDate, ".png")
file_wau_change_glow = paste0("outputs/au4wk_change_glow_", saveDate, ".png")
file_wau_change_nurture = paste0("outputs/au4wk_change_nurture_", saveDate, ".png")


######################
#### Load in Data ####
######################
# all
wau_statect <- read.csv("file name to read in")
wau_statect0 <- read.csv("file name to read in")
# glow
wau_statect_glow <- read.csv("file name to read in")
wau_statect_glow0 <- read.csv("file name to read in")
# nurture
wau_statect_nurture <- read.csv("file name to read in")
wau_statect_nurture0 <- read.csv("file name to read in")

#### Split by glow only, nurture only, and both glow and nurture ####
splittedAU = split_user(wau_statect_glow, wau_statect_nurture, wau_statect)
splittedCom = split_user(wau_statecom_glow, wau_statecom_nurture, wau_statecom)
splittedAU0 = split_user(wau_statect_glow0, wau_statect_nurture0, wau_statect0)
splittedCom0 = split_user(wau_statecom_glow0, wau_statecom_nurture0, wau_statecom0)


#### prepare for the WAU changes ####
# all
wau_change = change_prep(wau_statect, wau_statect0)
wau_change = replaceSmall(wau_statect0, wau_change[,c("state", "delta")])
# glow only
wau_change_glow = change_prep(splittedAU[,c("state", "glow_only")], splittedAU0[,c("state", "glow_only")])
wau_change_glow = replaceSmall(splittedAU0[,c("state", "glow_only")], wau_change_glow[,c("state", "delta")])
# nurture only
wau_change_nurture = change_prep(splittedAU[,c("state", "nurture_only")], splittedAU0[,c("state", "nurture_only")])
wau_change_nurture = replaceSmall(splittedAU0[,c("state", "nurture_only")], wau_change_nurture[,c("state", "delta")])



#################
#### Mapping ####
#################

#### WAU changes  ####
# all
legendName = "Percentage Change (%)\n"
mytitle =  paste("Percentage Change in Active Users by State\n", win4wk)

gg_changePt(wau_change, legendName, mylimit = c(-10,10),
            mybreak = c(-10, -7.5, -5 , -2.5, 0, 2.5, 5, 7.5, 10),
            mytitle, file_wau_change)

# glow
mytitle =  paste("Percentage Change in Glow Active Users by State\n", win4wk)

gg_changePt(wau_change_glow, legendName, mylimit = c(-15,15),
            mybreak = c(-15, -10, -5 , 0, 5, 10, 15),
            mytitle, file_wau_change_glow)

# nurture
mytitle =  paste("Percentage Change in Nurture Active Users by State\n", win4wk)

gg_changePt(wau_change_nurture, legendName, mylimit = c(-25,25),
            mybreak = c(-25, -20, -15, -10 , -5, 0, 5, 10, 15, 20, 25),
            mytitle, file_wau_change_nurture)
