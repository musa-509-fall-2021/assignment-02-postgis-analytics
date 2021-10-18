/* What are the top five neighborhoods according to your accessibility metric?

neighborhood_name   num_accessible  num_inaccessible    accessibility_metric
CEDARBROOK	        55	            0	                99.1451998592729	
YORKTOWN	        30	            0	                99.04530382963299	
EAST_OAK_LANE	    97	            0	                99.04301744316474	
BRIDESBURG	        32	            0	                98.90981566739934	
NORTHWOOD	        56	            0	                98.72002652021513
*/


select *
from septa_stop_access
order by accessibility_metric desc limit 5;
