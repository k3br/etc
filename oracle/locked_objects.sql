---Locked tables
SELECT B.Owner, B.Object_Name, A.Oracle_Username, A.OS_User_Name, A.SESSION_ID sid
FROM V$Locked_Object A, All_Objects B
WHERE A.Object_ID = B.Object_ID;

---Locked packages
select
   x.sid
from
   v$session x, v$sqltext y
where
   x.sql_address = y.address
--and y.sql_text like '%PKG_NAME%'
;