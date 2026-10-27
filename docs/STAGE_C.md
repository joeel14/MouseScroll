# Etapa C — Criterio GO / NO-GO

## Objetivo

Comprobar en **tu** MacBook Air M4 + ratón HP si los eventos de scroll se separan de forma estable en:

- **continuo** (`continuous=1`) — esperado del trackpad
- **discreto** (`continuous=0`) — esperado del ratón HP

Sin esta evidencia, la inversión permanece bloqueada en la UI.

## Procedimiento (manual, reversible)

1. Compila: `Scripts/build.sh`
2. Abre: `open "build/MouseScroll.app"`
3. Concede **Monitorización de entrada** (menú → instrucciones / Abrir Ajustes).
4. Activa **Diagnóstico (solo lectura)**.
5. Desplázate solo con el **trackpad** unos segundos.
6. Desplázate solo con el **ratón HP** unos segundos.
7. Menú → **Generar informe Etapa C…** (también escribe `build/Logs/stage_c_report.txt`).
8. Opcional: `Scripts/stage_c_analyze.sh`

## Criterios

| Resultado | Condición |
|-----------|-----------|
| **GO provisional** | Log con `continuous=1` y `continuous=0`; confirmación visual de que el trackpad es continuo y el HP discreto |
| **NO-GO** | Solo una clase, solapamiento ambiguo, o el trackpad aparece como discreto |

## Diseño seguro tras GO

Invertir **únicamente** eventos discretos. **Nunca** modificar continuos. Así un error de clasificación no invierte el trackpad si este es continuo.

## Estado de verificación automatizable

El script `Scripts/stage_c_analyze.sh` y el menú «Generar informe Etapa C» evalúan el log local. **No declaran que tu hardware pasó la prueba** hasta que existan eventos reales en `build/Logs/diagnostic.log`.
