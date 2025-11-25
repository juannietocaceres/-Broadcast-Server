DECLARE
BEGIN
    INSERT INTO usuarios(nombre, email, estado)
    VALUES ('Admin', 'admin@server.com', 1);

    INSERT INTO usuarios(nombre, email, estado)
    VALUES ('Juan', 'juan@mail.com', 1);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Usuarios insertados.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error insertando usuarios: ' || SQLERRM);
        ROLLBACK;
END;
/
