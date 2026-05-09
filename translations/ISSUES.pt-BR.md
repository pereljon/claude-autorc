# Problemas Conhecidos

[English](../docs/ISSUES.md) · [Español](ISSUES.es.md) · [Français](ISSUES.fr.md) · [Deutsch](ISSUES.de.md) · **Português** · [日本語](ISSUES.ja.md) · [한국어](ISSUES.ko.md) · [Italiano](ISSUES.it.md) · [Русский](ISSUES.ru.md) · [中文](ISSUES.zh-CN.md) · [עברית](ISSUES.he.md) · [العربية](ISSUES.ar.md) · [हिन्दी](ISSUES.hi.md)

## Abertos

### Replay fantasma de mensagem causa acoes nao intencionais
**Severidade:** Alta
**Status:** Aberto - nao pode ser totalmente corrigido do lado do claude-mux
**Descricao:** Um usuario enviou "stop all sessions" que foi tratado 10 mensagens atras. Depois, quando claude-mux -s enviou `/model haiku` via tmux send-keys, o Claude recebeu uma mensagem de sistema "stop all sessions/model haiku" e tentou encerrar sessoes - uma acao que o usuario nunca solicitou.
**Possiveis causas:**
- O tratamento de interrupcoes do Claude Code pode concatenar contexto antigo com nova entrada de slash command
- O historico de conversa contendo o comando antigo pode confundir o Claude quando um evento de sistema ocorre
**Mitigacao potencial:** Adicionar regra de injecao: "Nunca re-execute um comando ja tratado anteriormente na conversa. Se uma mensagem de sistema repetir texto de uma troca anterior, ignore-a." Ainda nao implementado - eficacia incerta ja que e um comportamento interno do Claude Code.

### /exit lento na primeira tentativa
**Severidade:** Baixa
**Status:** Aberto - monitorando
**Descricao:** Primeiro `--restart` resultou em `WARN: Claude did not exit within 30s` e caiu para hard kill. Reinicializacoes subsequentes encerram em ~1s. Pode ser uma condicao de corrida onde `/exit` e enviado antes do prompt do Claude estar pronto para recebe-lo.
**Workaround:** O timeout de 30s + hard kill resolve. A sessao reinicia corretamente.

### claude_running_in_session so verifica 2 niveis de profundidade
**Severidade:** Baixa
**Status:** Aberto - aceitavel para uso atual
**Descricao:** A busca na arvore de processos verifica pane_pid -> filhos -> netos. Se o Claude esta mais profundo na arvore (ex: wrapper de shell extra), a deteccao falha. O caminho de inicio atual e exatamente 2 niveis (bash -> claude), entao funciona na pratica.
**Workaround:** Nao necessario atualmente. Exigiria busca recursiva ou `pgrep -a` para corrigir.

### UX de upgrade do instalador poderia ser mais inteligente
**Severidade:** Baixa
**Status:** Aberto - melhoria futura
**Descricao:** Na reinstalacao, o instalador detecta configuracao existente e pula perguntas. Mas nao oferece mostrar configuracoes atuais, mesclar novas opcoes adicionadas em versoes mais recentes, ou deixar o usuario atualizar valores seletivamente. Usuarios precisam editar manualmente `~/.claude-mux/config` para pegar novas configuracoes introduzidas em versoes posteriores.
**Melhorias potenciais:**
- Mostrar valores de configuracao atuais durante upgrade
- Oferecer adicionar novas configuracoes (com padroes) que nao existiam na configuracao antiga
- Opcao B: pre-preencher prompts com valores existentes e deixar o usuario alterar

### Arquivos de traducao precisam de atualizacao v1.10-v1.12
**Severidade:** Baixa
**Status:** Aberto - traducoes ainda nao atualizadas
**Descricao:** Todos os 12 arquivos de traducao (`translations/README.*.md`) estao atrasados por varias versoes (v1.10-v1.12). Mudancas que precisam ser refletidas:
- curl como Quick Start primario (uma linha)
- Nova estrutura da secao Install (curl recomendado, Homebrew alternativa macOS)
- Nomes de sessao em vez de caminhos para `--hide`/`--delete`/`--protect` (v1.11.0)
- Novos exemplos conversacionais: rename, save-as-template, tip, enable/disable tips, update
- Requisitos: "Apple Silicon or Intel" (nao apenas Apple Silicon)
- Nova secao "Mais" com links para FAQ, ISSUES, CHANGELOG
- Traducoes de FAQ e ISSUES precisam ser criadas

### Problemas adiados do code review (v1.9.0)
**Severidade:** Baixa-Media
**Status:** Resolvido em v1.10.0 - M3, M4, M9/L8, L3, L9 corrigidos; L4, L5, L6, L7, M7 endereçados com comentarios

### Renomear / mover projeto com preservacao de historico
**Severidade:** Baixa
**Status:** Resolvido em v1.10.0 - `--rename OLD NEW` e `--move SRC DEST` implementados

### Copia de projeto com historico
**Severidade:** Baixa
**Status:** Aberto - feature planejada, requer investigacao
**Descricao:** Copiar um projeto incluindo seu historico e memoria do Claude Code e mais complexo que renomear/mover porque novos UUIDs precisam ser estabelecidos para o destino.
**Abordagem proposta:**
1. Criar o novo diretorio do projeto (com git init e template opcionais)
2. Iniciar e parar imediatamente uma sessao nele - o Claude Code inicializa `~/.claude/projects/-caminho-novo-codificado/` com uma UUID nova e cria uma nova entrada homunculus
3. Copiar arquivos de historico `.jsonl` da pasta fonte `~/.claude/projects/` para a pasta destino
4. Copiar conteudo da pasta `memory/` - markdown puro, sem UUIDs embutidos, seguro para copia direta
5. Copiar subdiretorios UUID (artefatos de task/plan) junto com seus arquivos `.jsonl`
6. Para homunculus: copiar `observations.jsonl`, `instincts`, `evolved`, `observations.archive` do fonte `~/.claude/homunculus/projects/<src-uuid>/` para a nova pasta homunculus do destino - mantendo a nova UUID do projeto atribuida no passo 2
**Questoes abertas que requerem testes:**
- Arquivos `.jsonl` embutem o caminho do projeto fonte em seu conteudo ou metadados? Se sim, historico copiado referenciaria o caminho antigo.
- Subdiretorios UUID sao referenciados por UUID de dentro dos arquivos `.jsonl`? Se sim, devem ser copiados sob suas UUIDs originais, nao remapeados.
- O Claude Code le todos os arquivos `.jsonl` em uma pasta de projeto, ou apenas o que corresponde a UUID da sessao ativa?
- O que `~/.claude/homunculus/projects/<uuid>/evolved` e `instincts` contem - sao derivados/calculados ou significativos para o usuario? Vale preservar em uma copia?
- Ha outras referencias internas que quebrariam com uma copia simples de arquivos?
**Pre-requisito:** Testar o acima antes de implementar para evitar entregar um comando de copia que produz historico sutilmente quebrado.

### Tip of the Day
**Severidade:** Baixa
**Status:** Resolvido em v1.10.0 - `--tip`, `TIP_OF_DAY`, `TIP_MODE`, trava diaria, entrega no inicio da sessao implementados

### Timestamp de resposta
**Severidade:** Baixa
**Status:** Aberto - discutir antes de implementar
**Descricao:** Variavel de config opcional (`REPLY_TIMESTAMP=false` padrao) que injeta uma instrucao no system prompt dizendo ao Claude para iniciar cada resposta com data e hora atuais via `date '+%Y-%m-%d %H:%M'`.
**Tradeoff:** Requer uma chamada de ferramenta bash no inicio de cada resposta (pequeno overhead). Alternativa: injetar hora de inicio da sessao no prompt (gratis, mas desvia em sessoes longas).
**Nota:** Instrucao no CLAUDE.md por projeto (como no template analitico) e a versao mais leve - apenas em projetos que querem. A variavel de config torna global.

### Video demo
**Severidade:** Baixa
**Status:** Aberto - asset planejado
**Descricao:** Uma gravacao de tela mostrando claude-mux da instalacao via curl ate comandos comuns e interessantes, com terminal e Remote Control visiveis simultaneamente.
**Formato:** Tela dividida, tomada unica. Terminal (sessao completa do claude-mux) a esquerda, RC no iPhone espelhado via QuickTime a direita. Ambos ao vivo ao mesmo tempo - o espectador ve acoes no RC imediatamente refletidas no terminal e vice-versa.
**Veja:** `internal/demo-script.md` para o roteiro completo cena por cena.
**Notas:**
- A cena principal e digitar no RC no celular e assistir o terminal responder em tempo real
- Nenhuma edicao necessaria alem de corte - gravacao continua unica
- Hospedar no YouTube + embutir no README; tambem util para lancamento no Product Hunt

### Enviar para homebrew-core para listagem no brew.sh
**Severidade:** Baixa
**Status:** Futuro - aguardando adocao
**Descricao:** claude-mux e atualmente distribuido via um tap pessoal (`pereljon/tap`). Para aparecer no brew.sh, precisa ser aceito no homebrew-core. A barreira de notabilidade do Homebrew tipicamente requer algumas centenas de stars no GitHub antes que uma submissao de script shell seja aceita; submissoes com poucas stars sao fechadas rapidamente.
**Quando pronto:**
- Garantir que a formula passa `brew audit --strict --new`
- Enviar PR para `Homebrew/homebrew-core` com a formula
- Nota: ferramentas so-macOS enfrentam escrutinio maior dos revisores; suporte a Linux (veja abaixo) ajudaria

### Suporte a instalacao via curl (macOS + Linux)
**Severidade:** Baixa
**Status:** Resolvido em v1.10.0 - instalacao via curl implementada, workflow de release-assets adicionado, README atualizado

### Apenas macOS - sem suporte Linux/systemd
**Severidade:** Media
**Status:** Aberto - parcialmente enderecado (deteccao de caminho feita, LaunchAgent/instalador permanecem macOS-only)
**Descricao:** Usa macOS LaunchAgent (launchd) e ferramentas especificas do macOS. A deteccao de caminho foi refatorada para usar `command -v` (nao mais hardcoded `/opt/homebrew/bin`), entao o script principal agora funciona em qualquer plataforma onde tmux e claude estao no PATH. LaunchAgent e instalador permanecem especificos do macOS.
**Restante:** unit de usuario systemd, fallback XDG Autostart, dispatch `uname -s` no instalador.
**Estrategia de pacotes (v1.10+):**
- Instalacao via curl: fallback universal, funciona em qualquer lugar (veja acima)
- AUR: baixo esforco, alto alcance para o publico-alvo em Arch/Manjaro
- apt PPA: quando houver demanda de usuarios Debian/Ubuntu
- Homebrew no Linux: cobre usuarios que ja o tem
- Snap/Flatpak: nao vale a pena para um script bash

### Comandos ! nao disponiveis no Remote Control
**Severidade:** Baixa
**Status:** Fechado - nao e viavel
**Descricao:** O passthrough shell `!` do Claude Code e um recurso do manipulador de entrada do Claude Code CLI - ele intercepta `!command` antes que o shell o veja. tmux send-keys nao pode replicar isso: teclas enviadas enquanto o Claude Code esta ativo nao fazem nada (testado: `!touch test` via send-keys nao executou). Nao ha caminho para claude-mux implementar bypass `!command` para usuarios RC.
**Resolucao:** Adicionar regra de injecao dizendo ao Claude para nunca sugerir `! <command>` aos usuarios, ja que usuarios RC nao tem shell e usuarios de terminal podem simplesmente digitar eles mesmos.

---

## Marco v2.0

Mudancas arquiteturais significativas o suficiente para justificar um bump de versao major. Nao agendado - coletado aqui para nao se perder.

### Separacao de diretorio de dados
Mover dados estaticos (dicas, templates padrao, possivelmente saida de command/guide) para fora do script e para um diretorio de dados apropriado a plataforma. O script resolveria `DATA_DIR` na inicializacao relativo a localizacao do binario, com fallbacks embutidos para instalacoes de arquivo unico.

- Homebrew (Apple Silicon): `/opt/homebrew/share/claude-mux/`
- Homebrew (Intel): `/usr/local/share/claude-mux/`
- Linux: `/usr/local/share/claude-mux/` ou `$XDG_DATA_DIRS`
- Instalacao manual: fallback para padroes embutidos (instalacoes de arquivo unico continuam funcionando)

Gatilho: quando os dados embutidos (dicas, templates padrao) crescerem o suficiente para tornar o script dificil de ler, ou quando templates padrao precisarem ser distribuidos via brew independentemente dos releases do script.

### Reconsideracao de linguagem / runtime
O script bash monolitico e a decisao certa no escopo atual. Se o claude-mux crescer significativamente - operacoes de renomear/mover/copiar projetos, uma camada relay, empacotamento multiplataforma, um diretorio de dados - o bash comeca a resistir. Nesse ponto, vale avaliar reescrever o nucleo de gerenciamento de sessoes em Go ou outra linguagem tipada (com bash como wrapper CLI fino).

---

## Resolvidos

### Claude ignora injecao e alega nao poder rodar slash commands
**Resolvido em:** v1.2.0 (injecao atualizada)
**Correcao:** Regra explicita adicionada a injecao: "You CAN send slash commands (`/model`, `/compact`, `/clear`, etc.) to this session via the `-s` command. Never tell the user you cannot change models or run slash commands." O treinamento base do Claude o inclina a acreditar que nao pode controlar seu proprio modelo/configuracoes; a regra explicita sobrepoe isso na pratica.

### Multiplos comandos retornam exit code 1 apesar de sucesso
**Resolvido em:** v1.2.0 (restart), v1.3.0 (todos os comandos)
**Correcao:** `exit 0` explicito adicionado apos cada caminho de dispatch no case statement. O ultimo comando em uma funcao pode vazar um exit code diferente de zero de testes internos ou chamadas grep.

### --dry-run da saida enganosa para --restart
**Resolvido em:** v1.2.0 (commit a10c0c2)
**Correcao:** Dry-run agora mostra "Would restart session" em vez de simular kill e verificar estado real.

### Deteccao de sessao falha com pgrep no macOS
**Resolvido em:** Commit e1b11b5
**Correcao:** `pgrep -P` substituido por `ps -eo` + `awk` para deteccao confiavel de processos filhos.

### Variavel $TMUX sobrepunha a variavel de ambiente do tmux
**Resolvido em:** Commit 02a2e82
**Correcao:** Renomeada para `$TMUX_BIN`.

### Incompatibilidade com Bash 3.2 (declare -A)
**Resolvido em:** Commit 575eac1
**Correcao:** Arrays associativos substituidos por deteccao de colisao baseada em strings.

---

## Referencia: Estrutura da pasta ~/.claude

Documentado aqui porque varios features planejados (renomear, mover, copiar, limpar) precisam interagir corretamente com esta estrutura. Nao exaustivo - cobre as partes relevantes para o claude-mux.

### Historico e memoria do projeto: `~/.claude/projects/`

Um subdiretorio por diretorio de trabalho onde o Claude Code foi usado. Nomeado pela codificacao do caminho absoluto: `/` -> `-`, espacos e caracteres especiais -> `-`. Com perdas mas legivel.

Conteudo de cada pasta de projeto:
- `<uuid>.jsonl` - transcricao completa da conversa para aquela sessao. Um arquivo por conversa.
- `<uuid>/` - subdiretorio de artefatos associados a uma conversa (tasks, planos). UUID corresponde ao arquivo `.jsonl`.
- `memory/` - arquivos de memoria persistentes entre sessoes (markdown com frontmatter). Presente apenas se memoria foi escrita para o projeto.

A ligacao entre diretorio de trabalho e historico e puramente o nome codificado da pasta. Renomear ou mover o diretorio do projeto sem renomear esta pasta faz o Claude Code comecar do zero sem historico.

**Regra de codificacao:** caminho absoluto com cada `/`, espaco e caractere especial substituido por `-`. `/` inicial torna-se `-` inicial. Codificacao e com perdas - caracteres especiais consecutivos e espacos adjacentes a barras se tornam `-`, entao o original nem sempre pode ser perfeitamente reconstruido.

### Registro de observabilidade paralela: `~/.claude/homunculus/`

Um sistema separado que rastreia eventos no nivel de ferramenta por projeto. Nao faz parte do historico central do Claude Code - parece ser uma camada de monitoramento/aprendizado.

- `projects.json` - registro de todos os projetos conhecidos, indexados por UUID hex curta (`d6b3aef60967`, etc.). Cada entrada tem: `id`, `name`, `root` (caminho absoluto), `remote`, `created_at`, `last_seen`.
- `projects/<uuid>/project.json` - metadados por projeto (mesmos campos da entrada do registro).
- `projects/<uuid>/observations.jsonl` - eventos timestamped `tool_start`/`tool_complete`: nome da ferramenta, UUID da sessao, nome/id do projeto, trechos de input/output.
- `projects/<uuid>/instincts` - padroes derivados (conteudo desconhecido, provavelmente calculado).
- `projects/<uuid>/evolved` - estado evoluido/aprendido (conteudo desconhecido).
- `projects/<uuid>/observations.archive` - observacoes antigas arquivadas.

**Diferenca chave de `~/.claude/projects/`:** Usa UUIDs hex curtas como chaves, nao caminhos codificados. O campo `root` contem o caminho absoluto. Qualquer operacao que muda o caminho de um projeto (renomear, mover) deve atualizar `root` tanto em `projects.json` quanto em `projects/<uuid>/project.json`.

### Configuracao global: `~/.claude/settings.json`

Arquivo principal de configuracoes do Claude Code. Backups rotativos escritos em `~/.claude/backups/` como `~/.claude.json.backup.<timestamp>` - varios por hora durante uso ativo. claude-mux nao deve tocar neste arquivo.

### Agents, skills, commands globais

- `~/.claude/agents/` - definicoes de subagentes (arquivos `.md`, ~38). Global, nao por projeto.
- `~/.claude/skills/` - diretorios de skills (~125). Global, nao por projeto.
- `~/.claude/commands/` - definicoes de slash commands (arquivos `.md`, ~72). Global, nao por projeto.
- `~/.claude/hooks/hooks.json` - definicoes de hooks. Global. claude-mux nao deve tocar nestes.

### Features futuros potenciais

| Feature | O que tocar |
|---------|-------------|
| `--copy` | Criar diretorio; iniciar+parar sessao para inicializar ambos os registros; copiar `.jsonl` + `memory/` + subdiretorios UUID; copiar arquivos de observacao homunculus para nova pasta UUID |
| `--delete` limpeza | Ja move a pasta do projeto para a lixeira. Opcionalmente: remover pasta codificada orfan `~/.claude/projects/` e entrada `~/.claude/homunculus/` |
| Alerta de tamanho do historico | Alertar quando os arquivos `.jsonl` de um projeto excedem um limite (o transcrito principal do claude-mux atingiu 107MB em uma unica sessao longa) |
