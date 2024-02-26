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


1. Study area and data description.
The data consists of 589 municipalities in Belgium which are treated as point observations of
outflow, inflow and resident commute patterns of the active population (based on census data,
2011).  The map below gives a global view of the distribution of these commute patterns.

![commuting_patterns_Belgium](https://github.com/emmolb/spatial_hexagon_mapping_inflow_Belgium/assets/34507394/5eadad6e-16a4-45d1-9d8b-b8db59916b70)






![hexgrid_2kmx2km](https://github.com/emmolb/spatial_hexagon_mapping_inflow_Belgium/assets/34507394/2b1b29a0-ab36-433b-b166-1d635ede429d)











