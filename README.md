# MouseScroll

App nativa de macOS (Swift / AppKit) para usar **desplazamiento natural en el trackpad** y **desplazamiento clásico en un ratón de rueda discreta** (p. ej. HP), **sin cambiar** la preferencia global de Natural Scrolling.

Diseñada para uso personal, con prioridad en **seguridad, estabilidad y reversibilidad**.

## Características

- Solo altera eventos `scrollWheel` **discretos** (rueda típica de ratón).
- Los eventos **continuos** (trackpad) no se tocan.
- Interfaz mínima: barra de menús + ventana opcional.
- Inicio al iniciar sesión (API oficial `SMAppService`, reversible en Ajustes).
- Sin red, telemetría, actualizadores ni dependencias de terceros.
- Sin `sudo`, sin drivers, sin extensiones de kernel, sin modificar preferencias del sistema.

## Requisitos

- macOS 14+
- Apple Silicon o Intel
- Xcode Command Line Tools (`swift`, `codesign`)
- Permiso de **Accesibilidad** (manual) para la copia en `~/Applications/MouseScroll.app`

## Compilar e instalar

```bash
./Scripts/build.sh
open ~/Applications/MouseScroll.app
```

El script:

1. Compila en un directorio temporal (evita problemas si la ruta del proyecto contiene `:`).
2. Genera `build/MouseScroll.app`.
3. Publica la copia estable en **`~/Applications/MouseScroll.app`** (recomendada para TCC/Accesibilidad).

## Primer uso

1. Abre `~/Applications/MouseScroll.app`.
2. Ajustes del Sistema → Privacidad y seguridad → **Accesibilidad**.
3. Añade **esa** copia (`~/Applications/MouseScroll.app`) y actívala.
4. Sal de MouseScroll y ábrela de nuevo.
5. Activa el interruptor (o el ítem **Activo** en la barra de menús).

### Controles

| Acción | Dónde |
|--------|--------|
| Activar / desactivar inversión | Interruptor en la ventana o menú de la barra |
| Abrir al iniciar sesión | Interruptor «Al iniciar sesión» / menú |
| Mostrar ventana | Menú de la barra → Mostrar ventana… |
| Salir | Botón o menú → Salir (detiene la interceptación) |

Cerrar la ventana **no** detiene la inversión; **Salir** sí.

## Cómo funciona

macOS solo ofrece un ajuste global de Natural Scrolling. MouseScroll instala un `CGEventTap` limitado a `scrollWheel` y niega los deltas de eventos con `scrollWheelEventIsContinuous == 0`.

Limitación: es una heurística (discreto ≈ rueda; continuo ≈ trackpad). Un Magic Mouse u otros dispositivos de scroll “suave” se tratan como continuo y no se invierten.

Detalles técnicos: [docs/STAGE_A.md](docs/STAGE_A.md), [docs/STAGE_D.md](docs/STAGE_D.md).

## Seguridad

- No modifica `defaults` ni Natural Scrolling.
- No toca la base TCC por Terminal.
- No intercepta teclado, clics, gestos ni el cursor.
- El permiso de Accesibilidad es potente: concederlo solo a esta app y revocarlo al desinstalar.
- Tras recompilar/firmar de nuevo, macOS a veces exige volver a activar Accesibilidad.

## Desinstalar

1. Sal de MouseScroll.
2. Desactiva «Abrir al iniciar sesión» (o quítalo en Ajustes → Generales → Elementos de inicio).
3. Quita MouseScroll de Accesibilidad.
4. Borra `~/Applications/MouseScroll.app` y, si quieres, esta carpeta del proyecto.

## Estructura del repositorio

```
AppBundle/          Info.plist e iconos
Sources/MouseScroll Código Swift
Scripts/build.sh    Compilación y publicación
docs/               Análisis de viabilidad y notas
Package.swift       Swift Package Manager
```

## Licencia

Uso personal / código abierto — ver [LICENSE](LICENSE).
