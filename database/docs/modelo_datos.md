# Modelo de Datos – Broadcast Server (PL/SQL Version)

## 1. Introducción
Este documento describe el modelo de datos del sistema **Broadcast Server**, desarrollado exclusivamente con bloques anónimos PL/SQL para creación de tablas, inserción de datos, reglas de negocio y flujos críticos.

El modelo se basa en una arquitectura modular, orientada a comandos y consultas (CQRS) y validaciones *table-driven*.

---

## 2. Entidades Principales
A continuación se listan las entidades centrales del sistema.

### 2.1 USERS
Representa a los usuarios registrados que pueden enviar mensajes a los canales.

**Atributos principales:**
- user_id (PK)
- username
- role
- created_at

---

### 2.2 CHANNELS
Grupo de comunicación donde se envían los mensajes.

**Atributos principales:**
- channel_id (PK)
- channel_name
- created_at

---

### 2.3 MESSAGES
Contiene los mensajes enviados por los usuarios.

**Atributos principales:**
- message_id (PK)
- channel_id (FK)
- user_id (FK)
- content
- state_id (FK)
- created_at
- updated_at

---

### 2.4 MESSAGE_STATES
Tabla table-driven que define el ciclo de vida de un mensaje.

**Atributos principales:**
- state_id (PK)
- state_code
- description

Ejemplos: INICIAL, PROCESANDO, VALIDADO, ERROR, COMPLETADO.

---

### 2.5 MESSAGE_VERSIONS
Registra el historial de cada mensaje cuando es editado.

**Atributos principales:**
- version_id (PK)
- message_id (FK)
- old_content
- version_date

---

### 2.6 VALIDATION_STRATEGIES
Tabla que almacena validaciones configurables.
Patrón *table-driven*.

**Atributos principales:**
- strategy_id (PK)
- strategy_name
- is_active
- config

---

### 2.7 REGISTRO_EVENTOS
Tabla auxiliar para almacenar eventos del sistema.

**Atributos principales:**
- evento_id (PK)
- seccion
- mensaje
- fecha_registro

---

## 3. Diagrama Entidad-Relación (Textual)
```
USERS (1) ────< (N) MESSAGES >──── (1) CHANNELS
                     │
                     ▼
              MESSAGE_VERSIONS (N)

MESSAGES (N) >──── (1) MESSAGE_STATES

VALIDATION_STRATEGIES (table-driven, independiente)
REGISTRO_EVENTOS (para logs)
```
---

## 4. Índices y Relaciones
- PKs generadas mediante constraints implícitas.
- FKs declaradas en USERS, CHANNELS, MESSAGES y MESSAGE_VERSIONS.
- Índices recomendados:
  - idx_messages_channel_id
  - idx_messages_user_id
  - idx_versions_message_id

---

## 5. Normalización
Todas las tablas cumplen las formas normales hasta **3FN**:
- No hay datos multivaluados.
- No hay dependencias transitivas.
- Configuraciones dinámicas se manejan vía VALIDATION_STRATEGIES.

---

## 6. Justificación del Modelo
- Separación de responsabilidades clara.
- Facilidad para versionar mensajes.
- Extensibilidad mediante reglas table-driven.
- Cohesión entre entidades.
- Optimización de consultas y comandos (enfoque CQRS).

---

## 7. Conclusión
El modelo de datos está preparado para soportar el flujo completo del Broadcast Server empleando únicamente PL/SQL en bloques anónimos. Su diseño facilita pruebas, mantenimiento, escalabilidad y futuras integraciones.

