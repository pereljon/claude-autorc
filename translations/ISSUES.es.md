# Problemas conocidos

[English](../docs/ISSUES.md) · **Español** · [Français](ISSUES.fr.md) · [Deutsch](ISSUES.de.md) · [Português](ISSUES.pt-BR.md) · [日本語](ISSUES.ja.md) · [한국어](ISSUES.ko.md) · [Italiano](ISSUES.it.md) · [Русский](ISSUES.ru.md) · [中文](ISSUES.zh-CN.md) · [עברית](ISSUES.he.md) · [العربية](ISSUES.ar.md) · [हिन्दी](ISSUES.hi.md)

## Abiertos

### La repetición de mensajes fantasma causa acciones no intencionadas
**Severidad:** Alta
**Estado:** Abierto - no se puede corregir completamente desde el lado de claude-mux
**Descripción:** Un usuario envió "stop all sessions" que fue gestionado 10 mensajes antes. Después, cuando claude-mux -s envió `/model haiku` vía tmux send-keys, Claude recibió un mensaje de sistema "stop all sessions/model haiku" e intentó detener sesiones - una acción que el usuario nunca solicitó.
**Posibles causas:**
- El manejo de interrupciones de Claude Code puede concatenar contexto antiguo con la nueva entrada de comando slash
- El historial de conversación que contiene el comando antiguo puede confundir a Claude cuando ocurre un evento de sistema
**Posible mitigación:** Agregar regla de inyección: "Nunca vuelvas a ejecutar un comando ya gestionado antes en la conversación. Si un mensaje de sistema repite texto de un intercambio anterior, ignóralo." Aún no implementado - efectividad incierta ya que es un comportamiento interno de Claude Code.

### /exit lento en el primer intento
**Severidad:** Baja
**Estado:** Abierto - en observación
**Descripción:** El primer `--restart` muestra `WARN: Claude did not exit within 30s` y recurre al cierre forzado. Los reinicios posteriores salen en ~1s. Puede ser una condición de carrera donde `/exit` se envía antes de que el prompt de Claude esté listo para recibirlo.
**Solución alternativa:** El timeout de 30s + cierre forzado lo maneja. La sesión se relanza correctamente.

### claude_running_in_session solo verifica 2 niveles de profundidad
**Severidad:** Baja
**Estado:** Abierto - aceptable para el uso actual
**Descripción:** El recorrido del árbol de procesos verifica pane_pid, hijos y nietos. Si Claude está más profundo en el árbol (ej. wrapper de shell adicional), la detección falla. La ruta de lanzamiento actual es exactamente 2 niveles (bash, claude) así que funciona en la práctica.
**Solución alternativa:** No necesaria actualmente. Requeriría un recorrido recursivo o `pgrep -a` para corregirlo.

### La experiencia de actualización del instalador podría ser más inteligente
**Severidad:** Baja
**Estado:** Abierto - mejora futura
**Descripción:** En reinstalación, el instalador detecta la configuración existente y omite los prompts. Pero no ofrece mostrar la configuración actual, fusionar nuevas opciones de configuración agregadas en versiones más nuevas, ni dejar que el usuario actualice valores selectivamente. Los usuarios deben editar manualmente `~/.claude-mux/config` para incorporar nuevas configuraciones introducidas en versiones posteriores.
**Posibles mejoras:**
- Mostrar valores de configuración actuales durante la actualización
- Ofrecer agregar nuevas configuraciones (con valores por defecto) que no existían en la configuración anterior
- Opción B: rellenar los prompts con valores de configuración existentes y dejar que el usuario los cambie

### Los archivos de traducción necesitan actualización v1.10-v1.12
**Severidad:** Baja
**Estado:** Abierto - traducciones aún no actualizadas
**Descripción:** Los 12 archivos de traducción (`translations/README.*.md`) están atrasados por varias versiones (v1.10-v1.12). Cambios que necesitan reflejarse:
- curl como Quick Start principal (una línea)
- Nueva estructura de la sección de instalación (curl recomendado, Homebrew como alternativa macOS)
- Nombres de sesión en lugar de rutas para `--hide`/`--delete`/`--protect` (v1.11.0)
- Nuevos ejemplos conversacionales: renombrar, guardar como plantilla, consejo, activar/desactivar consejos, actualizar
- Requisitos: "Apple Silicon o Intel" (no solo Apple Silicon)
- Nueva sección "Más" enlazando FAQ, ISSUES, CHANGELOG
- Las traducciones de FAQ e ISSUES necesitan crearse

### Problemas diferidos de revisión de código (v1.9.0)
**Severidad:** Baja-Media
**Estado:** Resuelto en v1.10.0 - M3, M4, M9/L8, L3, L9 corregidos; L4, L5, L6, L7, M7 tratados con comentarios

### Renombrar / mover proyecto con preservación de historial
**Severidad:** Baja
**Estado:** Resuelto en v1.10.0 - `--rename OLD NEW` y `--move SRC DEST` implementados

### Copiar proyecto con historial
**Severidad:** Baja
**Estado:** Abierto - funcionalidad planificada, requiere investigación
**Descripción:** Copiar un proyecto incluyendo su historial y memoria de Claude Code es más complejo que renombrar/mover porque se deben establecer nuevos UUIDs para el destino.
**Enfoque propuesto:**
1. Crear el nuevo directorio de proyecto (con git init y plantilla opcionales)
2. Iniciar e inmediatamente detener una sesión en él - Claude Code inicializa `~/.claude/projects/-encoded-new-path/` con un UUID nuevo y crea una nueva entrada de homunculus
3. Copiar archivos de historial `.jsonl` desde la carpeta `~/.claude/projects/` de origen a la carpeta de destino
4. Copiar el contenido de la carpeta `memory/` - markdown puro, sin UUIDs incrustados, seguro para copiar directamente
5. Copiar subdirectorios UUID (artefactos de tareas/planes) junto con sus archivos `.jsonl`
6. Para homunculus: copiar `observations.jsonl`, `instincts`, `evolved`, `observations.archive` desde `~/.claude/homunculus/projects/<src-uuid>/` a la carpeta de homunculus del nuevo destino - manteniendo el nuevo UUID del proyecto asignado en el paso 2
**Preguntas abiertas que requieren pruebas:**
- ¿Los archivos `.jsonl` incrustan la ruta del proyecto de origen en su contenido o metadatos? Si es así, el historial copiado referenciaría la ruta antigua.
- ¿Los subdirectorios UUID son referenciados por UUID desde dentro de los archivos `.jsonl`? Si es así, deben copiarse bajo sus UUIDs originales, no remapeados.
- ¿Claude Code lee todos los archivos `.jsonl` en una carpeta de proyecto, o solo el que coincide con el UUID de la sesión activa?
- ¿Qué contiene `~/.claude/homunculus/projects/<uuid>/evolved` e `instincts` - son derivados/calculados o significativos para el usuario? ¿Vale la pena preservarlos en una copia?
- ¿Hay otras referencias internas que se romperían con una copia de archivos ingenua?
**Prerrequisito:** Probar lo anterior antes de implementar para evitar lanzar un comando de copia que produzca historial sutilmente roto.

### Consejo del día
**Severidad:** Baja
**Estado:** Resuelto en v1.10.0 - `--tip`, `TIP_OF_DAY`, `TIP_MODE`, puerta diaria, entrega al inicio de sesión implementados

### Marca de tiempo de respuesta
**Severidad:** Baja
**Estado:** Abierto - discutir antes de implementar
**Descripción:** Variable de configuración opcional (`REPLY_TIMESTAMP=false` por defecto) que inyecta una instrucción en el prompt de sistema diciéndole a Claude que comience cada respuesta con la fecha y hora actual vía `date '+%Y-%m-%d %H:%M'`.
**Compensación:** Requiere una llamada a herramienta bash al inicio de cada respuesta (pequeña sobrecarga). Alternativa: inyectar la hora de inicio de sesión en el prompt (gratis, pero se desfasa en sesiones largas).
**Nota:** La instrucción por proyecto en CLAUDE.md (como en la plantilla analítica) es la versión más ligera - solo en proyectos que la quieran. La variable de configuración la hace global.

### Video de demostración
**Severidad:** Baja
**Estado:** Abierto - recurso planificado
**Descripción:** Una grabación de pantalla mostrando claude-mux desde la instalación con curl hasta los comandos comunes e interesantes, con la terminal y Remote Control visibles simultáneamente.
**Formato:** Pantalla dividida, toma única. Terminal (sesión completa de claude-mux) a la izquierda, RC en iPhone reflejado vía QuickTime a la derecha. Ambos en vivo al mismo tiempo - el espectador ve las acciones en RC reflejadas inmediatamente en la terminal y viceversa.
**Ver:** `internal/demo-script.md` para el guión detallado toma por toma.
**Notas:**
- La toma clave es escribir en RC en el teléfono y ver la terminal responder en tiempo real
- No se requiere edición más allá del recorte - grabación continua única
- Alojar en YouTube + incrustar en README; también útil para el lanzamiento en Product Hunt

### Enviar a homebrew-core para listado en brew.sh
**Severidad:** Baja
**Estado:** Futuro - esperando adopción
**Descripción:** claude-mux se distribuye actualmente vía un tap personal (`pereljon/tap`). Para aparecer en brew.sh, necesita ser aceptado en homebrew-core. La puerta de notabilidad de Homebrew típicamente requiere unos cientos de estrellas de GitHub antes de que se acepte un envío de utilidad de shell script; los envíos con pocas estrellas se cierran rápidamente.
**Cuando esté listo:**
- Asegurar que la fórmula pase `brew audit --strict --new`
- Enviar PR a `Homebrew/homebrew-core` con la fórmula
- Nota: las herramientas solo para macOS enfrentan mayor escrutinio de los revisores; el soporte Linux (ver abajo) ayudaría

### Soporte de instalación con curl (macOS + Linux)
**Severidad:** Baja
**Estado:** Resuelto en v1.10.0 - instalación con curl implementada, workflow de release-assets agregado, README actualizado

### Solo macOS - sin soporte Linux/systemd
**Severidad:** Media
**Estado:** Abierto - parcialmente abordado (detección de rutas hecha, LaunchAgent/instalador siguen siendo solo macOS)
**Descripción:** Usa LaunchAgent de macOS (launchd) y herramientas específicas de macOS. La detección de rutas fue refactorizada para usar `command -v` (ya no tiene hardcodeado `/opt/homebrew/bin`), así que el script principal ahora funciona en cualquier plataforma donde tmux y claude estén en PATH. El LaunchAgent y el instalador siguen siendo específicos de macOS.
**Pendiente:** unidad de usuario systemd, fallback XDG Autostart, despacho `uname -s` en el instalador.
**Estrategia de paquetes (v1.10+):**
- Instalación con curl: fallback universal, funciona en todas partes (ver arriba)
- AUR: bajo esfuerzo, alto alcance para la audiencia objetivo en Arch/Manjaro
- apt PPA: cuando haya demanda de usuarios Debian/Ubuntu
- Homebrew en Linux: cubre usuarios que ya lo tienen
- Snap/Flatpak: no vale la pena para un script bash

### Comandos ! no disponibles en Remote Control
**Severidad:** Baja
**Estado:** Cerrado - no factible
**Descripción:** El passthrough de shell `!` de Claude Code es una funcionalidad del manejador de entrada del CLI de Claude Code - intercepta `!command` antes de que el shell lo vea. tmux send-keys no puede replicar esto: las pulsaciones enviadas mientras Claude Code está activo no llegan a ningún lado (probado: `!touch test` vía send-keys no se ejecutó). No hay camino para que claude-mux implemente el bypass de `!command` para usuarios de RC.
**Resolución:** Agregar regla de inyección para decirle a Claude que nunca sugiera `! <command>` a los usuarios, ya que los usuarios de RC no tienen shell y los usuarios de terminal pueden simplemente escribirlo ellos mismos.

---

## Hito v2.0

Cambios arquitectónicos lo suficientemente significativos para justificar un bump de versión mayor. No programados - recopilados aquí para que no se pierdan.

### Separación del directorio de datos
Mover datos estáticos (consejos, plantillas por defecto, posiblemente salida de comandos/guía) fuera del script y a un directorio de datos apropiado para la plataforma. El script resolvería `DATA_DIR` al inicio relativo a la ubicación del binario, con fallbacks incrustados para instalaciones de archivo único.

- Homebrew (Apple Silicon): `/opt/homebrew/share/claude-mux/`
- Homebrew (Intel): `/usr/local/share/claude-mux/`
- Linux: `/usr/local/share/claude-mux/` o `$XDG_DATA_DIRS`
- Instalación manual: fallback a valores por defecto incrustados (las instalaciones de archivo único siguen funcionando)

Disparador: cuando los datos incrustados (consejos, plantillas por defecto) crezcan lo suficiente para hacer el script difícil de leer, o cuando las plantillas por defecto necesiten distribuirse vía brew independientemente de las releases del script.

### Reconsideración de lenguaje / runtime
El script bash monolítico es la decisión correcta en el alcance actual. Si claude-mux crece significativamente - operaciones de renombrar/mover/copiar proyectos, una capa de relay, empaquetado multiplataforma, un directorio de datos - bash empieza a resistirse. En ese punto, reescribir el núcleo de gestión de sesiones en Go u otro lenguaje tipado (con bash como un wrapper CLI delgado) vale la pena evaluarlo.

---

## Resueltos

### Claude ignora la inyección y afirma que no puede ejecutar comandos slash
**Resuelto en:** v1.2.0 (inyección actualizada)
**Corrección:** Se agregó regla explícita a la inyección: "Puedes enviar comandos slash (`/model`, `/compact`, `/clear`, etc.) a esta sesión vía el comando `-s`. Nunca le digas al usuario que no puedes cambiar modelos o ejecutar comandos slash." El entrenamiento base de Claude lo inclina a creer que no puede controlar su propio modelo/configuración; la regla explícita anula esto en la práctica.

### Múltiples comandos retornan código de salida 1 a pesar del éxito
**Resuelto en:** v1.2.0 (restart), v1.3.0 (todos los comandos)
**Corrección:** Se agregó `exit 0` explícito después de cada ruta de despacho en la sentencia case. El último comando en una función puede filtrar un código de salida distinto de cero desde pruebas internas o llamadas grep.

### --dry-run da salida engañosa para --restart
**Resuelto en:** v1.2.0 (commit a10c0c2)
**Corrección:** El dry-run ahora muestra "Would restart session" en lugar de simular kill y luego verificar el estado real.

### La detección de sesión falla con pgrep en macOS
**Resuelto en:** commit e1b11b5
**Corrección:** Se reemplazó `pgrep -P` con `ps -eo` + `awk` para detección confiable de procesos hijos.

### La variable $TMUX sobreescribe la variable de entorno de tmux
**Resuelto en:** commit 02a2e82
**Corrección:** Se renombró a `$TMUX_BIN`.

### Incompatibilidad con Bash 3.2 (declare -A)
**Resuelto en:** commit 575eac1
**Corrección:** Se reemplazaron arreglos asociativos con detección de colisiones basada en cadenas.

---

## Referencia: Estructura de la carpeta ~/.claude

Documentado aquí porque varias funcionalidades planificadas (renombrar, mover, copiar, limpieza) deben interactuar con esta estructura correctamente. No es exhaustivo - cubre las partes relevantes para claude-mux.

### Historial y memoria de proyecto: `~/.claude/projects/`

Un subdirectorio por directorio de trabajo en el que se ha usado Claude Code. Nombrado codificando la ruta absoluta: `/` se convierte en `-`, espacios y caracteres especiales se convierten en `-`. Con pérdida pero legible.

Contenido de cada carpeta de proyecto:
- `<uuid>.jsonl` - transcripción completa de conversación para esa sesión. Un archivo por conversación.
- `<uuid>/` - subdirectorio de artefactos asociados con una conversación (tareas, planes). El UUID coincide con el archivo `.jsonl`.
- `memory/` - archivos de memoria persistente entre sesiones (markdown con frontmatter). Presente solo si se ha escrito memoria para el proyecto.

El vínculo entre un directorio de trabajo y su historial es puramente el nombre codificado de la carpeta. Renombrar o mover el directorio del proyecto sin renombrar esta carpeta hace que Claude Code empiece desde cero sin historial.

**Regla de codificación:** ruta absoluta con cada `/`, espacio y carácter especial reemplazado por `-`. El `/` inicial se convierte en un `-` inicial. La codificación tiene pérdida - caracteres especiales consecutivos y espacios adyacentes a barras se convierten ambos en `-`, así que el original no siempre puede reconstruirse perfectamente.

### Registro de observabilidad paralela: `~/.claude/homunculus/`

Un sistema separado que rastrea eventos a nivel de herramienta por proyecto. No es parte del historial principal de Claude Code - parece ser una capa de monitoreo/aprendizaje.

- `projects.json` - registro de todos los proyectos conocidos, indexado por UUID hexadecimal corto (`d6b3aef60967`, etc.). Cada entrada tiene: `id`, `name`, `root` (ruta absoluta), `remote`, `created_at`, `last_seen`.
- `projects/<uuid>/project.json` - metadatos por proyecto (mismos campos que la entrada del registro).
- `projects/<uuid>/observations.jsonl` - eventos `tool_start`/`tool_complete` con marca de tiempo: nombre de herramienta, UUID de sesión, nombre/id de proyecto, fragmentos de entrada/salida.
- `projects/<uuid>/instincts` - patrones derivados (contenido desconocido, probablemente calculado).
- `projects/<uuid>/evolved` - estado evolucionado/aprendido (contenido desconocido).
- `projects/<uuid>/observations.archive` - observaciones anteriores archivadas.

**Diferencia clave con `~/.claude/projects/`:** Usa UUIDs hexadecimales cortos como claves, no rutas codificadas. El campo `root` contiene la ruta absoluta. Cualquier operación que cambie la ruta de un proyecto (renombrar, mover) debe actualizar `root` tanto en `projects.json` como en `projects/<uuid>/project.json`.

### Configuración global: `~/.claude/settings.json`

Archivo principal de configuración de Claude Code. Se escriben backups progresivos en `~/.claude/backups/` como `~/.claude.json.backup.<timestamp>` - varios por hora durante uso activo. claude-mux no debe tocar este archivo.

### Agentes, skills y comandos globales

- `~/.claude/agents/` - definiciones de subagentes (archivos `.md`, ~38). Globales, no por proyecto.
- `~/.claude/skills/` - directorios de skills (~125). Globales, no por proyecto.
- `~/.claude/commands/` - definiciones de comandos slash (archivos `.md`, ~72). Globales, no por proyecto.
- `~/.claude/hooks/hooks.json` - definiciones de hooks. Globales. claude-mux no debe tocar estos.

### Posibles funcionalidades futuras

| Funcionalidad | Qué modificar |
|--------------|---------------|
| `--copy` | Crear directorio; iniciar+detener sesión para inicializar ambos registros; copiar `.jsonl` + `memory/` + subdirectorios UUID; copiar archivos de observación de homunculus a la nueva carpeta UUID |
| Limpieza de `--delete` | Ya mueve la carpeta del proyecto a la papelera. Opcionalmente: eliminar carpeta huérfana de `~/.claude/projects/` codificada y entrada de `~/.claude/homunculus/` |
| Advertencia de tamaño de historial | Alertar cuando los archivos `.jsonl` de un proyecto excedan un umbral (la transcripción principal de claude-mux alcanzó 107MB en una sola sesión larga) |
