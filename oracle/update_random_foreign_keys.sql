declare
tmp_uid number;
begin
for c1 in (select rowid, dst.* from deli_stavb dst) loop
    SELECT upravnik_id
      INTO tmp_uid
      FROM (  SELECT upravnik_id
                FROM upravniki
               ORDER BY DBMS_RANDOM.VALUE)
     WHERE ROWNUM = 1;
    ------ 
    update deli_stavb dst
       set upravnik_id = tmp_uid
     WHERE rowid = c1.rowid;
end loop;
end;
/