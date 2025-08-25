# Plan: Seguimiento de Facturación (Billing Tracking)

## Objetivo
Agregar funcionalidades de seguimiento completo a la facturación existente, incluyendo:
- Numeración de facturas
- Estados de factura (pendiente, pagada, vencida)
- Fechas de vencimiento
- Asociación con clientes
- Historial de pagos
- Seguimiento de cobros

## Cambios Requeridos

### 1. Actualizar src/lib/billing.ts
- Expandir interface BillingRecord para incluir campos de seguimiento
- Agregar interface Invoice separada para facturas
- Implementar sistema de numeración automática
- Agregar funciones de seguimiento de estado
- Implementar cálculo de facturas vencidas

### 2. Crear src/lib/invoices.ts
- Sistema completo de gestión de facturas
- Estados: 'pending', 'paid', 'overdue', 'cancelled'
- Asociación con clientes
- Historial de pagos
- Recordatorios automáticos

### 3. Actualizar src/app/billing/page.tsx
- Agregar vista de facturas vs gastos generales
- Implementar filtros por estado
- Mostrar indicadores visuales de estado
- Agregar funcionalidad de marcar como pagado
- Vista de facturas vencidas

### 4. Crear componentes de seguimiento
- Componente de estado de factura
- Indicadores visuales de vencimiento
- Formulario de registro de pago
- Dashboard de seguimiento

### 5. Actualizar navegación
- Agregar sección de seguimiento en el tab bar
- Crear página dedicada al seguimiento
