select *
from public_gold.gold_station_latest
where latitude not between 51.0 and 52.0
   or longitude not between -1.0 and 1.0