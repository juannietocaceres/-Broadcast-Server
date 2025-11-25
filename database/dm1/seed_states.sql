DECLARE
BEGIN
    INSERT INTO estados(nombre, descripcion)
    VALUES ('ACTIVO', 'Registro habilitado');

    INSERT INTO estados(nombre, descripcion)
    VALUES ('INACTIVO', 'Registro deshabilitado');

    INSERT INTO estados(nombre, descripcion)
    VALUES ('BORRADO', 'Marcado para eliminación');

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Estados insertados correctamente.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error insertando estados: ' || SQLERRM);
        ROLLBACK;
END;
/
