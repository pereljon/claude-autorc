# claude-mux - מולטיפלקסר ל-Claude Code

[English](../README.md) · [Español](README.es.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Português](README.pt-BR.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [中文](README.zh-CN.md) · **עברית** · [العربية](README.ar.md) · [हिन्दी](README.hi.md)

> הערה: תרגום זה עשוי להיות מאחור ביחס ל-README באנגלית. ראו [README.md](../README.md) לגרסה הקנונית.

סשנים מתמשכים של Claude Code לכל הפרויקטים שלך - נגישים מכל מקום דרך אפליקציית Claude לנייד.

סקריפט shell שמפעיל את Claude Code בתוך tmux עם Remote Control מופעל, חידוש שיחות וניהול עצמי של סשנים - הצגת סשנים, שליחת פקודות slash, יצירת פרויקטים חדשים, כיבוי או הפעלה מחדש. הרץ `claude-mux` בכל ספרייה כדי לקבל סשן מתמשך הנגיש מהטלפון שלך.

## התחלה מהירה

```bash
./install.sh
```

```bash
claude-mux ~/path/to/your/project
```

או `cd` לספריית הפרויקט שלך והרץ:

```bash
claude-mux
```

זהו - אתה בתוך סשן Claude מתמשך ומודע-לסשן עם Remote Control מופעל.

claude-mux הוא סקריפט bash בודד ללא תלויות מעבר ל-tmux ו-Claude Code.

## מה זה עושה

1. **סשני tmux מתמשכים עם Remote Control** - מפעיל את Claude Code בתוך tmux עם `--remote-control` מופעל, כך שכל סשן נגיש מאפליקציית Claude לנייד
2. **חידוש שיחות** - אם Claude רץ בעבר בספרייה, מחדש את השיחה האחרונה (`claude -c`) בתוך סשן tmux חדש עם Remote Control, תוך שמירה על ההקשר שלך
3. **ניהול סשנים** - הצגת סשנים פעילים (`-l`) או כל הפרויקטים כולל אלה שלא רצים עדיין (`-L`), כיבוי (`--shutdown`), הפעלה מחדש (`--restart`), החלפת מצבי הרשאות (`--permission-mode`), חיבור (`-t`), שליחת פקודות slash לסשנים (`-s`)
4. **ניהול עצמי של Claude** - לכל סשן מוזרק system prompt כך ש-Claude יכול להריץ את כל הפקודות הנ"ל ישירות מתוך הנחיות שיחה (טרמינל או אפליקציית נייד):
   - א. הצגת סשנים פעילים וכל הפרויקטים
   - ב. הפעלת סשנים חדשים, יצירת פרויקטים חדשים
   - ג. שליחת פקודות slash לעצמו או לסשנים אחרים (פתרון עוקף ל-[פקודות slash שלא עובדות באופן מקורי דרך RC](https://github.com/anthropics/claude-code/issues/30674))
   - ד. כיבוי, הפעלה מחדש, או החלפת מצבי הרשאות של סשנים
5. **סשן הבית** - סשן קל-משקל שתמיד רץ בספריית הבסיס שלך, מופעל בכניסה למערכת (ניתן להגדרה דרך `LAUNCHAGENT_MODE`). שומר על Remote Control זמין תמיד מאפליקציית Claude לנייד ויכול לנהל את כל הסשנים האחרים שלך. מוגן מפני כיבוי בטעות.
6. **יצירת פרויקט חדש** - `claude-mux -n DIRECTORY` יוצר פרויקט מוכן-לקידוד עם git, `.gitignore`, ומצב הרשאות מוגדר (`-p` יוצר את הספרייה אם אינה קיימת). כל סשן רץ יכול ליצור פרויקטים חדשים - בקש מ-Claude להגדיר ריפו בכל אחד מחשבונות ה-GitHub שלך ולהתחיל לקודד, מכל מקום
7. **תבניות CLAUDE.md** - שמור ספריית קבצי הוראות CLAUDE.md ב-`~/.claude-mux/templates/` (למשל `web.md`, `python.md`, `default.md`) והחל אותן אוטומטית על פרויקטים חדשים. השתמש ב-`--template NAME` לבחירת תבנית ספציפית או תן לברירת המחדל לחול
8. **מודעות לחשבונות SSH** - מזריק כינויי GitHub SSH host מ-`~/.ssh/config` כך ש-Claude יודע אילו חשבונות זמינים לפעולות git
9. **הרשאות מאושרות אוטומטית** - claude-mux מוסיף את עצמו לרשימת ההיתר של `.claude/settings.local.json` של כל פרויקט כך ש-Claude יכול להריץ פקודות claude-mux ללא בקשת הרשאה
10. **העברת תהליכים תועים** - אם Claude כבר רץ בספרייה היעד מחוץ ל-tmux, מסיים אותו ומפעיל מחדש בתוך סשן tmux מנוהל (השיחה מתחדשת דרך `claude -c`)
11. **שיפורי איכות חיים של Tmux** - סשנים מוגדרים עם תמיכת עכבר, מאגר scrollback של 50k, אינטגרציית clipboard, 256-color, השהיית escape מופחתת, מקשים מורחבים (Shift+Enter), ניטור פעילות, וכותרות טאב של טרמינל - הכול ניתן להגדרה ב-`~/.claude-mux/config`

> **הערה:** זה שונה מ-`claude --worktree --tmux`, שיוצר סשן tmux ל-git worktree מבודד. claude-mux מנהל סשנים מתמשכים לספריות הפרויקט הממשיות שלך, עם Remote Control והזרקת system prompt.

### סשן הבית

סשן בודד לשימוש כללי שגר ב-`$BASE_DIR`. מופעל אוטומטית בכניסה למערכת כאשר `LAUNCHAGENT_MODE=home`, או ידנית על ידי הרצת `claude-mux` מ-`$BASE_DIR`. נותן לך סשן Claude אחד תמיד-מוכן הנגיש מהטלפון שלך מבלי להפעיל סשנים לכל פרויקט.

סשן הבית הוא תמיד **מוגן** - `--shutdown home` מסרב לעצור אותו ללא `--force`, ללא תלות בדרך שבה הופעל. סשנים מוגנים מסומנים ב-`*` בפלט של `-l`/`-L` (למשל `active*`).

## דרישות

- macOS (Apple Silicon)
- [tmux](https://github.com/tmux/tmux) - `brew install tmux`
- [Claude Code](https://claude.ai/code) - `brew install claude`

## התקנה

```bash
./install.sh
```

המתקין האינטראקטיבי שואל היכן ממוקמים פרויקטי Claude שלך, האם להפעיל סשן בית בכניסה למערכת, ובאיזה מודל להשתמש. הוא מתקין את `claude-mux` ל-`~/bin`, יוצר את `~/.claude-mux/config`, ומגדיר את ה-LaunchAgent.

השתמש ב-`--non-interactive` כדי לדלג על הנחיות ולקבל ברירות מחדל.

אפשרויות:

```bash
./install.sh --non-interactive                     # skip prompts, use defaults
./install.sh --base-dir ~/work/claude              # use a different base directory
./install.sh --launchagent-mode none               # disable LaunchAgent behavior
./install.sh --home-model haiku                    # use Haiku for home session
./install.sh --no-launchagent                      # skip LaunchAgent installation entirely
```

ה-LaunchAgent מריץ את `claude-mux --autolaunch` בכניסה למערכת עם השהיית הפעלה של 45 שניות כדי לאפשר לשירותי המערכת להתאתחל.

## שימוש

```bash
claude-mux                       # launch Claude in current directory and attach
claude-mux ~/projects/my-app     # launch Claude in a directory and attach
claude-mux -d ~/projects/my-app  # same as above (explicit form)
claude-mux -a                    # start all managed sessions under BASE_DIR
claude-mux -n ~/projects/app     # create a new Claude project and attach
claude-mux -n ~/new/path/app -p  # same, creating the directory and parents
claude-mux -n ~/app --template web  # new project with a specific CLAUDE.md template
claude-mux --list-templates      # show available CLAUDE.md templates
claude-mux -t my-app             # attach to an existing tmux session
claude-mux -s my-app '/model sonnet' # send a slash command to a session
claude-mux -l                    # list sessions by status (active, running, stopped)
claude-mux -L                    # list all projects (active + idle)
claude-mux --shutdown            # gracefully exit all managed Claude sessions
claude-mux --shutdown my-app     # shut down a specific session
claude-mux --shutdown a b c      # shut down multiple sessions
claude-mux --shutdown home --force  # shut down protected home session
claude-mux --restart             # restart sessions that were running
claude-mux --restart my-app      # restart a specific session
claude-mux --restart a b c       # restart multiple sessions
claude-mux --permission-mode plan my-app    # restart session with plan mode
claude-mux --permission-mode dangerously-skip-permissions my-app  # yolo mode
claude-mux --dry-run             # preview actions without executing
claude-mux --version             # print version
claude-mux --help                # show all options
claude-mux --guide               # show conversational commands for use within sessions

# Watch the log
tail -f ~/Library/Logs/claude-mux.log
```

כשהוא מורץ מהטרמינל, הפלט משתקף ל-stdout בזמן אמת. כשמורץ דרך LaunchAgent, הפלט מועבר רק לקובץ ה-log.

## סטטוסי סשן

| סטטוס | משמעות |
|--------|---------|
| `active` | סשן tmux קיים, Claude רץ, ו-tmux client מקומי מחובר |
| `running` | סשן tmux קיים ו-Claude רץ (ללא client מקומי מחובר) |
| `stopped` | סשן tmux קיים אך Claude יצא |
| `idle` | פרויקט `.claude/` קיים תחת `BASE_DIR` אך אין לו סשן tmux של claude-mux רץ (מוצג רק עם `-L`) |

`*` נגררת על כל סטטוס מציינת שהסשן מוגן ודורש `--force` כדי לכבותו (למשל `active*`, `running*`). סשן הבית הוא תמיד מוגן.

הרצת `claude-mux` בספרייה שכבר יש לה סשן רץ מחברת אליו. ניתן לחבר טרמינלים מרובים לאותו סשן (התנהגות tmux סטנדרטית).

## דוגמאות הנחיה ל-Claude

מכיוון שלכל סשן מוזרקות פקודות claude-mux, אתה יכול לנהל סשנים ישירות מהנחיות שיחה - בטרמינל או דרך אפליקציית הנייד:

```
You: "What sessions are running?"
Claude: runs `claude-mux -l` and displays the results

You: "Show me all projects"
Claude: runs `claude-mux -L` and displays the results

You: "Start a session for my api-server work project"
Claude: runs `claude-mux -d ~/Claude/work/api-server --no-attach`

You: "Create a new personal project called mobile-app"
Claude: runs `claude-mux -n ~/Claude/personal/mobile-app -p --no-attach`

You: "What templates do I have?"
Claude: runs `claude-mux --list-templates` and displays the results

You: "Create a new work project called api-server using the web template"
Claude: runs `claude-mux -n ~/Claude/work/api-server -p --template web --no-attach`

You: "Switch all sessions to Sonnet"
Claude: runs `claude-mux -s SESSION '/model sonnet'` for each running session

You: "Shut down the data-pipeline session"
Claude: runs `claude-mux --shutdown data-pipeline`

You: "Restart the stuck web-dashboard session"
Claude: runs `claude-mux --restart web-dashboard`

You: "Switch the api-server session to plan mode"
Claude: runs `claude-mux --permission-mode plan api-server`

You: "Yolo the data-pipeline session"
Claude: runs `claude-mux --permission-mode dangerously-skip-permissions data-pipeline`

You: "Launch the data-pipeline session in the background"
Claude: runs `claude-mux -d ~/Claude/work/data-pipeline --no-attach`

You: "Start all my projects"
Claude: runs `claude-mux -a` (after confirming - this starts every managed project)
```

## הגדרות

בהרצה ראשונה, `~/.claude-mux/config` נוצר אוטומטית עם כל ההגדרות מסומנות בתור הערות. ערוך אותו כדי לעקוף ברירות מחדל - הסקריפט עצמו אף פעם לא צריך להיות שונה ישירות.

| משתנה | ברירת מחדל | תיאור |
|----------|---------|-------------|
| `BASE_DIR` | `$HOME/Claude` | ספריית שורש לסריקה של פרויקטי Claude (ספריות המכילות `.claude/`) |
| `LOG_DIR` | `$HOME/Library/Logs` | ספרייה לקובץ `claude-mux.log` |
| `DEFAULT_PERMISSION_MODE` | `auto` | הגדרת `permissions.defaultMode` של Claude בכל פרויקט. ערכים תקפים: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`. הגדר ל-`""` כדי להשבית. |
| `ALLOW_CROSS_SESSION_CONTROL` | `false` | כאשר `true`, סשני Claude יכולים לשלוח פקודות slash לסשנים אחרים - שימושי לתזמור מולטי-סוכן |
| `TEMPLATES_DIR` | `$HOME/.claude-mux/templates` | ספרייה המכילה קבצי תבנית CLAUDE.md |
| `DEFAULT_TEMPLATE` | `default.md` | תבנית ברירת מחדל המוחלת על פרויקטים חדשים (`-n`). הגדר ל-`""` כדי להשבית. |
| `SLEEP_BETWEEN` | `5` | שניות בין הפעלות סשנים כאשר `-a` בשימוש. הגדל אם רישום RC נכשל. |
| `HOME_SESSION_MODEL` | `""` | מודל לסשן הבית. ערכים תקפים: `sonnet`, `haiku`, `opus`. ריק יורש את ברירת המחדל של Claude. |
| `LAUNCHAGENT_MODE` | `home` | התנהגות LaunchAgent בכניסה למערכת: `none` (לא לעשות כלום) או `home` (להפעיל סשן בית מוגן). `LAUNCHAGENT_ENABLED=true` ישן מטופל כ-`home`. |

**אפשרויות סשן Tmux** (כולן ניתנות להגדרה, כולן מופעלות כברירת מחדל):

| משתנה | ברירת מחדל | תיאור |
|----------|---------|-------------|
| `TMUX_MOUSE` | `true` | תמיכת עכבר - גלילה, בחירה, שינוי גודל panes |
| `TMUX_HISTORY_LIMIT` | `50000` | גודל מאגר scrollback בשורות (ברירת המחדל של tmux היא 2000) |
| `TMUX_CLIPBOARD` | `true` | אינטגרציית clipboard מערכת דרך OSC 52 |
| `TMUX_DEFAULT_TERMINAL` | `tmux-256color` | סוג טרמינל לעיבוד צבע נכון |
| `TMUX_EXTENDED_KEYS` | `true` | רצפי מקשים מורחבים כולל Shift+Enter (דורש tmux 3.2+) |
| `TMUX_ESCAPE_TIME` | `10` | השהיית מקש escape במילישניות (ברירת המחדל של tmux היא 500) |
| `TMUX_TITLE_FORMAT` | `#S` | פורמט כותרת טרמינל/טאב (`#S` = שם סשן, `""` כדי להשבית) |
| `TMUX_MONITOR_ACTIVITY` | `true` | התראה כאשר מתרחשת פעילות בסשנים אחרים |

## מבנה הספריות

פרויקטים מתגלים על ידי נוכחות של ספריית `.claude/`, בכל עומק:

```
~/Claude/
├── work/
│   ├── project-a/          # ✓ has .claude/ - managed
│   │   └── .claude/
│   ├── project-b/          # ✓ has .claude/ - managed
│   │   └── .claude/
│   └── -archived/          # ✗ excluded (starts with -)
│       └── .claude/
├── personal/
│   ├── project-c/          # ✓ has .claude/ - managed
│   │   └── .claude/
│   ├── .hidden/            # ✗ excluded (hidden directory)
│   │   └── .claude/
│   └── project-d/          # ✗ no .claude/ - not a Claude project
├── deep/nested/project-e/  # ✓ has .claude/ - found at any depth
│   └── .claude/
└── ignored-project/        # ✗ excluded (.ignore-claudemux)
    ├── .claude/
    └── .ignore-claudemux
```

שמות סשן נגזרים משמות ספריות: רווחים הופכים למקפים, תווים שאינם אלפא-נומריים (חוץ ממקפים) מוחלפים, ומקפים מובילים/נגררים מוסרים. ספריות ששמן עובר ניקוי לריק מדולגות עם אזהרת log.

## System Prompt של סשן

כל סשן Claude מופעל עם `--append-system-prompt` המכיל הקשר אודות הסביבה שלו:

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

כאשר `ALLOW_CROSS_SESSION_CONTROL=true`, פקודת השליחה משתנה כדי לאפשר מיקוד לכל סשן, לא רק לעצמו. הנתיב הוא הנתיב המוחלט לסקריפט בזמן ההפעלה, כך שסשנים אינם תלויים ב-`PATH`.

## פתרון תקלות

### סשנים מציגים "Not logged in · Run /login"

זה קורה בהפעלה ראשונה אם ה-keychain של macOS נעול (נפוץ כשהסקריפט רץ לפני שה-keychain פתוח לאחר הכניסה למערכת). תיקון:

```bash
# Unlock the keychain in a regular terminal
security unlock-keychain

# Then complete auth in any one running session
claude-mux -t <any-session>
# Run /login and complete the browser flow
```

לאחר השלמת אימות פעם אחת, הרוג והפעל מחדש את כל הסשנים - הם יקלטו את האישור המאוחסן אוטומטית.

### סשנים לא מופיעים ב-Claude Code Remote

סשנים חייבים להיות מאומתים (לא מציגים "Not logged in"). לאחר הפעלה מאומתת נקייה הם אמורים להופיע ברשימת ה-RC תוך כמה שניות.

### קלט מרובה-שורות ב-tmux

הפקודה `/terminal-setup` לא יכולה לרוץ בתוך tmux. claude-mux מפעיל את tmux `extended-keys` כברירת מחדל (`TMUX_EXTENDED_KEYS=true`), שתומך ב-Shift+Enter ברוב הטרמינלים המודרניים. אם Shift+Enter לא עובד, השתמש ב-`\` + Return כדי להזין שורות חדשות בהנחיה שלך.

### פקודות slash דרך Remote Control

פקודות slash (למשל `/model`, `/clear`) [אינן נתמכות באופן מקורי](https://github.com/anthropics/claude-code/issues/30674) בסשני RC. claude-mux עוקף זאת - לכל סשן מוזרק `claude-mux -s` כך ש-Claude יכול לשלוח פקודות slash לעצמו דרך tmux.

## לוגים

- `~/Library/Logs/claude-mux.log` - כל פעולות הסקריפט עם חותמות זמן UTC (ניתן להגדרה דרך `LOG_DIR`)

עבור דיבוג ברמה נמוכה של LaunchAgent, השתמש ב-Console.app או `log show`.
