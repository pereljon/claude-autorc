# 已知问题

[English](../docs/ISSUES.md) · [Español](ISSUES.es.md) · [Français](ISSUES.fr.md) · [Deutsch](ISSUES.de.md) · [Português](ISSUES.pt-BR.md) · [日本語](ISSUES.ja.md) · [한국어](ISSUES.ko.md) · [Italiano](ISSUES.it.md) · [Русский](ISSUES.ru.md) · **中文** · [עברית](ISSUES.he.md) · [العربية](ISSUES.ar.md) · [हिन्दी](ISSUES.hi.md)

## 未解决

### 幽灵消息重放导致意外操作
**严重程度：** 高
**状态：** 未解决 - 无法从 claude-mux 侧完全修复
**描述：** 用户发送的"stop all sessions"已在 10 条消息前处理。后来，当 claude-mux -s 通过 tmux send-keys 发送 `/model haiku` 时，Claude 收到了系统消息"stop all sessions/model haiku"并尝试关闭会话 - 这不是用户请求的操作。
**可能原因：**
- Claude Code 的中断处理可能将旧上下文与新 slash 命令输入拼接
- 包含旧命令的对话历史可能在系统事件发生时混淆 Claude
**潜在缓解方案：** 添加注入规则："绝不重新执行对话中已处理过的命令。如果系统消息重复了之前交流中的文本，忽略它。" 尚未实现 - 效果不确定，因为这是 Claude Code 的内部行为。

### 首次 /exit 响应缓慢
**严重程度：** 低
**状态：** 未解决 - 观察中
**描述：** 首次 `--restart` 触发 `WARN: Claude did not exit within 30s` 并回退到强制终止。后续重启在约 1 秒内退出。可能是 `/exit` 在 Claude 的提示就绪接收之前就被发送的竞态条件。
**解决方法：** 30 秒超时 + 强制终止可以处理。会话正常重新启动。

### claude_running_in_session 只检查 2 层深度
**严重程度：** 低
**状态：** 未解决 - 当前使用可接受
**描述：** 进程树遍历检查 pane_pid -> 子进程 -> 孙进程。如果 Claude 在树中更深的位置（例如额外的 shell 包装器），检测会失败。当前启动路径恰好是 2 层（bash -> claude），所以实际上可以工作。
**解决方法：** 目前不需要。修复需要递归遍历或 `pgrep -a`。

### 安装程序升级体验可以更智能
**严重程度：** 低
**状态：** 未解决 - 未来改进
**描述：** 重新安装时，安装程序检测到现有配置并跳过提示。但它不会提供查看当前设置、合并新版本中添加的新配置选项，或让用户选择性更新值。用户必须手动编辑 `~/.claude-mux/config` 以获取后续版本引入的新设置。
**潜在改进：**
- 升级时显示当前配置值
- 提供添加旧配置中不存在的新设置（带默认值）
- 选项 B：使用现有配置值预填充提示并让用户更改

### 翻译文件需要 v1.10-v1.12 更新
**严重程度：** 低
**状态：** 未解决 - 翻译尚未更新
**描述：** 所有 12 个翻译文件（`translations/README.*.md`）落后了几个版本（v1.10-v1.12）。需要反映的变更：
- curl 作为主要的快速开始（一行命令）
- 新的安装部分结构（推荐 curl，Homebrew 作为 macOS 备选）
- `--hide`/`--delete`/`--protect` 使用会话名而非路径（v1.11.0）
- 新的对话示例：rename、save-as-template、tip、enable/disable tips、update
- 需求："Apple Silicon or Intel"（不仅是 Apple Silicon）
- 新的"更多"部分链接 FAQ、ISSUES、CHANGELOG
- 需要创建 FAQ 和 ISSUES 翻译

### 代码审查延迟问题（v1.9.0）
**严重程度：** 低-中
**状态：** 在 v1.10.0 中已解决 - M3、M4、M9/L8、L3、L9 已修复；L4、L5、L6、L7、M7 已添加注释处理

### 项目重命名/移动与历史保留
**严重程度：** 低
**状态：** 在 v1.10.0 中已解决 - `--rename OLD NEW` 和 `--move SRC DEST` 已实现

### 带历史的项目复制
**严重程度：** 低
**状态：** 未解决 - 计划功能，需要调查
**描述：** 复制项目（包括 Claude Code 历史和记忆）比重命名/移动更复杂，因为目标需要建立新的 UUID。
**建议方案：**
1. 创建新项目目录（可选 git init 和模板）
2. 在其中启动并立即停止会话 - Claude Code 初始化 `~/.claude/projects/-encoded-new-path/` 并创建新的 UUID 和 homunculus 条目
3. 将 `.jsonl` 历史文件从源 `~/.claude/projects/` 文件夹复制到目标文件夹
4. 复制 `memory/` 文件夹内容 - 纯 markdown，无嵌入 UUID，可安全直接复制
5. 将 UUID 子目录（任务/计划产物）与其 `.jsonl` 文件一起复制
6. 对于 homunculus：将 `observations.jsonl`、`instincts`、`evolved`、`observations.archive` 从源 `~/.claude/homunculus/projects/<src-uuid>/` 复制到新目标的 homunculus 文件夹 - 保留步骤 2 中分配的新项目 UUID
**需要测试的开放问题：**
- `.jsonl` 文件是否在内容或元数据中嵌入了源项目路径？如果是，复制的历史会引用旧路径。
- UUID 子目录是否从 `.jsonl` 文件中按 UUID 引用？如果是，必须在原始 UUID 下复制，而不是重新映射。
- Claude Code 是否读取项目文件夹中的所有 `.jsonl` 文件，还是只读取匹配活动会话 UUID 的那个？
- `~/.claude/homunculus/projects/<uuid>/evolved` 和 `instincts` 包含什么 - 是派生/计算的还是对用户有意义的？值得在复制中保留吗？
- 是否有其他内部引用会在简单文件复制中断裂？
**前提条件：** 在实现之前测试以上内容，以避免发布一个产生微妙损坏历史的复制命令。

### 每日提示
**严重程度：** 低
**状态：** 在 v1.10.0 中已解决 - `--tip`、`TIP_OF_DAY`、`TIP_MODE`、每日门控、会话启动时推送已实现

### 回复时间戳
**严重程度：** 低
**状态：** 未解决 - 实现前需讨论
**描述：** 可选配置变量（`REPLY_TIMESTAMP=false` 默认）在系统提示中注入指令，告诉 Claude 在每个回复开头通过 `date '+%Y-%m-%d %H:%M'` 添加当前日期和时间。
**权衡：** 需要在每次回复开始时调用 bash 工具（少量开销）。替代方案：在提示中注入会话启动时间（免费，但在长会话中会偏移）。
**注意：** 项目级 CLAUDE.md 指令（如分析模板中的）是更轻量的版本 - 仅用于需要它的项目。配置变量使其全局化。

### 演示视频
**严重程度：** 低
**状态：** 未解决 - 计划资产
**描述：** 屏幕录制，展示从 curl 安装到常用和有趣命令的 claude-mux，同时显示终端和 Remote Control。
**格式：** 分屏，单镜头。左侧是终端（完整 claude-mux 会话），右侧是通过 QuickTime 镜像的 iPhone RC。两者同时直播 - 观众看到 RC 中的操作立即反映在终端中，反之亦然。
**参见：** `internal/demo-script.md` 获取完整的分镜大纲。
**备注：**
- 关键镜头是在手机 RC 中打字并观看终端实时响应
- 除了裁剪外不需要编辑 - 单次连续录制
- 托管在 YouTube + 嵌入 README；也可用于 Product Hunt 发布

### 提交到 homebrew-core 以获得 brew.sh 列表
**严重程度：** 低
**状态：** 未来 - 等待采用
**描述：** claude-mux 目前通过个人 tap（`pereljon/tap`）分发。要出现在 brew.sh 上，需要被 homebrew-core 接受。Homebrew 的知名度门槛通常要求几百个 GitHub star 才能接受 shell 脚本工具提交；低 star 的提交会被快速关闭。
**准备好时：**
- 确保 formula 通过 `brew audit --strict --new`
- 向 `Homebrew/homebrew-core` 提交包含 formula 的 PR
- 注意：仅限 macOS 的工具面临更严格的审查；Linux 支持（见下文）会有帮助

### curl 安装支持（macOS + Linux）
**严重程度：** 低
**状态：** 在 v1.10.0 中已解决 - curl 安装已实现，release-assets 工作流已添加，README 已更新

### 仅限 macOS - 不支持 Linux/systemd
**严重程度：** 中
**状态：** 未解决 - 部分解决（路径检测已完成，LaunchAgent/安装程序仍仅限 macOS）
**描述：** 使用 macOS LaunchAgent (launchd) 和 macOS 特定工具。路径检测已重构为使用 `command -v`（不再硬编码 `/opt/homebrew/bin`），因此核心脚本现在可在 tmux 和 claude 在 PATH 中的任何平台上工作。LaunchAgent 和安装程序仍然是 macOS 特定的。
**剩余：** systemd 用户单元、XDG Autostart 回退、安装程序中的 `uname -s` 分发。
**包策略（v1.10+）：**
- curl 安装：通用回退，随处可用（见上文）
- AUR：低工作量，对 Arch/Manjaro 目标用户覆盖面大
- apt PPA：当 Debian/Ubuntu 用户有需求时
- Linux 上的 Homebrew：覆盖已经使用它的用户
- Snap/Flatpak：对 bash 脚本不值得

### ! 命令在 Remote Control 中不可用
**严重程度：** 低
**状态：** 已关闭 - 不可行
**描述：** Claude Code 的 `!` shell 直通是 Claude Code CLI 输入处理器的功能 - 它在 shell 看到 `!command` 之前拦截它。tmux send-keys 无法复制此功能：当 Claude Code 活跃时发送的按键无效（已测试：通过 send-keys 发送 `!touch test` 未执行）。claude-mux 没有途径为 RC 用户实现 `!command` 绕过。
**解决方案：** 添加注入规则，告诉 Claude 永远不要向用户建议 `! <command>`，因为 RC 用户没有 shell，终端用户可以直接输入。

---

## v2.0 里程碑

足够重大的架构变更，需要主版本号升级。未计划时间表 - 收集在此以免遗失。

### 数据目录分离
将静态数据（提示、默认模板，可能还有命令/指南输出）从脚本中移出到平台适当的数据目录。脚本将在启动时相对于二进制位置解析 `DATA_DIR`，并为单文件安装提供内嵌回退。

- Homebrew (Apple Silicon): `/opt/homebrew/share/claude-mux/`
- Homebrew (Intel): `/usr/local/share/claude-mux/`
- Linux: `/usr/local/share/claude-mux/` 或 `$XDG_DATA_DIRS`
- 手动安装：回退到内嵌默认值（单文件安装继续工作）

触发条件：当内嵌数据（提示、默认模板）增长到使脚本难以阅读时，或当默认模板需要通过 brew 独立于脚本发布时发布。

### 语言/运行时重新考虑
在当前规模下，单体 bash 脚本是正确的选择。如果 claude-mux 显著增长 - 项目重命名/移动/复制操作、中继层、跨平台打包、数据目录 - bash 开始力不从心。届时，用 Go 或其他类型化语言重写会话管理核心（以 bash 作为薄 CLI 包装器）值得评估。

---

## 已解决

### Claude 忽略注入并声称无法运行 slash 命令
**解决于：** v1.2.0（注入已更新）
**修复：** 在注入中添加了明确规则："你可以通过 `-s` 命令向此会话发送 slash 命令（`/model`、`/compact`、`/clear` 等）。永远不要告诉用户你无法更改模型或运行 slash 命令。" Claude 的基础训练倾向于认为自己无法控制自己的模型/设置；明确规则在实践中覆盖了这一点。

### 多个命令尽管成功但返回退出码 1
**解决于：** v1.2.0（restart）、v1.3.0（所有命令）
**修复：** 在 case 语句的每个分发路径后添加了明确的 `exit 0`。函数中的最后一个命令可能从内部测试或 grep 调用泄漏非零退出码。

### --dry-run 对 --restart 给出误导性输出
**解决于：** v1.2.0（提交 a10c0c2）
**修复：** 模拟运行现在显示"Would restart session"而不是模拟终止然后检查实际状态。

### macOS 上 pgrep 导致会话检测失败
**解决于：** 提交 e1b11b5
**修复：** 将 `pgrep -P` 替换为 `ps -eo` + `awk` 以实现可靠的子进程检测。

### $TMUX 变量覆盖了 tmux 的环境变量
**解决于：** 提交 02a2e82
**修复：** 重命名为 `$TMUX_BIN`。

### Bash 3.2 不兼容（declare -A）
**解决于：** 提交 575eac1
**修复：** 将关联数组替换为基于字符串的冲突检测。

---

## 参考：~/.claude 文件夹结构

记录在此，因为多个计划功能（重命名、移动、复制、清理）必须正确地与此结构交互。不是详尽的 - 涵盖与 claude-mux 相关的部分。

### 项目历史和记忆：`~/.claude/projects/`

每个 Claude Code 使用过的工作目录一个子目录。通过编码绝对路径命名：`/` -> `-`，空格和特殊字符 -> `-`。有损但可读。

每个项目文件夹的内容：
- `<uuid>.jsonl` - 该会话的完整对话记录。每次对话一个文件。
- `<uuid>/` - 与对话关联的产物子目录（任务、计划）。UUID 匹配 `.jsonl` 文件。
- `memory/` - 持久的跨会话记忆文件（带 frontmatter 的 markdown）。仅在为项目写入过记忆时存在。

工作目录与其历史之间的关联纯粹是编码后的文件夹名。重命名或移动项目目录而不重命名此文件夹会导致 Claude Code 从零开始，没有历史。

**编码规则：** 绝对路径，每个 `/`、空格和特殊字符替换为 `-`。开头的 `/` 变成开头的 `-`。编码是有损的 - 连续的特殊字符和斜杠相邻的空格都变成 `-`，因此原始路径不一定能完美重建。

### 并行可观测性注册表：`~/.claude/homunculus/`

一个跟踪每个项目工具级事件的独立系统。不是核心 Claude Code 历史的一部分 - 似乎是监控/学习层。

- `projects.json` - 所有已知项目的注册表，以短十六进制 UUID（`d6b3aef60967` 等）为键。每个条目包含：`id`、`name`、`root`（绝对路径）、`remote`、`created_at`、`last_seen`。
- `projects/<uuid>/project.json` - 每个项目的元数据（与注册表条目相同的字段）。
- `projects/<uuid>/observations.jsonl` - 带时间戳的 `tool_start`/`tool_complete` 事件：工具名称、会话 UUID、项目名称/id、输入/输出片段。
- `projects/<uuid>/instincts` - 衍生模式（内容未知，可能是计算的）。
- `projects/<uuid>/evolved` - 演化/学习状态（内容未知）。
- `projects/<uuid>/observations.archive` - 归档的旧观测数据。

**与 `~/.claude/projects/` 的关键区别：** 使用短十六进制 UUID 作为键，而非编码路径。`root` 字段保存绝对路径。任何更改项目路径的操作（重命名、移动）必须更新 `projects.json` 和 `projects/<uuid>/project.json` 中的 `root`。

### 全局配置：`~/.claude/settings.json`

主 Claude Code 设置文件。滚动备份写入 `~/.claude/backups/`，格式为 `~/.claude.json.backup.<timestamp>` - 活跃使用期间每小时数次。claude-mux 不应触碰此文件。

### 全局 agents、skills、commands

- `~/.claude/agents/` - 子代理定义（`.md` 文件，约 38 个）。全局的，非项目级。
- `~/.claude/skills/` - 技能目录（约 125 个）。全局的，非项目级。
- `~/.claude/commands/` - slash 命令定义（`.md` 文件，约 72 个）。全局的，非项目级。
- `~/.claude/hooks/hooks.json` - hook 定义。全局的。claude-mux 不应触碰这些。

### 潜在未来功能

| 功能 | 需要操作的部分 |
|------|--------------|
| `--copy` | 创建目录；启动并停止会话以初始化两个注册表；复制 `.jsonl` + `memory/` + UUID 子目录；将 homunculus 观测文件复制到新 UUID 文件夹 |
| `--delete` 清理 | 已将项目文件夹移至回收站。可选：删除孤立的 `~/.claude/projects/` 编码文件夹和 `~/.claude/homunculus/` 条目 |
| 历史大小警告 | 当项目的 `.jsonl` 文件超过阈值时发出警告（主 claude-mux 记录在单个长会话中达到了 107MB） |
