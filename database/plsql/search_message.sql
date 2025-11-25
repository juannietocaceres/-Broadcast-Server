DECLARE
    v_query VARCHAR2(100) := 'prueba';
BEGIN
    DBMS_OUTPUT.PUT_LINE('Resultados de búsqueda: "' || v_query || '"');
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');

    FOR r IN (
        SELECT id_mensaje, contenido
        FROM mensajes
        WHERE LOWER(contenido) LIKE '%' || LOWER(v_query) || '%'
          AND estado <> 3 -- no mostrar borrados
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'ID ' || r.id_mensaje || ': ' ||
            SUBSTR(r.contenido, 1, 60)
        );
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error buscando mensajes: ' || SQLERRM);
END;
/
