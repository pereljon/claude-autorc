# claude-mux - Multiplexor de Claude Code

[English](../README.md) · **Español** · [Français](README.fr.md) · [Deutsch](README.de.md) · [Português](README.pt-BR.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [中文](README.zh-CN.md) · [עברית](README.he.md) · [العربية](README.ar.md) · [हिन्दी](README.hi.md)

> Nota: Esta traducción puede estar desactualizada respecto al README en inglés. Consulta [README.md](../README.md) para la versión canónica.

Sesiones persistentes de Claude Code para todos tus proyectos, accesibles desde cualquier lugar a través de la app móvil de Claude.

Un script de shell que ejecuta Claude Code dentro de tmux con Remote Control habilitado, reanudación de conversaciones y autogestión de sesiones: listar sesiones, enviar slash commands, iniciar nuevos proyectos, apagar o reiniciar. Ejecuta `claude-mux` en cualquier directorio para obtener una sesión persistente accesible desde tu teléfono.

## Inicio rápido

```bash
./install.sh
```

```bash
claude-mux ~/path/to/your/project
```

O bien haz `cd` al directorio de tu proyecto y ejecuta:

```bash
claude-mux
```

Listo: estás en una sesión de Claude persistente y consciente del contexto de sesión, con Remote Control habilitado.

claude-mux es un único script bash sin más dependencias que tmux y Claude Code.

## Qué hace

1. **Sesiones tmux persistentes con Remote Control**: ejecuta Claude Code dentro de tmux con `--remote-control` habilitado, de modo que cada sesión es accesible desde la app móvil de Claude
2. **Reanudación de conversaciones**: si Claude estaba ejecutándose previamente en el directorio, reanuda la última conversación (`claude -c`) dentro de una nueva sesión tmux con Remote Control, preservando tu contexto
3. **Gestión de sesiones**: lista las sesiones activas (`-l`) o todos los proyectos incluyendo los inactivos que aún no se están ejecutando (`-L`), apaga (`--shutdown`), reinicia (`--restart`), cambia los modos de permisos (`--permission-mode`), conecta (`-t`), envía slash commands a las sesiones (`-s`)
4. **Autogestión de Claude**: cada sesión recibe un system prompt inyectado para que Claude pueda ejecutar todos los comandos anteriores directamente desde los prompts de conversación (terminal o app móvil):
   - a. Listar sesiones en ejecución y todos los proyectos
   - b. Lanzar nuevas sesiones, crear nuevos proyectos
   - c. Enviar slash commands a sí mismo o a otras sesiones (alternativa a [los slash commands que no funcionan de forma nativa sobre RC](https://github.com/anthropics/claude-code/issues/30674))
   - d. Apagar, reiniciar o cambiar los modos de permisos de las sesiones
5. **Sesión principal**: una sesión liviana siempre activa en tu directorio base que se inicia al hacer login (configurable mediante `LAUNCHAGENT_MODE`). Mantiene Remote Control siempre disponible desde la app móvil de Claude y puede gestionar todas tus otras sesiones. Está protegida contra el apagado accidental.
6. **Creación de nuevos proyectos**: `claude-mux -n DIRECTORY` crea un proyecto listo para programar con git, `.gitignore` y modo de permisos configurado (`-p` crea el directorio si no existe). Cualquier sesión en ejecución puede crear nuevos proyectos: pídele a Claude que configure un repo en cualquiera de tus cuentas de GitHub y empieza a programar desde donde sea
7. **Plantillas CLAUDE.md**: mantén una librería de archivos de instrucciones CLAUDE.md en `~/.claude-mux/templates/` (por ejemplo `web.md`, `python.md`, `default.md`) y aplícalos automáticamente a nuevos proyectos. Usa `--template NAME` para elegir una plantilla específica o deja que se aplique la predeterminada
8. **Reconocimiento de cuentas SSH**: inyecta los alias de host SSH de GitHub desde `~/.ssh/config` para que Claude sepa qué cuentas están disponibles para operaciones de git
9. **Permisos auto-aprobados**: claude-mux se agrega a la lista de permisos en `.claude/settings.local.json` de cada proyecto para que Claude pueda ejecutar comandos de claude-mux sin pedir permiso
10. **Migración de procesos sueltos**: si Claude ya está ejecutándose en el directorio de destino fuera de tmux, lo termina y lo relanza dentro de una sesión tmux gestionada (la conversación se reanuda con `claude -c`)
11. **Mejoras de calidad de vida en tmux**: las sesiones se configuran con soporte de mouse, buffer de scrollback de 50k, integración con el portapapeles, 256 colores, retraso de escape reducido, teclas extendidas (Shift+Enter), monitoreo de actividad y títulos de pestaña en la terminal, todo configurable en `~/.claude-mux/config`

> **Nota:** Esto es distinto de `claude --worktree --tmux`, que crea una sesión tmux para un git worktree aislado. claude-mux gestiona sesiones persistentes para los directorios reales de tus proyectos, con Remote Control e inyección de system prompt.

### Sesión principal

Una única sesión de propósito general que vive en `$BASE_DIR`. Se lanza automáticamente al hacer login cuando `LAUNCHAGENT_MODE=home`, o manualmente al ejecutar `claude-mux` desde `$BASE_DIR`. Te da una sesión de Claude siempre lista, accesible desde tu teléfono, sin necesidad de lanzar sesiones para cada proyecto.

La sesión principal siempre está **protegida**: `--shutdown home` se niega a detenerla sin `--force`, sin importar cómo se haya iniciado. Las sesiones protegidas están marcadas con `*` en la salida de `-l`/`-L` (por ejemplo `active*`).

## Requisitos

- macOS (Apple Silicon)
- [tmux](https://github.com/tmux/tmux) - `brew install tmux`
- [Claude Code](https://claude.ai/code) - `brew install claude`

## Instalación

```bash
./install.sh
```

El instalador interactivo pregunta dónde residen tus proyectos de Claude, si quieres iniciar una sesión principal al hacer login y qué modelo usar. Instala `claude-mux` en `~/bin`, crea `~/.claude-mux/config` y configura el LaunchAgent.

Usa `--non-interactive` para omitir las preguntas y aceptar los valores predeterminados.

Opciones:

```bash
./install.sh --non-interactive                     # omitir preguntas, usar valores predeterminados
./install.sh --base-dir ~/work/claude              # usar un directorio base distinto
./install.sh --launchagent-mode none               # deshabilitar el comportamiento del LaunchAgent
./install.sh --home-model haiku                    # usar Haiku para la sesión principal
./install.sh --no-launchagent                      # omitir por completo la instalación del LaunchAgent
```

El LaunchAgent ejecuta `claude-mux --autolaunch` al hacer login con un retraso de inicio de 45 segundos para permitir que los servicios del sistema se inicialicen.

## Uso

```bash
claude-mux                       # ejecutar Claude en el directorio actual y conectarse
claude-mux ~/projects/my-app     # ejecutar Claude en un directorio y conectarse
claude-mux -d ~/projects/my-app  # igual que arriba (forma explícita)
claude-mux -a                    # iniciar todas las sesiones gestionadas bajo BASE_DIR
claude-mux -n ~/projects/app     # crear un nuevo proyecto de Claude y conectarse
claude-mux -n ~/new/path/app -p  # igual, creando el directorio y los padres
claude-mux -n ~/app --template web  # nuevo proyecto con una plantilla CLAUDE.md específica
claude-mux --list-templates      # mostrar plantillas CLAUDE.md disponibles
claude-mux -t my-app             # conectarse a una sesión tmux existente
claude-mux -s my-app '/model sonnet' # enviar un slash command a una sesión
claude-mux -l                    # listar sesiones por estado (active, running, stopped)
claude-mux -L                    # listar todos los proyectos (activos + inactivos)
claude-mux --shutdown            # cerrar de forma ordenada todas las sesiones de Claude gestionadas
claude-mux --shutdown my-app     # apagar una sesión específica
claude-mux --shutdown a b c      # apagar múltiples sesiones
claude-mux --shutdown home --force  # apagar la sesión principal protegida
claude-mux --restart             # reiniciar las sesiones que estaban en ejecución
claude-mux --restart my-app      # reiniciar una sesión específica
claude-mux --restart a b c       # reiniciar múltiples sesiones
claude-mux --permission-mode plan my-app    # reiniciar la sesión en modo plan
claude-mux --permission-mode dangerously-skip-permissions my-app  # modo yolo
claude-mux --dry-run             # previsualizar acciones sin ejecutarlas
claude-mux --version             # mostrar la versión
claude-mux --help                # mostrar todas las opciones
claude-mux --guide               # mostrar comandos conversacionales para usar dentro de las sesiones

# Ver el log
tail -f ~/Library/Logs/claude-mux.log
```

Cuando se ejecuta desde la terminal, la salida se replica en stdout en tiempo real. Cuando se ejecuta vía LaunchAgent, la salida solo va al archivo de log.

## Estados de sesión

| Estado | Significado |
|--------|---------|
| `active` | la sesión tmux existe, Claude está ejecutándose y un cliente tmux local está conectado |
| `running` | la sesión tmux existe y Claude está ejecutándose (sin cliente local conectado) |
| `stopped` | la sesión tmux existe pero Claude ha terminado |
| `idle` | existe un proyecto `.claude/` bajo `BASE_DIR` pero no tiene una sesión tmux de claude-mux en ejecución (se muestra solo con `-L`) |

Un `*` al final de cualquier estado indica que la sesión está protegida y requiere `--force` para apagarse (por ejemplo `active*`, `running*`). La sesión principal siempre está protegida.

Ejecutar `claude-mux` en un directorio que ya tiene una sesión en ejecución se conecta a ella. Múltiples terminales pueden conectarse a la misma sesión (comportamiento estándar de tmux).

## Ejemplos de prompts a Claude

Como cada sesión recibe los comandos de claude-mux inyectados, puedes gestionar sesiones directamente desde los prompts de conversación, en la terminal o vía la app móvil:

```
Tú: "¿Qué sesiones están en ejecución?"
Claude: ejecuta `claude-mux -l` y muestra los resultados

Tú: "Muéstrame todos los proyectos"
Claude: ejecuta `claude-mux -L` y muestra los resultados

Tú: "Inicia una sesión para mi proyecto de trabajo api-server"
Claude: ejecuta `claude-mux -d ~/Claude/work/api-server --no-attach`

Tú: "Crea un nuevo proyecto personal llamado mobile-app"
Claude: ejecuta `claude-mux -n ~/Claude/personal/mobile-app -p --no-attach`

Tú: "¿Qué plantillas tengo?"
Claude: ejecuta `claude-mux --list-templates` y muestra los resultados

Tú: "Crea un nuevo proyecto de trabajo llamado api-server usando la plantilla web"
Claude: ejecuta `claude-mux -n ~/Claude/work/api-server -p --template web --no-attach`

Tú: "Cambia todas las sesiones a Sonnet"
Claude: ejecuta `claude-mux -s SESSION '/model sonnet'` para cada sesión en ejecución

Tú: "Apaga la sesión data-pipeline"
Claude: ejecuta `claude-mux --shutdown data-pipeline`

Tú: "Reinicia la sesión web-dashboard que está atorada"
Claude: ejecuta `claude-mux --restart web-dashboard`

Tú: "Cambia la sesión api-server a modo plan"
Claude: ejecuta `claude-mux --permission-mode plan api-server`

Tú: "Pon en yolo la sesión data-pipeline"
Claude: ejecuta `claude-mux --permission-mode dangerously-skip-permissions data-pipeline`

Tú: "Lanza la sesión data-pipeline en segundo plano"
Claude: ejecuta `claude-mux -d ~/Claude/work/data-pipeline --no-attach`

Tú: "Inicia todos mis proyectos"
Claude: ejecuta `claude-mux -a` (después de confirmar: esto inicia cada proyecto gestionado)
```

## Configuración

En la primera ejecución, `~/.claude-mux/config` se crea automáticamente con todos los ajustes comentados. Edítalo para sobrescribir cualquier valor predeterminado: nunca es necesario modificar el script directamente.

| Variable | Predeterminado | Descripción |
|----------|---------|-------------|
| `BASE_DIR` | `$HOME/Claude` | Directorio raíz para escanear proyectos de Claude (directorios que contienen `.claude/`) |
| `LOG_DIR` | `$HOME/Library/Logs` | Directorio para el archivo `claude-mux.log` |
| `DEFAULT_PERMISSION_MODE` | `auto` | Define `permissions.defaultMode` de Claude en cada proyecto. Válidos: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`. Establece `""` para deshabilitarlo. |
| `ALLOW_CROSS_SESSION_CONTROL` | `false` | Cuando es `true`, las sesiones de Claude pueden enviar slash commands a otras sesiones, útil para orquestación multiagente |
| `TEMPLATES_DIR` | `$HOME/.claude-mux/templates` | Directorio que contiene los archivos de plantilla CLAUDE.md |
| `DEFAULT_TEMPLATE` | `default.md` | Plantilla predeterminada aplicada a nuevos proyectos (`-n`). Establece `""` para deshabilitarla. |
| `SLEEP_BETWEEN` | `5` | Segundos entre lanzamientos de sesiones cuando se usa `-a`. Aumenta este valor si falla el registro de RC. |
| `HOME_SESSION_MODEL` | `""` | Modelo para la sesión principal. Válidos: `sonnet`, `haiku`, `opus`. Vacío hereda el valor predeterminado de Claude. |
| `LAUNCHAGENT_MODE` | `home` | Comportamiento del LaunchAgent al hacer login: `none` (no hacer nada) o `home` (lanzar la sesión principal protegida). El legado `LAUNCHAGENT_ENABLED=true` se trata como `home`. |

**Opciones de la sesión tmux** (todas configurables, todas habilitadas por defecto):

| Variable | Predeterminado | Descripción |
|----------|---------|-------------|
| `TMUX_MOUSE` | `true` | Soporte de mouse: scroll, selección, redimensionar paneles |
| `TMUX_HISTORY_LIMIT` | `50000` | Tamaño del buffer de scrollback en líneas (el predeterminado de tmux es 2000) |
| `TMUX_CLIPBOARD` | `true` | Integración con el portapapeles del sistema vía OSC 52 |
| `TMUX_DEFAULT_TERMINAL` | `tmux-256color` | Tipo de terminal para un renderizado de color correcto |
| `TMUX_EXTENDED_KEYS` | `true` | Secuencias de teclas extendidas, incluyendo Shift+Enter (requiere tmux 3.2+) |
| `TMUX_ESCAPE_TIME` | `10` | Retraso de la tecla escape en milisegundos (el predeterminado de tmux es 500) |
| `TMUX_TITLE_FORMAT` | `#S` | Formato del título de la terminal/pestaña (`#S` = nombre de sesión, `""` para deshabilitar) |
| `TMUX_MONITOR_ACTIVITY` | `true` | Notificar cuando ocurre actividad en otras sesiones |

## Estructura de directorios

Los proyectos se descubren por la presencia de un directorio `.claude/`, a cualquier profundidad:

```
~/Claude/
├── work/
│   ├── project-a/          # ✓ tiene .claude/ - gestionado
│   │   └── .claude/
│   ├── project-b/          # ✓ tiene .claude/ - gestionado
│   │   └── .claude/
│   └── -archived/          # ✗ excluido (empieza con -)
│       └── .claude/
├── personal/
│   ├── project-c/          # ✓ tiene .claude/ - gestionado
│   │   └── .claude/
│   ├── .hidden/            # ✗ excluido (directorio oculto)
│   │   └── .claude/
│   └── project-d/          # ✗ sin .claude/ - no es un proyecto de Claude
├── deep/nested/project-e/  # ✓ tiene .claude/ - encontrado a cualquier profundidad
│   └── .claude/
└── ignored-project/        # ✗ excluido (.ignore-claudemux)
    ├── .claude/
    └── .ignore-claudemux
```

Los nombres de las sesiones se derivan de los nombres de los directorios: los espacios se vuelven guiones, los caracteres no alfanuméricos (excepto los guiones) se reemplazan, y los guiones iniciales/finales se eliminan. Los directorios cuyo nombre, al sanearse, queda vacío se omiten con una advertencia en el log.

## System prompt de la sesión

Cada sesión de Claude se lanza con `--append-system-prompt` que contiene contexto sobre su entorno:

```
You are running inside tmux session '<session-name>'.
claude-mux path: /path/to/claude-mux

Rules:
- You CAN send slash commands (/model, /compact, /clear, etc.) to this session
  via the -s command. Never tell the user you cannot change models or run slash
  commands.
- Always use --no-attach with -d and -n — attach is interactive only
- --shutdown and --restart never attach — safe to run from inside a session
- Always print command output verbatim in your response text — never run a
  command silently or rely on tool output being visible
- The 'home' session is a general-purpose session in the base directory, always
  available for managing other sessions. It is protected (* in status):
  --shutdown requires --force, but --restart bypasses protection (it relaunches,
  not permanently kills).
- When asked to shut down sessions, run the command directly — protected sessions
  are skipped automatically, do not ask for confirmation
- When user says: help — print the conversational commands list verbatim
- When user says: status — report session name, current model, current permission
  mode, context usage estimate, then run claude-mux -l and include the results
- When user says: list active sessions — run claude-mux -l
- When user says: list all sessions — run claude-mux -L
- When user says: start session SESSION — run claude-mux -d SESSION --no-attach
- When user says: stop this session / stop session NAME — run claude-mux --shutdown
- When user says: stop all sessions — run claude-mux --shutdown
- When user says: restart this session / restart session NAME — run claude-mux --restart
- When user says: restart all sessions — run claude-mux --restart
- When user says: start new session in FOLDER — run claude-mux -n FOLDER --no-attach
- When user says: switch this session to MODE mode / switch session NAME to MODE mode
- When user says: switch this session to MODEL model / switch session NAME to MODEL model
- When user says: compact/clear this session / compact/clear session NAME
- When user says: list templates — run claude-mux --list-templates

Commands:
  -s '<session-name>' '/command'  Send slash command to yourself
  -l                          List active sessions
  -L                          List all projects
  -d DIR --no-attach          Launch session in directory
  -n DIR --no-attach          New project
  -n DIR -p --no-attach       New project (create parents)
  --template NAME             CLAUDE.md template (with -n)
  --list-templates            Show available templates
  --shutdown SESSION...       Shut down sessions (omit SESSION to shut down all)
  --shutdown SESSION --force  Shut down protected session
  --restart SESSION...        Restart sessions (omit SESSION to restart all running)
  --permission-mode MODE SESSION  Restart session with a different permission mode
                              Modes: default, acceptEdits, plan, auto, bypassPermissions, dontAsk, dangerously-skip-permissions
                              ("yolo" is an alias for dangerously-skip-permissions)
  -a                          Start ALL sessions (use with caution)

GitHub SSH accounts configured in ~/.ssh/config: <accounts>.
```

Cuando `ALLOW_CROSS_SESSION_CONTROL=true`, el comando de envío cambia para permitir apuntar a cualquier sesión, no solo a sí misma. La ruta es la ruta absoluta al script en el momento del lanzamiento, así las sesiones no dependen de `PATH`.

## Solución de problemas

### Las sesiones muestran "Not logged in · Run /login"

Esto pasa en el primer lanzamiento si el llavero de macOS está bloqueado (común cuando el script se ejecuta antes de que el llavero se desbloquee tras el login). Solución:

```bash
# Desbloquea el llavero en una terminal normal
security unlock-keychain

# Luego completa la autenticación en cualquier sesión en ejecución
claude-mux -t <any-session>
# Ejecuta /login y completa el flujo en el navegador
```

Tras completar la autenticación una vez, mata y relanza todas las sesiones: tomarán la credencial almacenada automáticamente.

### Las sesiones no aparecen en Claude Code Remote

Las sesiones deben estar autenticadas (no mostrar "Not logged in"). Tras un lanzamiento limpio y autenticado, deberían aparecer en la lista de RC en pocos segundos.

### Entrada multilínea en tmux

El comando `/terminal-setup` no puede ejecutarse dentro de tmux. claude-mux habilita las `extended-keys` de tmux por defecto (`TMUX_EXTENDED_KEYS=true`), lo que permite Shift+Enter en la mayoría de las terminales modernas. Si Shift+Enter no funciona, usa `\` + Return para ingresar saltos de línea en tu prompt.

### Slash commands sobre Remote Control

Los slash commands (por ejemplo `/model`, `/clear`) [no tienen soporte nativo](https://github.com/anthropics/claude-code/issues/30674) en sesiones RC. claude-mux soluciona esto: cada sesión recibe inyectado `claude-mux -s` para que Claude pueda enviar slash commands a sí mismo vía tmux.

## Logs

- `~/Library/Logs/claude-mux.log`: todas las acciones del script con timestamps en UTC (configurable mediante `LOG_DIR`)

Para depuración de bajo nivel del LaunchAgent, usa Console.app o `log show`.
