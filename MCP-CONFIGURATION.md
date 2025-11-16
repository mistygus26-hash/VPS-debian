# Configuration MCP Détaillée

## 📋 Vue d'ensemble

Le VPS utilise le protocole MCP (Model Context Protocol) pour permettre à Qwen 2.5 Coder 3B d'interagir avec le système de manière sécurisée et structurée.

**Modes d'utilisation**:
- MCP local pour Qwen sur le VPS (pas de conflit avec Mistral)
- MCP distant pour accès depuis Windows 10 via Claude Desktop

---

## 🖥️ MCP pour Accès Distant au VPS (Windows 10)

### VPS MCP Server v3

**Fonction**: Permet à Claude Desktop (Windows 10) de gérer le VPS Debian à distance via SSH

#### Configuration Claude Desktop
**Fichier**: `C:\Users\Chris\AppData\Roaming\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "vps-debian": {
      "command": "python",
      "args": ["C:\\Users\\Chris\\mcp-servers\\vps-mcp-server-v3.py"]
    }
  }
}
```

#### Caractéristiques Techniques

**Version**: v3 (novembre 2025)  
**SDK**: MCP 1.19.0 officiel (mcp.server)  
**Protocole**: stdio  
**Connexion**: SSH avec authentification par clé Ed25519  

**Migration depuis v1 et v2**:
- ❌ v1 (`vps-mcp-server.py`) - Obsolète
- ❌ v2 (`vps-mcp-server-v2.py` avec FastMCP) - Incompatible stdio Claude Desktop
- ✅ v3 (`vps-mcp-server-v3.py`) - Compatible SDK MCP officiel

#### Outils Disponibles

| Outil | Description | Usage |
|-------|-------------|-------|
| `execute_command` | Exécuter commandes SSH sur le VPS | Administration système, diagnostics |
| `list_docker_containers` | Lister conteneurs Docker actifs | Monitoring infrastructure |
| `check_docker_logs` | Consulter logs d'un conteneur | Debugging workflows n8n |
| `restart_docker_container` | Redémarrer un conteneur | Résolution incidents |
| `check_system_resources` | Ressources système (CPU, RAM, disque) | Monitoring performance |
| `diagnose_vps` | Diagnostic complet VPS | Troubleshooting général |
| `query_postgres` | Requêtes PostgreSQL directes | Consultation base n8n |

#### Cas d'usage Principaux

**Gestion quotidienne**:
- Monitoring des services Docker (n8n, Ollama, PostgreSQL)
- Consultation des logs en temps réel
- Vérification des ressources système

**Troubleshooting**:
- Diagnostic complet en cas d'incident
- Redémarrage sélectif de conteneurs
- Analyse des logs d'erreurs

**Administration workflows n8n**:
- Vérification statut des workers
- Consultation base PostgreSQL
- Debugging des exécutions

#### Sécurité

**Authentification**:
- ✅ Clé SSH Ed25519 (pas de mot de passe)
- ✅ Connexion chiffrée SSH
- ✅ Pas de credentials stockés dans le code MCP

**Isolation**:
- ✅ Commandes Docker en lecture seule (sauf restart)
- ✅ Requêtes PostgreSQL en lecture seule
- ⚠️ execute_command: accès root SSH (utilisé avec précaution)

**Bonnes pratiques**:
- Ne pas stocker le fichier de configuration dans un repo public
- Vérifier régulièrement les logs d'accès SSH sur le VPS
- Limiter l'usage de `execute_command` aux tâches nécessaires

#### Configuration Système Requise

**Windows 10**:
- Python 3.11+
- Package `mcp` via pip
- Package `paramiko` pour SSH
- Clé SSH Ed25519 configurée

**VPS Debian**:
- OpenSSH Server actif
- Clé publique autorisée dans `~/.ssh/authorized_keys`
- Docker accessible sans sudo (ou via sudo configuré)

#### Troubleshooting

**Problème**: MCP ne se charge pas dans Claude Desktop

```bash
# Vérifier Python disponible
python --version

# Vérifier packages installés
pip list | grep mcp
pip list | grep paramiko

# Tester connexion SSH manuellement
ssh -i ~/.ssh/id_ed25519 root@<VPS_IP>
```

**Problème**: Timeout lors de connexion SSH

```python
# Dans vps-mcp-server-v3.py, augmenter timeout
timeout = 30  # au lieu de 10
```

**Problème**: Docker commands échouent

```bash
# Sur le VPS, vérifier que l'utilisateur SSH peut accéder à Docker
docker ps
# Si erreur, ajouter l'utilisateur au groupe docker
sudo usermod -aG docker $USER
```

---

## 🔧 Serveurs MCP Configurés sur le VPS (Qwen)

> **Note**: Cette section documente les MCP utilisés par Qwen 2.5 Coder 3B directement sur le VPS, pas les MCP pour accès distant.

### 1. Memory MCP - Graphe de Connaissance

#### Configuration
```javascript
{
  'command': 'npx',
  'args': ['-y', '@modelcontextprotocol/server-memory']
}
```

#### Capacités
- Création d'entités dans un graphe de connaissance
- Relations entre entités
- Observations et mémorisation contextuelle
- Recherche dans le graphe

#### Cas d'usage
- Mémoriser l'historique des VPS clients
- Tracker les workflows déployés
- Garder trace des erreurs corrigées
- Mémoriser les configurations spécifiques

#### Outils disponibles
- `memory:create_entities` - Créer des entités
- `memory:create_relations` - Créer des relations
- `memory:add_observations` - Ajouter des observations
- `memory:read_graph` - Lire le graphe complet
- `memory:search_nodes` - Rechercher dans le graphe

#### Isolation
⚠️ **IMPORTANT**: Ce MCP n'est utilisé QUE par Qwen pour éviter les conflits d'écriture simultanée.

---

### 2. Sequential Thinking MCP - Raisonnement Approfondi

#### Configuration
```javascript
{
  'command': 'npx',
  'args': ['-y', '@modelcontextprotocol/server-sequential-thinking']
}
```

#### Capacités
- Raisonnement séquentiel étape par étape
- Révision de pensées précédentes
- Branchement de raisonnement
- Génération et vérification d'hypothèses

#### Cas d'usage
- Débogage de workflows complexes
- Planification de déploiements multi-étapes
- Résolution de problèmes système
- Validation de configurations

#### Outils disponibles
- `sequentialthinking:sequentialthinking` - Outil principal de raisonnement

#### Paramètres clés
- `thought` - Étape de réflexion actuelle
- `thought_number` - Numéro de l'étape
- `total_thoughts` - Estimation du nombre total d'étapes
- `is_revision` - Indique une révision de pensée
- `next_thought_needed` - Indique si plus de réflexion est nécessaire

#### Sécurité
✅ **SAFE**: Pas de stockage persistent, chaque instance est isolée

---

### 3. Filesystem MCP - Accès Fichiers Sécurisé

#### Configuration
```javascript
{
  'command': 'npx',
  'args': [
    '-y', 
    '@modelcontextprotocol/server-filesystem',
    '/opt/qwen-agent',
    '/opt/workflows',
    '/opt/vps-inventory',
    '/tmp',
    '/var/log'
  ]
}
```

#### Répertoires Autorisés

| Répertoire | Permission | Usage |
|------------|------------|-------|
| `/opt/qwen-agent` | R/W | Code de l'orchestrateur |
| `/opt/workflows` | R/W | Templates de workflows n8n |
| `/opt/vps-inventory` | R/W | Historique et inventaire VPS |
| `/tmp` | R/W | Fichiers temporaires |
| `/var/log` | R | Logs système (lecture seule) |

#### Outils disponibles
- `filesystem:read_text_file` - Lire un fichier texte
- `filesystem:read_multiple_files` - Lire plusieurs fichiers
- `filesystem:write_file` - Créer/écraser un fichier
- `filesystem:edit_file` - Éditer un fichier (remplacement de lignes)
- `filesystem:create_directory` - Créer un répertoire
- `filesystem:list_directory` - Lister le contenu
- `filesystem:directory_tree` - Arbre récursif
- `filesystem:move_file` - Déplacer/renommer
- `filesystem:search_files` - Rechercher des fichiers
- `filesystem:get_file_info` - Métadonnées fichier

#### Cas d'usage
- Lecture de templates de workflows
- Consultation de logs pour debugging
- Sauvegarde de configurations générées
- Historique des actions sur VPS clients

#### Sécurité
- ✅ Whitelist stricte de répertoires
- ✅ Impossible d'accéder en dehors des répertoires autorisés
- ⚠️ Éviter écriture simultanée sur mêmes fichiers (géré par Qwen seul)

---

### 4. n8n MCP - Gestion Workflows

#### Configuration
```javascript
{
  'command': 'npx',
  'args': ['n8n-mcp'],
  'env': {
    'MCP_MODE': 'stdio',
    'N8N_API_URL': 'https://n8n.aurastackai.com/api/v1',
    'LOG_LEVEL': 'error',
    'DISABLE_CONSOLE_OUTPUT': 'true'
  }
}
```

#### Capacités Principales

##### Gestion des Workflows
- Créer des workflows complets
- Modifier des workflows existants
- Valider la structure et configuration
- Lister et rechercher workflows
- Supprimer workflows

##### Outils Workflow
- `n8n:n8n_create_workflow` - Créer un workflow
- `n8n:n8n_get_workflow` - Récupérer un workflow
- `n8n:n8n_update_full_workflow` - Mise à jour complète
- `n8n:n8n_update_partial_workflow` - Mise à jour incrémentale (diff)
- `n8n:n8n_delete_workflow` - Supprimer
- `n8n:n8n_list_workflows` - Lister avec filtres
- `n8n:n8n_validate_workflow` - Valider configuration

##### Validation et Autofix
- `n8n:n8n_validate_workflow` - Validation complète
- `n8n:n8n_autofix_workflow` - Correction automatique d'erreurs
- `n8n:validate_workflow` - Validation workflow JSON
- `n8n:validate_workflow_connections` - Validation connexions
- `n8n:validate_workflow_expressions` - Validation expressions

##### Gestion des Exécutions
- `n8n:n8n_get_execution` - Détails d'exécution
- `n8n:n8n_list_executions` - Lister les exécutions
- `n8n:n8n_delete_execution` - Supprimer une exécution
- `n8n:n8n_trigger_webhook_workflow` - Déclencher via webhook

##### Catalogue de Nœuds
- `n8n:list_nodes` - Lister les nœuds disponibles
- `n8n:get_node_info` - Documentation complète d'un nœud
- `n8n:search_nodes` - Rechercher des nœuds
- `n8n:get_node_essentials` - Info essentielle nœud

#### Cas d'usage Spécifiques

**Détection d'erreurs de configuration**:
- Credentials manquants
- URLs incorrectes (localhost vs IP publique)
- Ports mal configurés
- Chemins de fichiers erronés
- Expressions n8n avec mauvaises variables

**Workflows types générés**:
1. Supervision de VPS clients
2. Déploiement automatisé de workflows
3. Détection et correction d'erreurs
4. Copie de workflows avec adaptation

#### Sécurité
✅ **SAFE**: Utilise l'API REST n8n qui gère les requêtes concurrentes
✅ Pas de risque de conflit avec d'autres systèmes

---

## 🔄 Processus d'Initialisation MCP

### Au démarrage de Qwen Orchestrator

1. **Chargement configuration**
   ```python
   llm_cfg = {
       'model': 'qwen2.5-coder:3b-instruct',
       'model_server': 'http://localhost:11434/v1'
   }
   ```

2. **Initialisation des MCP**
   ```
   2025-11-15 06:02:42 - Initializing MCP tools from mcp servers: 
   ['memory', 'sequential-thinking', 'filesystem', 'n8n']
   ```

3. **Connexion séquentielle**
   - Memory (1-2s)
   - Sequential-thinking (1-2s)
   - Filesystem (1-2s)
   - n8n (1-2s)

4. **Vérification disponibilité**
   ```
   ✅ Knowledge Graph MCP Server running on stdio
   ✅ Sequential Thinking MCP Server running on stdio
   ✅ Secure MCP Filesystem Server running on stdio
   ✅ n8n MCP running
   ```

5. **Interface prête**
   ```
   ✅ Agent initialisé avec succès !
   🌐 Interface Gradio: http://0.0.0.0:7860
   ```

**Temps total**: ~10-12 secondes

---

## 📊 Monitoring MCP

### Vérification État Services
```bash
# Status services MCP
systemctl status mcp-sandbox mcp-secure mcp-wrapper-secure

# Status Qwen avec MCP
systemctl status qwen-workflow-creator
```

### Logs MCP
```bash
# Logs initialisation MCP
journalctl -u qwen-workflow-creator | grep -i "mcp"

# Logs filesystem MCP
journalctl -u qwen-workflow-creator | grep -i "filesystem"

# Logs n8n MCP
journalctl -u qwen-workflow-creator | grep -i "n8n"
```

### Diagnostics

#### Problème: MCP ne démarre pas
```bash
# Vérifier npx disponible
which npx

# Vérifier packages npm
npm list -g @modelcontextprotocol/server-memory
npm list -g @modelcontextprotocol/server-sequential-thinking
npm list -g n8n-mcp
```

#### Problème: Filesystem MCP - accès refusé
```bash
# Vérifier permissions
ls -la /opt/qwen-agent
ls -la /opt/workflows
ls -la /opt/vps-inventory
```

---

## 🚀 Évolutions Futures Possibles

### MCP Additionnels (si besoin)

#### Shell MCP (actuellement non utilisé)
```javascript
{
  'command': 'mcp-shell',
  'env': {
    'MCP_ALLOWED_COMMANDS': 'docker,systemctl,journalctl'
  }
}
```
**Pourquoi non utilisé**: Qwen peut utiliser filesystem + n8n pour la majorité des tâches

#### Postgres MCP (actuellement non utilisé)
```javascript
{
  'command': 'npx',
  'args': ['-y', '@modelcontextprotocol/server-postgres']
}
```
**Pourquoi non utilisé**: Accès via n8n workflows et VPS MCP Server v3 suffit

### Mistral Integration (futur)

**Si nécessaire**, configuration isolée possible:
```javascript
// Mistral utiliserait uniquement:
- sequential-thinking (safe, pas de stockage)
- n8n (safe, API REST)

// Pas utilisés par Mistral (éviter conflits)
- memory (risque écriture simultanée)
- filesystem (risque corruption fichiers)
```

---

## ⚠️ Points d'Attention

### Conflits Potentiels

1. **Memory MCP**: 
   - ❌ NE PAS utiliser avec multiple LLMs
   - ✅ Exclusif à Qwen actuellement

2. **Filesystem MCP**:
   - ⚠️ Risque si écriture simultanée sur même fichier
   - ✅ OK si Qwen seul ou fichiers différents

3. **Sequential-thinking**: 
   - ✅ Pas de conflit, sans état

4. **n8n MCP**: 
   - ✅ Pas de conflit, API gère concurrence

5. **VPS MCP Server v3** (Windows 10):
   - ✅ Pas de conflit avec MCP locaux sur le VPS
   - ✅ Isolation complète via SSH
   - ⚠️ Attention aux commandes destructives via execute_command

### Bonnes Pratiques

**MCP Locaux (VPS)**:
- ✅ Un seul LLM avec Memory MCP
- ✅ Logs désactivés pour MCP (DISABLE_CONSOLE_OUTPUT=true)
- ✅ Whitelist stricte filesystem
- ✅ Services systemd avec auto-restart
- ✅ Monitoring régulier des logs

**MCP Distant (Windows 10)**:
- ✅ Authentification SSH par clé uniquement
- ✅ Pas de credentials dans le code
- ✅ Limitation des commandes sensibles
- ✅ Logs d'accès SSH sur le VPS
- ✅ Fichier de configuration sécurisé

---

## 📝 Historique des Versions

### VPS MCP Server

| Version | Date | Statut | Notes |
|---------|------|--------|-------|
| v1 | Oct 2025 | ❌ Obsolète | Version initiale, non compatible SDK MCP moderne |
| v2 (FastMCP) | Nov 2025 | ❌ Obsolète | Incompatible stdio Claude Desktop |
| **v3** | Nov 2025 | ✅ **Actif** | SDK MCP 1.19.0 officiel, compatible Claude Desktop |

### MCP Locaux (VPS)

Tous les serveurs MCP utilisent les versions officielles via npx avec auto-update:
- `@modelcontextprotocol/server-memory` - Latest
- `@modelcontextprotocol/server-sequential-thinking` - Latest
- `@modelcontextprotocol/server-filesystem` - Latest
- `n8n-mcp` - Latest

---

**Dernière mise à jour**: 2025-11-16  
**Configuration validée**: 
- ✅ Qwen 2.5 Coder 3B with 4 MCP servers (VPS local)
- ✅ Claude Desktop with VPS MCP Server v3 (Windows 10 remote)
