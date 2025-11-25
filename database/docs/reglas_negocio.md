# Reglas de Negocio

## 1. Validación de Inventario

-   No se puede registrar una salida de alimentos si no hay stock
    suficiente.
-   Los productos perecederos deben priorizarse por fecha de caducidad
    (FIFO).

## 2. Registro de Donaciones

-   Toda donación debe incluir: proveedor, tipo de alimento, cantidad y
    fecha de ingreso.
-   Los alimentos deben clasificarse automáticamente según categoría
    (perecedero/no perecedero).

## 3. Control de Estados

-   Los productos pueden tener estados: Disponible, Reservado, Agotado,
    Vencido.
-   El estado cambia automáticamente según acciones del sistema.

## 4. Usuarios y Roles

-   Solo supervisores pueden eliminar registros.
-   Los operarios solo pueden registrar entradas y salidas.

## 5. Auditoría

-   Toda operación debe quedar registrada con usuario, fecha y acción
    realizada.
