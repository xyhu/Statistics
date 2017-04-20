library(ggplot2)
library(ggmap)
library(maps)
library(mapdata)
library(dplyr)


# a white backgroup us map with border line to be black
usa = map_data("usa") # returns the borderline lat and long data
gg_us_map = ggplot() + geom_polygon(data = usa, aes(x=long, y = lat, group = group), fill = NA, color = "grey") + 
  coord_fixed(1.3) + theme_bw() + 
  theme(panel.border = element_blank(), panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), axis.text = element_blank(), 
        axis.ticks = element_blank(), axis.title=element_blank())


# read in data and plot
data = read.csv('/Users/huxiangyu/Documents/repo_output/local_outputs/Glow/glow_all_time_ttc.csv', header=TRUE)

min_lat = min(usa$lat)
max_lat = max(usa$lat)
min_long = min(usa$long)
max_long = max(usa$long)
in_range_lat = between(data$latitude, min_lat, max_lat) 
data2 = data[in_range_lat, ]
in_range_long = between(data2$longitude, min_long, max_long)
data3 = data2[in_range_long, ]

data3$lat_log = log(data3$latitude)
data3$long_log = log(-data3$longitude)

lat_agg = aggregate(latitude ~ lat_log + long_log, data3, mean)
long_agg = aggregate(longitude ~ lat_log + long_log, data3, mean)
ct_agg = aggregate(user_id ~ lat_log + long_log, data3, function(x) length(x))

tmp1 = merge(lat_agg, long_agg, by=c('lat_log', 'long_log'))
final_data = merge(tmp1, ct_agg, by=c('lat_log', 'long_log'))

# log_base = 20, 30, 40
final_map = gg_us_map + geom_point(aes(x=longitude, y=latitude), data=final_data, 
                                   size = log(final_data$user_id, 40), alpha=0.1, color='purple')  
  