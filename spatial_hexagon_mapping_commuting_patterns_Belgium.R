# Spatial hexagon mapping of commute patterns in Belgium
setwd( )
library(dplyr)
library(tidyr)
library(sp)
library(raster)
library(rgeos)
library(rgbif)
library(viridis)
library(gridExtra)
library(rasterVis)
library(gstat)
library(automap)
library(RColorBrewer)
library(classInt)
library(leaflet)
# create hexagon grid file
# shapefile Belgium
study_area <- getData("GADM", country = "BEL", level = 0) %>% 
  disaggregate %>% 
  geometry
class(study_area)
summary(study_area)
plot(study_area)
# cleaning up and remove polygons other than the main polygon of Belgium
study_area <- sapply(study_area@polygons, slot, "area") %>% 
  {which(. == max(.))} %>% 
  study_area[.]
plot(study_area)
plot(study_area, col = "grey50", bg = "light blue", axes = TRUE)
proj4string(study_area)
# reproject into UTM
study_area_utm <- spTransform(study_area,CRS("+proj=lcc +lat_1=51.16666723333333 +lat_2=49.8333339 +lat_0=90 +lon_0=4.367486666666666 +x_0=150000.013 +y_0=5400088.438 +ellps=intl +towgs84=106.869,-52.2978,103.724,-0.33657,0.456955,-1.84218,1 +units=m +no_defs"))
plot(study_area_utm)
proj4string(study_area_utm)
summary(study_area_utm)

# hexagonal grid with clipping
# make_grid() function
make_grid <- function(x, cell_diameter, cell_area, clip = FALSE) {
  if (missing(cell_diameter)) {
    if (missing(cell_area)) {
      stop("Must provide cell_diameter or cell_area")
    } else {
      cell_diameter <- sqrt(2 * cell_area / sqrt(3))
    }
  }
  ext <- as(extent(x) + cell_diameter, "SpatialPolygons")
  projection(ext) <- projection(x)
  # generate array of hexagon centers
  g <- spsample(ext, type = "hexagonal", cellsize = cell_diameter, 
                offset = c(0.5, 0.5))
  # convert center points to hexagons
  g <- HexPoints2SpatialPolygons(g, dx = cell_diameter)
  # clip to boundary of study area
  if (clip) {
    g <- gIntersection(g, x, byid = TRUE)
  } else {
    g <- g[x, ]
  }
  # clean up feature IDs
  row.names(g) <- as.character(1:length(g))
  return(g)
}
# 2 km x 2 km hexagonal grid with clipping
hex_grid22 <- make_grid(study_area_utm, cell_area = 4000000, clip = TRUE)
plot(study_area_utm, col = "grey50", bg = "light blue", axes = FALSE)
plot(hex_grid22, border = "white", add = TRUE)
box()
class(hex_grid22)
plot(hex_grid22)
hex_grid22
# convert grids-polygon into SpatialPolygonsDataFrame
df <- data.frame(id=getSpPPolygonsIDSlots(hex_grid22))
str(df)
row.names(df) <- getSpPPolygonsIDSlots(hex_grid22)
class(df)
str(df)
# make a SpatialPolygonsDataFrame 
spdf <- SpatialPolygonsDataFrame(hex_grid22,data=df)
class(spdf)
plot(spdf)
summary(spdf)
str(spdf@data)  
# we use data frame "geo_home_work.csv" and extract values for inflow, outflow and resident (municipalities)
commute <- read.csv("geo_home_work.csv")
str(commute)
commute <- subset(commute,select=c("ID","inflow","outflow","resident"))
str(commute)
# delete Baarle-Hertog from the data frame since it is not in the main polygon of Belgium
# commute has 587 municipalities (589 - Herstappe - Baarle-Hertog)
commute <- commute[commute$ID != 7, ]
str(commute)
# we use polygonshapefile "M_Belgium" to extract the centroids
library(rgdal)
mun <- readOGR(".","M_Belgium")
class(mun)
str(mun@data)
plot(mun)
mun.centroids <- data.frame(coordinates(mun),mun@data$ID_4)
names(mun.centroids) <- c("lon","lat","ID")
str(mun.centroids)
# add latlon data to commute
x <- merge(commute,mun.centroids,by="ID")
str(x)
datafile <- x
names(datafile)[5] <- "x"
names(datafile)[6] <- "y"
class(datafile)
str(datafile)
# make datafile a SpatialPointsDataFrame
coordinates(datafile) <- ~ x + y
class(datafile)
plot(datafile)
# convert latlon into UTM
proj4string(datafile)
lonlatproj <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
proj4string(datafile) <- lonlatproj
proj4string(datafile)
plot(datafile)
newproj <- proj4string(study_area_utm)
datafile <- spTransform(datafile,newproj)
proj4string(datafile)
plot(datafile)
str(datafile)
plot(study_area_utm,col="grey50",bg="light blue",axes=TRUE)
plot(datafile,col="darkblue",pch=20,cex=0.8,add=T)
# grid and datafile must have the same projection
r <- raster(nrow=500,ncol=500,
            xmn=bbox(study_area_utm)["x","min"],xmx=bbox(study_area_utm)["x","max"],
            ymn=bbox(study_area_utm)["y","min"],ymx=bbox(study_area_utm)["y","max"],
            crs=proj4string(datafile))
class(r)
library(gstat)
library(automap)
str(datafile)
# interpolation with ordinary kriging 
v <- autofitVariogram(formula=inflow ~ 1,input_data=datafile)
plot(v)
ok <- gstat(formula=inflow ~ 1,data=datafile,model=v$var_model)
z <- interpolate(r,ok)
z <- mask(z,study_area_utm)
plot(z)
cv <- gstat.cv(ok)
head(cv@data)
rmse <- function(x) sqrt(sum((-x$residual)^2)/nrow(x))
rmse(cv)
z
plot(z,col=topo.colors(12),axes=FALSE,main="Results interpolation inflow with ordinary kriging")
# plot with contour lines
par(bty="n")
cols <- c("#FFFFFF","#EE4000","#CC00CC")
col.ramp <- colorRampPalette(cols)
plot(z,axes=FALSE,col=(col.ramp(100)),legend=T)
levelplot(z,main="Levelplot interpolation inflow with ordinary kriging")
plot3D(z,lit=TRUE)
sq_srtm <- extract(z,hex_grid22,fun=mean,na.rm=TRUE,sp=TRUE)
class(sq_srtm)
str(sq_srtm@data)
summary(sq_srtm)
library(sp)
sq_srtm@data[is.na(sq_srtm@data)] <- NA
my.palette <- brewer.pal(n=7, name="OrRd")
spplot(sq_srtm,"var1.pred",col.regions=my.palette,cuts=6,col="gray", main="Hexagon map commute patterns : inflow")
proj4string(sq_srtm)
sq_srtm <- spTransform(sq_srtm,CRS("+init=epsg:4326"))
library(leaflet)
qpal <- colorQuantile("YlGnBu",sq_srtm$var1.pred,n=4)
map <- leaflet(sq_srtm) %>% addTiles()
map %>%
  addPolygons(stroke=FALSE,smoothFactor=0.2,fillOpacity=0.6,color=~qpal(var1.pred)) %>%
  addLegend("topright",pal=qpal,values=~var1.pred,title="inflow quantile dist.",opacity=1)
