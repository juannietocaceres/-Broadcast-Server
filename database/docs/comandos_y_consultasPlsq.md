# Separación de Comandos y Consultas (CQS) en PL/SQL

Proyecto: Broadcast Server – Plataforma basada en Bloques Anónimos PL/SQL

## 1. Introducción

El principio Command Query Separation (CQS) establece que:

Un comando (Command) modifica el estado de la base de datos.

Una consulta (Query) solo lee datos y no tiene efectos secundarios.

En un proyecto basado exclusivamente en bloques anónimos PL/SQL, este principio se vuelve esencial para:

Organizar los bloques PL/SQL de forma clara.

Evitar mezclar lecturas con mutaciones.

Dar trazabilidad a las transacciones.

Facilitar las pruebas de cada operación.

Mantener un diseño limpio sin funciones ni procedimientos.

## 2. Definición de Comandos y Consultas en el proyecto
 Comandos (mutaciones)

Son bloques que:

INSERTAN

ACTUALIZAN

ELIMINAN

Cambian estados

Registran auditorías

Ejemplos en este proyecto:

Crear mensaje

Editar mensaje

Cambiar estado

Eliminar mensaje

Versionar contenido

Registrar logs

Aplicar validaciones en bloque antes del COMMIT

Incluyen además:

Manejo manual de transacciones

Uso de ROLLBACK en fallas

DBMS_OUTPUT para diagnóstico

 Consultas (lecturas)

Son bloques que:

Devuelven listados

Obtienen un mensaje por ID

Filtran por estado

Obtienen historial de versiones

Generan reportes

Consultan reglas table-driven

Nunca alteran datos.

Se usan para analítica, interfaces externas, o verificación de integridad.

## 3. Estructura recomendada para bloques PL/SQL según CQS
### 3.1. Plantilla para COMANDOS
DECLARE
    -- Variables internas
    v_id_mensaje NUMBER;
    v_error VARCHAR2(200);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Iniciando comando: CREAR MENSAJE');

    -- Lógica de negocio (table-driven + validaciones)
    -- ...
    
    INSERT INTO mensajes (titulo, contenido, tipo)
    VALUES ('Mensaje Test', 'Contenido demo', 'BROADCAST')
    RETURNING id_mensaje INTO v_id_mensaje;

    -- Auditoría en tabla auxiliar
    INSERT INTO logs_mensajes (id_mensaje, descripcion)
    VALUES (v_id_mensaje, 'Mensaje creado');

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Mensaje creado con ID: ' || v_id_mensaje);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error en comando: ' || SQLERRM);
END;
/

### 3.2. Plantilla para CONSULTAS
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('Consulta: listar mensajes activos');

    FOR msg IN (
        SELECT id_mensaje, titulo, estado
        FROM mensajes
        WHERE estado = 'PUBLICADO'
        ORDER BY fecha_creado DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            msg.id_mensaje || ' - ' ||
            msg.titulo || ' [' || msg.estado || ']'
        );
    END LOOP;
END;
/


Sin COMMIT, sin INSERT, sin UPDATE, sin excepciones transaccionales.

## 4. Beneficios de CQS en el Broadcast Server
Beneficio	Descripción
Claridad	Cada bloque tiene un propósito único.
Mantenibilidad	Es más fácil modificar o agregar reglas.
Pruebas aisladas	Testear comandos y consultas por separado evita efectos secundarios.
Seguridad transaccional	Mutaciones controladas y reversibles sin afectar reportes.
Escalabilidad	Futuras APIs o módulos pueden consumir los bloques de consulta sin riesgo.
## 5. Ejemplos concretos aplicados al proyecto
 Comandos que ya definimos o definiremos

Crear mensaje

Editar mensaje

Eliminar mensaje

Cambiar estado

Registrar versión

Aplicar estrategia de validación (table-driven)

Log de acciones

 Consultas críticas

Listar mensajes por estado

Obtener un mensaje con su historial

Buscar por texto

Reporte de versiones

Consultar estados

Consultar las reglas activas de una estrategia

## 6. Integración con Validaciones y Table-Driven

Los comandos:

Obtienen reglas dinámicas desde las tablas table-driven.

Aplican validaciones antes de impactar la base.

Registran versiones y logs.

Las consultas:

Reutilizan esas configuraciones pero nunca alteran datos.

Esto genera un sistema altamente flexible sin necesidad de procedimientos almacenados.

## 7. Conclusión

Aplicar CQS permite que el desarrollo en PL/SQL basado únicamente en bloques anónimos sea:

Más modular

Más seguro

Más fácil de mantener

Más orientado a buenas prácticas de ingeniería

En el Broadcast Server, esta separación es un pilar que sustenta claridad, escalabilidad y robustez.