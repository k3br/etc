/* Formatted on 02/09/2019 12:07:59 (QP5 v5.318) */
WITH
    pos_all_cols
    AS
        (  SELECT lower(table_name) table_name,
                  LISTAGG ('                    ' || lower(column_name), ', 
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
                  LISTAGG ('                    obj.' || lower(column_name), ', 
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
         ORDER BY table_name),
    rpe_table_const 
    AS(
                      SELECT 'RPE_CETRTNE_SKUPNOSTI' table_name, 'pkg_app$CONST.gc_objekt_cetrtna_skupnost' object_type  from dual
            UNION ALL SELECT 'RPE_DZ_VOLISCA',             'pkg_app$CONST.gc_objekt_dz_volisce'                          from dual
            UNION ALL SELECT 'RPE_KRAJEVNE_SKUPNOSTI',     'pkg_app$CONST.gc_objekt_krajevna_skupnost'                   from dual
            UNION ALL SELECT 'RPE_LOKALNA_VOLISCA',        'pkg_app$CONST.gc_objekt_lok_volisce'                         from dual
            UNION ALL SELECT 'RPE_LOKALNE_VOLILNE_ENOTE',  'pkg_app$CONST.gc_objekt_lok_volilna_enota'                   from dual
            UNION ALL SELECT 'RPE_NASELJA',                'pkg_app$CONST.gc_objekt_naselje'                             from dual
            UNION ALL SELECT 'RPE_OBCINE',                 'pkg_app$CONST.gc_objekt_obcina'                              from dual
            UNION ALL SELECT 'RPE_POSTNI_OKOLISI',         'pkg_app$CONST.gc_objekt_postni_okolis'                       from dual
            UNION ALL SELECT 'RPE_SOLSKI_OKOLISI',         'pkg_app$CONST.gc_objekt_solski_okolis'                       from dual
            UNION ALL SELECT 'RPE_STATISTICNE_REGIJE',     'pkg_app$CONST.gc_objekt_statisticna_regija'                  from dual
            UNION ALL SELECT 'RPE_ULICE',                  'pkg_app$CONST.gc_objekt_ulica'                               from dual
            UNION ALL SELECT 'RPE_UPRAVNE_ENOTE',          'pkg_app$CONST.gc_objekt_upravna_enota'                       from dual
            UNION ALL SELECT 'RPE_VASKE_SKUPNOSTI',        'pkg_app$CONST.gc_objekt_vaska_skupnost'                      from dual
            UNION ALL SELECT 'RPE_VOLILNE_ENOTE_DZ',       'pkg_app$CONST.gc_objekt_volilna_enota_dz'                    from dual
            UNION ALL SELECT 'RPE_VOLILNI_OKRAJI',         'pkg_app$CONST.gc_objekt_volilni_okraj'                       from dual)
select
'-- Kopiranje nabora v '|| rtc.table_name || '
  PROCEDURE nabor_' || substr(rtc.object_type, 25) || '(pi_postopek_id NUMBER,
                                   pi_uporabnik VARCHAR2 AS
    INSERT INTO nep_pos.' || lower(pac.table_name) ||'(
' || pac.all_cols || ',
                    sprememba,
                    postopek_id,
                    datum_sys,
                    uporabnik
    )
    SELECT          nep_pos.' || lower(pac.table_name) || '_seq.nextval,
                    '  || nac.table_id || ',
'  || nac.all_cols || ',
                    pkg_app$CONST.gc_sprememba_nespremenjen,
                    pi_postopek_id,
                    sysdate,
                    pi_uporabnik
     FROM nep.' || lower(nac.TABLE_NAME) || ' obj
          JOIN nep_pos.nabor_objektov pno 
            ON     pno.objekt_id = '  || nac.table_id || ' 
               AND pno.tip_objekta = ' ||rtc.object_type ||'
               AND pno.postopek_id = pi_postopek_id
    WHERE NOT EXISTS ( SELECT p' || nac.table_id || ' 
                         FROM nep_pos.' || nac.table_name || ' pobj
                        WHERE pobj.postopek_id = pi_postopek_id
                          AND p' || nac.table_id || ' = ' || nac.table_id || ');
  END nabor_' || substr(rtc.object_type, 25) || ';

'
    from pos_all_cols pac 
         join nep_all_cols nac on (nac.table_name = pac.table_name)
         join rpe_table_const rtc on (rtc.table_name = upper(nac.table_name));