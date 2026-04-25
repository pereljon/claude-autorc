# claude-mux - مُجمِّع جلسات Claude Code

[English](../README.md) · [Español](README.es.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Português](README.pt-BR.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [中文](README.zh-CN.md) · [עברית](README.he.md) · **العربية** · [हिन्दी](README.hi.md)

> ملاحظة: قد تكون هذه الترجمة متأخرة عن ملف README الإنجليزي. راجع [README.md](../README.md) للنسخة الأساسية.

جلسات Claude Code دائمة لجميع مشاريعك، يمكن الوصول إليها من أي مكان عبر تطبيق Claude للهاتف المحمول.

سكربت شِل يُشغِّل Claude Code داخل tmux مع تفعيل Remote Control واستئناف المحادثات والإدارة الذاتية للجلسات: عرض الجلسات، إرسال الأوامر المائلة، بدء مشاريع جديدة، إيقاف التشغيل أو إعادة التشغيل. شغِّل `claude-mux` في أي دليل للحصول على جلسة دائمة يمكن الوصول إليها من هاتفك.

## البدء السريع

```bash
./install.sh
```

```bash
claude-mux ~/path/to/your/project
```

أو انتقل بالأمر `cd` إلى دليل مشروعك ثم شغِّل:

```bash
claude-mux
```

هذا كل شيء — أنت الآن داخل جلسة Claude دائمة وواعية بذاتها مع تفعيل Remote Control.

claude-mux عبارة عن سكربت bash واحد لا يعتمد على أي شيء سوى tmux و Claude Code.

## ماذا يفعل

1. **جلسات tmux دائمة مع Remote Control** — يُشغِّل Claude Code داخل tmux مع تفعيل `--remote-control`، فتصبح كل جلسة قابلة للوصول من تطبيق Claude للهاتف المحمول
2. **استئناف المحادثة** — إذا كان Claude يعمل سابقًا في الدليل، يستأنف آخر محادثة (`claude -c`) داخل جلسة tmux جديدة مع Remote Control، مع الحفاظ على سياقك
3. **إدارة الجلسات** — عرض الجلسات النشطة (`-l`) أو جميع المشاريع بما فيها الخامِلة التي لم تعمل بعد (`-L`)، إيقاف التشغيل (`--shutdown`)، إعادة التشغيل (`--restart`)، تبديل أوضاع الأذونات (`--permission-mode`)، الإلحاق (`-t`)، إرسال أوامر مائلة إلى الجلسات (`-s`)
4. **إدارة Claude لذاته** — يُحقن في كل جلسة موجِّه نظام بحيث يستطيع Claude تشغيل جميع الأوامر السابقة مباشرةً من موجِّهات المحادثة (سواء من الطرفية أو من تطبيق الهاتف):
   - أ. عرض الجلسات قيد التشغيل وجميع المشاريع
   - ب. إطلاق جلسات جديدة، وإنشاء مشاريع جديدة
   - ج. إرسال أوامر مائلة إلى نفسه أو إلى جلسات أخرى (حلٌ بديل لمشكلة [عدم عمل الأوامر المائلة بشكل أصيل عبر RC](https://github.com/anthropics/claude-code/issues/30674))
   - د. إيقاف التشغيل أو إعادة التشغيل أو تبديل أوضاع الأذونات للجلسات
5. **الجلسة الرئيسية** — جلسة خفيفة الوزن تعمل دائمًا في دليلك الأساسي وتُطلق عند تسجيل الدخول (قابلة للضبط عبر `LAUNCHAGENT_MODE`). تُبقي Remote Control متاحًا دائمًا من تطبيق Claude للهاتف المحمول، ويمكنها إدارة جميع جلساتك الأخرى. محمية من الإيقاف العَرَضي.
6. **إنشاء مشروع جديد** — `claude-mux -n DIRECTORY` يُنشئ مشروعًا جاهزًا للبرمجة مع git و `.gitignore` ووضع الأذونات مضبوطًا (`-p` يُنشئ الدليل إن لم يكن موجودًا). أي جلسة قيد التشغيل يمكنها إنشاء مشاريع جديدة — اطلب من Claude إعداد مستودع على أي من حسابات GitHub الخاصة بك وابدأ البرمجة من أي مكان
7. **قوالب CLAUDE.md** — احتفظ بمكتبة من ملفات تعليمات CLAUDE.md في `~/.claude-mux/templates/` (مثل `web.md` و `python.md` و `default.md`) وطبِّقها تلقائيًا على المشاريع الجديدة. استخدم `--template NAME` لاختيار قالب محدد أو دع القالب الافتراضي يُطبَّق
8. **الوعي بحسابات SSH** — يحقن أسماء مضيفي GitHub البديلة عبر SSH من `~/.ssh/config` بحيث يعرف Claude الحسابات المتاحة لعمليات git
9. **أذونات معتمدة تلقائيًا** — يُضيف claude-mux نفسه إلى قائمة السماح في `.claude/settings.local.json` لكل مشروع، فيتمكن Claude من تشغيل أوامر claude-mux دون طلب الإذن
10. **ترحيل العمليات الشاردة** — إذا كان Claude يعمل في الدليل المستهدف خارج tmux، يُنهي العملية ويُعيد إطلاقها داخل جلسة tmux مُدارة (تُستأنف المحادثة عبر `claude -c`)
11. **تحسينات tmux لجودة الاستخدام** — تُهيَّأ الجلسات بدعم الفأرة، ومخزن تمرير سعته 50 ألف سطر، وتكامل الحافظة، وألوان 256، وتقليل تأخير مفتاح الإلغاء، والمفاتيح الموسَّعة (Shift+Enter)، ومراقبة النشاط، وعناوين تبويبات الطرفية — كل ذلك قابل للضبط في `~/.claude-mux/config`

> **ملاحظة:** هذا يختلف عن `claude --worktree --tmux` الذي يُنشئ جلسة tmux لشجرة عمل git معزولة. يُدير claude-mux جلسات دائمة لأدلة مشاريعك الفعلية، مع Remote Control وحقن موجِّه النظام.

### الجلسة الرئيسية

جلسة عامة الغرض واحدة تعيش في `$BASE_DIR`. تُطلق تلقائيًا عند تسجيل الدخول حين يكون `LAUNCHAGENT_MODE=home`، أو يدويًا بتشغيل `claude-mux` من `$BASE_DIR`. تمنحك جلسة Claude واحدة جاهزة دائمًا يمكن الوصول إليها من هاتفك دون الحاجة إلى إطلاق جلسات لكل مشروع.

الجلسة الرئيسية **محمية** دائمًا — `--shutdown home` يرفض إيقافها دون `--force`، بصرف النظر عن طريقة تشغيلها. الجلسات المحمية تُعلَّم بالعلامة `*` في مخرجات `-l`/`-L` (مثل `active*`).

## المتطلبات

- macOS (Apple Silicon)
- [tmux](https://github.com/tmux/tmux) — `brew install tmux`
- [Claude Code](https://claude.ai/code) — `brew install claude`

## التثبيت

```bash
./install.sh
```

يسأل المُثبِّت التفاعلي عن مكان مشاريع Claude، وعمّا إذا كنت تريد بدء جلسة رئيسية عند تسجيل الدخول، وأي نموذج تستخدم. ثم يُثبِّت `claude-mux` في `~/bin`، ويُنشئ `~/.claude-mux/config`، ويُعدّ LaunchAgent.

استخدم `--non-interactive` لتجاوز المطالبات وقبول القيم الافتراضية.

الخيارات:

```bash
./install.sh --non-interactive                     # تجاوز المطالبات واستخدم القيم الافتراضية
./install.sh --base-dir ~/work/claude              # استخدام دليل أساسي مختلف
./install.sh --launchagent-mode none               # تعطيل سلوك LaunchAgent
./install.sh --home-model haiku                    # استخدام Haiku للجلسة الرئيسية
./install.sh --no-launchagent                      # تخطي تثبيت LaunchAgent بالكامل
```

يُشغِّل LaunchAgent الأمر `claude-mux --autolaunch` عند تسجيل الدخول مع تأخير بدء قدره 45 ثانية للسماح لخدمات النظام بالتهيئة.

## الاستخدام

```bash
claude-mux                       # تشغيل Claude في الدليل الحالي والإلحاق
claude-mux ~/projects/my-app     # تشغيل Claude في دليل والإلحاق
claude-mux -d ~/projects/my-app  # نفس ما سبق (الصيغة الصريحة)
claude-mux -a                    # بدء جميع الجلسات المُدارة تحت BASE_DIR
claude-mux -n ~/projects/app     # إنشاء مشروع Claude جديد والإلحاق
claude-mux -n ~/new/path/app -p  # نفس ما سبق مع إنشاء الدليل والآباء
claude-mux -n ~/app --template web  # مشروع جديد بقالب CLAUDE.md محدد
claude-mux --list-templates      # عرض قوالب CLAUDE.md المتاحة
claude-mux -t my-app             # الإلحاق بجلسة tmux قائمة
claude-mux -s my-app '/model sonnet' # إرسال أمر مائل إلى جلسة
claude-mux -l                    # عرض الجلسات حسب الحالة (active، running، stopped)
claude-mux -L                    # عرض جميع المشاريع (نشطة + خاملة)
claude-mux --shutdown            # الخروج بسلاسة من جميع جلسات Claude المُدارة
claude-mux --shutdown my-app     # إيقاف جلسة محددة
claude-mux --shutdown a b c      # إيقاف عدة جلسات
claude-mux --shutdown home --force  # إيقاف الجلسة الرئيسية المحمية
claude-mux --restart             # إعادة تشغيل الجلسات التي كانت تعمل
claude-mux --restart my-app      # إعادة تشغيل جلسة محددة
claude-mux --restart a b c       # إعادة تشغيل عدة جلسات
claude-mux --permission-mode plan my-app    # إعادة تشغيل الجلسة بوضع plan
claude-mux --permission-mode dangerously-skip-permissions my-app  # وضع yolo
claude-mux --dry-run             # معاينة الإجراءات دون تنفيذها
claude-mux --version             # طباعة الإصدار
claude-mux --help                # عرض جميع الخيارات
claude-mux --guide               # عرض الأوامر التحاورية للاستخدام داخل الجلسات

# متابعة السجل
tail -f ~/Library/Logs/claude-mux.log
```

عند التشغيل من الطرفية، تُعكس المخرجات إلى stdout في الزمن الحقيقي. وعند التشغيل عبر LaunchAgent، تذهب المخرجات إلى ملف السجل فقط.

## حالات الجلسات

| الحالة | المعنى |
|--------|--------|
| `active` | جلسة tmux موجودة و Claude يعمل، وعميل tmux محلي ملحق |
| `running` | جلسة tmux موجودة و Claude يعمل (بدون عميل محلي ملحق) |
| `stopped` | جلسة tmux موجودة لكن Claude خرج |
| `idle` | يوجد مشروع `.claude/` تحت `BASE_DIR` لكن لا توجد جلسة tmux من claude-mux تعمل (يظهر فقط مع `-L`) |

علامة `*` في نهاية أي حالة تعني أن الجلسة محمية وتتطلب `--force` لإيقافها (مثل `active*` و `running*`). الجلسة الرئيسية محمية دائمًا.

تشغيل `claude-mux` في دليل لديه جلسة قيد التشغيل بالفعل يُلحقك بها. يمكن لعدة طرفيات الإلحاق بالجلسة نفسها (سلوك tmux القياسي).

## أمثلة على موجِّهات Claude

نظرًا لأن كل جلسة تُحقن بأوامر claude-mux، يمكنك إدارة الجلسات مباشرةً من موجِّهات المحادثة، سواء في الطرفية أو عبر تطبيق الهاتف المحمول:

```
أنت: "ما الجلسات قيد التشغيل؟"
Claude: يُشغِّل `claude-mux -l` ويعرض النتائج

أنت: "اعرض لي جميع المشاريع"
Claude: يُشغِّل `claude-mux -L` ويعرض النتائج

أنت: "ابدأ جلسة لمشروع العمل api-server"
Claude: يُشغِّل `claude-mux -d ~/Claude/work/api-server --no-attach`

أنت: "أنشئ مشروعًا شخصيًا جديدًا اسمه mobile-app"
Claude: يُشغِّل `claude-mux -n ~/Claude/personal/mobile-app -p --no-attach`

أنت: "ما القوالب التي لديّ؟"
Claude: يُشغِّل `claude-mux --list-templates` ويعرض النتائج

أنت: "أنشئ مشروع عمل جديد اسمه api-server باستخدام قالب web"
Claude: يُشغِّل `claude-mux -n ~/Claude/work/api-server -p --template web --no-attach`

أنت: "حوِّل جميع الجلسات إلى Sonnet"
Claude: يُشغِّل `claude-mux -s SESSION '/model sonnet'` لكل جلسة قيد التشغيل

أنت: "أوقف جلسة data-pipeline"
Claude: يُشغِّل `claude-mux --shutdown data-pipeline`

أنت: "أعد تشغيل جلسة web-dashboard المتعطلة"
Claude: يُشغِّل `claude-mux --restart web-dashboard`

أنت: "حوِّل جلسة api-server إلى وضع plan"
Claude: يُشغِّل `claude-mux --permission-mode plan api-server`

أنت: "اجعل جلسة data-pipeline في وضع yolo"
Claude: يُشغِّل `claude-mux --permission-mode dangerously-skip-permissions data-pipeline`

أنت: "أطلق جلسة data-pipeline في الخلفية"
Claude: يُشغِّل `claude-mux -d ~/Claude/work/data-pipeline --no-attach`

أنت: "ابدأ جميع مشاريعي"
Claude: يُشغِّل `claude-mux -a` (بعد التأكيد — هذا يبدأ كل مشروع مُدار)
```

## التهيئة

عند التشغيل لأول مرة، يُنشأ `~/.claude-mux/config` تلقائيًا مع تعطيل جميع الإعدادات بالتعليق. عدِّله لتجاوز أي قيم افتراضية — لا حاجة أبدًا لتعديل السكربت مباشرةً.

| المتغير | الافتراضي | الوصف |
|---------|-----------|-------|
| `BASE_DIR` | `$HOME/Claude` | الدليل الجذر للبحث عن مشاريع Claude (الأدلة التي تحتوي `.claude/`) |
| `LOG_DIR` | `$HOME/Library/Logs` | دليل ملف `claude-mux.log` |
| `DEFAULT_PERMISSION_MODE` | `auto` | يضبط `permissions.defaultMode` لـ Claude في كل مشروع. القيم الصحيحة: `default`، `acceptEdits`، `plan`، `auto`، `dontAsk`، `bypassPermissions`. اضبطه على `""` للتعطيل. |
| `ALLOW_CROSS_SESSION_CONTROL` | `false` | عند `true`، تستطيع جلسات Claude إرسال أوامر مائلة إلى جلسات أخرى — مفيد لتنسيق الوكلاء المتعددين |
| `TEMPLATES_DIR` | `$HOME/.claude-mux/templates` | دليل ملفات قوالب CLAUDE.md |
| `DEFAULT_TEMPLATE` | `default.md` | القالب الافتراضي المُطبَّق على المشاريع الجديدة (`-n`). اضبطه على `""` للتعطيل. |
| `SLEEP_BETWEEN` | `5` | عدد الثواني بين إطلاق الجلسات عند استخدام `-a`. زِدها إذا فشل تسجيل RC. |
| `HOME_SESSION_MODEL` | `""` | نموذج الجلسة الرئيسية. القيم الصحيحة: `sonnet`، `haiku`، `opus`. القيمة الفارغة ترث افتراضي Claude. |
| `LAUNCHAGENT_MODE` | `home` | سلوك LaunchAgent عند تسجيل الدخول: `none` (لا شيء) أو `home` (إطلاق الجلسة الرئيسية المحمية). يُعامَل `LAUNCHAGENT_ENABLED=true` القديم كـ `home`. |

**خيارات جلسة tmux** (جميعها قابلة للضبط ومُفعَّلة افتراضيًا):

| المتغير | الافتراضي | الوصف |
|---------|-----------|-------|
| `TMUX_MOUSE` | `true` | دعم الفأرة — التمرير، التحديد، تغيير حجم الألواح |
| `TMUX_HISTORY_LIMIT` | `50000` | حجم مخزن التمرير بالأسطر (الافتراضي في tmux هو 2000) |
| `TMUX_CLIPBOARD` | `true` | تكامل حافظة النظام عبر OSC 52 |
| `TMUX_DEFAULT_TERMINAL` | `tmux-256color` | نوع الطرفية لعرض ألوان سليم |
| `TMUX_EXTENDED_KEYS` | `true` | تسلسلات مفاتيح موسَّعة بما فيها Shift+Enter (يتطلب tmux 3.2+) |
| `TMUX_ESCAPE_TIME` | `10` | تأخير مفتاح escape بالملي ثانية (الافتراضي في tmux هو 500) |
| `TMUX_TITLE_FORMAT` | `#S` | صيغة عنوان الطرفية/التبويب (`#S` = اسم الجلسة، `""` للتعطيل) |
| `TMUX_MONITOR_ACTIVITY` | `true` | الإشعار عند حدوث نشاط في جلسات أخرى |

## بنية الأدلة

تُكتشف المشاريع بوجود دليل `.claude/` على أي عمق:

```
~/Claude/
├── work/
│   ├── project-a/          # ✓ يحوي .claude/ — مُدار
│   │   └── .claude/
│   ├── project-b/          # ✓ يحوي .claude/ — مُدار
│   │   └── .claude/
│   └── -archived/          # ✗ مستثنى (يبدأ بـ -)
│       └── .claude/
├── personal/
│   ├── project-c/          # ✓ يحوي .claude/ — مُدار
│   │   └── .claude/
│   ├── .hidden/            # ✗ مستثنى (دليل مخفي)
│   │   └── .claude/
│   └── project-d/          # ✗ لا يوجد .claude/ — ليس مشروع Claude
├── deep/nested/project-e/  # ✓ يحوي .claude/ — يُكتشف على أي عمق
│   └── .claude/
└── ignored-project/        # ✗ مستثنى (.ignore-claudemux)
    ├── .claude/
    └── .ignore-claudemux
```

تُشتق أسماء الجلسات من أسماء الأدلة: تتحوَّل المسافات إلى شَرَط، وتُستبدل المحارف غير الأبجدية الرقمية (باستثناء الشَرَط)، وتُجرَّد الشَرَط في البداية والنهاية. الأدلة التي يُفضي تطهير اسمها إلى سلسلة فارغة تُتجاوز مع تحذير في السجل.

## موجِّه نظام الجلسة

تُطلق كل جلسة Claude بوسيط `--append-system-prompt` يحوي سياقًا عن بيئتها:

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

عندما يكون `ALLOW_CROSS_SESSION_CONTROL=true`، يتغير أمر الإرسال للسماح باستهداف أي جلسة، لا الجلسة نفسها فحسب. المسار هو المسار المطلق للسكربت وقت الإطلاق، فلا تعتمد الجلسات على `PATH`.

## استكشاف الأخطاء وإصلاحها

### تعرض الجلسات "Not logged in · Run /login"

يحدث هذا عند الإطلاق الأول إذا كانت سلسلة مفاتيح macOS مقفلة (شائع عند تشغيل السكربت قبل فتح سلسلة المفاتيح بعد تسجيل الدخول). الحل:

```bash
# افتح سلسلة المفاتيح في طرفية عادية
security unlock-keychain

# ثم أكمل المصادقة في أي جلسة قيد التشغيل
claude-mux -t <any-session>
# شغِّل /login وأكمل تدفق المتصفح
```

بعد إكمال المصادقة مرة واحدة، أوقف وأعد إطلاق جميع الجلسات — ستلتقط بيانات الاعتماد المحفوظة تلقائيًا.

### الجلسات لا تظهر في Claude Code Remote

يجب أن تكون الجلسات مُصادَقًا عليها (لا تعرض "Not logged in"). بعد إطلاق نظيف ومُصادَق عليه، يُفترض أن تظهر في قائمة RC في غضون ثوانٍ قليلة.

### الإدخال متعدد الأسطر في tmux

لا يمكن تشغيل أمر `/terminal-setup` داخل tmux. يُفعِّل claude-mux ميزة `extended-keys` في tmux افتراضيًا (`TMUX_EXTENDED_KEYS=true`)، وهي تدعم Shift+Enter في معظم الطرفيات الحديثة. إذا لم يعمل Shift+Enter، استخدم `\` + Return لإدخال أسطر جديدة في موجِّهك.

### الأوامر المائلة عبر Remote Control

الأوامر المائلة (مثل `/model` و `/clear`) [غير مدعومة بشكل أصيل](https://github.com/anthropics/claude-code/issues/30674) في جلسات RC. يلتف claude-mux حول ذلك — تُحقن كل جلسة بـ `claude-mux -s` بحيث يستطيع Claude إرسال الأوامر المائلة إلى نفسه عبر tmux.

## السجلات

- `~/Library/Logs/claude-mux.log` — جميع إجراءات السكربت بطوابع زمنية UTC (قابل للضبط عبر `LOG_DIR`)

لتصحيح أخطاء LaunchAgent منخفضة المستوى، استخدم Console.app أو `log show`.
