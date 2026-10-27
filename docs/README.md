# Documentación técnica

Notas del análisis por etapas (diseño seguro y límites de macOS):

| Documento | Contenido |
|-----------|-----------|
| [STAGE_A.md](STAGE_A.md) | Viabilidad, APIs, riesgos, enfoques descartados |
| [STAGE_C.md](STAGE_C.md) | Criterio continuo vs discreto (diagnóstico histórico) |
| [STAGE_C_RESULT.md](STAGE_C_RESULT.md) | Resultado / pendientes de hardware |
| [STAGE_D.md](STAGE_D.md) | Inversión solo de eventos discretos |
| [TESTING.md](TESTING.md) | Checklist de pruebas |

La app actual es la versión simplificada (menú + ventana + inicio al login). El flujo de “diagnóstico / informe Etapa C” del prototipo temprano ya no es la UI principal; la lógica segura sigue siendo: **invertir solo discretos**.
