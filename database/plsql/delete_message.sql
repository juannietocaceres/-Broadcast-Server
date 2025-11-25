DECLARE
    v_id_mensaje NUMBER := 1;
    v_id_usuario NUMBER := 1;
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
            RAISE_APPLICATION_ERROR(-20020, 'El mensaje no existe.');
    END;

    -- Marcar como borrado
    UPDATE mensajes
    SET estado = 3 -- estado BORRADO
    WHERE id_mensaje = v_id_mensaje;

    INSERT INTO registro_eventos(id_usuario, tipo, mensaje)
    VALUES(v_id_usuario, 'ELIMINACIÓN', 'Mensaje ' || v_id_mensaje || ' marcado como borrado');

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Mensaje marcado como borrado.');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error borrando mensaje: ' || SQLERRM);
END;
/
