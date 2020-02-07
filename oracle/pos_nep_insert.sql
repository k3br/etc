/* Formatted on 02/09/2019 12:07:59 (QP5 v5.318) */
WITH
    pos_all_cols
    AS
        (  SELECT lower(table_name) table_name,
                  LISTAGG ('                ' || lower(column_name), ', 
')
                      WITHIN GROUP (ORDER BY column_id)
                      all_cols
             FROM all_tab_columns
            WHERE table_name LIKE 'RPE_%'
              and owner = 'NEP_POS'
              and table_name not like '%\_H' escape '\'
              and column_name not in ('PLOMBA', 
                                      'POSTOPEK_ID',
                                      'DATUM_SYS',
                                      'UPORABNIK',
                                      'SPREMEMBA')
         GROUP BY table_name
         ORDER BY table_name),
    nep_all_cols
    AS
        (  SELECT lower(table_name) table_name,
                  'obj.' || min(lower(column_name)) keep (dense_rank first order by column_id) table_id,
                  LISTAGG ('                obj.' || lower(column_name), ', 
')
                      WITHIN GROUP (ORDER BY column_id)
                      all_cols
             FROM all_tab_columns
            WHERE table_name LIKE 'RPE_%'
              and owner = 'NEP'
              and table_name not like '%\_H' escape '\'
              and column_name not in ('PLOMBA', 
                                      'POSTOPEK_ID',
                                      'DATUM_SYS',
                                      'UPORABNIK',
                                      'SPREMEMBA')
         GROUP BY table_name
         ORDER BY table_name)
select
'INSERT INTO nep_pos.' || lower(pac.table_name) ||'(
' ||
    pac.all_cols || ',
                sprememba,
                postopek_id,
                datum_sys,
                uporabnik
)
SELECT          nep_pos.' || lower(pac.table_name) || '_seq.nextval,
                '  || nac.table_id || ',
'  || nac.all_cols || ',
                ''N'',
                pi_postopek_id,
                sysdate,
                pi_uporabnik
 FROM nep.' || lower(nac.TABLE_NAME) || ' obj
WHERE NOT EXISTS ( SELECT p' || nac.table_id || ' 
                     FROM nep_pos.' || nac.table_name || ' pobj
                    WHERE pobj.postopek_id = pi_postopek_id
                      AND p' || nac.table_id || ' = ' || nac.table_id || ')'
    from pos_all_cols pac 
    join nep_all_cols nac on (nac.table_name = pac.table_name);