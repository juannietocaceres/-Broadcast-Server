# Patrones Table-Driven en la Arquitectura de Datos

Proyecto: Broadcast Server – Plataforma PL/SQL (solo bloques anónimos)

## 1. Introducción

El enfoque table-driven consiste en trasladar lógica configurable—como validaciones, comportamientos, estados, estrategias y reglas—desde el código hacia tablas de configuración dentro del esquema de datos.

En un sistema sin procedimientos ni funciones (solo bloques anónimos PL/SQL), este patrón se vuelve clave para:

Reducir duplicación de lógica.

Activar/desactivar comportamientos sin modificar el código.

Centralizar reglas de negocio.

Permitir que el sistema evolucione sin tocar los bloques PL/SQL de los casos de uso.

## 2. Objetivo del Table-Driven en el Broadcast Server

Para nuestro proyecto, utilizamos tablas para controlar:

 Estrategias de validación

Ej.: ¿Qué campos son obligatorios para un mensaje?
Ej.: ¿Qué reglas se aplican según el tipo de mensaje?

 Estados configurables

Ya definidos previamente en la tabla ESTADOS_MENSAJE.

 Tipos de evento y su impacto

Ej.: broadcast, mensaje directo, sistema, log.

 Restricciones operativas

Ej.: ¿Puede un mensaje en estado “ARCHIVADO” ser editado?

Todo sin modificar bloques PL/SQL.

## 3. Tablas para implementar el patrón
3.1. Tabla: ESTRATEGIAS_VALIDACION

Define qué tipos de validación existen y cómo se deben aplicar.

CREATE TABLE estrategias_validacion (
    id_estrategia      NUMBER GENERATED ALWAYS AS IDENTITY,
    nombre             VARCHAR2(50) NOT NULL,
    descripcion        VARCHAR2(200),
    activo             CHAR(1) DEFAULT 'S' CHECK (activo IN ('S','N')),
    PRIMARY KEY (id_estrategia)
);

## 3.2. Tabla: ESTRATEGIA_X_TIPO_MENSAJE

Asigna estrategias a tipo de mensaje de forma dinámica.

CREATE TABLE estrategia_x_tipo_mensaje (
    id_relacion       NUMBER GENERATED ALWAYS AS IDENTITY,
    id_estrategia     NUMBER NOT NULL,
    tipo_mensaje      VARCHAR2(30) NOT NULL,
    PRIMARY KEY (id_relacion),
    FOREIGN KEY (id_estrategia) REFERENCES estrategias_validacion(id_estrategia)
);

## 3.3. Tabla: REGLAS_VALIDACION

Cada regla representa una verificación específica.

CREATE TABLE reglas_validacion (
    id_regla           NUMBER GENERATED ALWAYS AS IDENTITY,
    id_estrategia      NUMBER NOT NULL,
    codigo_regla       VARCHAR2(50) NOT NULL,
    mensaje_error      VARCHAR2(200) NOT NULL,
    parametro          VARCHAR2(100),  -- opcional, configurable
    PRIMARY KEY (id_regla),
    FOREIGN KEY (id_estrategia) REFERENCES estrategias_validacion(id_estrategia)
);


Ejemplos de reglas:

CAMPO_OBLIGATORIO:campo_titulo

LONGITUD_MAXIMA:200

NO_PERMITIR_EDICION_SI_ESTADO=ARCHIVADO

## 4. Uso del Patrón en Bloques PL/SQL
4.1. Obtención dinámica de validaciones

Ejemplo: al crear o editar un mensaje.

DECLARE
    v_tipo_mensaje mensajes.tipo%TYPE := 'BROADCAST';
BEGIN
    FOR cfg IN (
        SELECT r.codigo_regla, r.mensaje_error, r.parametro
        FROM estrategias_validacion e
        JOIN estrategia_x_tipo_mensaje x ON x.id_estrategia = e.id_estrategia
        JOIN reglas_validacion r ON r.id_estrategia = e.id_estrategia
        WHERE x.tipo_mensaje = v_tipo_mensaje
          AND e.activo = 'S'
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Aplicando regla: ' || cfg.codigo_regla);
        -- Aquí se implementarían validaciones dinámicas según la regla
    END LOOP;
END;
/


Esto permite cambiar reglas sin modificar el bloque PL/SQL.

## 5. Ejemplos de Estrategias en el Sistema
 Estrategia "VALIDACION_BASICA"

Título obligatorio

Contenido obligatorio

Longitud máxima: 200 caracteres

 Estrategia "VALIDACION_ADMIN"

Permite edición de mensajes publicados

Verifica estado destino permitido

 Estrategia "VALIDACION_RESTRINGIDA"

No permite edición si estado = ARCHIVADO

Exige un campo extra: prioridad

## 6. Beneficios del Table-Driven aplicado al proyecto
Beneficio	Impacto
Configurabilidad	Cambiar reglas sin modificar código
Escalabilidad	Añadir nuevas reglas mediante datos
Menos duplicación	Misma regla aplica a múltiples tipos de mensaje
Trazabilidad	Registros de qué reglas se aplican a qué mensajes
Gobernabilidad	Todo centralizado en tablas auditables
## 7. Conclusión

El patrón table-driven permite que la plataforma PL/SQL sea altamente dinámica, manteniendo las reglas de negocio fuera del código estático y moviéndolas hacia tablas configurables.
Este enfoque facilita el mantenimiento, escalabilidad y extensibilidad del sistema de broadcast que estamos documentando.