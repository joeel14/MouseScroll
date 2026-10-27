#!/bin/zsh
# Analiza diagnostic.log y emite un veredicto GO / NO-GO para Etapa C.
# No modifica el sistema; solo lee el log local.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG="${1:-$ROOT/build/Logs/diagnostic.log}"

if [[ ! -f "$LOG" ]]; then
  echo "NO-GO: no existe el log: $LOG"
  echo "Activa el diagnóstico en MouseScroll, desplázate con trackpad y ratón, y vuelve a ejecutar."
  exit 2
fi

CONT=$(grep -c 'continuous=1' "$LOG" || true)
DISC=$(grep -c 'continuous=0' "$LOG" || true)

echo "=== Etapa C — análisis de $LOG ==="
echo "Eventos continuos: $CONT"
echo "Eventos discretos: $DISC"
echo ""

if (( CONT > 0 && DISC > 0 )); then
  echo "Veredicto provisional: GO"
  echo "Clases disjuntas observadas. Diseño seguro: invertir solo discretos."
  echo "Confirma manualmente: trackpad=continuo, ratón HP=discreto antes de usar inversión."
  exit 0
elif (( CONT > 0 && DISC == 0 )); then
  echo "Veredicto: NO-GO — solo continuos. Usa también el ratón HP."
  exit 1
elif (( DISC > 0 && CONT == 0 )); then
  echo "Veredicto: NO-GO — solo discretos. Usa también el trackpad."
  exit 1
else
  echo "Veredicto: NO-GO — sin eventos de scroll en el log."
  exit 1
fi
