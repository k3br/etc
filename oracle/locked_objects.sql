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



---Final blocking session
/* Formatted on 12/09/2019 14:57:58 (QP5 v5.318) */
WITH
    blocing_sessions
    AS
        (SELECT (SELECT username
                   FROM v$session
                  WHERE sid = a.sid)
                    blocker,
                    a.sid
                    blocker_sid,
                (SELECT username
                   FROM v$session
                  WHERE sid = b.sid)
                    blockee,
                b.sid
                    blockee_sid
           FROM v$lock a, v$lock b
          WHERE     a.block = 1
                AND b.request > 0
                AND a.id1 = b.id1
                AND a.id2 = b.id2)
SELECT blocker_sid, blocker
  FROM blocing_sessions
 WHERE blocker_sid NOT IN (SELECT blockee_sid FROM blocing_sessions);