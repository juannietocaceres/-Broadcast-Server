DECLARE
    v_id_usuario   NUMBER := 1; -- cambiar según prueba
    v_contenido    CLOB := 'Mensaje de prueba creado desde bloque anónimo';
    v_estado       NUMBER := 1; -- ACTIVO
    v_id_mensaje   NUMBER;
BEGIN
    -- Validación: usuario debe existir y estar ACTIVO
    DECLARE
        v_estado_usuario NUMBER;
    BEGIN
        SELECT estado INTO v_estado_usuario
        FROM usuarios
        WHERE id_usuario = v_id_usuario;

        IF v_estado_usuario <> 1 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El usuario no está activo.');
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'El usuario no existe.');
    END;

    INSERT INTO mensajes(id_usuario, contenido, estado)
    VALUES (v_id_usuario, v_contenido, v_estado)
    RETURNING id_mensaje INTO v_id_mensaje;

    INSERT INTO registro_eventos(id_usuario, tipo, mensaje)
    VALUES(v_id_usuario, 'CREACIÓN', 'Mensaje creado con ID ' || v_id_mensaje);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Mensaje creado correctamente. ID=' || v_id_mensaje);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error creando mensaje: ' || SQLERRM);
END;
/
