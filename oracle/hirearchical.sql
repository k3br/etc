with glg as (
select a.*, rownum*100000 ord from (
    select glg.layer_group_id, rpad(' ' , (level-1)*5, ' ') || glg.title title, level lvl, status
      from geo_layer_groups glg
      WHERE status = 1
     start with parent_id is null
    connect by prior glg.layer_group_id = glg.parent_id
    order siblings by order_no asc) a
)
select glg.title, gl.title, gl.layer_id, gl.legend_order_no
from glg 
left join geo_layers gl on (gl.layer_group_id = glg.layer_group_id
 and gl.status =1
 and gl.tile = 1)
--where gl.status = 1
order by ord, gl.legend_order_no
;