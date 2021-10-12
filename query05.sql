/*
In this question, I want to investigate the accessibility index by neighbourhoods size,
and the proportion of accessible bus stops and inaccessible bus stops.

Thus the function would be: (the proportion between accessible: inaccessible) devided
    by the shape area. However, since some neighbors do not have inaccessible bus stops,
	I will add 1 to the num_bus_stops_inaccessible in the syntax.

The final metric function is shown below:

  (num_bus_stops_accessible/(num_bus_stops_inaccessible+1))/shape_area as
   accessibility_metric
*/
	   