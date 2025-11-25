# Casos de Uso -- Broadcast Server

## 1. Crear Mensaje (Broadcast)

**Actor:** Administrador\
**Descripción:** El administrador crea un mensaje para ser enviado a
todos los usuarios conectados.\
**Flujo principal:** 1. El sistema recibe título y contenido. 2. Valida
longitud, estado y usuario creador. 3. Inserta en `MESSAGES`. 4.
Registra versión inicial en `MESSAGE_VERSIONS`. 5. Devuelve ID generado.

------------------------------------------------------------------------

## 2. Editar Mensaje

**Actor:** Administrador\
**Descripción:** Se actualiza un mensaje existente creando una nueva
versión.\
**Flujo:** 1. Verifica que el mensaje exista. 2. Verifica estado (no
eliminado). 3. Genera nueva versión en `MESSAGE_VERSIONS`. 4. Actualiza
datos del mensaje en `MESSAGES`.

------------------------------------------------------------------------

## 3. Eliminar Mensaje

**Actor:** Administrador\
**Descripción:** Se marca un mensaje como eliminado.\
**Flujo:** 1. Verifica existencia. 2. Cambia estado a "DELETED".

------------------------------------------------------------------------

## 4. Listar Mensajes

**Actor:** Sistema / Cliente\
**Descripción:** Devuelve la lista de mensajes activos.\
**Flujo:** 1. Consulta `MESSAGES` filtrando por estado "ACTIVE".

------------------------------------------------------------------------

## 5. Buscar Mensaje

**Actor:** Administrador / Sistema\
**Descripción:** Permite buscar mensajes por ID o texto.\
**Flujo:** 1. Si se pasa ID → retorno único.\
2. Si se pasa texto → busca coincidencias.

------------------------------------------------------------------------

## 6. Versionar Mensaje

**Actor:** Sistema\
**Descripción:** Cada edición genera una nueva versión.\
**Flujo:** 1. Lee última versión. 2. Incrementa version_number. 3.
Guarda versión en `MESSAGE_VERSIONS`.

------------------------------------------------------------------------

## 7. Enviar Broadcast (Simulación)

**Actor:** Sistema\
**Descripción:** Marca mensaje como enviado a todos los usuarios
registrados.\
**Flujo:** 1. Recorre tabla `USERS`. 2. Inserta registro en
`USER_MESSAGES` (si se usa). 3. Devuelve total de usuarios notificados.
