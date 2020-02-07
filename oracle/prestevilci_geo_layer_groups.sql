declare
ln_test number;
begin 
   for cc in (
    select 
     layer_group_id, (row_number() over (order by order_no))*2 new_order_no
    from geo_layer_groups
     where layer_group_id < 1000) loop
     
     update geo_layer_groups 
        set order_no = cc.new_order_no
      where layer_group_id = cc.layer_group_id;
             
   end loop;
   /*
       select order_no, count(1) from 
         geo_layer_groups where layer_group_id < 1000 
          group by order_no 
          having count(1) > 1
   */
                    
end;
/
