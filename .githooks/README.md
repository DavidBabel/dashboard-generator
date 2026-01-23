# Git Hooks - Automatisation du Versioning des Blueprints

## 📋 Qu'est-ce que c'est ?

Ce hook pre-commit **incrémente automatiquement la version** de chaque blueprint modifié lors d'un commit.

## 🚀 Installation (À faire une seule fois)

### Méthode 1 : Script automatique (Recommandé)

**Sur Windows** - Double-cliquez sur le fichier :

```
.githooks\install-hooks.bat
```

Ou depuis le terminal :

```cmd
.\.githooks\install-hooks.bat
```

**Sur Linux/Mac** :

```bash
chmod +x .githooks/pre-commit
git config core.hooksPath .githooks
```

### Méthode 2 : Installation manuelle (1 ligne)

Depuis la racine du projet :

```bash
git config core.hooksPath .githooks
```

C'est tout ! 🎉

### ⚠️ Dépendances

Le hook utilise **Bash** qui est automatiquement installé avec **Git Bash** sur Windows.

- Git Bash est inclus avec l'installation de Git sur Windows
- Aucune installation supplémentaire requise ! 🎉
- Utilisez Git Bash pour faire vos commits

## 📦 Comment ça fonctionne ?

### 1. Versioning dans les blueprints

Chaque blueprint contient maintenant une ligne de version en haut :

```yaml
# Version: 1.0.0
blueprint:
  name: "Mon Blueprint"
  ...
```

### 2. Incrémentation automatique

Quand vous modifiez un blueprint et faites un commit :

1. Le hook détecte les fichiers `.yaml` modifiés dans `blueprints/automation/`
2. Lit la version actuelle (ex: `1.0.5`)
3. Incrémente la version patch (→ `1.0.6`)
4. Met à jour le fichier
5. Ajoute automatiquement la modification au commit

### 3. Format SemVer

Le versioning suit **Semantic Versioning** :

- **MAJOR.MINOR.PATCH** (ex: `1.2.3`)
  - **MAJOR** : Changements incompatibles (manuel)
  - **MINOR** : Nouvelles fonctionnalités compatibles (manuel)
  - **PATCH** : Corrections de bugs (automatique ✅)

## 🔧 Utilisation quotidienne

**Aucune action manuelle nécessaire !** 🎉

Votre workflow habituel :

```bash
git add blueprints/automation/DavidBabel/mon_blueprint.yaml
git commit -m "Fix: correction du délai de notification"
```

Le hook s'exécute automatiquement et affiche :

```
✓ Version mise à jour : blueprints/automation/DavidBabel/mon_blueprint.yaml

📦 Versions automatiquement incrémentées :
  • blueprints/automation/DavidBabel/mon_blueprint.yaml: 1.0.5 → 1.0.6
```

## 📝 Incrémenter manuellement MAJOR ou MINOR

Pour les changements majeurs ou nouvelles fonctionnalités, modifiez manuellement :

```yaml
# Version: 1.2.0  → 2.0.0 (breaking change)
# Version: 1.2.0  → 1.3.0 (nouvelle feature)
```

Le hook continuera à incrémenter le PATCH par la suite.

## 🛠️ Désactiver temporairement

Si nécessaire, contourner le hook :

```bash
git commit --no-verify -m "Message"
```

## 🧪 Tester le hook

Modifiez un blueprint, puis :

```bash
git add blueprints/automation/DavidBabel/test.yaml
git commit -m "Test hook"
```

Vérifiez que la version a été incrémentée.

## ❓ Résolution de problèmes

### Le hook ne s'exécute pas

```bash
# Vérifier la configuration
git config core.hooksPath

# Doit retourner : .githooks
```

Si la configuration est correcte mais le hook ne s'exécute pas, vérifiez que vous utilisez **Git Bash** pour faire vos commits (pas PowerShell ou CMD).

### Tester le hook manuellement

```bash
# Depuis Git Bash
bash .githooks/pre-commit
```

### Réinitialiser les hooks

```bash
# Retour aux hooks par défaut
git config --unset core.hooksPath
```

## 📊 Avantages

✅ **Zéro effort** : Versioning automatique
✅ **Zéro dépendance** : Utilise uniquement Git Bash (inclus avec Git)
✅ **Traçabilité** : Historique clair des modifications
✅ **Cohérence** : Format SemVer standardisé
✅ **Simplicité** : Rien à penser, tout est géré
✅ **Multi-plateforme** : Fonctionne sur Windows, Linux et Mac

## 🔄 Migration des blueprints existants

Tous les blueprints ont été initialisés à `1.0.0`. Le hook les incrémentera automatiquement dès la prochaine modification.

## 📋 Scripts utilitaires

### get_links - Génération automatique des liens GitHub

Deux scripts sont disponibles pour générer automatiquement les liens GitHub raw de tous les blueprints, organisés par appartement :

**Sur Windows** :

```cmd
.\.githooks\get_links.bat
```

**Sur Linux/Mac** :

```bash
chmod +x .githooks/get_links.sh
./.githooks/get_links.sh
```

Ces scripts :

- Parcourent tous les blueprints dans `blueprints/automation/DavidBabel/`
- Extraient la catégorie (Appartement) de chaque blueprint
- Génèrent des liens GitHub raw organisés par catégorie
- Créent/mettent à jour le fichier `blueprints/links.md`

Le fichier généré contient des liens prêts à être copiés dans Home Assistant pour importer les blueprints.
