DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('Listado de mensajes activos:');
    DBMS_OUTPUT.PUT_LINE('----------------------------');

    FOR r IN (
        SELECT m.id_mensaje, u.nombre AS usuario, m.fecha_envio, m.contenido
        FROM mensajes m
        JOIN usuarios u ON u.id_usuario = m.id_usuario
        WHERE m.estado = 1
        ORDER BY m.fecha_envio DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'ID: ' || r.id_mensaje ||
            ' | Usuario: ' || r.usuario ||
            ' | Fecha: ' || r.fecha_envio ||
            ' | Contenido: ' || SUBSTR(r.contenido, 1, 40)
        );
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error listando mensajes: ' || SQLERRM);
END;
/
