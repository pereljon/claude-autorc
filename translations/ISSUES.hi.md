# ज्ञात समस्याएँ

[English](../docs/ISSUES.md) · [Español](ISSUES.es.md) · [Français](ISSUES.fr.md) · [Deutsch](ISSUES.de.md) · [Português](ISSUES.pt-BR.md) · [日本語](ISSUES.ja.md) · [한국어](ISSUES.ko.md) · [Italiano](ISSUES.it.md) · [Русский](ISSUES.ru.md) · [中文](ISSUES.zh-CN.md) · [עברית](ISSUES.he.md) · [العربية](ISSUES.ar.md) · **हिन्दी**

## खुली समस्याएँ

### Phantom message replay अनपेक्षित कार्य करवाता है
**गंभीरता:** उच्च
**स्थिति:** खुली - claude-mux की तरफ से पूरा ठीक नहीं हो सकता
**विवरण:** एक user ने "stop all sessions" भेजा जो 10 messages पहले handle हो चुका था। बाद में, जब claude-mux -s ने tmux send-keys से `/model haiku` भेजा, Claude को एक system message "stop all sessions/model haiku" मिली और उसने sessions बंद करने की कोशिश की - एक action जो user ने कभी request नहीं किया।
**संभावित कारण:**
- Claude Code का interruption handling पुराने context को नए slash command input के साथ concatenate कर सकता है
- पुराना command वाली conversation history Claude को confuse कर सकती है जब system event होता है
**संभावित समाधान:** Injection rule जोड़ें: "बातचीत में पहले handle हो चुके command को कभी दोबारा execute न करें। अगर system message पिछले exchange का text दोहराती है, तो उसे ignore करें।" अभी implement नहीं हुआ - effectiveness अनिश्चित क्योंकि यह Claude Code का internal behavior है।

### पहली बार /exit धीमा
**गंभीरता:** कम
**स्थिति:** खुली - निगरानी में
**विवरण:** पहला `--restart` `WARN: Claude did not exit within 30s` तक पहुँचा और hard kill पर चला गया। बाद के restarts ~1s में exit होते हैं। Race condition हो सकती है जहाँ `/exit` Claude का prompt ready होने से पहले भेजा जाता है।
**Workaround:** 30s timeout + hard kill इसे handle करता है। Session सही से relaunch होता है।

### claude_running_in_session केवल 2 levels deep check करता है
**गंभीरता:** कम
**स्थिति:** खुली - वर्तमान उपयोग के लिए स्वीकार्य
**विवरण:** Process tree walk pane_pid, children, और grandchildren check करता है। अगर Claude tree में गहरा है (जैसे extra shell wrapper), तो detection fail होता है। वर्तमान launch path exactly 2 levels है (bash -> claude) इसलिए practice में काम करता है।
**Workaround:** अभी ज़रूरत नहीं। Fix करने के लिए recursive walk या `pgrep -a` चाहिए।

### Installer upgrade UX बेहतर हो सकता है
**गंभीरता:** कम
**स्थिति:** खुली - भविष्य में सुधार
**विवरण:** Reinstall पर, installer existing config पहचानता है और prompts skip करता है। लेकिन यह current settings दिखाने, नए versions में जोड़े गए नए config options merge करने, या user को selectively values update करने नहीं देता। Users को `~/.claude-mux/config` manually edit करना होता है नई settings लेने के लिए।
**संभावित सुधार:**
- Upgrade के दौरान current config values दिखाएं
- नई settings (defaults के साथ) जोड़ने का offer करें जो पुराने config में नहीं थीं
- Option B: existing config values से prompts pre-fill करें और user को बदलने दें

### Translation files को v1.10-v1.12 update चाहिए
**गंभीरता:** कम
**स्थिति:** खुली - translations अभी update नहीं हुए
**विवरण:** सभी 12 translation files (`translations/README.*.md`) कई versions पीछे हैं (v1.10-v1.12)। जो बदलाव reflect होने चाहिए:
- curl primary Quick Start के रूप में (one-liner)
- नया Install section structure (curl recommended, Homebrew macOS alternative)
- `--hide`/`--delete`/`--protect` के लिए paths की जगह session names (v1.11.0)
- नए conversational examples: rename, save-as-template, tip, enable/disable tips, update
- Requirements: "Apple Silicon या Intel" (सिर्फ Apple Silicon नहीं)
- FAQ, ISSUES, CHANGELOG link करने वाला नया "More" section
- FAQ और ISSUES translations बनाने की ज़रूरत

### Code review deferred issues (v1.9.0)
**गंभीरता:** कम-मध्यम
**स्थिति:** v1.10.0 में हल - M3, M4, M9/L8, L3, L9 fix हुए; L4, L5, L6, L7, M7 comments के साथ address हुए

### Project rename / move with history preservation
**गंभीरता:** कम
**स्थिति:** v1.10.0 में हल - `--rename OLD NEW` और `--move SRC DEST` implement हुए

### Project copy with history
**गंभीरता:** कम
**स्थिति:** खुली - planned feature, investigation आवश्यक
**विवरण:** Project को Claude Code history और memory सहित copy करना rename/move से ज़्यादा complex है क्योंकि destination के लिए नए UUIDs establish करने होते हैं।
**प्रस्तावित approach:**
1. नई project directory बनाएँ (optional git init और template के साथ)
2. उसमें session start और तुरंत stop करें - Claude Code `~/.claude/projects/-encoded-new-path/` को fresh UUID से initialize करता है और नया homunculus entry बनाता है
3. Source `~/.claude/projects/` folder से `.jsonl` history files destination folder में copy करें
4. `memory/` folder contents copy करें - pure markdown, कोई embedded UUIDs नहीं, directly copy करना safe
5. UUID subdirectories (task/plan artifacts) उनकी `.jsonl` files के साथ copy करें
6. Homunculus के लिए: `observations.jsonl`, `instincts`, `evolved`, `observations.archive` source `~/.claude/homunculus/projects/<src-uuid>/` से destination के homunculus folder में copy करें - step 2 में assign हुआ नया project UUID रखते हुए
**खुले प्रश्न जिनके testing चाहिए:**
- क्या `.jsonl` files अपने content या metadata में source project path embed करती हैं? अगर हाँ, तो copied history पुराने path को reference करेगी।
- क्या UUID subdirectories को `.jsonl` files के अंदर से UUID द्वारा reference किया जाता है? अगर हाँ, तो उन्हें original UUIDs के तहत copy करना होगा, remap नहीं।
- क्या Claude Code project folder में सभी `.jsonl` files पढ़ता है, या सिर्फ active session UUID से matching वाली?
- `~/.claude/homunculus/projects/<uuid>/evolved` और `instincts` में क्या है - क्या ये derived/computed हैं या user-meaningful? Copy में preserve करने लायक?
- क्या कोई अन्य internal references हैं जो naive file copy से टूट जाएँगी?
**Prerequisites:** Implement करने से पहले ऊपर test करें ताकि subtly broken history produce करने वाला copy command ship न हो।

### Tip of the day
**गंभीरता:** कम
**स्थिति:** v1.10.0 में हल - `--tip`, `TIP_OF_DAY`, `TIP_MODE`, daily gate, session-start delivery implement हुए

### Reply timestamp
**गंभीरता:** कम
**स्थिति:** खुली - implement करने से पहले चर्चा करें
**विवरण:** Optional config var (`REPLY_TIMESTAMP=false` default) जो system prompt में instruction inject करता है Claude को हर response `date '+%Y-%m-%d %H:%M'` से current date और time के साथ शुरू करने के लिए।
**Tradeoff:** हर reply की शुरुआत में bash tool call आवश्यक (छोटा overhead)। Alternative: prompt में session start time inject करें (free, लेकिन लंबे sessions में drift होता है)।
**नोट:** Per-project CLAUDE.md instruction (जैसे analytical template में) हल्का version है - सिर्फ उन projects पर जो इसे चाहते हैं। Config var इसे global बनाता है।

### Demo video
**गंभीरता:** कम
**स्थिति:** खुली - planned asset
**विवरण:** Screen recording जो claude-mux को curl install से common और interesting commands तक दिखाए, terminal और Remote Control एक साथ visible।
**Format:** Split screen, single take। Terminal (पूरा claude-mux session) बाईं तरफ, QuickTime से mirrored iPhone पर RC दाईं तरफ। दोनों live - viewer RC में actions तुरंत terminal में reflect होते देखता है और vice versa।
**देखें:** `internal/demo-script.md` shot-by-shot outline के लिए।
**नोट्स:**
- Key shot: phone पर RC में type करना और terminal को real time में respond करते देखना
- Trim के अलावा कोई editing नहीं - single continuous recording
- YouTube पर host + README में embed; Product Hunt launch के लिए भी उपयोगी

### homebrew-core में submit करें brew.sh listing के लिए
**गंभीरता:** कम
**स्थिति:** भविष्य - adoption की प्रतीक्षा
**विवरण:** claude-mux वर्तमान में personal tap (`pereljon/tap`) से distribute होता है। brew.sh पर दिखने के लिए, homebrew-core में accept होना चाहिए। Homebrew का notability gate आमतौर पर कुछ सौ GitHub stars माँगता है shell script utility submission accept करने से पहले; low-star submissions जल्दी close हो जाती हैं।
**तैयार होने पर:**
- Formula `brew audit --strict --new` pass करे सुनिश्चित करें
- `Homebrew/homebrew-core` में formula के साथ PR submit करें
- नोट: macOS-only tools को reviewers से ज़्यादा scrutiny मिलती है; Linux support (नीचे देखें) मदद करेगा

### curl install support (macOS + Linux)
**गंभीरता:** कम
**स्थिति:** v1.10.0 में हल - curl install implement हुआ, release-assets workflow जुड़ा, README update हुआ

### macOS only - कोई Linux/systemd support नहीं
**गंभीरता:** मध्यम
**स्थिति:** खुली - आंशिक रूप से address हुई (path detection हुआ, LaunchAgent/installer macOS-specific बने हुए)
**विवरण:** macOS LaunchAgent (launchd) और macOS-specific tools उपयोग करता है। Path detection `command -v` उपयोग करने के लिए refactor हुआ (अब `/opt/homebrew/bin` hardcode नहीं), इसलिए core script अब किसी भी platform पर काम करता है जहाँ tmux और claude PATH में हैं। LaunchAgent और installer macOS-specific बने हुए हैं।
**बाकी:** systemd user unit, XDG Autostart fallback, installer में `uname -s` dispatch।
**Package strategy (v1.10+):**
- curl install: universal fallback, हर जगह काम करता है (ऊपर देखें)
- AUR: कम effort, Arch/Manjaro पर target audience के लिए ज़्यादा reach
- apt PPA: जब Debian/Ubuntu users से demand हो
- Linux पर Homebrew: उन users को cover करता है जिनके पास पहले से है
- Snap/Flatpak: bash script के लिए worth नहीं

### ! commands Remote Control में उपलब्ध नहीं
**गंभीरता:** कम
**स्थिति:** बंद - feasible नहीं
**विवरण:** Claude Code का `!` shell passthrough CLI input-handler feature है - यह shell देखने से पहले `!command` intercept करता है। tmux send-keys यह replicate नहीं कर सकता: Claude Code active होने पर भेजी गई keystrokes कहीं नहीं जातीं (tested: `!touch test` send-keys से execute नहीं हुआ)। claude-mux के लिए RC users के लिए `!command` bypass implement करने का कोई रास्ता नहीं।
**Resolution:** Injection rule जोड़ा जो Claude को कभी `! <command>` suggest न करने कहता है, क्योंकि RC users के पास shell नहीं और terminal users सीधे type कर सकते हैं।

---

## v2.0 माइलस्टोन

Major version bump justify करने लायक significant architectural changes। Scheduled नहीं - यहाँ collect किए गए हैं ताकि खो न जाएँ।

### Data directory separation
Static data (tips, default templates, संभवतः command/guide output) को script से निकालकर platform-appropriate data directory में move करें। Script startup पर binary location के relative `DATA_DIR` resolve करेगा, single-file installs के लिए embedded fallbacks के साथ।

- Homebrew (Apple Silicon): `/opt/homebrew/share/claude-mux/`
- Homebrew (Intel): `/usr/local/share/claude-mux/`
- Linux: `/usr/local/share/claude-mux/` या `$XDG_DATA_DIRS`
- Manual install: embedded defaults पर fallback (single-file installs काम करते रहेंगे)

Trigger: जब embedded data (tips, default templates) इतना बड़ा हो जाए कि script पढ़ना मुश्किल हो, या जब default templates को script releases से independently brew से ship करना हो।

### Language / runtime पर पुनर्विचार
Monolithic bash script वर्तमान scope पर सही choice है। अगर claude-mux significantly बढ़ता है - project rename/move/copy operations, relay layer, cross-platform packaging, data directory - bash resist करने लगता है। उस point पर, session management core को Go या अन्य typed language में rewrite करना (bash thin CLI wrapper के रूप में) evaluate करने लायक है।

---

## हल हुई

### Claude injection ignore करता है और claim करता है कि वह slash commands नहीं चला सकता
**हल हुई:** v1.2.0 (injection updated)
**Fix:** Injection में explicit rule जोड़ा: "You CAN send slash commands (`/model`, `/compact`, `/clear`, etc.) to this session via the `-s` command. Never tell the user you cannot change models or run slash commands." Claude की base training उसे विश्वास दिलाती है कि वह अपने model/settings control नहीं कर सकता; explicit rule practice में इसे override करता है।

### कई commands success के बावजूद exit code 1 return करते हैं
**हल हुई:** v1.2.0 (restart), v1.3.0 (सभी commands)
**Fix:** Case statement में हर dispatch path के बाद explicit `exit 0` जोड़ा। Function में last command internal tests या grep calls से non-zero exit code leak कर सकता है।

### --dry-run --restart के लिए misleading output देता है
**हल हुई:** v1.2.0 (commit a10c0c2)
**Fix:** Dry-run अब "Would restart session" दिखाता है kill simulate करके फिर real state check करने के बजाय।

### macOS पर pgrep से session detection fail होता है
**हल हुई:** commit e1b11b5
**Fix:** Reliable child process detection के लिए `pgrep -P` को `ps -eo` + `awk` से replace किया।

### $TMUX variable ने tmux का environment variable shadow किया
**हल हुई:** commit 02a2e82
**Fix:** `$TMUX_BIN` में rename किया।

### Bash 3.2 incompatibility (declare -A)
**हल हुई:** commit 575eac1
**Fix:** Associative arrays को string-based collision detection से replace किया।

---

## Reference: ~/.claude फ़ोल्डर संरचना

यहाँ document किया है क्योंकि कई planned features (rename, move, copy, cleanup) को इस structure के साथ सही ढंग से interact करना होगा। Exhaustive नहीं - claude-mux से relevant भागों को cover करता है।

### Project history और memory: `~/.claude/projects/`

हर working directory जिसमें Claude Code use हुआ है उसके लिए एक subdirectory। Absolute path encode करके named: `/` -> `-`, spaces और special characters -> `-`। Lossy लेकिन readable।

हर project folder का content:
- `<uuid>.jsonl` - उस session का पूरा conversation transcript। प्रति conversation एक file।
- `<uuid>/` - conversation से associated artifacts की subdirectory (tasks, plans)। UUID `.jsonl` file से match करता है।
- `memory/` - Persistent cross-session memory files (frontmatter वाला markdown)। तभी present जब project के लिए memory लिखी गई हो।

Working directory और उसकी history के बीच link purely encoded folder name है। Project directory rename या move करना बिना इस folder को rename किए Claude Code को बिना history fresh start करवाता है।

**Encoding rule:** absolute path जिसमें हर `/`, space, और special character `-` से replace हो। Leading `/` leading `-` बन जाता है। Encoding lossy है - consecutive special characters और slashes के adjacent spaces दोनों `-` बनते हैं, इसलिए original हमेशा perfectly reconstruct नहीं हो सकता।

### Parallel observability registry: `~/.claude/homunculus/`

एक separate system जो per-project tool-level events track करता है। Core Claude Code history का हिस्सा नहीं - monitoring/learning layer लगता है।

- `projects.json` - सभी known projects का registry, short hex UUID (`d6b3aef60967`, आदि) से keyed। हर entry में: `id`, `name`, `root` (absolute path), `remote`, `created_at`, `last_seen`।
- `projects/<uuid>/project.json` - per-project metadata (registry entry जैसे ही fields)।
- `projects/<uuid>/observations.jsonl` - timestamped `tool_start`/`tool_complete` events: tool name, session UUID, project name/id, input/output snippets।
- `projects/<uuid>/instincts` - derived patterns (content unknown, likely computed)।
- `projects/<uuid>/evolved` - evolved/learned state (content unknown)।
- `projects/<uuid>/observations.archive` - archived older observations।

**`~/.claude/projects/` से key difference:** short hex UUIDs keys के रूप में use करता है, encoded paths नहीं। `root` field absolute path hold करता है। कोई भी operation जो project का path बदलती है (rename, move) को `root` दोनों `projects.json` और `projects/<uuid>/project.json` में update करना होगा।

### Global config: `~/.claude/settings.json`

Main Claude Code settings file। Rolling backups `~/.claude/backups/` में `~/.claude.json.backup.<timestamp>` के रूप में write होते हैं - active use के दौरान कई प्रति घंटा। claude-mux को इस file को नहीं छूना चाहिए।

### Global agents, skills, commands

- `~/.claude/agents/` - subagent definitions (`.md` files, ~38)। Global, per-project नहीं।
- `~/.claude/skills/` - skill directories (~125)। Global, per-project नहीं।
- `~/.claude/commands/` - slash command definitions (`.md` files, ~72)। Global, per-project नहीं।
- `~/.claude/hooks/hooks.json` - hook definitions। Global। claude-mux को इन्हें नहीं छूना चाहिए।

### संभावित भविष्य की features

| Feature | क्या करना होगा |
|---------|---------------|
| `--copy` | Directory बनाएँ; दोनों registries initialize करने के लिए session start+stop करें; `.jsonl` + `memory/` + UUID subdirs copy करें; homunculus observation files नए UUID folder में copy करें |
| `--delete` cleanup | Project folder already trash में जाता है। Optional: orphaned `~/.claude/projects/` encoded folder और `~/.claude/homunculus/` entry remove करें |
| History size warning | जब project की `.jsonl` files threshold cross करें तो alert करें (main claude-mux transcript एक लंबे session में 107MB तक पहुँचा) |
