library(maptools)
library(mapproj)
library(rgeos)
library(rgdal)
library(RColorBrewer)
library(ggplot2)

setwd("/Users/huxiangyu/Documents/data_science/multiple_apps/us_map_template_in_r/")
# Adopted from:
# https://github.com/hrbrmstr/rd3albers

# Download the .zip file for any boarder you want from below
# https://www.census.gov/geo/maps-data/data/tiger-cart-boundary.html
# 2014 State boundry 5m file downlaoded
us <- readOGR(dsn="cb_2014_us_state_5m", layer="cb_2014_us_state_5m")

# convert it to Albers equal area
us_aea <- spTransform(us, CRS("+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +a=6370997 +b=6370997 +units=m +no_defs"))
us_aea@data$id <- rownames(us_aea@data)

# extract, then rotate, shrink & move alaska (and reset projection)
# need to use state IDs via # https://www.census.gov/geo/reference/ansi_statetables.html
# 02 is alaska
# 15 is hawaii
alaska <- us_aea[us_aea$STATEFP=="02",]
alaska <- elide(alaska, rotate=-50)
alaska <- elide(alaska, scale=max(apply(bbox(alaska), 1, diff)) / 2.3)
alaska <- elide(alaska, shift=c(-2100000, -2500000))
proj4string(alaska) <- proj4string(us_aea)

# extract, then rotate & shift hawaii
hawaii <- us_aea[us_aea$STATEFP=="15",]
hawaii <- elide(hawaii, rotate=-35)
hawaii <- elide(hawaii, shift=c(5400000, -1400000))
proj4string(hawaii) <- proj4string(us_aea)


# remove alaska and hawaii and all the US territories --> US mainland states
us_aea <- us_aea[!us_aea$STATEFP %in% c("02", "15", "60", "66", "69", "72", "78"),]
# add back the alaska and hawaii
us_aea <- rbind(us_aea, alaska, hawaii)

# us_aea created is SpatialPolygonsDataFrame, find the colmn name that sores the names of state
# get ready for ggplotting it... this takes a cpl seconds
# STUSPS: stores the abbr. of states, will be the id in the new data map
map <- fortify(us_aea, region="STUSPS")

# plot it
gg <- ggplot()
# size: controls the thickness of the lines that draw the border
# fill: the filling color, the current one is white
# color: the color of the border line, the current one is black
gg <- gg + geom_map(data=map, map=map,
                    aes(x=long, y=lat, map_id=id, group=group),
                    fill="#ffffff", color="#0e0e0e", size=0.15)


##### the data to be mapped on
# get some data to show...perhaps drought data via:
# http://droughtmonitor.unl.edu/MapsAndData/GISData.aspx
#droughts <- read.csv("data/dm_export_state_20141111.csv")
#droughts$total <- with(droughts, (D0+D1+D2+D3+D4)/5)

#gg <- gg + geom_map(data=droughts, map=map, aes(map_id=State, fill=total),
#                    color="#0e0e0e", size=0.15)
#gg <- gg + scale_fill_gradientn(colours=c("#ffffff", brewer.pal(n=9, name="YlOrRd")),
#                                na.value="#ffffff", name="% of County")
