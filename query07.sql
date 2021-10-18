/* What are the bottom five neighborhoods according to your accessibility metric?

neighborhood_name   num_accessible  num_inaccessible    accessibility_metric
SOUTHWEST_SCHUYLKILL	23	        29	                41.05698088342312	
TORRESDALE	            58	        0	                41.98577724770579	
PASCHALL	            32	        38	                42.27479155967324	
CEDAR_PARK	            20	        20	                43.42183339947786	
KINGSESSING	            37	        32	                50.32238570357015

*/


select *
from septa_stop_access
order by accessibility_metric limit 5;
