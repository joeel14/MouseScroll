# Etapa A — Viabilidad y riesgos

## Veredicto

Es técnicamente posible obtener scroll natural en el trackpad y clásico en un ratón externo **sin modificar preferencias de macOS**, usando un event tap oficial de Core Graphics limitado a `scrollWheel`.

No es posible garantizar con APIs públicas una atribución 100 % al dispositivo físico. La distinción disponible es heurística (`scrollWheelEventIsContinuous`). La inversión automática solo debe activarse tras la Etapa C.

## Enfoques descartados

| Enfoque | Motivo |
|--------|--------|
| Cambiar `com.apple.swipescrolldirection` | Modifica preferencias globales |
| Kernel extensions / DriverKit | Fuera de reglas de seguridad |
| Electron / Python / Node / Homebrew obligatorio | Fuera de arquitectura mínima |
| Interceptar teclado, clics, gestos o cursor | Alcance y riesgo innecesarios |
| Manipular TCC vía Terminal/`tccutil` | Manipulación de permisos |

## API elegida

- **Core Graphics**: `CGEvent.tapCreate` — máscara únicamente `CGEventType.scrollWheel`
- **Lectura (diagnóstico)**: `scrollWheelEventIsContinuous`, deltas de eje, `NSEvent.isDirectionInvertedFromDevice`
- **Escritura (inversión, solo si Etapa C = go)**: negar deltas de eventos **discretos**; nunca tocar eventos continuos ni otros tipos de evento
- **UI**: `NSStatusItem` (AppKit), sin dependencias de terceros, sin red

## Permisos

| Modo | Tap | Ajustes del Sistema | Capacidad |
|------|-----|---------------------|-----------|
| Diagnóstico | `listenOnly` | Monitorización de entrada | Observar eventos; no modificarlos |
| Inversión | modificador | Accesibilidad | Alterar el flujo de eventos (solo scroll) |

La app no se autootorga permisos ni toca la base TCC. Sin permiso permanece inactiva.

## Limitaciones de clasificación

- `isContinuous == 1`: típico trackpad, Magic Mouse, ratones con smooth scroll
- `isContinuous == 0`: típico rueda discreta de ratón
- No es identidad de dispositivo (vendor/product)
- Diseño seguro previsto: **invertir solo discretos; nunca continuos** (protege el trackpad si este siempre es continuo)

## Riesgos de clasificación incorrecta

| Error | Efecto (con Natural Scrolling ON) |
|-------|-----------------------------------|
| Invertir un continuo (p. ej. trackpad) | Trackpad deja de ser natural — **mitigado: no invertir continuos** |
| No invertir un discreto (ratón) | Ratón sigue natural — fallo funcional, no de seguridad del trackpad |
| Revocar Accesibilidad con tap activo | Posible comportamiento anómalo de entrada — salir/detener antes de revocar |

## Hipótesis de hardware (pendiente de Etapa C)

MacBook Air M4 + ratón HP de rueda discreta:

- Trackpad → continuo
- HP → discreto
