---LIST ALL EIDs
select distinct  TABLE_NAME, substr(search_condition_vc, 13, 16)
from all_constraints
WHERE constraint_type='C'
and constraint_name like '%EID%'
and table_name not like '%\_H' escape '\'
order by 2;