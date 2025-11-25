DECLARE
    v_id_mensaje   NUMBER := 1; -- mensaje a editar
    v_id_usuario   NUMBER := 1; -- usuario que edita
    v_nuevo_texto  CLOB := 'Nuevo contenido actualizado';
    v_estado       NUMBER;
BEGIN
    -- Validación: mensaje debe existir
    DECLARE
        v_dummy NUMBER;
    BEGIN
        SELECT 1 INTO v_dummy
        FROM mensajes
        WHERE id_mensaje = v_id_mensaje;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20010, 'El mensaje no existe.');
    END;

    -- Guardar versión previa
    INSERT INTO mensaje_version(id_mensaje, contenido_anterior)
    SELECT id_mensaje, contenido
    FROM mensajes
    WHERE id_mensaje = v_id_mensaje;

    -- Actualizar mensaje
    UPDATE mensajes
    SET contenido = v_nuevo_texto
    WHERE id_mensaje = v_id_mensaje;

    INSERT INTO registro_eventos(id_usuario, tipo, mensaje)
    VALUES(v_id_usuario, 'EDICIÓN', 'Mensaje ' || v_id_mensaje || ' editado');

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Mensaje actualizado con éxito.');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error editando mensaje: ' || SQLERRM);
END;
/
