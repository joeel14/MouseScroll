# Pruebas

## Ejecutadas en desarrollo (esta máquina / sesión)

| Prueba | Resultado |
|--------|-----------|
| Compilación `Scripts/build.sh` → `build/MouseScroll.app` (arm64, ad-hoc) | OK |
| Arranque de la app y terminación limpia | OK |
| Lógica de puerta Etapa C (`Scripts/test_stage_c_gate.swift`) | OK |
| `stage_c_analyze.sh` sin log | NO-GO esperado (sin eventos aún) |
| Inversión con hardware real HP + trackpad | **No ejecutada** (requiere permisos TCC y uso físico) |
| Scroll clásico en HP / natural en trackpad con inversión ON | **No ejecutada** |
| Denegar permisos sin errores | Pendiente de comprobar por el usuario en UI |
| Consumo de recursos | Pendiente (tap solo con interruptor ON) |

## Checklist del usuario (antes de confiar en la inversión)

1. [ ] Sin permisos: la app está inactiva y explica el motivo (no cambia el sistema)
2. [ ] Diagnóstico: trackpad → continuo; HP → discreto (informe Etapa C = GO)
3. [ ] Inversión ON: HP en dirección clásica; trackpad sigue natural
4. [ ] «Detener ahora» restaura el comportamiento inmediato del sistema
5. [ ] Salir detiene toda interceptación
6. [ ] Revocar permisos **después** de salir no deja el ratón bloqueado
7. [ ] Sin actividad de red (Activity Monitor / firewall personal si lo usas)

**Política:** no marques estos ítems como hechos en nombre del proyecto sin haberlos realizado.
