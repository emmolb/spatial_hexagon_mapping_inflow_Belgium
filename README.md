Commute patterns refer to the regular movements of people between their homes and workplaces.  
Based on Belgian census data, we visualized various commute patterns as outflow, inflow or resident
(xxxxx). In this post we use spatial hexagon mapping to represent the proportions of the active 
population that is comprised of people moving in from nearby or more distant areas to access 
jobs or job opportunities (inflow).  

We partition our study area (Belgium) into identifiable grid cells.  Spatial gridding is the 
process of dividing a continuous geographical area into a regular grid of discrete cells.  
Grid cells can tessellate, i.e. cover an area by the repeated use of a single shape without 
gaps or overlapping.  We use hexagons for a regular tessellation of a geographical area and 
apply a spatial overlay operation to map data points into the hexagonal structure.  
One way of modifying point data is to create an interpolated surface that calculates predicted 
values over areas where points do not exist and convert these values to a raster surface.  
This can be used to create a map where each hexagon represents a geographical area 
that is shaded or coloured based on the commute data (i.e. darker shades might indicate 
higer inflow counts). 

The description of the workflow to produce a spatial hexagon grid analysis can be found 
in the following R-code.

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

















