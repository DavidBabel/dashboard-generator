# Copilot Instructions - Home Assistant Blueprints Repository

## 🎯 Objectif du Repository

Ce repository sert à **stocker et centraliser les blueprints Home Assistant** qui sont déployés automatiquement chaque nuit sur l'ensemble du parc d'instances Home Assistant.

Les blueprints doivent être :

- ✅ Valides et testés
- ✅ Réutilisables sur plusieurs appartements/sites
- ✅ Documentés avec des descriptions claires
- ✅ Maintenables et évolutifs

---

## 📋 Standards de Création de Blueprints

### 1. Structure Obligatoire

Chaque blueprint **DOIT** contenir :

```yaml
blueprint:
  name: "🔤 Nom Explicite du Blueprint"
  description: >
    Description détaillée et multilignes expliquant clairement
    le fonctionnement et l'objectif du blueprint.
  domain: automation # ou script selon le type
  input:
    # Tous les inputs DOIVENT avoir des valeurs par défaut
```

### 2. ⚠️ RÈGLE CRITIQUE : Valeurs par Défaut Obligatoires

**Tous les `input` DOIVENT avoir une valeur `default`** pour permettre :

- Une utilisation immédiate sans configuration
- Des exemples concrets pour l'utilisateur
- Une documentation par l'exemple

✅ **BON EXEMPLE :**

```yaml
input:
  capteurs:
    name: Capteurs de danger
    description: Sélectionne un ou plusieurs capteurs
    default:
      - binary_sensor.detecteur_eau_engel_chauffe_eau_water_leak
      - binary_sensor.detecteur_fumee_romains_cellier_smoke
    selector:
      entity:
        domain: binary_sensor
        multiple: true

  delai_rappel:
    name: Intervalle de rappel
    default: 10
    selector:
      number:
        min: 1
        max: 60
        unit_of_measurement: minutes
```

❌ **MAUVAIS EXEMPLE :**

```yaml
input:
  capteurs:
    name: Capteurs
    selector:
      entity:
        domain: binary_sensor
  # ❌ Pas de default !
```

### 3. 📝 RÈGLE : Commentaires et Documentation Détaillés

**Tous les blueprints DOIVENT contenir des commentaires détaillés** pour faciliter la maintenance et la compréhension :

#### Structure des commentaires obligatoires :

```yaml
# ==============================================================================
# SECTION PRINCIPALE (INPUTS, VARIABLES, TRIGGERS, ACTIONS, etc.)
# ==============================================================================

# --------------------------------------------------------------------------
# Sous-section : Description du composant
# Type attendu : sensor.xxx, input_number.xxx, etc.
# Valeur attendue : pourcentage, température, état, etc.
# Comment créer : Instructions si nécessaire (Helper, configuration.yaml)
# --------------------------------------------------------------------------
```

#### Commentaires requis pour chaque input :

```yaml
input:
  # --------------------------------------------------------------------------
  # Nom descriptif de l'input
  # Type attendu : Préciser le domain et le format (sensor.xxx, binary_sensor.xxx)
  # Valeur attendue : Préciser l'unité et la plage (0-100%, température en °C)
  # Création : Si helper nécessaire, expliquer comment le créer
  # --------------------------------------------------------------------------
  mon_input:
    name: Nom Convivial
    description: >
      Description détaillée avec exemples concrets
    default: sensor.exemple_par_defaut
    selector:
      entity:
        domain: sensor
```

#### Commentaires requis pour les triggers :

Chaque trigger doit expliquer :

- **Quand** il se déclenche
- **Pourquoi** il existe
- **Quelle logique** il implémente

```yaml
trigger:
  # --------------------------------------------------------------------------
  # Trigger 1 : Nom descriptif
  # Se déclenche quand : condition exacte
  # Objectif : expliquer pourquoi ce trigger existe
  # --------------------------------------------------------------------------
  - platform: state
    entity_id: sensor.exemple
    id: mon_trigger
```

#### Commentaires requis pour les actions :

Chaque scénario d'action doit expliquer :

- **Dans quel cas** il s'exécute
- **Quelle logique** il implémente
- **Quelles conditions** sont vérifiées

```yaml
action:
  - choose:
      # ------------------------------------------------------------------------
      # SCÉNARIO 1 : Description du cas d'usage
      # Se déclenche quand : conditions exactes
      # Objectif : expliquer ce que fait ce scénario
      # ------------------------------------------------------------------------
      - conditions:
          - condition: trigger
            id: mon_trigger
        sequence:
          - service: notify.mobile_app
            # Action commentée si nécessaire
```

✅ **EXEMPLE COMPLET DE RÉFÉRENCE :**

Voir [`warning_nobody_detected_for_long.yaml`](blueprints/automation/DavidBabel/warning_nobody_detected_for_long.yaml) pour un exemple complet de blueprint bien commenté.

**Bénéfices :**

- ✅ Maintenance facilitée
- ✅ Compréhension immédiate du fonctionnement
- ✅ Onboarding rapide pour nouveaux contributeurs
- ✅ Documentation technique intégrée au code

---

## 📱 Standard de Notification

### Système de Notification Standardisé

**Toutes les notifications** doivent utiliser le pattern suivant :

#### 1. Input Device Mobile App

```yaml
input:
  notify_device:
    name: Device à notifier
    description: >
      Le device doit utiliser l'application mobile officielle Home Assistant.
    selector:
      device:
        filter:
          integration: mobile_app
```

#### 2. Construction Dynamique du Service

```yaml
variables:
  notify_device: !input notify_device
  notify_service: >
    notify.mobile_app_{{ device_attr(notify_device, 'name')
      | lower
      | replace(' ', '_')
      | replace('-', '_') }}
```

#### 3. Utilisation dans les Actions

```yaml
action:
  - service: "{{ notify_service }}"
    data:
      title: "🚨 TITRE DE LA NOTIFICATION"
      message: >
        📍 Description claire du message
        Utiliser des emojis pour la lisibilité
      data:
        tag: "unique_tag_{{ entity_id }}" # Pour remplacer les notifications
        notification_icon: mdi:icon-name
        push:
          sound:
            name: default
            critical: 1 # 1 pour notifications critiques uniquement
            volume: 1.0
        ttl: 0 # 0 pour notifications persistantes
        priority: high # high pour les alertes importantes
```

#### 4. Types de Notifications Standards

**🚨 Alerte Critique (répétitive avec rappel) :**

- `critical: 1`
- `priority: high`
- `ttl: 0`
- Tag unique pour permettre le remplacement
- Système de rappel avec `repeat` + `while` + `delay`

**✅ Retour à la Normale :**

- Pas de `critical`
- Même `tag` pour effacer l'alerte active
- Icon `mdi:check-circle` ou similaire

**ℹ️ Information Simple :**

- Pas de `critical`
- `priority: normal` ou pas de priority
- Pas de système de rappel

---

## 🏗️ Patterns Recommandés

### Multi-Site / Multi-Appartement

Utiliser un input pour filtrer par préfixe :

```yaml
input:
  appartement:
    name: Appartement
    default: "🟧 Engel"
    selector:
      select:
        options:
          - "🟧 Engel"
          - "🟩 Romains"
          - "🟦 Carmes"

variables:
  prefix_appartement: "{{ appartement.split(' ')[1] | lower }}"
```

### Seuils Configurables

Utiliser des `input_number` pour les seuils :

```yaml
input:
  seuil_entite:
    name: Entité seuil d'alerte
    default: input_number.seuil_alerte_batterie
    selector:
      entity:
        domain: input_number

action:
  - variables:
      seuil_alerte: "{{ states(seuil_entite) | float(80) }}"
```

### Mode d'Exécution

```yaml
mode: parallel  # Pour alertes critiques qui peuvent se déclencher simultanément
max: 10         # Limite raisonnable

# OU

mode: single    # Pour vérifications périodiques uniques
```

---

## 🔧 Recommandations Techniques

### Templates Jinja2

1. **Toujours avoir des valeurs par défaut dans les filtres :**

   ```yaml
   {{ states(entity) | float(0) }}
   {{ states(entity) | int(100) }}
   {{ variable | default('fallback') }}
   ```

2. **Vérifier l'existence des états :**

   ```yaml
   condition:
     - condition: template
       value_template: "{{ states(entity) not in ['unknown', 'unavailable', ''] }}"
   ```

3. **Utiliser des variables pour sécuriser les templates :**
   ```yaml
   variables:
     entity_id: !input capteur
     friendly_name: "{{ state_attr(entity_id, 'friendly_name') }}"
   ```

### Emojis et Lisibilité

Utiliser des emojis pour améliorer la lisibilité :

- 🔥 Fumée/Incendie
- 💧 Eau/Fuite
- 🪫 Batterie
- 🚨 Alerte critique
- ✅ Retour à la normale
- 📍 Localisation
- 🏥 Santé système
- 👮 Présence

### Organisation des Fichiers

```
blueprints/
  automation/
    DavidBabel/
      alerts.yaml           # Alertes critiques
      batteries_check.yaml  # Vérifications périodiques
      presence_detection.yaml
      ha_healthcheck.yaml
      smart_heating_reset.yaml
```

---

## 🚫 RÈGLES STRICTES

### ⛔ NE JAMAIS CRÉER DE FICHIERS .md

**RÈGLE CRITIQUE :** Les agents **NE DOIVENT JAMAIS** créer de fichiers Markdown (`.md`) sauf si l'utilisateur le demande **EXPLICITEMENT**.

❌ **INTERDIT :**

- Créer des fichiers de documentation automatiquement
- Créer des README pour chaque blueprint
- Créer des fichiers de résumé ou de changelog
- Créer des fichiers de notes

✅ **AUTORISÉ UNIQUEMENT :**

- Si l'utilisateur dit explicitement "crée un fichier .md pour..."
- Si l'utilisateur demande de la documentation écrite

**Les blueprints doivent être auto-documentés via leurs champs `name`, `description` et les descriptions des `input`.**

### Validation Avant Commit

Avant de proposer un blueprint :

1. ✅ Tous les inputs ont des valeurs `default`
2. ✅ Le système de notification utilise le pattern standardisé
3. ✅ Les templates Jinja2 ont des valeurs par défaut
4. ✅ La description est claire et complète
5. ✅ Le mode d'exécution est approprié
6. ✅ Les emojis sont utilisés pour la lisibilité
7. ✅ **Les commentaires détaillés sont présents** (sections, inputs, triggers, actions)

---

## 📦 Déploiement

Les blueprints de ce repository sont **déployés automatiquement chaque nuit** sur toutes les instances Home Assistant du parc via le script `update_blueprints_auto.sh`.

Toute modification doit donc être :

- ✅ Testée localement avant commit
- ✅ Compatible avec toutes les instances
- ✅ Non-breaking pour les automations existantes

---

## 💡 Exemples de Références

Pour créer un nouveau blueprint, s'inspirer des blueprints existants :

- [`security_alerts.yaml`](blueprints/automation/DavidBabel/security_alerts.yaml) - Alertes critiques avec rappel
- [`batteries_check.yaml`](blueprints/automation/DavidBabel/batteries_check.yaml) - Vérification périodique
- [`warning_nobody_detected_for_long.yaml`](blueprints/automation/DavidBabel/warning_nobody_detected_for_long.yaml) - Exemple de référence pour les commentaires détaillés
- [`healthcheck_ha_distants.yaml`](blueprints/automation/DavidBabel/healthcheck_ha_distants.yaml) - Monitoring système

---

## 🎯 En Résumé

1. **Toujours des valeurs par défaut** sur tous les inputs
2. **Utiliser le pattern de notification standardisé** (device mobile_app)
3. **Ne jamais créer de fichiers .md** sans demande explicite
4. **Auto-documenter** via descriptions et exemples
5. **Tester avant commit** car déploiement automatique nocturne
