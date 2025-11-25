# Validaciones y Reglas de Negocio en PL/SQL

Proyecto: Arquitectura de Datos – Broadcast Server
Documento: Validaciones y Reglas de Negocio
Formato: Markdown
Tipo: Texto completo para copiar

## 1. Introducción

El presente documento describe las validaciones, reglas de negocio y controles programáticos que se implementarán dentro de los bloques anónimos PL/SQL del proyecto Broadcast Server, siguiendo el enunciado oficial:

No se utilizan procedimientos, funciones ni paquetes.

Todo se ejecuta mediante bloques anónimos.

Las validaciones deben combinar:

Restricciones declarativas (DDL)

Verificación programática dentro del bloque

Manejo explícito de transacciones

Mensajes diagnósticos mediante DBMS_OUTPUT

Auditoría cuando sea necesario

Este documento es fundamental para garantizar integridad, coherencia de datos y correcto comportamiento del negocio.

## 2. Tipos de Validaciones
 2.1 Validaciones Declarativas (definidas en el DDL)

Estas restricciones son aplicadas directamente en el esquema:

NOT NULL

UNIQUE

CHECK

FOREIGN KEY

DEFAULT

Índices para optimización o unicidad

Ejemplos aplicados en el proyecto:

email VARCHAR2(320) NOT NULL UNIQUE,
created_at DATE DEFAULT SYSDATE NOT NULL,
status VARCHAR2(20) CHECK (status IN ('ACTIVE','INACTIVE','DELETED')),


Ventajas:

Garantizan integridad a nivel de base de datos.

Se aplican sin necesidad de lógica adicional.

## 2.2 Validaciones Programáticas (dentro del bloque PL/SQL)

Son validaciones personalizadas que deben ejecutarse antes de cualquier operación de mutación.

Ejemplo: Validación de existencia previa.

SELECT COUNT(*) INTO v_exists
FROM messages
WHERE message_id = v_id;

IF v_exists = 0 THEN
  RAISE_APPLICATION_ERROR(-20001, 'El mensaje no existe.');
END IF;


Validación de longitud:

IF LENGTH(v_title) < 3 THEN
  RAISE_APPLICATION_ERROR(-20002, 'El título debe tener al menos 3 caracteres.');
END IF;


Validación de estado:

IF v_state = 'DELETED' THEN
  RAISE_APPLICATION_ERROR(-20003, 'No se pueden modificar mensajes eliminados.');
END IF;

## 3. Reglas de Negocio del Proyecto

A continuación se incluyen las reglas que gobiernan los casos de uso del Broadcast Server.

🔹 3.1 Regla: Creación de Mensajes

El título debe tener mínimo 3 caracteres.

El contenido no puede ser nulo.

El mensaje inicia siempre en estado ACTIVO.

Debe crearse automáticamente la versión 1 en la tabla de versiones.

Se debe registrar la operación en auditoría.

🔹 3.2 Regla: Edición de Mensajes (Versionado)

No se puede editar un mensaje eliminado.

Cada edición crea una nueva versión.

El updated_at debe actualizarse.

No se debe permitir versionar si no se cumple la estrategia definida (table-driven).

🔹 3.3 Regla: Eliminación Lógica (Soft Delete)

Los mensajes nunca se eliminan físicamente.

El estado pasa a DELETED.

No pueden volver a estado activo.

No generan nuevas versiones.

🔹 3.4 Regla: Buscar Mensajes

No deben mostrarse mensajes eliminados.

La búsqueda por texto debe permitir coincidencias parciales.

El filtrado es una regla firme del sistema.

🔹 3.5 Regla: Broadcast (Enviar Mensaje)

Solo se pueden enviar mensajes en estado ACTIVE.

Debe registrarse la entrega para cada usuario.

Si la entrega falla → la transacción completa se revierte.

La operación debe auditarse.

## 4. Validaciones Basadas en Table-Driven (Estrategias desde Tablas)

Este proyecto implementa el concepto de validaciones configuradas desde tablas.

Tabla ejemplo:

VALIDATION_STRATEGIES
----------------------
strategy_id
strategy_code
min_title_length
requires_content
can_edit_deleted
max_version_length
...


Funcionamiento:

El bloque PL/SQL consulta la estrategia activa.

Extrae los valores configurados.

Aplica las reglas dinámicamente.

Ejemplo:

IF LENGTH(v_title) < v_strategy.min_title_length THEN
    RAISE_APPLICATION_ERROR(-20050, 'Título demasiado corto según estrategia.');
END IF;


Ventajas:

Permite modificar validaciones sin tocar el código PL/SQL.

Facilita pruebas y despliegues.

## 5. Auditoría y Registro de Errores

Cada operación crítica debe registrar información en:

AUDIT_LOG
---------
audit_id
user_id
action
target_table
details
created_at


Ejemplo de registro en caso de error:

INSERT INTO audit_log (action, target_table, details)
VALUES ('VALIDATION_FAIL', 'messages', 'Título demasiado corto');


Cuando la auditoría no afecta la integridad de datos:

COMMIT; -- auditoría siempre se guarda

## 6. Manejo de Excepciones y Transacciones

Cada bloque debe envolver sus operaciones en:

BEGIN
    -- validaciones
    -- operaciones
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: '||SQLERRM);
END;
/


Si una validación falla:

No se aplica ningún cambio.

Se escribe en auditoría.

Se devuelve mensaje al usuario.

## 7. Ejemplo Completo de Bloque con Validaciones + Regla + Auditoría
DECLARE
    v_title VARCHAR2(100) := 'Hi';
    v_content VARCHAR2(2000) := 'Contenido de prueba';
    v_min_len NUMBER := 5;
BEGIN
    -- Validación programática
    IF LENGTH(v_title) < v_min_len THEN
        INSERT INTO audit_log(action, target_table, details)
        VALUES('VALIDATION_FAIL','messages','El título es demasiado corto');
        COMMIT; -- auditoría sí se guarda
        RAISE_APPLICATION_ERROR(-20020, 'El título no cumple la longitud mínima.');
    END IF;

    -- Inserción segura
    INSERT INTO messages (message_id, title, content, state_id, created_at)
    VALUES (messages_seq.NEXTVAL, v_title, v_content, 1, SYSDATE);

    INSERT INTO audit_log(action, target_table, details)
    VALUES('CREATE','messages','Mensaje creado correctamente');

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error al crear mensaje: ' || SQLERRM);
END;
/

## 8. Conclusión

Este documento describe de manera exhaustiva cómo se aplican:

Validaciones declarativas

Validaciones programáticas

Reglas de negocio

Auditoría

Table-driven validations

Manejo de transacciones y errores

Todo ello únicamente mediante bloques anónimos PL/SQL, cumpliendo estrictamente el enunciado del proyecto.
