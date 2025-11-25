# Arquitectura del Sistema

## 1. Visión General
El sistema está diseñado bajo una arquitectura modular, basada en el principio de **separación de responsabilidades**, donde cada capa cumple una función clara: persistencia, lógica de validación, mutaciones, consultas y auditoría.

La solución utiliza **PL/SQL con bloques anónimos** para garantizar:
- Repetibilidad de ejecución
- Manejo controlado de errores
- Independencia entre operaciones mutadoras y de lectura
- Validaciones basadas en configuraciones table-driven

---

## 2. Componentes Principales

### **2.1 Capa de Datos (Relacional)**
Incluye todas las tablas necesarias para el modelo:
- `users`
- `channels`
- `broadcasts`
- `messages`
- `notes`
- `note_versions`
- `validation_strategies`
- `audit_log`

Se incluyen índices y restricciones para optimizar y proteger la integridad del modelo.

---

## 2.2 Capa de Validación (Table-Driven)
El sistema delega reglas de negocio en la tabla:
- `validation_strategies`

Permite:
- Activar/desactivar reglas sin cambiar código
- Configurar parámetros (ej: mínimo de caracteres en títulos)
- Seleccionar dinámicamente estrategias en tiempo de ejecución

---

## 2.3 Capa de Lógica (PL/SQL)
Implementada mediante bloques anónimos:

### **Mutaciones (WRITE):**
- Creación/edición/borrado de notas
- Inserción de broadcasts
- Manejo de versiones
- Auditoría de cambios

### **Consultas (READ-ONLY):**
- Listado de notas activas
- Búsqueda de broadcasts
- Inspección de auditorías

Esta separación previene efectos secundarios no deseados.

---

## 3. Flujo General de Procesamiento

1. **Entrada de datos** → recibido desde otra capa (API, CLI, o script)
2. **Validación table-driven** → lectura dinámica de reglas
3. **Ejecución de operación** (insert/update/delete)
4. **Creación de versiones** (cuando aplica)
5. **Registro en auditoría**
6. **Confirmación transaccional (COMMIT)**

---

## 4. Módulo de Versionado
La tabla `note_versions` permite reconstruir el historial completo de una nota.

Características:
- Cada edición crea una nueva entrada
- Se incrementa el campo `current_version` en la tabla padre
- Auditoría registra: quién, cuándo y qué cambió

---

## 5. Auditoría Centralizada
`audit_log` asegura trazabilidad:
- Origen del cambio (`who`)
- Acción ejecutada
- Tabla afectada
- Identificador del registro
- Detalles adicionales

Permite diagnósticos, debugging y análisis compliance.

---

## 6. Estados del Proceso
Integrado con la tabla añadida en el documento de datos:

| Estado | Significado |
|--------|-------------|
| INICIAL | Entrada de datos recibida |
| PROCESANDO | Bloque PL/SQL en ejecución |
| VALIDADO | Lógica table-driven aprobada |
| ERROR | Falla en validación o mutación |
| COMPLETADO | Transacción finalizada |

---

## 7. Futuras Extensiones
- Motor de validaciones más complejo (JSON avanzado)
- Enrutamiento por canal (rules per channel)
- Auditoría diferencial (comparar versión anterior vs nueva)
- Integración con API REST externa

---

## 8. Conclusión
La arquitectura es robusta, escalable y totalmente basada en PL/SQL anónimo con separación clara entre capas. Esto simplifica el mantenimiento, acelera pruebas y favorece la extensibilidad del sistema.