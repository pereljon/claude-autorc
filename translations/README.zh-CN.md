# claude-mux - Claude Code 多路复用器

[English](../README.md) · [Español](README.es.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Português](README.pt-BR.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · **中文** · [עברית](README.he.md) · [العربية](README.ar.md) · [हिन्दी](README.hi.md)

> 注意：此翻译可能落后于英文 README。规范版本请参阅 [README.md](../README.md)。

为你所有项目提供持久的 Claude Code 会话 - 通过 Claude 移动应用从任何地方访问。

一个 shell 脚本，在 tmux 中启动 Claude Code，启用 Remote Control、对话恢复以及会话自管理 - 列出会话、发送斜杠命令、启动新项目、关闭或重启。在任意目录运行 `claude-mux` 即可获得一个可从手机访问的持久会话。

## 快速开始

```bash
./install.sh
```

```bash
claude-mux ~/path/to/your/project
```

或者 `cd` 进入你的项目目录并运行：

```bash
claude-mux
```

就这么简单 - 你已经进入了一个启用了 Remote Control 的、持久的、会话感知的 Claude 会话。

claude-mux 是一个独立的 bash 脚本，除 tmux 和 Claude Code 之外没有其他依赖。

## 它做什么

1. **启用 Remote Control 的持久 tmux 会话** - 在 tmux 中以 `--remote-control` 启动 Claude Code，因此每个会话都可以通过 Claude 移动应用访问
2. **对话恢复** - 如果之前在该目录中运行过 Claude，会在启用 Remote Control 的新 tmux 会话中恢复上一次对话（`claude -c`），保留你的上下文
3. **会话管理** - 列出活动会话（`-l`）或包括尚未运行的空闲项目在内的所有项目（`-L`）、关闭（`--shutdown`）、重启（`--restart`）、切换权限模式（`--permission-mode`）、附加（`-t`）、向会话发送斜杠命令（`-s`）
4. **Claude 自管理** - 每个会话都被注入了一段系统提示，使 Claude 可以直接在对话提示（终端或移动应用）中运行上述全部命令：
   - a. 列出运行中的会话和所有项目
   - b. 启动新会话、创建新项目
   - c. 向自身或其他会话发送斜杠命令（针对 [斜杠命令在 RC 下不能原生工作](https://github.com/anthropics/claude-code/issues/30674) 的变通方案）
   - d. 关闭、重启或切换会话的权限模式
5. **主会话** - 一个轻量级、始终运行的会话，位于你的根目录中，登录时启动（可通过 `LAUNCHAGENT_MODE` 配置）。让 Remote Control 始终可从 Claude 移动应用访问，并能管理你的所有其他会话。受保护，不会被意外关闭。
6. **新项目创建** - `claude-mux -n DIRECTORY` 创建一个开箱即用的项目，配置好 git、`.gitignore` 和权限模式（`-p` 在目录不存在时创建它）。任意运行中的会话都可以创建新项目 - 让 Claude 在你的任意 GitHub 账户中建好仓库就开始编码，从任何地方都行
7. **CLAUDE.md 模板** - 在 `~/.claude-mux/templates/` 中维护一个 CLAUDE.md 指令文件库（如 `web.md`、`python.md`、`default.md`），并自动应用到新项目。使用 `--template NAME` 选择特定模板，或让默认模板生效
8. **SSH 账户感知** - 从 `~/.ssh/config` 注入 GitHub SSH host 别名，让 Claude 知道哪些账户可用于 git 操作
9. **自动批准权限** - claude-mux 将自身添加到每个项目的 `.claude/settings.local.json` 允许列表中，因此 Claude 可以无需提示就运行 claude-mux 命令
10. **野生进程迁移** - 如果目标目录中已有运行在 tmux 之外的 Claude，会终止它并在受管的 tmux 会话中重新启动（通过 `claude -c` 恢复对话）
11. **Tmux 体验改进** - 会话默认配置了鼠标支持、50k 滚动缓冲区、剪贴板集成、256 色、缩短的 escape 延迟、扩展按键（Shift+Enter）、活动监视和终端标签标题 - 全部可在 `~/.claude-mux/config` 中配置

> **注意：** 这与 `claude --worktree --tmux` 不同，后者为隔离的 git worktree 创建一个 tmux 会话。claude-mux 管理的是面向你实际项目目录的持久会话，并附带 Remote Control 和系统提示注入。

### 主会话

一个位于 `$BASE_DIR` 的通用会话。当 `LAUNCHAGENT_MODE=home` 时在登录时自动启动，或在 `$BASE_DIR` 中手动运行 `claude-mux` 启动。让你拥有一个始终就绪、可从手机访问的 Claude 会话，而不必为每个项目都启动会话。

主会话始终是 **受保护的** - `--shutdown home` 会拒绝在没有 `--force` 的情况下停止它，无论它是如何启动的。受保护的会话在 `-l`/`-L` 输出中以 `*` 标记（例如 `active*`）。

## 系统要求

- macOS（Apple Silicon）
- [tmux](https://github.com/tmux/tmux) - `brew install tmux`
- [Claude Code](https://claude.ai/code) - `brew install claude`

## 安装

```bash
./install.sh
```

交互式安装程序会询问你的 Claude 项目所在位置、登录时是否启动主会话、以及使用哪个模型。它会把 `claude-mux` 安装到 `~/bin`，创建 `~/.claude-mux/config`，并设置 LaunchAgent。

使用 `--non-interactive` 跳过提示并接受默认值。

选项：

```bash
./install.sh --non-interactive                     # 跳过提示，使用默认值
./install.sh --base-dir ~/work/claude              # 使用不同的根目录
./install.sh --launchagent-mode none               # 禁用 LaunchAgent 行为
./install.sh --home-model haiku                    # 主会话使用 Haiku
./install.sh --no-launchagent                      # 完全跳过 LaunchAgent 安装
```

LaunchAgent 在登录时运行 `claude-mux --autolaunch`，并有 45 秒的启动延迟，以便系统服务初始化。

## 用法

```bash
claude-mux                       # 在当前目录启动 Claude 并附加
claude-mux ~/projects/my-app     # 在指定目录启动 Claude 并附加
claude-mux -d ~/projects/my-app  # 同上（显式形式）
claude-mux -a                    # 启动 BASE_DIR 下所有受管会话
claude-mux -n ~/projects/app     # 创建一个新的 Claude 项目并附加
claude-mux -n ~/new/path/app -p  # 同上，并创建目录及其父目录
claude-mux -n ~/app --template web  # 使用指定 CLAUDE.md 模板创建新项目
claude-mux --list-templates      # 显示可用的 CLAUDE.md 模板
claude-mux -t my-app             # 附加到一个已存在的 tmux 会话
claude-mux -s my-app '/model sonnet' # 向会话发送斜杠命令
claude-mux -l                    # 按状态列出会话（active、running、stopped）
claude-mux -L                    # 列出所有项目（活动 + 空闲）
claude-mux --shutdown            # 优雅退出所有受管 Claude 会话
claude-mux --shutdown my-app     # 关闭指定会话
claude-mux --shutdown a b c      # 关闭多个会话
claude-mux --shutdown home --force  # 关闭受保护的主会话
claude-mux --restart             # 重启此前正在运行的会话
claude-mux --restart my-app      # 重启指定会话
claude-mux --restart a b c       # 重启多个会话
claude-mux --permission-mode plan my-app    # 以 plan 模式重启会话
claude-mux --permission-mode dangerously-skip-permissions my-app  # yolo 模式
claude-mux --dry-run             # 预览动作但不执行
claude-mux --version             # 打印版本号
claude-mux --help                # 显示所有选项
claude-mux --guide               # 显示供会话内使用的对话式命令

# 跟踪日志
tail -f ~/Library/Logs/claude-mux.log
```

从终端运行时，输出会实时镜像到 stdout。通过 LaunchAgent 运行时，输出仅写入日志文件。

## 会话状态

| 状态 | 含义 |
|--------|---------|
| `active` | tmux 会话存在、Claude 正在运行，并且有本地 tmux 客户端已附加 |
| `running` | tmux 会话存在且 Claude 正在运行（无本地客户端附加） |
| `stopped` | tmux 会话存在但 Claude 已退出 |
| `idle` | `BASE_DIR` 下存在 `.claude/` 项目，但没有运行中的 claude-mux tmux 会话（仅在 `-L` 中显示） |

任何状态末尾的 `*` 表示该会话受保护，需要 `--force` 才能关闭（例如 `active*`、`running*`）。主会话始终受保护。

在已有运行会话的目录中运行 `claude-mux` 会附加到该会话。多个终端可以附加到同一个会话（标准 tmux 行为）。

## Claude 提示示例

由于每个会话都注入了 claude-mux 命令，你可以直接在对话提示中管理会话 - 在终端或通过移动应用都行：

```
你："哪些会话在运行？"
Claude：运行 `claude-mux -l` 并展示结果

你："给我看所有项目"
Claude：运行 `claude-mux -L` 并展示结果

你："为我的 api-server work 项目启动一个会话"
Claude：运行 `claude-mux -d ~/Claude/work/api-server --no-attach`

你："创建一个名为 mobile-app 的新个人项目"
Claude：运行 `claude-mux -n ~/Claude/personal/mobile-app -p --no-attach`

你："我有哪些模板？"
Claude：运行 `claude-mux --list-templates` 并展示结果

你："使用 web 模板创建一个名为 api-server 的新工作项目"
Claude：运行 `claude-mux -n ~/Claude/work/api-server -p --template web --no-attach`

你："把所有会话切换到 Sonnet"
Claude：对每个运行中的会话运行 `claude-mux -s SESSION '/model sonnet'`

你："关闭 data-pipeline 会话"
Claude：运行 `claude-mux --shutdown data-pipeline`

你："重启卡住的 web-dashboard 会话"
Claude：运行 `claude-mux --restart web-dashboard`

你："把 api-server 会话切换到 plan 模式"
Claude：运行 `claude-mux --permission-mode plan api-server`

你："对 data-pipeline 会话开 yolo"
Claude：运行 `claude-mux --permission-mode dangerously-skip-permissions data-pipeline`

你："在后台启动 data-pipeline 会话"
Claude：运行 `claude-mux -d ~/Claude/work/data-pipeline --no-attach`

你："启动我所有的项目"
Claude：运行 `claude-mux -a`（确认后 - 这会启动所有受管项目）
```

## 配置

首次运行时会自动创建 `~/.claude-mux/config`，所有设置都已注释。编辑该文件即可覆盖任何默认值 - 无需直接修改脚本。

| 变量 | 默认值 | 说明 |
|----------|---------|-------------|
| `BASE_DIR` | `$HOME/Claude` | 用于扫描 Claude 项目（包含 `.claude/` 的目录）的根目录 |
| `LOG_DIR` | `$HOME/Library/Logs` | `claude-mux.log` 文件所在目录 |
| `DEFAULT_PERMISSION_MODE` | `auto` | 在每个项目中设置 Claude 的 `permissions.defaultMode`。有效值：`default`、`acceptEdits`、`plan`、`auto`、`dontAsk`、`bypassPermissions`。设为 `""` 可禁用。 |
| `ALLOW_CROSS_SESSION_CONTROL` | `false` | 为 `true` 时，Claude 会话可向其他会话发送斜杠命令 - 适合多 agent 编排 |
| `TEMPLATES_DIR` | `$HOME/.claude-mux/templates` | 存放 CLAUDE.md 模板文件的目录 |
| `DEFAULT_TEMPLATE` | `default.md` | 应用于新项目（`-n`）的默认模板。设为 `""` 可禁用。 |
| `SLEEP_BETWEEN` | `5` | 使用 `-a` 时各会话启动之间的秒数。如 RC 注册失败可调大。 |
| `HOME_SESSION_MODEL` | `""` | 主会话使用的模型。有效值：`sonnet`、`haiku`、`opus`。留空则继承 Claude 默认值。 |
| `LAUNCHAGENT_MODE` | `home` | 登录时的 LaunchAgent 行为：`none`（什么也不做）或 `home`（启动受保护的主会话）。旧的 `LAUNCHAGENT_ENABLED=true` 等同于 `home`。 |

**Tmux 会话选项**（全部可配置，全部默认启用）：

| 变量 | 默认值 | 说明 |
|----------|---------|-------------|
| `TMUX_MOUSE` | `true` | 鼠标支持 - 滚动、选择、调整窗格大小 |
| `TMUX_HISTORY_LIMIT` | `50000` | 滚动缓冲区行数（tmux 默认是 2000） |
| `TMUX_CLIPBOARD` | `true` | 通过 OSC 52 集成系统剪贴板 |
| `TMUX_DEFAULT_TERMINAL` | `tmux-256color` | 终端类型，确保正确的颜色渲染 |
| `TMUX_EXTENDED_KEYS` | `true` | 扩展按键序列，包括 Shift+Enter（需要 tmux 3.2+） |
| `TMUX_ESCAPE_TIME` | `10` | Escape 键延迟（毫秒，tmux 默认是 500） |
| `TMUX_TITLE_FORMAT` | `#S` | 终端/标签标题格式（`#S` = 会话名，`""` 可禁用） |
| `TMUX_MONITOR_ACTIVITY` | `true` | 当其他会话有活动时通知 |

## 目录结构

通过是否存在 `.claude/` 目录来发现项目，深度不限：

```
~/Claude/
├── work/
│   ├── project-a/          # ✓ 含 .claude/ - 被管理
│   │   └── .claude/
│   ├── project-b/          # ✓ 含 .claude/ - 被管理
│   │   └── .claude/
│   └── -archived/          # ✗ 排除（以 - 开头）
│       └── .claude/
├── personal/
│   ├── project-c/          # ✓ 含 .claude/ - 被管理
│   │   └── .claude/
│   ├── .hidden/            # ✗ 排除（隐藏目录）
│   │   └── .claude/
│   └── project-d/          # ✗ 无 .claude/ - 不是 Claude 项目
├── deep/nested/project-e/  # ✓ 含 .claude/ - 任意深度都能找到
│   └── .claude/
└── ignored-project/        # ✗ 排除（.ignore-claudemux）
    ├── .claude/
    └── .ignore-claudemux
```

会话名由目录名派生：空格变为连字符，非字母数字字符（连字符除外）会被替换，前后多余的连字符会被去除。如果目录名清洗后为空，会被跳过并记录一条警告。

## 会话系统提示

每个 Claude 会话以 `--append-system-prompt` 启动，包含其环境的相关上下文：

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

当 `ALLOW_CROSS_SESSION_CONTROL=true` 时，send 命令会变为允许定向到任意会话，而不仅仅是自身。该 path 是启动时脚本的绝对路径，因此会话不依赖 `PATH`。

## 故障排查

### 会话显示 "Not logged in · Run /login"

这通常发生在首次启动时，macOS keychain 还处于锁定状态（脚本在登录后 keychain 解锁之前运行时常见）。修复方式：

```bash
# 在普通终端解锁 keychain
security unlock-keychain

# 然后在任意一个运行中的会话里完成认证
claude-mux -t <any-session>
# 运行 /login 并完成浏览器流程
```

完成一次认证后，关闭并重新启动所有会话 - 它们会自动获取已存储的凭据。

### 会话未出现在 Claude Code Remote 中

会话必须已认证（不显示 "Not logged in"）。在干净的已认证启动后，几秒内它们就应当出现在 RC 列表里。

### tmux 中的多行输入

`/terminal-setup` 命令无法在 tmux 内运行。claude-mux 默认启用了 tmux 的 `extended-keys`（`TMUX_EXTENDED_KEYS=true`），它在大多数现代终端中支持 Shift+Enter。如果 Shift+Enter 不起作用，可在提示中使用 `\` + Return 输入换行。

### 通过 Remote Control 使用斜杠命令

斜杠命令（如 `/model`、`/clear`）在 RC 会话中 [并未原生支持](https://github.com/anthropics/claude-code/issues/30674)。claude-mux 对此做了变通 - 每个会话都注入了 `claude-mux -s`，让 Claude 通过 tmux 向自己发送斜杠命令。

## 日志

- `~/Library/Logs/claude-mux.log` - 所有脚本动作，附带 UTC 时间戳（可通过 `LOG_DIR` 配置）

如需进行底层 LaunchAgent 调试，请使用 Console.app 或 `log show`。
