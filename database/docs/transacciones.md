# Transacciones en PL/SQL para el Proyecto Broadcast Server

Este documento describe cómo manejar **transacciones explícitas** en los
bloques anónimos PL/SQL del sistema Broadcast Server.

------------------------------------------------------------------------

## 1. Concepto General

Una transacción es un conjunto de operaciones que deben ejecutarse como
una unidad indivisible.\
En PL/SQL podemos controlarla mediante:

-   `COMMIT` → Guarda los cambios.
-   `ROLLBACK` → Revierte los cambios.
-   `SAVEPOINT` → Punto intermedio para rollback parcial.
-   Manejo de excepciones `EXCEPTION WHEN ... THEN`.

------------------------------------------------------------------------

## 2. Transacción Típica en el Proyecto

Cada caso de uso crítico (crear, editar, eliminar, versionar, enviar
broadcast) debe ejecutarse bajo un bloque "todo o nada".

Ejemplo:

``` sql
DECLARE
    v_message_id NUMBER;
BEGIN
    INSERT INTO MESSAGES (id, title, content, state_id, created_at)
    VALUES (messages_seq.NEXTVAL, 'Título', 'Contenido', 1, SYSDATE)
    RETURNING id INTO v_message_id;

    INSERT INTO MESSAGE_VERSIONS (version_id, message_id, version_number, content)
    VALUES (msg_versions_seq.NEXTVAL, v_message_id, 1, 'Contenido versión inicial');

    COMMIT; -- si todo va bien
    DBMS_OUTPUT.PUT_LINE('Mensaje creado con ID: ' || v_message_id);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; -- revierte ambas inserciones
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
```

------------------------------------------------------------------------

## 3. Uso de SAVEPOINT

Cuando deseas revertir solo una parte del proceso:

``` sql
SAVEPOINT before_versions;

INSERT INTO MESSAGE_VERSIONS (...);

-- si falla:
ROLLBACK TO before_versions;
```

------------------------------------------------------------------------

## 4. Transacciones en Cada Caso de Uso

**Crear mensaje**\
- Inserta mensaje → inserta versión → commit\
- Si falla: rollback

**Editar mensaje (versionar)**\
- Verifica estado → inserta nueva versión → actualiza mensaje\
- Commit/rollback

**Eliminar mensaje**\
- Update → commit\
- Falla → rollback

**Enviar broadcast (simulado)**\
- Insert masivo en USER_MESSAGES\
- Commit al final para asegurar consistencia

------------------------------------------------------------------------

## 5. Reglas de Buenas Prácticas

-   Siempre usar bloque `BEGIN … EXCEPTION … END`.
-   Nunca hacer commit parcial.
-   Usar `DBMS_OUTPUT.PUT_LINE` para auditoría.
-   Validar estados y llaves antes de modificar datos.
-   Usar `ROLLBACK` para dejar la BD limpia si hay error.

------------------------------------------------------------------------

## 6. Ejemplo Completo: Enviar Broadcast

``` sql
DECLARE
    v_count NUMBER := 0;
BEGIN
    FOR usr IN (SELECT id FROM USERS WHERE state_id = 1) LOOP

        INSERT INTO USER_MESSAGES (id, user_id, message_id, delivered_at)
        VALUES (user_msg_seq.NEXTVAL, usr.id, 1005, SYSDATE);

        v_count := v_count + 1;
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Broadcast enviado a ' || v_count || ' usuarios.');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error enviando broadcast: ' || SQLERRM);
END;
```

------------------------------------------------------------------------

## 7. Conclusión

Este documento estandariza cómo deben implementarse transacciones
explícitas dentro del proyecto.\
Todos los bloques anónimos PL/SQL deberán seguir este patrón para
asegurar integridad y consistencia.
