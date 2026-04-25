# claude-mux - Claude Code マルチプレクサ

[English](../README.md) · [Español](README.es.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Português](README.pt-BR.md) · **日本語** · [한국어](README.ko.md) · [Italiano](README.it.md) · [Русский](README.ru.md) · [中文](README.zh-CN.md) · [עברית](README.he.md) · [العربية](README.ar.md) · [हिन्दी](README.hi.md)

> 注意: この翻訳は英語版 README より遅れている場合があります。正規版については [README.md](../README.md) を参照してください。

すべてのプロジェクトに対して永続的な Claude Code セッションを提供し、Claude モバイルアプリからどこでもアクセスできるようにします。

Remote Control を有効にした tmux 内で Claude Code を起動するシェルスクリプトです。会話の再開、セッションのセルフ管理 (一覧表示、スラッシュコマンド送信、新規プロジェクト作成、シャットダウン、再起動) に対応します。任意のディレクトリで `claude-mux` を実行すると、スマートフォンからアクセスできる永続セッションを得られます。

## クイックスタート

```bash
./install.sh
```

```bash
claude-mux ~/path/to/your/project
```

または、プロジェクトディレクトリへ `cd` してから実行します:

```bash
claude-mux
```

これだけで、Remote Control が有効化されたセッション認識型の永続的な Claude セッションに入れます。

claude-mux は単一の bash スクリプトで、tmux と Claude Code 以外には依存関係がありません。

## 機能概要

1. **Remote Control 付きの永続的な tmux セッション** - `--remote-control` を有効にして tmux 内で Claude Code を起動するため、すべてのセッションが Claude モバイルアプリからアクセス可能になります
2. **会話の再開** - 該当ディレクトリで Claude が以前実行されていた場合、Remote Control 付きの新しい tmux セッション内で直前の会話を再開し (`claude -c`)、コンテキストを保持します
3. **セッション管理** - アクティブなセッションの一覧 (`-l`) や、まだ起動していない idle 状態を含むすべてのプロジェクトの一覧 (`-L`)、シャットダウン (`--shutdown`)、再起動 (`--restart`)、permission モードの切替 (`--permission-mode`)、アタッチ (`-t`)、セッションへのスラッシュコマンド送信 (`-s`)
4. **Claude のセルフ管理** - 各セッションにはシステムプロンプトが注入され、Claude が会話プロンプト (ターミナルでもモバイルアプリでも) から上記コマンドを直接実行できます:
   - a. 実行中のセッションおよびすべてのプロジェクトの一覧表示
   - b. 新規セッションの起動、新規プロジェクトの作成
   - c. 自分自身または他のセッションへスラッシュコマンドを送信 ([RC 経由ではスラッシュコマンドがネイティブには動作しない](https://github.com/anthropics/claude-code/issues/30674) ことへの回避策)
   - d. セッションのシャットダウン、再起動、permission モードの切替
5. **Home セッション** - ベースディレクトリで常時稼働する軽量なセッションで、ログイン時に起動します (`LAUNCHAGENT_MODE` で設定可能)。Claude モバイルアプリから Remote Control を常に利用可能にし、他のすべてのセッションを管理できます。誤って停止しないよう保護されています
6. **新規プロジェクト作成** - `claude-mux -n DIRECTORY` は git、`.gitignore`、permission モードを設定したコーディング即開始可能なプロジェクトを作成します (`-p` を付けるとディレクトリが存在しない場合に作成)。実行中の任意のセッションから新規プロジェクトを作成可能で、Claude にお好みの GitHub アカウントでリポジトリをセットアップさせ、どこからでもコーディングを開始できます
7. **CLAUDE.md テンプレート** - `~/.claude-mux/templates/` に CLAUDE.md 指示ファイルのライブラリ (例: `web.md`、`python.md`、`default.md`) を維持し、新規プロジェクトに自動適用します。`--template NAME` で特定のテンプレートを指定するか、デフォルトを適用させることもできます
8. **SSH アカウント認識** - `~/.ssh/config` の GitHub SSH ホストエイリアスを注入し、git 操作で利用可能なアカウントを Claude が把握できるようにします
9. **権限の自動承認** - claude-mux は各プロジェクトの `.claude/settings.local.json` の許可リストに自身を追加するため、Claude が claude-mux コマンドを許可確認なしに実行できます
10. **野良プロセスの移行** - 対象ディレクトリで Claude が tmux の外で既に動いている場合、それを終了させて管理対象の tmux セッション内で再起動します (`claude -c` で会話を再開)
11. **tmux の品質向上設定** - 各セッションはマウス対応、50k 行のスクロールバックバッファ、クリップボード連携、256 色、エスケープ遅延の短縮、拡張キー (Shift+Enter)、アクティビティ監視、ターミナルタブタイトルが設定されており、すべて `~/.claude-mux/config` で設定可能です

> **注意:** これは `claude --worktree --tmux` とは異なります。後者は隔離された git worktree 用に tmux セッションを作成するものです。claude-mux は実際のプロジェクトディレクトリの永続セッションを管理し、Remote Control とシステムプロンプトの注入を提供します。

### Home セッション

`$BASE_DIR` で動作する単一の汎用セッションです。`LAUNCHAGENT_MODE=home` の場合はログイン時に自動起動するか、`$BASE_DIR` から `claude-mux` を手動実行することで起動できます。プロジェクトごとにセッションを起動しなくても、スマートフォンからアクセスできる常時待機状態の Claude セッションを 1 つ確保できます。

home セッションは常に**保護**されています。起動方法に関わらず、`--shutdown home` は `--force` なしでは停止を拒否します。保護されているセッションは `-l`/`-L` の出力で `*` 付き (例: `active*`) として表示されます。

## 必要環境

- macOS (Apple Silicon)
- [tmux](https://github.com/tmux/tmux) - `brew install tmux`
- [Claude Code](https://claude.ai/code) - `brew install claude`

## インストール

```bash
./install.sh
```

対話型インストーラは、Claude プロジェクトの配置場所、ログイン時に home セッションを開始するか、どのモデルを使うかを尋ねます。`claude-mux` を `~/bin` にインストールし、`~/.claude-mux/config` を作成し、LaunchAgent をセットアップします。

プロンプトをスキップしてデフォルトを受け入れるには `--non-interactive` を使用します。

オプション:

```bash
./install.sh --non-interactive                     # プロンプトをスキップしてデフォルトを使用
./install.sh --base-dir ~/work/claude              # 別のベースディレクトリを使用
./install.sh --launchagent-mode none               # LaunchAgent の動作を無効化
./install.sh --home-model haiku                    # home セッションに Haiku を使用
./install.sh --no-launchagent                      # LaunchAgent のインストールを完全にスキップ
```

LaunchAgent はログイン時に `claude-mux --autolaunch` を実行し、システムサービスの初期化を待つために 45 秒の起動遅延を入れます。

## 使い方

```bash
claude-mux                       # カレントディレクトリで Claude を起動してアタッチ
claude-mux ~/projects/my-app     # 指定ディレクトリで Claude を起動してアタッチ
claude-mux -d ~/projects/my-app  # 同上 (明示形式)
claude-mux -a                    # BASE_DIR 配下の管理対象セッションをすべて起動
claude-mux -n ~/projects/app     # 新規 Claude プロジェクトを作成してアタッチ
claude-mux -n ~/new/path/app -p  # 同上、必要なら親ディレクトリも作成
claude-mux -n ~/app --template web  # 特定の CLAUDE.md テンプレートで新規プロジェクトを作成
claude-mux --list-templates      # 利用可能な CLAUDE.md テンプレートを表示
claude-mux -t my-app             # 既存の tmux セッションにアタッチ
claude-mux -s my-app '/model sonnet' # セッションにスラッシュコマンドを送信
claude-mux -l                    # ステータス別にセッションを一覧 (active、running、stopped)
claude-mux -L                    # すべてのプロジェクトを一覧 (active + idle)
claude-mux --shutdown            # 管理対象の Claude セッションをすべて正常終了
claude-mux --shutdown my-app     # 特定のセッションをシャットダウン
claude-mux --shutdown a b c      # 複数のセッションをシャットダウン
claude-mux --shutdown home --force  # 保護された home セッションをシャットダウン
claude-mux --restart             # 動作していたセッションを再起動
claude-mux --restart my-app      # 特定のセッションを再起動
claude-mux --restart a b c       # 複数のセッションを再起動
claude-mux --permission-mode plan my-app    # plan モードでセッションを再起動
claude-mux --permission-mode dangerously-skip-permissions my-app  # yolo モード
claude-mux --dry-run             # 実行せずアクションをプレビュー
claude-mux --version             # バージョンを表示
claude-mux --help                # すべてのオプションを表示
claude-mux --guide               # セッション内で使う会話コマンド一覧を表示

# ログを監視
tail -f ~/Library/Logs/claude-mux.log
```

ターミナルから実行するとリアルタイムで stdout に出力もミラーされます。LaunchAgent 経由で実行された場合はログファイルにのみ出力されます。

## セッションのステータス

| ステータス | 意味 |
|--------|---------|
| `active` | tmux セッションが存在し、Claude が動作しており、ローカルの tmux クライアントがアタッチされている |
| `running` | tmux セッションが存在し、Claude が動作している (ローカルクライアントは未アタッチ) |
| `stopped` | tmux セッションは存在するが、Claude が終了している |
| `idle` | `BASE_DIR` 配下に `.claude/` プロジェクトが存在するが、claude-mux の tmux セッションが動作していない (`-L` の場合のみ表示) |

ステータス末尾の `*` は、そのセッションが保護されており、シャットダウンに `--force` が必要であることを示します (例: `active*`、`running*`)。home セッションは常に保護されています。

すでに動作中のセッションがあるディレクトリで `claude-mux` を実行すると、そのセッションへアタッチします。複数のターミナルから同じセッションへアタッチできます (標準的な tmux の挙動)。

## Claude プロンプトの例

各セッションには claude-mux のコマンドが注入されているため、ターミナルでもモバイルアプリでも、会話プロンプトから直接セッションを管理できます:

```
あなた: "実行中のセッションは?"
Claude: `claude-mux -l` を実行して結果を表示

あなた: "全プロジェクトを表示して"
Claude: `claude-mux -L` を実行して結果を表示

あなた: "work プロジェクトの api-server 用にセッションを起動して"
Claude: `claude-mux -d ~/Claude/work/api-server --no-attach` を実行

あなた: "mobile-app という個人プロジェクトを新規作成して"
Claude: `claude-mux -n ~/Claude/personal/mobile-app -p --no-attach` を実行

あなた: "どんなテンプレートがある?"
Claude: `claude-mux --list-templates` を実行して結果を表示

あなた: "web テンプレートで api-server という新規 work プロジェクトを作成して"
Claude: `claude-mux -n ~/Claude/work/api-server -p --template web --no-attach` を実行

あなた: "全セッションを Sonnet に切り替えて"
Claude: 動作中の各セッションに対して `claude-mux -s SESSION '/model sonnet'` を実行

あなた: "data-pipeline セッションをシャットダウンして"
Claude: `claude-mux --shutdown data-pipeline` を実行

あなた: "詰まっている web-dashboard セッションを再起動して"
Claude: `claude-mux --restart web-dashboard` を実行

あなた: "api-server セッションを plan モードに切り替えて"
Claude: `claude-mux --permission-mode plan api-server` を実行

あなた: "data-pipeline セッションを yolo にして"
Claude: `claude-mux --permission-mode dangerously-skip-permissions data-pipeline` を実行

あなた: "data-pipeline セッションをバックグラウンドで起動して"
Claude: `claude-mux -d ~/Claude/work/data-pipeline --no-attach` を実行

あなた: "全プロジェクトを開始して"
Claude: `claude-mux -a` を実行 (確認後 - これにより管理対象のすべてのプロジェクトが起動します)
```

## 設定

初回実行時に `~/.claude-mux/config` が自動作成され、すべての設定はコメントアウトされた状態になります。デフォルトを上書きするには編集してください。スクリプト本体を直接書き換える必要はありません。

| 変数 | デフォルト | 説明 |
|----------|---------|-------------|
| `BASE_DIR` | `$HOME/Claude` | Claude プロジェクト (`.claude/` を含むディレクトリ) を走査するルートディレクトリ |
| `LOG_DIR` | `$HOME/Library/Logs` | `claude-mux.log` ファイルを置くディレクトリ |
| `DEFAULT_PERMISSION_MODE` | `auto` | 各プロジェクトの Claude `permissions.defaultMode` を設定。有効値: `default`、`acceptEdits`、`plan`、`auto`、`dontAsk`、`bypassPermissions`。`""` で無効化 |
| `ALLOW_CROSS_SESSION_CONTROL` | `false` | `true` の場合、Claude セッション同士でスラッシュコマンドを送信可能。マルチエージェント連携で有用 |
| `TEMPLATES_DIR` | `$HOME/.claude-mux/templates` | CLAUDE.md テンプレートファイルを置くディレクトリ |
| `DEFAULT_TEMPLATE` | `default.md` | 新規プロジェクト (`-n`) に適用されるデフォルトテンプレート。`""` で無効化 |
| `SLEEP_BETWEEN` | `5` | `-a` 使用時のセッション起動間隔の秒数。RC 登録が失敗する場合は値を増やす |
| `HOME_SESSION_MODEL` | `""` | home セッション用のモデル。有効値: `sonnet`、`haiku`、`opus`。空の場合は Claude のデフォルトを継承 |
| `LAUNCHAGENT_MODE` | `home` | ログイン時の LaunchAgent の動作: `none` (何もしない) または `home` (保護された home セッションを起動)。レガシーの `LAUNCHAGENT_ENABLED=true` は `home` として扱われる |

**Tmux セッションのオプション** (すべて設定可能、デフォルトで有効):

| 変数 | デフォルト | 説明 |
|----------|---------|-------------|
| `TMUX_MOUSE` | `true` | マウスサポート - スクロール、選択、ペインサイズ変更 |
| `TMUX_HISTORY_LIMIT` | `50000` | スクロールバックバッファのサイズ (行数。tmux のデフォルトは 2000) |
| `TMUX_CLIPBOARD` | `true` | OSC 52 によるシステムクリップボード連携 |
| `TMUX_DEFAULT_TERMINAL` | `tmux-256color` | 適切な色表示のための端末タイプ |
| `TMUX_EXTENDED_KEYS` | `true` | Shift+Enter を含む拡張キーシーケンス (tmux 3.2 以上が必要) |
| `TMUX_ESCAPE_TIME` | `10` | Escape キーの遅延 (ミリ秒。tmux のデフォルトは 500) |
| `TMUX_TITLE_FORMAT` | `#S` | ターミナル/タブタイトルのフォーマット (`#S` = セッション名、`""` で無効化) |
| `TMUX_MONITOR_ACTIVITY` | `true` | 他セッションでアクティビティが発生したときに通知 |

## ディレクトリ構造

プロジェクトは任意の階層に存在する `.claude/` ディレクトリの有無で検出されます:

```
~/Claude/
├── work/
│   ├── project-a/          # ✓ .claude/ あり - 管理対象
│   │   └── .claude/
│   ├── project-b/          # ✓ .claude/ あり - 管理対象
│   │   └── .claude/
│   └── -archived/          # ✗ 除外 (- で始まる)
│       └── .claude/
├── personal/
│   ├── project-c/          # ✓ .claude/ あり - 管理対象
│   │   └── .claude/
│   ├── .hidden/            # ✗ 除外 (隠しディレクトリ)
│   │   └── .claude/
│   └── project-d/          # ✗ .claude/ なし - Claude プロジェクトではない
├── deep/nested/project-e/  # ✓ .claude/ あり - 任意の階層で検出
│   └── .claude/
└── ignored-project/        # ✗ 除外 (.ignore-claudemux)
    ├── .claude/
    └── .ignore-claudemux
```

セッション名はディレクトリ名から導出されます。スペースはハイフンに置換され、英数字とハイフン以外の文字は置換され、先頭/末尾のハイフンは削除されます。サニタイズ後に空文字列となるディレクトリは、ログに警告を出してスキップされます。

## Session System Prompt

各 Claude セッションは、その環境に関するコンテキストを含む `--append-system-prompt` 付きで起動されます:

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

`ALLOW_CROSS_SESSION_CONTROL=true` の場合、send コマンドの説明は変更され、自身のみではなく任意のセッションを対象に取れるようになります。パスは起動時のスクリプトの絶対パスで、セッションは `PATH` に依存しません。

## トラブルシューティング

### セッションに "Not logged in · Run /login" と表示される

これは初回起動時に macOS のキーチェーンがロックされている場合に発生します (ログイン後にキーチェーンがアンロックされる前にスクリプトが動くケースで一般的)。修正方法:

```bash
# 通常のターミナルでキーチェーンをアンロック
security unlock-keychain

# その後、動作中の任意のセッションで認証を完了
claude-mux -t <any-session>
# /login を実行してブラウザフローを完了
```

一度認証を完了すれば、すべてのセッションを kill して再起動するだけで、保存された認証情報を自動的に拾います。

### Claude Code Remote にセッションが表示されない

セッションは認証済みでなければなりません ("Not logged in" が表示されないこと)。クリーンに認証された起動の後、数秒以内に RC のリストに表示されるはずです。

### tmux 内での複数行入力

`/terminal-setup` コマンドは tmux 内では動作しません。claude-mux はデフォルトで tmux の `extended-keys` を有効化しているため (`TMUX_EXTENDED_KEYS=true`)、現代的な多くのターミナルで Shift+Enter をサポートします。Shift+Enter が動作しない場合は、プロンプトで `\` + Return を使って改行を入力してください。

### Remote Control 経由のスラッシュコマンド

スラッシュコマンド (例: `/model`、`/clear`) は RC セッションでは [ネイティブにサポートされていません](https://github.com/anthropics/claude-code/issues/30674)。claude-mux はこれを回避します。各セッションには `claude-mux -s` が注入されており、Claude が tmux 経由で自身にスラッシュコマンドを送信できます。

## ログ

- `~/Library/Logs/claude-mux.log` - すべてのスクリプトアクションを UTC タイムスタンプで記録 (`LOG_DIR` で設定可能)

LaunchAgent の低レベルなデバッグには Console.app または `log show` を使用してください。
