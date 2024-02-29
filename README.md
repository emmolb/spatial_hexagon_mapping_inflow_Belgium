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

Study area and data description.
The data consists of 589 municipalities in Belgium which are treated as point observations of
outflow, inflow and resident commute patterns of the active population (based on census data,
2011).  The map below gives a global view of the distribution of these commute patterns.

![commuting_patterns_Belgium](https://github.com/emmolb/spatial_hexagon_mapping_inflow_Belgium/assets/34507394/5eadad6e-16a4-45d1-9d8b-b8db59916b70)

Hexagonal grid.
To generate a hexagonal grid of polygons convering the Belgian area, we first created a
hexagonal grid of points, each with a cell size of 2 km by 2 km.
This point grid is then converted to a grid of polygons (we used a function developed
by Matt Strimas-Mackey, see strimas.com/spatial/hexagonal_grids, january 2016).

![hexgrid_2kmx2km](https://github.com/emmolb/spatial_hexagon_mapping_inflow_Belgium/assets/34507394/fc648999-554d-4e83-9a30-8663704d5361)


Kriging interpolation.
We have data that is aggregated by geographic boundaries (muncipalities).  But we haven't data
across a continuous spectrum.  Therefore we need to interpolate the point data.  Interpolation
is performed by using the kriging technique with an experimental variagram.  Kriging is a
technique for spatial interpolation to estimate values (in this case of inflow) at unmeasured
locations within a study area.  The variogram is a component of kriging that describes 
the spatial variability of a variable over the study area.  It quantifies how the variance of
the variable changes as the distance between sample points increases.  Once the variogram
model s established, kriging can be used to predict values at unsampled locations.

![variogram_model_inflow](https://github.com/emmolb/spatial_hexagon_mapping_inflow_Belgium/assets/34507394/8ca3f6fd-d783-46a7-aafb-f29611bb500c)

Kriging was performed for a fine grid and the kriged values of inflow ware generated in
a raster format.  

![contour_plot](https://github.com/emmolb/spatial_hexagon_mapping_inflow_Belgium/assets/34507394/0923a5d6-b158-455c-863b-7b8e1ea2ce59)
![levelplot_interpolation_inflow_ok](https://github.com/emmolb/spatial_hexagon_mapping_inflow_Belgium/assets/34507394/c4a8769f-d4a6-4c19-aa2d-d4f32f68e175)










