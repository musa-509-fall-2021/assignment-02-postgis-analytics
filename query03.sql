CREATE INDEX phl_pwd_parcels__the__geom__32129__idx
	ON phl_pwd_parcels
	using GiST (ST_Transform(geom, 32129));
  
 
