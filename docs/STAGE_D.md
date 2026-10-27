# Etapa D — Inversión (solo discretos)

## Condiciones previas

1. Etapa C con evidencia disjunta en la sesión (continuo + discreto).
2. Permiso de **Accesibilidad** concedido manualmente.
3. El usuario activa explícitamente «Invertir ratón (solo discretos)» (off por defecto).

## Comportamiento

- Tap modificador solo para `CGEventType.scrollWheel`.
- Si `scrollWheelEventIsContinuous != 0` → **no se modifica** (trackpad / Magic Mouse / smooth).
- Si es discreto → se niegan `scrollWheelEventDeltaAxis1` y `scrollWheelEventDeltaAxis2`.
- No se interceptan teclado, clics, gestos ni movimiento del cursor.
- No se modifica `com.apple.swipescrolldirection` ni ninguna preferencia de macOS.

## Controles

| Control | Efecto |
|---------|--------|
| Invertir ratón | Activa/desactiva el tap modificador |
| Detener ahora | `CGEventTapEnable(false)` + libera el tap |
| Salir | Detiene el tap y termina el proceso |

## Riesgo residual

Si un dispositivo “ratón” reporta scroll continuo, no se invertirá (fallo funcional, no afecta al trackpad). Si el trackpad reportara discreto (atípico), podría invertirse — por eso la Etapa C debe confirmar el comportamiento real antes de usar esta función.
