/* Formatted on 07.02.2020 10:36:07 (QP5 v5.318) */
/* https://asktom.oracle.com/pls/asktom/f?p=100:11:0::::P11_QUESTION_ID:4530093713805#26568859366976*/

WITH unindexed_foreign_keys AS
    (SELECT table_name,
            constraint_name,
               cname1
            || NVL2 (cname2, ',' || cname2, NULL)
            || NVL2 (cname3, ',' || cname3, NULL)
            || NVL2 (cname4, ',' || cname4, NULL)
            || NVL2 (cname5, ',' || cname5, NULL)
            || NVL2 (cname6, ',' || cname6, NULL)
            || NVL2 (cname7, ',' || cname7, NULL)
            || NVL2 (cname8, ',' || cname8, NULL)
                columns
       FROM (  SELECT b.table_name,
                      b.constraint_name,
                      MAX (DECODE (position, 1, column_name, NULL)) cname1,
                      MAX (DECODE (position, 2, column_name, NULL)) cname2,
                      MAX (DECODE (position, 3, column_name, NULL)) cname3,
                      MAX (DECODE (position, 4, column_name, NULL)) cname4,
                      MAX (DECODE (position, 5, column_name, NULL)) cname5,
                      MAX (DECODE (position, 6, column_name, NULL)) cname6,
                      MAX (DECODE (position, 7, column_name, NULL)) cname7,
                      MAX (DECODE (position, 8, column_name, NULL)) cname8,
                      COUNT (*)                                   col_cnt
                 FROM (SELECT SUBSTR (table_name, 1, 30)
                                  table_name,
                              SUBSTR (constraint_name, 1, 30)
                                  constraint_name,
                              SUBSTR (column_name, 1, 30)
                                  column_name,
                              position
                         FROM user_cons_columns) a,
                      user_constraints b
                WHERE     a.constraint_name = b.constraint_name
                      AND b.constraint_type = 'R'
             GROUP BY b.table_name, b.constraint_name) cons
      WHERE col_cnt > ALL (  SELECT COUNT (*)
                               FROM user_ind_columns i
                              WHERE     i.table_name = cons.table_name
                                    AND i.column_name IN (cname1,
                                                          cname2,
                                                          cname3,
                                                          cname4,
                                                          cname5,
                                                          cname6,
                                                          cname7,
                                                          cname8)
                                    AND i.column_position <= cons.col_cnt
                           GROUP BY i.index_name)),
idx_suffixes AS
    (  SELECT table_name,
              MAX (TO_NUMBER (NVL (idx_suffix, 0))) last_idx_id
         FROM (SELECT table_name,
                      SUBSTR (index_name,
                              NULLIF (INSTR (index_name, 'IDX'), 0) + 3)
                          idx_suffix
                 FROM all_indexes)
        WHERE VALIDATE_CONVERSION (idx_suffix AS NUMBER) = 1
     GROUP BY table_name)
SELECT uifk.*,
          'CREATE INDEX ' || uifk.table_name || '_IDX' || 
           --find index with IDX[NN] sufix and start incrementing from last index
           LPAD (row_number() over (partition by uifk.table_name order by uifk.columns) + idxs.last_idx_id, 2, '0')
       || ' ON ' || uifk.table_name || '(' || uifk.columns || ');'
           CREATE_INDEX_STATEMENT
  FROM unindexed_foreign_keys  uifk
       JOIN idx_suffixes idxs ON (uifk.table_name = idxs.table_name);
       