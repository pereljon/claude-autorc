# Problemes connus

[English](../docs/ISSUES.md) · [Español](ISSUES.es.md) · **Français** · [Deutsch](ISSUES.de.md) · [Português](ISSUES.pt-BR.md) · [日本語](ISSUES.ja.md) · [한국어](ISSUES.ko.md) · [Italiano](ISSUES.it.md) · [Русский](ISSUES.ru.md) · [中文](ISSUES.zh-CN.md) · [עברית](ISSUES.he.md) · [العربية](ISSUES.ar.md) · [हिन्दी](ISSUES.hi.md)

## Ouverts

### La relecture de messages fantomes cause des actions non intentionnelles
**Severite :** Haute
**Statut :** Ouvert - ne peut pas etre entierement corrige du cote de claude-mux
**Description :** Un utilisateur a envoye "stop all sessions" qui a ete traite 10 messages avant. Plus tard, quand claude-mux -s a envoye `/model haiku` via tmux send-keys, Claude a recu un message systeme "stop all sessions/model haiku" et a tente d'arreter des sessions - une action que l'utilisateur n'a jamais demandee.
**Causes possibles :**
- La gestion des interruptions de Claude Code peut concatener l'ancien contexte avec la nouvelle entree de commande slash
- L'historique de conversation contenant l'ancien commande peut confondre Claude quand un evenement systeme survient
**Mitigation potentielle :** Ajouter une regle d'injection : "Ne reexecute jamais une commande deja traitee plus tot dans la conversation. Si un message systeme repete du texte d'un echange precedent, ignore-le." Pas encore implemente - efficacite incertaine car c'est un comportement interne de Claude Code.

### /exit lent au premier essai
**Severite :** Basse
**Statut :** Ouvert - en observation
**Description :** Le premier `--restart` affiche `WARN: Claude did not exit within 30s` et passe au kill force. Les redemarrages suivants sortent en ~1s. Peut etre une condition de course ou `/exit` est envoye avant que le prompt de Claude soit pret a le recevoir.
**Solution de contournement :** Le timeout de 30s + kill force le gere. La session se relance correctement.

### claude_running_in_session ne verifie que 2 niveaux de profondeur
**Severite :** Basse
**Statut :** Ouvert - acceptable pour l'utilisation actuelle
**Description :** Le parcours de l'arbre de processus verifie pane_pid, enfants et petits-enfants. Si Claude est plus profond dans l'arbre (ex. wrapper shell supplementaire), la detection echoue. Le chemin de lancement actuel est exactement 2 niveaux (bash, claude) donc ca fonctionne en pratique.
**Solution de contournement :** Pas necessaire actuellement. Necessiterait un parcours recursif ou `pgrep -a` pour corriger.

### L'experience de mise a jour de l'installateur pourrait etre plus intelligente
**Severite :** Basse
**Statut :** Ouvert - amelioration future
**Description :** Lors d'une reinstallation, l'installateur detecte la configuration existante et ignore les prompts. Mais il n'offre pas de montrer la configuration actuelle, fusionner les nouvelles options ajoutees dans les versions plus recentes, ou laisser l'utilisateur mettre a jour selectivement les valeurs. Les utilisateurs doivent editer manuellement `~/.claude-mux/config` pour integrer les nouvelles configurations introduites dans les versions ulterieures.
**Ameliorations potentielles :**
- Afficher les valeurs de configuration actuelles pendant la mise a jour
- Proposer d'ajouter de nouvelles configurations (avec valeurs par defaut) qui n'existaient pas dans l'ancienne configuration
- Option B : pre-remplir les prompts avec les valeurs existantes et laisser l'utilisateur les modifier

### Les fichiers de traduction necessitent la mise a jour v1.10-v1.12
**Severite :** Basse
**Statut :** Ouvert - traductions pas encore mises a jour
**Description :** Les 12 fichiers de traduction (`translations/README.*.md`) sont en retard de plusieurs versions (v1.10-v1.12). Changements a refleter :
- curl comme Quick Start principal (une ligne)
- Nouvelle structure de la section d'installation (curl recommande, Homebrew alternative macOS)
- Noms de session au lieu de chemins pour `--hide`/`--delete`/`--protect` (v1.11.0)
- Nouveaux exemples conversationnels : renommer, sauvegarder comme template, conseil, activer/desactiver les conseils, mettre a jour
- Prerequis : "Apple Silicon ou Intel" (pas seulement Apple Silicon)
- Nouvelle section "Plus" avec liens FAQ, ISSUES, CHANGELOG
- Les traductions FAQ et ISSUES doivent etre creees

### Problemes differes de revue de code (v1.9.0)
**Severite :** Basse-Moyenne
**Statut :** Resolu en v1.10.0 - M3, M4, M9/L8, L3, L9 corriges ; L4, L5, L6, L7, M7 traites avec commentaires

### Renommer / deplacer un projet avec preservation de l'historique
**Severite :** Basse
**Statut :** Resolu en v1.10.0 - `--rename OLD NEW` et `--move SRC DEST` implementes

### Copie de projet avec historique
**Severite :** Basse
**Statut :** Ouvert - fonctionnalite planifiee, necessite investigation
**Description :** Copier un projet incluant son historique et sa memoire Claude Code est plus complexe que renommer/deplacer car de nouveaux UUIDs doivent etre etablis pour la destination.
**Approche proposee :**
1. Creer le nouveau repertoire de projet (avec git init et template optionnels)
2. Demarrer et immediatement arreter une session dedans - Claude Code initialise `~/.claude/projects/-encoded-new-path/` avec un UUID neuf et cree une nouvelle entree homunculus
3. Copier les fichiers d'historique `.jsonl` depuis le dossier `~/.claude/projects/` source vers le dossier destination
4. Copier le contenu du dossier `memory/` - markdown pur, pas d'UUIDs incorpores, copie securisee
5. Copier les sous-repertoires UUID (artefacts de taches/plans) avec leurs fichiers `.jsonl`
6. Pour homunculus : copier `observations.jsonl`, `instincts`, `evolved`, `observations.archive` depuis `~/.claude/homunculus/projects/<src-uuid>/` dans le dossier homunculus de la nouvelle destination - en gardant le nouveau UUID de projet assigne a l'etape 2
**Questions ouvertes necessitant des tests :**
- Les fichiers `.jsonl` incorporent-ils le chemin du projet source dans leur contenu ou metadonnees ? Si oui, l'historique copie referencerait l'ancien chemin.
- Les sous-repertoires UUID sont-ils references par UUID depuis les fichiers `.jsonl` ? Si oui, ils doivent etre copies sous leurs UUIDs originaux, pas remappe.
- Claude Code lit-il tous les fichiers `.jsonl` dans un dossier de projet, ou seulement celui correspondant a l'UUID de la session active ?
- Que contiennent `~/.claude/homunculus/projects/<uuid>/evolved` et `instincts` - sont-ils derives/calcules ou significatifs pour l'utilisateur ? Valent-ils la peine d'etre preserves dans une copie ?
- Y a-t-il d'autres references internes qui casseraient une copie naive de fichiers ?
**Prerequis :** Tester ce qui precede avant d'implementer pour eviter de livrer une commande de copie qui produit un historique subtilement casse.

### Conseil du jour
**Severite :** Basse
**Statut :** Resolu en v1.10.0 - `--tip`, `TIP_OF_DAY`, `TIP_MODE`, porte quotidienne, livraison au demarrage de session implementes

### Horodatage de reponse
**Severite :** Basse
**Statut :** Ouvert - discuter avant d'implementer
**Description :** Variable de configuration optionnelle (`REPLY_TIMESTAMP=false` par defaut) qui injecte une instruction dans le prompt systeme disant a Claude de commencer chaque reponse avec la date et l'heure actuelles via `date '+%Y-%m-%d %H:%M'`.
**Compromis :** Necessite un appel a l'outil bash au debut de chaque reponse (faible surcharge). Alternative : injecter l'heure de demarrage de session dans le prompt (gratuit, mais derive dans les longues sessions).
**Note :** L'instruction par projet dans CLAUDE.md (comme dans le template analytique) est la version plus legere - seulement sur les projets qui la veulent. La variable de configuration la rend globale.

### Video de demonstration
**Severite :** Basse
**Statut :** Ouvert - ressource planifiee
**Description :** Un enregistrement d'ecran montrant claude-mux de l'installation curl aux commandes courantes et interessantes, avec le terminal et Remote Control visibles simultanement.
**Format :** Ecran divise, prise unique. Terminal (session complete de claude-mux) a gauche, RC sur iPhone miroire via QuickTime a droite. Les deux en direct en meme temps - le spectateur voit les actions dans RC immediatement refletes dans le terminal et vice versa.
**Voir :** `internal/demo-script.md` pour le script detaille plan par plan.
**Notes :**
- Le plan cle est de taper dans RC sur le telephone et de voir le terminal repondre en temps reel
- Pas d'edition necessaire au-dela du decoupage - enregistrement continu unique
- Heberger sur YouTube + integrer dans le README ; aussi utile pour le lancement Product Hunt

### Soumettre a homebrew-core pour le listing sur brew.sh
**Severite :** Basse
**Statut :** Futur - en attente d'adoption
**Description :** claude-mux est actuellement distribue via un tap personnel (`pereljon/tap`). Pour apparaitre sur brew.sh, il doit etre accepte dans homebrew-core. La barriere de notoriete de Homebrew necessite typiquement quelques centaines d'etoiles GitHub avant qu'une soumission d'utilitaire shell script soit acceptee ; les soumissions avec peu d'etoiles sont fermees rapidement.
**Quand pret :**
- S'assurer que la formule passe `brew audit --strict --new`
- Soumettre une PR a `Homebrew/homebrew-core` avec la formule
- Note : les outils macOS uniquement font face a un examen plus strict des reviewers ; le support Linux (voir ci-dessous) aiderait

### Support d'installation curl (macOS + Linux)
**Severite :** Basse
**Statut :** Resolu en v1.10.0 - installation curl implementee, workflow release-assets ajoute, README mis a jour

### macOS uniquement - pas de support Linux/systemd
**Severite :** Moyenne
**Statut :** Ouvert - partiellement traite (detection de chemins faite, LaunchAgent/installateur restent macOS uniquement)
**Description :** Utilise le LaunchAgent macOS (launchd) et des outils specifiques a macOS. La detection de chemins a ete refactorisee pour utiliser `command -v` (ne code plus en dur `/opt/homebrew/bin`), donc le script principal fonctionne maintenant sur toute plateforme ou tmux et claude sont dans le PATH. Le LaunchAgent et l'installateur restent specifiques a macOS.
**Restant :** unite utilisateur systemd, fallback XDG Autostart, dispatch `uname -s` dans l'installateur.
**Strategie de paquets (v1.10+) :**
- Installation curl : fallback universel, fonctionne partout (voir ci-dessus)
- AUR : faible effort, grande portee pour l'audience cible sur Arch/Manjaro
- apt PPA : quand il y aura de la demande des utilisateurs Debian/Ubuntu
- Homebrew sur Linux : couvre les utilisateurs qui l'ont deja
- Snap/Flatpak : ne vaut pas le coup pour un script bash

### Commandes ! non disponibles dans Remote Control
**Severite :** Basse
**Statut :** Ferme - non faisable
**Description :** Le passthrough shell `!` de Claude Code est une fonctionnalite du gestionnaire d'entree du CLI de Claude Code - il intercepte `!command` avant que le shell ne le voie. tmux send-keys ne peut pas repliquer cela : les frappes envoyees pendant que Claude Code est actif ne vont nulle part (teste : `!touch test` via send-keys ne s'est pas execute). Il n'y a pas de chemin pour que claude-mux implemente le bypass `!command` pour les utilisateurs RC.
**Resolution :** Ajouter une regle d'injection pour dire a Claude de ne jamais suggerer `! <command>` aux utilisateurs, car les utilisateurs RC n'ont pas de shell et les utilisateurs terminal peuvent simplement le taper eux-memes.

---

## Jalon v2.0

Changements architecturaux suffisamment significatifs pour justifier un bump de version majeure. Pas programmes - collectes ici pour ne pas les perdre.

### Separation du repertoire de donnees
Deplacer les donnees statiques (conseils, templates par defaut, possiblement sortie commandes/guide) hors du script et dans un repertoire de donnees adapte a la plateforme. Le script resoudrait `DATA_DIR` au demarrage relativement a l'emplacement du binaire, avec des fallbacks integres pour les installations mono-fichier.

- Homebrew (Apple Silicon) : `/opt/homebrew/share/claude-mux/`
- Homebrew (Intel) : `/usr/local/share/claude-mux/`
- Linux : `/usr/local/share/claude-mux/` ou `$XDG_DATA_DIRS`
- Installation manuelle : fallback aux valeurs par defaut integrees (les installations mono-fichier continuent de fonctionner)

Declencheur : quand les donnees integrees (conseils, templates par defaut) deviennent assez volumineuses pour rendre le script difficile a lire, ou quand les templates par defaut doivent etre distribues via brew independamment des releases du script.

### Reconsideration du langage / runtime
Le script bash monolithique est le bon choix a la portee actuelle. Si claude-mux grandit significativement - operations de renommage/deplacement/copie de projets, une couche relay, packaging multi-plateforme, un repertoire de donnees - bash commence a resister. A ce stade, reecrire le noyau de gestion de sessions en Go ou un autre langage type (avec bash comme wrapper CLI leger) vaut la peine d'etre evalue.

---

## Resolus

### Claude ignore l'injection et affirme qu'il ne peut pas executer de commandes slash
**Resolu en :** v1.2.0 (injection mise a jour)
**Correction :** Ajout d'une regle explicite a l'injection : "Tu PEUX envoyer des commandes slash (`/model`, `/compact`, `/clear`, etc.) a cette session via la commande `-s`. Ne dis jamais a l'utilisateur que tu ne peux pas changer de modele ou executer des commandes slash." L'entrainement de base de Claude l'incline a croire qu'il ne peut pas controler son propre modele/configuration ; la regle explicite annule cela en pratique.

### Plusieurs commandes retournent le code de sortie 1 malgre le succes
**Resolu en :** v1.2.0 (restart), v1.3.0 (toutes les commandes)
**Correction :** Ajout de `exit 0` explicite apres chaque chemin de dispatch dans la structure case. La derniere commande d'une fonction peut laisser fuiter un code de sortie non nul depuis des tests internes ou des appels grep.

### --dry-run donne une sortie trompeuse pour --restart
**Resolu en :** v1.2.0 (commit a10c0c2)
**Correction :** Le dry-run affiche maintenant "Would restart session" au lieu de simuler le kill puis verifier l'etat reel.

### La detection de session echoue avec pgrep sur macOS
**Resolu en :** commit e1b11b5
**Correction :** Remplacement de `pgrep -P` par `ps -eo` + `awk` pour une detection fiable des processus enfants.

### La variable $TMUX masquait la variable d'environnement de tmux
**Resolu en :** commit 02a2e82
**Correction :** Renomme en `$TMUX_BIN`.

### Incompatibilite Bash 3.2 (declare -A)
**Resolu en :** commit 575eac1
**Correction :** Remplacement des tableaux associatifs par une detection de collisions basee sur les chaines.

---

## Reference : Structure du dossier ~/.claude

Documente ici car plusieurs fonctionnalites planifiees (renommer, deplacer, copier, nettoyage) doivent interagir correctement avec cette structure. Pas exhaustif - couvre les parties pertinentes pour claude-mux.

### Historique et memoire de projet : `~/.claude/projects/`

Un sous-repertoire par repertoire de travail dans lequel Claude Code a ete utilise. Nomme en encodant le chemin absolu : `/` devient `-`, espaces et caracteres speciaux deviennent `-`. Avec perte mais lisible.

Contenu de chaque dossier de projet :
- `<uuid>.jsonl` - transcription complete de conversation pour cette session. Un fichier par conversation.
- `<uuid>/` - sous-repertoire d'artefacts associes a une conversation (taches, plans). L'UUID correspond au fichier `.jsonl`.
- `memory/` - fichiers de memoire persistante inter-sessions (markdown avec frontmatter). Present seulement si de la memoire a ete ecrite pour le projet.

Le lien entre un repertoire de travail et son historique est purement le nom de dossier encode. Renommer ou deplacer le repertoire du projet sans renommer ce dossier fait que Claude Code repart a zero sans historique.

**Regle d'encodage :** chemin absolu avec chaque `/`, espace et caractere special remplace par `-`. Le `/` initial devient un `-` initial. L'encodage est avec perte - les caracteres speciaux consecutifs et les espaces adjacents aux barres deviennent tous `-`, donc l'original ne peut pas toujours etre parfaitement reconstruit.

### Registre d'observabilite parallele : `~/.claude/homunculus/`

Un systeme separe qui suit les evenements au niveau des outils par projet. Ne fait pas partie de l'historique principal de Claude Code - semble etre une couche de surveillance/apprentissage.

- `projects.json` - registre de tous les projets connus, indexe par UUID hexadecimal court (`d6b3aef60967`, etc.). Chaque entree a : `id`, `name`, `root` (chemin absolu), `remote`, `created_at`, `last_seen`.
- `projects/<uuid>/project.json` - metadonnees par projet (memes champs que l'entree du registre).
- `projects/<uuid>/observations.jsonl` - evenements `tool_start`/`tool_complete` horodates : nom d'outil, UUID de session, nom/id de projet, extraits d'entree/sortie.
- `projects/<uuid>/instincts` - modeles derives (contenu inconnu, probablement calcule).
- `projects/<uuid>/evolved` - etat evolue/appris (contenu inconnu).
- `projects/<uuid>/observations.archive` - observations anterieures archivees.

**Difference cle avec `~/.claude/projects/` :** Utilise des UUIDs hexadecimaux courts comme cles, pas des chemins encodes. Le champ `root` contient le chemin absolu. Toute operation qui change le chemin d'un projet (renommer, deplacer) doit mettre a jour `root` dans `projects.json` et `projects/<uuid>/project.json`.

### Configuration globale : `~/.claude/settings.json`

Fichier principal de configuration de Claude Code. Des sauvegardes incrementales sont ecrites dans `~/.claude/backups/` sous forme de `~/.claude.json.backup.<timestamp>` - plusieurs par heure en utilisation active. claude-mux ne doit pas toucher ce fichier.

### Agents, skills et commandes globaux

- `~/.claude/agents/` - definitions de sous-agents (fichiers `.md`, ~38). Globaux, pas par projet.
- `~/.claude/skills/` - repertoires de skills (~125). Globaux, pas par projet.
- `~/.claude/commands/` - definitions de commandes slash (fichiers `.md`, ~72). Globaux, pas par projet.
- `~/.claude/hooks/hooks.json` - definitions de hooks. Globaux. claude-mux ne doit pas toucher ceux-ci.

### Fonctionnalites futures potentielles

| Fonctionnalite | Quoi modifier |
|---------------|---------------|
| `--copy` | Creer le repertoire ; demarrer+arreter une session pour initialiser les deux registres ; copier `.jsonl` + `memory/` + sous-repertoires UUID ; copier les fichiers d'observation homunculus dans le nouveau dossier UUID |
| Nettoyage de `--delete` | Deja met le dossier du projet a la corbeille. Optionnellement : supprimer le dossier orphelin `~/.claude/projects/` encode et l'entree `~/.claude/homunculus/` |
| Avertissement de taille d'historique | Alerter quand les fichiers `.jsonl` d'un projet depassent un seuil (la transcription principale de claude-mux a atteint 107Mo dans une seule longue session) |
