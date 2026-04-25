# claude-mux - Claude Code मल्टीप्लेक्सर

[English](../README.md) · [Español](README.es.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Português](README.pt-BR.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [中文](README.zh-CN.md) · [עברית](README.he.md) · [العربية](README.ar.md) · **हिन्दी**

> नोट: यह अनुवाद अंग्रेज़ी README से पीछे हो सकता है। आधिकारिक संस्करण के लिए [README.md](../README.md) देखें।

आपके सभी प्रोजेक्ट्स के लिए परसिस्टेंट Claude Code सेशन - Claude मोबाइल ऐप के माध्यम से कहीं से भी एक्सेस करने योग्य।

एक shell स्क्रिप्ट जो Claude Code को tmux के अंदर Remote Control सक्षम के साथ लॉन्च करती है, conversation resume और सेल्फ-मैनेजमेंट के साथ - सेशन सूचीबद्ध करें, slash commands भेजें, नए प्रोजेक्ट शुरू करें, बंद करें या पुनः शुरू करें। किसी भी डायरेक्टरी में `claude-mux` चलाएँ और अपने फोन से एक्सेस करने योग्य परसिस्टेंट सेशन प्राप्त करें।

## त्वरित शुरुआत

```bash
./install.sh
```

```bash
claude-mux ~/path/to/your/project
```

या अपनी प्रोजेक्ट डायरेक्टरी में `cd` करके चलाएँ:

```bash
claude-mux
```

बस इतना ही - आप एक परसिस्टेंट, सेशन-अवेयर Claude सेशन में हैं जिसमें Remote Control सक्षम है।

claude-mux एक एकल bash स्क्रिप्ट है जिसमें tmux और Claude Code के अलावा कोई निर्भरता नहीं है।

## यह क्या करता है

1. **Remote Control के साथ परसिस्टेंट tmux सेशन** - Claude Code को tmux के अंदर `--remote-control` सक्षम के साथ लॉन्च करता है, ताकि हर सेशन Claude मोबाइल ऐप से एक्सेस करने योग्य हो
2. **Conversation resume** - यदि Claude पहले डायरेक्टरी में चल रहा था, तो Remote Control वाले नए tmux सेशन के अंदर अंतिम बातचीत को (`claude -c`) फिर से शुरू करता है, आपके कॉन्टेक्स्ट को संरक्षित करते हुए
3. **सेशन प्रबंधन** - सक्रिय सेशन (`-l`) या सभी प्रोजेक्ट्स की सूची बनाएँ जिसमें वे निष्क्रिय शामिल हैं जो अभी तक नहीं चल रहे (`-L`), बंद करें (`--shutdown`), पुनः शुरू करें (`--restart`), अनुमति मोड बदलें (`--permission-mode`), अटैच करें (`-t`), सेशन को slash commands भेजें (`-s`)
4. **Claude सेल्फ-मैनेजमेंट** - प्रत्येक सेशन को एक system prompt इंजेक्ट किया जाता है ताकि Claude उपरोक्त सभी कमांड्स को बातचीत के prompts से सीधे चला सके (टर्मिनल या मोबाइल ऐप):
   - a. चल रहे सेशन और सभी प्रोजेक्ट्स की सूची बनाना
   - b. नए सेशन लॉन्च करना, नए प्रोजेक्ट बनाना
   - c. खुद को या अन्य सेशन को slash commands भेजना ([RC पर slash commands मूल रूप से काम न करने](https://github.com/anthropics/claude-code/issues/30674) के लिए वर्कअराउंड)
   - d. सेशन को बंद करना, पुनः शुरू करना, या अनुमति मोड बदलना
5. **होम सेशन** - आपकी बेस डायरेक्टरी में एक हल्का, हमेशा चलने वाला सेशन जो लॉगिन के समय लॉन्च होता है (`LAUNCHAGENT_MODE` के माध्यम से कॉन्फ़िगर करने योग्य)। Claude मोबाइल ऐप से Remote Control हमेशा उपलब्ध रखता है और आपके सभी अन्य सेशन को मैनेज कर सकता है। आकस्मिक शटडाउन से सुरक्षित।
6. **नया प्रोजेक्ट निर्माण** - `claude-mux -n DIRECTORY` git, `.gitignore`, और कॉन्फ़िगर किए गए अनुमति मोड के साथ कोडिंग के लिए तैयार प्रोजेक्ट बनाता है (`-p` डायरेक्टरी न होने पर बनाता है)। कोई भी चल रहा सेशन नए प्रोजेक्ट बना सकता है - Claude से कहीं भी से अपने किसी भी GitHub अकाउंट पर repo सेट अप करने और कोडिंग शुरू करने के लिए कहें
7. **CLAUDE.md टेम्पलेट** - `~/.claude-mux/templates/` में CLAUDE.md इंस्ट्रक्शन फ़ाइलों की लाइब्रेरी रखें (जैसे `web.md`, `python.md`, `default.md`) और उन्हें नए प्रोजेक्ट्स पर स्वचालित रूप से लागू करें। विशिष्ट टेम्पलेट चुनने के लिए `--template NAME` का उपयोग करें या डिफ़ॉल्ट को लागू होने दें
8. **SSH अकाउंट जागरूकता** - `~/.ssh/config` से GitHub SSH host aliases इंजेक्ट करता है ताकि Claude को पता हो कि git ऑपरेशन के लिए कौन से अकाउंट उपलब्ध हैं
9. **स्वतः-स्वीकृत अनुमतियाँ** - claude-mux खुद को प्रत्येक प्रोजेक्ट की `.claude/settings.local.json` allow list में जोड़ता है ताकि Claude अनुमति माँगे बिना claude-mux कमांड्स चला सके
10. **आवारा प्रक्रिया माइग्रेशन** - यदि Claude पहले से ही टार्गेट डायरेक्टरी में tmux के बाहर चल रहा है, तो उसे टर्मिनेट करता है और मैनेज्ड tmux सेशन के अंदर पुनः लॉन्च करता है (बातचीत `claude -c` के माध्यम से फिर से शुरू होती है)
11. **Tmux क्वालिटी-ऑफ-लाइफ** - सेशन माउस सपोर्ट, 50k स्क्रॉलबैक बफर, क्लिपबोर्ड इंटीग्रेशन, 256-color, कम escape delay, extended keys (Shift+Enter), activity monitoring, और टर्मिनल टैब टाइटल के साथ कॉन्फ़िगर किए जाते हैं - सभी `~/.claude-mux/config` में कॉन्फ़िगर करने योग्य

> **नोट:** यह `claude --worktree --tmux` से अलग है, जो एक isolated git worktree के लिए tmux सेशन बनाता है। claude-mux आपकी वास्तविक प्रोजेक्ट डायरेक्टरीज़ के लिए परसिस्टेंट सेशन मैनेज करता है, Remote Control और system prompt injection के साथ।

### होम सेशन

`$BASE_DIR` में रहने वाला एकल सामान्य-उद्देश्य सेशन। `LAUNCHAGENT_MODE=home` होने पर लॉगिन पर स्वचालित रूप से लॉन्च होता है, या `$BASE_DIR` से `claude-mux` चलाकर मैन्युअल रूप से। आपको हर प्रोजेक्ट के लिए सेशन लॉन्च किए बिना अपने फोन से एक्सेस योग्य एक हमेशा-तैयार Claude सेशन देता है।

होम सेशन हमेशा **सुरक्षित** होता है - `--shutdown home` इसे `--force` के बिना रोकने से इनकार करता है, चाहे यह कैसे भी शुरू हुआ हो। सुरक्षित सेशन `-l`/`-L` आउटपुट में `*` के साथ चिह्नित होते हैं (जैसे `active*`)।

## आवश्यकताएँ

- macOS (Apple Silicon)
- [tmux](https://github.com/tmux/tmux) - `brew install tmux`
- [Claude Code](https://claude.ai/code) - `brew install claude`

## इंस्टॉल

```bash
./install.sh
```

इंटरैक्टिव इंस्टॉलर पूछता है कि आपके Claude प्रोजेक्ट्स कहाँ रहते हैं, क्या लॉगिन पर होम सेशन शुरू करना है, और कौन सा मॉडल उपयोग करना है। यह `claude-mux` को `~/bin` पर इंस्टॉल करता है, `~/.claude-mux/config` बनाता है, और LaunchAgent सेट करता है।

prompts को छोड़ने और डिफ़ॉल्ट स्वीकार करने के लिए `--non-interactive` का उपयोग करें।

विकल्प:

```bash
./install.sh --non-interactive                     # prompts छोड़ें, डिफ़ॉल्ट उपयोग करें
./install.sh --base-dir ~/work/claude              # अलग बेस डायरेक्टरी उपयोग करें
./install.sh --launchagent-mode none               # LaunchAgent व्यवहार अक्षम करें
./install.sh --home-model haiku                    # होम सेशन के लिए Haiku उपयोग करें
./install.sh --no-launchagent                      # LaunchAgent इंस्टॉलेशन पूरी तरह छोड़ें
```

LaunchAgent लॉगिन पर `claude-mux --autolaunch` को 45-सेकंड स्टार्टअप delay के साथ चलाता है ताकि सिस्टम सेवाओं को इनिशियलाइज़ होने का समय मिले।

## उपयोग

```bash
claude-mux                       # वर्तमान डायरेक्टरी में Claude लॉन्च करें और attach करें
claude-mux ~/projects/my-app     # डायरेक्टरी में Claude लॉन्च करें और attach करें
claude-mux -d ~/projects/my-app  # ऊपर के समान (स्पष्ट रूप)
claude-mux -a                    # BASE_DIR के तहत सभी मैनेज्ड सेशन शुरू करें
claude-mux -n ~/projects/app     # नया Claude प्रोजेक्ट बनाएँ और attach करें
claude-mux -n ~/new/path/app -p  # वही, डायरेक्टरी और parents बनाते हुए
claude-mux -n ~/app --template web  # विशिष्ट CLAUDE.md टेम्पलेट के साथ नया प्रोजेक्ट
claude-mux --list-templates      # उपलब्ध CLAUDE.md टेम्पलेट दिखाएँ
claude-mux -t my-app             # मौजूदा tmux सेशन से attach करें
claude-mux -s my-app '/model sonnet' # सेशन को slash command भेजें
claude-mux -l                    # status के अनुसार सेशन सूचीबद्ध करें (active, running, stopped)
claude-mux -L                    # सभी प्रोजेक्ट सूचीबद्ध करें (active + idle)
claude-mux --shutdown            # सभी मैनेज्ड Claude सेशन को gracefully बंद करें
claude-mux --shutdown my-app     # विशिष्ट सेशन बंद करें
claude-mux --shutdown a b c      # कई सेशन बंद करें
claude-mux --shutdown home --force  # सुरक्षित होम सेशन बंद करें
claude-mux --restart             # चल रहे सेशन पुनः शुरू करें
claude-mux --restart my-app      # विशिष्ट सेशन पुनः शुरू करें
claude-mux --restart a b c       # कई सेशन पुनः शुरू करें
claude-mux --permission-mode plan my-app    # plan mode के साथ सेशन पुनः शुरू करें
claude-mux --permission-mode dangerously-skip-permissions my-app  # yolo mode
claude-mux --dry-run             # बिना execute किए actions का preview करें
claude-mux --version             # version प्रिंट करें
claude-mux --help                # सभी विकल्प दिखाएँ
claude-mux --guide               # सेशन के अंदर उपयोग के लिए conversational commands दिखाएँ

# लॉग देखें
tail -f ~/Library/Logs/claude-mux.log
```

टर्मिनल से चलाने पर, आउटपुट को रियल टाइम में stdout पर मिरर किया जाता है। LaunchAgent के माध्यम से चलाने पर, आउटपुट केवल लॉग फ़ाइल में जाता है।

## सेशन स्टेटस

| स्टेटस | अर्थ |
|--------|---------|
| `active` | tmux सेशन मौजूद है, Claude चल रहा है, और एक स्थानीय tmux client attached है |
| `running` | tmux सेशन मौजूद है और Claude चल रहा है (कोई स्थानीय client attached नहीं) |
| `stopped` | tmux सेशन मौजूद है लेकिन Claude exit हो चुका है |
| `idle` | `BASE_DIR` के तहत एक `.claude/` प्रोजेक्ट मौजूद है लेकिन कोई claude-mux tmux सेशन नहीं चल रहा (केवल `-L` के साथ दिखाया जाता है) |

किसी भी status पर ट्रेलिंग `*` इंगित करता है कि सेशन सुरक्षित है और बंद करने के लिए `--force` की आवश्यकता है (जैसे `active*`, `running*`)। होम सेशन हमेशा सुरक्षित होता है।

`claude-mux` को ऐसी डायरेक्टरी में चलाना जिसमें पहले से ही चल रहा सेशन है, उससे attach हो जाता है। एक ही सेशन से कई टर्मिनल attach हो सकते हैं (मानक tmux व्यवहार)।

## Claude Prompt के उदाहरण

चूँकि प्रत्येक सेशन को claude-mux कमांड्स इंजेक्ट किए जाते हैं, आप बातचीत के prompts से सीधे सेशन मैनेज कर सकते हैं - टर्मिनल में या मोबाइल ऐप के माध्यम से:

```
आप: "कौन से सेशन चल रहे हैं?"
Claude: `claude-mux -l` चलाता है और परिणाम दिखाता है

आप: "मुझे सभी प्रोजेक्ट दिखाओ"
Claude: `claude-mux -L` चलाता है और परिणाम दिखाता है

आप: "मेरे api-server work प्रोजेक्ट के लिए सेशन शुरू करो"
Claude: `claude-mux -d ~/Claude/work/api-server --no-attach` चलाता है

आप: "mobile-app नाम से नया personal प्रोजेक्ट बनाओ"
Claude: `claude-mux -n ~/Claude/personal/mobile-app -p --no-attach` चलाता है

आप: "मेरे पास कौन से टेम्पलेट हैं?"
Claude: `claude-mux --list-templates` चलाता है और परिणाम दिखाता है

आप: "web टेम्पलेट का उपयोग करते हुए api-server नाम से नया work प्रोजेक्ट बनाओ"
Claude: `claude-mux -n ~/Claude/work/api-server -p --template web --no-attach` चलाता है

आप: "सभी सेशन को Sonnet पर स्विच करो"
Claude: हर चल रहे सेशन के लिए `claude-mux -s SESSION '/model sonnet'` चलाता है

आप: "data-pipeline सेशन बंद करो"
Claude: `claude-mux --shutdown data-pipeline` चलाता है

आप: "अटके हुए web-dashboard सेशन को पुनः शुरू करो"
Claude: `claude-mux --restart web-dashboard` चलाता है

आप: "api-server सेशन को plan mode पर स्विच करो"
Claude: `claude-mux --permission-mode plan api-server` चलाता है

आप: "data-pipeline सेशन को yolo करो"
Claude: `claude-mux --permission-mode dangerously-skip-permissions data-pipeline` चलाता है

आप: "data-pipeline सेशन को बैकग्राउंड में लॉन्च करो"
Claude: `claude-mux -d ~/Claude/work/data-pipeline --no-attach` चलाता है

आप: "मेरे सभी प्रोजेक्ट शुरू करो"
Claude: `claude-mux -a` चलाता है (पुष्टि के बाद - यह हर मैनेज्ड प्रोजेक्ट को शुरू करता है)
```

## कॉन्फ़िगरेशन

पहली बार चलाने पर, `~/.claude-mux/config` स्वचालित रूप से बनाया जाता है जिसमें सभी settings comment किए गए होते हैं। किसी भी डिफ़ॉल्ट को override करने के लिए इसे संपादित करें - स्क्रिप्ट को कभी भी सीधे संशोधित करने की आवश्यकता नहीं है।

| वेरिएबल | डिफ़ॉल्ट | विवरण |
|----------|---------|-------------|
| `BASE_DIR` | `$HOME/Claude` | Claude प्रोजेक्ट्स (`.claude/` वाली डायरेक्टरीज़) के लिए स्कैन की जाने वाली रूट डायरेक्टरी |
| `LOG_DIR` | `$HOME/Library/Logs` | `claude-mux.log` फ़ाइल के लिए डायरेक्टरी |
| `DEFAULT_PERMISSION_MODE` | `auto` | प्रत्येक प्रोजेक्ट में Claude का `permissions.defaultMode` सेट करें। मान्य: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`। अक्षम करने के लिए `""` सेट करें। |
| `ALLOW_CROSS_SESSION_CONTROL` | `false` | जब `true` हो, Claude सेशन अन्य सेशन को slash commands भेज सकते हैं - मल्टी-एजेंट ऑर्केस्ट्रेशन के लिए उपयोगी |
| `TEMPLATES_DIR` | `$HOME/.claude-mux/templates` | CLAUDE.md टेम्पलेट फ़ाइलों वाली डायरेक्टरी |
| `DEFAULT_TEMPLATE` | `default.md` | नए प्रोजेक्ट्स (`-n`) पर लागू डिफ़ॉल्ट टेम्पलेट। अक्षम करने के लिए `""` सेट करें। |
| `SLEEP_BETWEEN` | `5` | `-a` का उपयोग करने पर सेशन लॉन्च के बीच सेकंड। RC रजिस्ट्रेशन फेल होने पर बढ़ाएँ। |
| `HOME_SESSION_MODEL` | `""` | होम सेशन के लिए मॉडल। मान्य: `sonnet`, `haiku`, `opus`। खाली होने पर Claude का डिफ़ॉल्ट inherit करता है। |
| `LAUNCHAGENT_MODE` | `home` | लॉगिन पर LaunchAgent व्यवहार: `none` (कुछ नहीं करें) या `home` (सुरक्षित होम सेशन लॉन्च करें)। Legacy `LAUNCHAGENT_ENABLED=true` को `home` के रूप में माना जाता है। |

**Tmux सेशन विकल्प** (सभी कॉन्फ़िगर करने योग्य, सभी डिफ़ॉल्ट रूप से सक्षम):

| वेरिएबल | डिफ़ॉल्ट | विवरण |
|----------|---------|-------------|
| `TMUX_MOUSE` | `true` | माउस सपोर्ट - स्क्रॉल, सेलेक्ट, panes का आकार बदलें |
| `TMUX_HISTORY_LIMIT` | `50000` | लाइनों में स्क्रॉलबैक बफर साइज़ (tmux डिफ़ॉल्ट 2000 है) |
| `TMUX_CLIPBOARD` | `true` | OSC 52 के माध्यम से सिस्टम क्लिपबोर्ड इंटीग्रेशन |
| `TMUX_DEFAULT_TERMINAL` | `tmux-256color` | उचित color rendering के लिए टर्मिनल टाइप |
| `TMUX_EXTENDED_KEYS` | `true` | Shift+Enter सहित extended key sequences (tmux 3.2+ की आवश्यकता) |
| `TMUX_ESCAPE_TIME` | `10` | Escape key delay मिलीसेकंड में (tmux डिफ़ॉल्ट 500 है) |
| `TMUX_TITLE_FORMAT` | `#S` | टर्मिनल/टैब टाइटल फॉर्मेट (`#S` = सेशन नाम, अक्षम करने के लिए `""`) |
| `TMUX_MONITOR_ACTIVITY` | `true` | अन्य सेशन में activity होने पर सूचित करें |

## डायरेक्टरी संरचना

प्रोजेक्ट किसी भी गहराई पर `.claude/` डायरेक्टरी की उपस्थिति से खोजे जाते हैं:

```
~/Claude/
├── work/
│   ├── project-a/          # ✓ .claude/ है - मैनेज्ड
│   │   └── .claude/
│   ├── project-b/          # ✓ .claude/ है - मैनेज्ड
│   │   └── .claude/
│   └── -archived/          # ✗ बहिष्कृत (- से शुरू)
│       └── .claude/
├── personal/
│   ├── project-c/          # ✓ .claude/ है - मैनेज्ड
│   │   └── .claude/
│   ├── .hidden/            # ✗ बहिष्कृत (छिपी डायरेक्टरी)
│   │   └── .claude/
│   └── project-d/          # ✗ कोई .claude/ नहीं - Claude प्रोजेक्ट नहीं
├── deep/nested/project-e/  # ✓ .claude/ है - किसी भी गहराई पर मिला
│   └── .claude/
└── ignored-project/        # ✗ बहिष्कृत (.ignore-claudemux)
    ├── .claude/
    └── .ignore-claudemux
```

सेशन नाम डायरेक्टरी नामों से प्राप्त होते हैं: स्पेस hyphens बन जाते हैं, गैर-alphanumeric वर्ण (hyphens को छोड़कर) बदल दिए जाते हैं, और शुरू/अंत के hyphens हटा दिए जाते हैं। जिन डायरेक्टरीज़ का नाम sanitize होकर खाली हो जाता है, उन्हें लॉग चेतावनी के साथ छोड़ दिया जाता है।

## सेशन सिस्टम प्रॉम्प्ट

प्रत्येक Claude सेशन को इसके environment के बारे में context वाले `--append-system-prompt` के साथ लॉन्च किया जाता है:

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

जब `ALLOW_CROSS_SESSION_CONTROL=true` हो, तो send कमांड बदल जाती है ताकि किसी भी सेशन को टार्गेट किया जा सके, सिर्फ़ खुद को नहीं। पाथ लॉन्च समय पर स्क्रिप्ट का पूर्ण पाथ है, इसलिए सेशन `PATH` पर निर्भर नहीं करते।

## समस्या निवारण

### सेशन "Not logged in · Run /login" दिखाते हैं

यह पहले लॉन्च पर होता है यदि macOS keychain locked है (आम बात जब स्क्रिप्ट लॉगिन के बाद keychain unlock होने से पहले चलती है)। समाधान:

```bash
# सामान्य टर्मिनल में keychain unlock करें
security unlock-keychain

# फिर किसी एक चल रहे सेशन में auth पूरा करें
claude-mux -t <any-session>
# /login चलाएँ और browser flow पूरा करें
```

एक बार auth पूरा करने के बाद, सभी सेशन को kill करके पुनः लॉन्च करें - वे संग्रहीत credential स्वचालित रूप से उठा लेंगे।

### सेशन Claude Code Remote में नहीं दिख रहे

सेशन authenticated होने चाहिए (कोई "Not logged in" नहीं दिखाते)। एक स्वच्छ authenticated लॉन्च के बाद उन्हें कुछ सेकंड के भीतर RC लिस्ट में दिखना चाहिए।

### tmux में मल्टी-लाइन इनपुट

`/terminal-setup` कमांड tmux के अंदर नहीं चल सकती। claude-mux डिफ़ॉल्ट रूप से tmux `extended-keys` सक्षम करता है (`TMUX_EXTENDED_KEYS=true`), जो अधिकांश आधुनिक टर्मिनलों में Shift+Enter को सपोर्ट करता है। यदि Shift+Enter काम नहीं करता, तो अपने prompt में newlines डालने के लिए `\` + Return का उपयोग करें।

### Remote Control पर slash commands

Slash commands (जैसे `/model`, `/clear`) RC सेशन में [मूल रूप से समर्थित नहीं हैं](https://github.com/anthropics/claude-code/issues/30674)। claude-mux इस पर काम करता है - प्रत्येक सेशन को `claude-mux -s` इंजेक्ट किया जाता है ताकि Claude tmux के माध्यम से खुद को slash commands भेज सके।

## लॉग

- `~/Library/Logs/claude-mux.log` - UTC टाइमस्टैम्प के साथ सभी स्क्रिप्ट actions (`LOG_DIR` के माध्यम से कॉन्फ़िगर करने योग्य)

low-level LaunchAgent debugging के लिए, Console.app या `log show` का उपयोग करें।
