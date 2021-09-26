-- data: stops.txt - wheelchair_boarding - 0(ukn/inherit),1(yes),2(no)

create index phl_neighborhood_geo_index 
on neighborhood 
using gist (the_geom);
