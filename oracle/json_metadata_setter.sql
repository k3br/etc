DECLARE
    v_jsoncol       geo_layers.metadata%TYPE;
    v_json_obj      json_object_t;
    v_new_jsoncol   geo_layers.metadata%TYPE;
BEGIN

    for c in (
        WITH rpe_link as(
                      SELECT 'RPE_CETRTNE_SKUPNOSTI' table_name, 'CETRTNA_SKUPNOST' object_type , 'rpe_cm' rpe_ol     from dual
            UNION ALL SELECT 'RPE_DZ_VOLISCA', 'DZ_VOLISCE'                     , 'rpe_vd'      from dual
            UNION ALL SELECT 'RPE_KRAJEVNE_SKUPNOSTI', 'KRAJEVNA_SKUPNOST'             , 'rpe_ks'      from dual
            UNION ALL SELECT 'RPE_LOKALNA_VOLISCA', 'LOK_VOLISCE'                , 'rpe_lv'      from dual
            UNION ALL SELECT 'RPE_LOKALNE_VOLILNE_ENOTE', 'LOK_VOLILNA_ENOTA'         , 'rpe_le'      from dual
            UNION ALL SELECT 'RPE_NASELJA', 'NASELJE'                         , 'rpe_na'      from dual
            UNION ALL SELECT 'RPE_OBCINE', 'OBCINA'                          , 'rpe_ob'      from dual
            UNION ALL SELECT 'RPE_POSTNI_OKOLISI', 'POSTNI_OKOLIS'                 , 'rpe_postni_okolisi'      from dual
            UNION ALL SELECT 'RPE_SOLSKI_OKOLISI', 'SOLSKI_OKOLIS'                 , 'rpe_sl'      from dual
            UNION ALL SELECT 'RPE_STATISTICNE_REGIJE', 'STATISTICNA_REGIJA'             , 'rpe_sr'      from dual
            UNION ALL SELECT 'RPE_ULICE', 'ULICA'                           , 'rpe_ul'      from dual
            UNION ALL SELECT 'RPE_UPRAVNE_ENOTE', 'UPRAVNA_ENOTA'                  , 'rpe_'ue      from dual
            UNION ALL SELECT 'RPE_VASKE_SKUPNOSTI', 'VASKA_SKUPNOST'                , 'rpe_cv'      from dual
            UNION ALL SELECT 'RPE_VOLILNE_ENOTE_DZ', 'VOLILNA_ENOTA_DZ'               , 'rpe_ve'      from dual
            UNION ALL SELECT 'RPE_VOLILNI_OKRAJI', 'VOLILNI_OKRAJ'                 , 'rpe_vo'      from dual)
        select gl.layer_id, gl.openlayers_name, rl.object_type, gl.metadata
        from geo_layers gl join rpe_link rl on (gl.openlayers_name = rl.rpe_ol) 
       where gl.layer_group_id in ( 43, 1043)) 
    loop
        v_json_obj := TREAT(json_element_t.parse(c.metadata) AS json_object_t);
        v_json_obj.put('object_type', c.object_type); --add new value
        v_json_obj.put('selectable', true); --selectable
        v_new_jsoncol := v_json_obj.to_string; --converts to string
        
        UPDATE geo_layers a
           SET a.metadata = v_new_jsoncol
         WHERE a.layer_id = c.layer_id; --update ( use appropriate where clause)
    end loop;

END;
/



