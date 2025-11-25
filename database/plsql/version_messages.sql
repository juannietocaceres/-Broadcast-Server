DECLARE
    v_id_mensaje NUMBER := 1;
BEGIN
    INSERT INTO mensaje_version(id_mensaje, contenido_anterior)
    SELECT id_mensaje, contenido
    FROM mensajes
    WHERE id_mensaje = v_id_mensaje;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Versión creada correctamente para el mensaje ' || v_id_mensaje);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error versionando mensaje: ' || SQLERRM);
END;
/
