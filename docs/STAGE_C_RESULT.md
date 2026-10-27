# Etapa C — Resultado

**Fecha de este archivo:** generado con el proyecto; la evidencia de hardware la aporta el usuario.

## Verificación de la herramienta de puerta (sin hardware)

- [x] Contadores continuo/discreto en `DiagnosticStore`
- [x] `hasDisjointEvidence` exige ambas clases antes de habilitar inversión
- [x] Informe de sesión + `Scripts/stage_c_analyze.sh`
- [x] Inversión deshabilitada en UI hasta evidencia disjunta

## Evidencia de hardware (usuario)

Marca tras seguir [STAGE_C.md](STAGE_C.md):

- [ ] Trackpad produce solo (o casi solo) `continuous=1`
- [ ] Ratón HP produce solo (o casi solo) `continuous=0`
- [ ] Informe Etapa C = GO provisional
- [ ] `Scripts/stage_c_analyze.sh` exit 0

**Veredicto de hardware en esta sesión de desarrollo:** no ejecutado con eventos reales de trackpad/HP (requiere permisos TCC del usuario y uso físico de los dispositivos). La app **no afirma** que la clasificación en tu Mac esté verificada hasta que completes la lista anterior.

**Política del código:** aunque falte la marca de hardware, la inversión solo se puede activar tras evidencia disjunta en la sesión de diagnóstico y permiso de Accesibilidad; y solo altera eventos discretos.
