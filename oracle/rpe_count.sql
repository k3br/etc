declare
record_count number;
v_sql varchar2(255);
postopek_id number := 10000001638;
begin
for c1 in (select * from user_tables where table_name like 'RPE%') loop
    v_sql := 'SELECT count(1) FROM nep_pos.'||c1.table_name || 
             ' WHERE postopek_id = '|| postopek_id;
    execute immediate v_sql into record_count;
    dbms_output.put_line(RPAD(c1.table_name,30)||record_count); 
end loop;
end;
/