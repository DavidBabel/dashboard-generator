# 🏠 Home Assistant - Blueprints Repository

Repository centralisé pour les blueprints Home Assistant déployés automatiquement sur l'ensemble du parc d'instances.

## 📂 Structure du projet

```
ha-github/
├── .githooks/          # Hooks Git pour l'automatisation
│   ├── get_links.bat   # Génère les liens GitHub des blueprints
│   ├── get_links.sh    # Version Linux/Mac
│   ├── pre-commit      # Incrémente automatiquement les versions
│   └── post-commit     # Finalise les commits
├── blueprints/
│   ├── automation/
│   │   └── DavidBabel/ # Vos blueprints
│   ├── links.md        # Liens GitHub générés automatiquement
│   └── status.md       # État des blueprints
├── automations/        # Automations spécifiques
├── dashboards/         # Backups de dashboards
└── scripts/            # Scripts utilitaires

```

## 🚀 Démarrage rapide

### Installation des Git Hooks

**Windows :**

```cmd
.\.githooks\install-hooks.bat
```

**Linux/Mac :**

```bash
chmod +x .githooks/install-hooks.sh
./.githooks/install-hooks.sh
```

Voir [.githooks/README.md](.githooks/README.md) pour plus de détails sur le système de versioning automatique.

### Générer les liens des blueprints

**Windows :**

```cmd
.\get_links.bat
```

**Linux/Mac :**

```bash
./get_links.sh
```

Le fichier [blueprints/links.md](blueprints/links.md) sera créé/mis à jour avec tous les liens GitHub raw organisés par appartement.

## 📋 Blueprints disponibles

### 🟧 Engel / 🟩 Romains / 🟦 Carmes

Voir [blueprints/links.md](blueprints/links.md) pour la liste complète des liens d'import dans Home Assistant.

### 🔄 Blueprints universels (Tous)

- **🪫 batteries_check** - Vérification quotidienne des batteries
- **🛡️🔥 security_alerts** - Alertes urgence (eau/fumée)
- **🕵️ warning_danfoss_ally_unplug** - Surveillance vannes thermostatiques
- **❤️ healthcheck_prise_shelly** - Surveillance prises connectées
- **🔄 smart_heating_reset** - Reset intelligent du chauffage
- Et bien d'autres...

## 🛠️ Développement

### Standards de création

Consulter [copilot-instructions.md](copilot-instructions.md) pour les standards complets de développement des blueprints.

**Points clés :**

- ✅ Tous les `input` doivent avoir une valeur `default`
- ✅ Version format SemVer (`1.0.0`)
- ✅ Header avec statut (`✅ working` / `🧪 to test`)
- ✅ Appartement cible en ligne 3 (`# Appartement: Tous`)
- ✅ Documentation complète des paramètres

### Workflow de développement

1. **Modifier un blueprint**

```bash
# Éditer le fichier
nano blueprints/automation/DavidBabel/mon_blueprint.yaml
```

2. **Commit (versioning automatique)**

```bash
git add blueprints/automation/DavidBabel/mon_blueprint.yaml
git commit -m "feat: amélioration notification"
# Le hook incrémente automatiquement la version: 1.0.5 → 1.0.6
```

3. **Générer les nouveaux liens**

```cmd
.\get_links.bat
```

4. **Push vers GitHub**

```bash
git push origin master
```

### Déploiement automatique

Les blueprints sont déployés automatiquement chaque nuit sur toutes les instances Home Assistant via le script :

- [blueprints/update_daily/update_blueprints_auto.sh](blueprints/update_daily/update_blueprints_auto.sh)

## 📝 Scripts utiles

### get_links

Génère automatiquement les liens GitHub raw de tous les blueprints :

```cmd
.\get_links.bat                    # Windows
./get_links.sh                     # Linux/Mac
```

Les liens sont organisés par appartement dans [blueprints/links.md](blueprints/links.md).

### Dashboard Generator

Outil pour gérer les dashboards Home Assistant :

```bash
cd dashboard-generator
npm install
# Voir dashboard-generator/agent.md pour l'utilisation
```

## 🔗 Liens utiles

- [Documentation Git Hooks](.githooks/README.md)
- [Standards Copilot](copilot-instructions.md)
- [Agent Dashboard](dashboard-generator/agent.md)

## 📦 Technologies

- **Home Assistant** - Domotique
- **YAML** - Format des blueprints
- **Git Hooks** - Automatisation du versioning
- **Bash/Batch** - Scripts d'automatisation

## 👤 Auteur

DavidBabel - [GitHub](https://github.com/DavidBabel/ha)

## 📄 Licence

Usage personnel - Home Assistant Blueprints
