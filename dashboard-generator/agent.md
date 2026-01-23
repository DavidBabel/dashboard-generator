# Dashboard Generator - Home Assistant

## Objectif Global

Ce projet me permet de générer des dashboards Home Assistant réutilisables et paramétrables à partir d'un template YAML. L'workflow est le suivant :

1. Exporter un dashboard généré via l'interface Lovelace en YAML
2. Le transformer en template avec des variables placeholders
3. Utiliser une interface web pour remplacer les variables et générer des dashboards pour différents appartements/pièces
4. Copier le code généré directement dans Home Assistant

## Structure du Projet

```
dashboard-generator/
 index.html                          # Interface web de génération
 template.yaml                       # Template paramétrable (variables {})
 agent.md                           # Documentation (ce fichier)
 rewrite-template/
    new-reference-to-paste-here.yaml  # Fichier de référence original
    regenerate-reference.sh           # Script de génération du template
 history/
     template_backup_*.yaml           # Sauvegardes avec timestamps
```

## Workflow de Génération du Template

### Script: `regenerate-reference.sh`

Transforme un dashboard brut en template réutilisable.

**Étapes :**

1. **Backup** : Crée une copie datée du `template.yaml` dans `history/`

   - Format du timestamp : `YYYY-MM-DD_HH-MM-SS`

2. **Templating** : Remplace les patterns spécifiques par des variables :

   - `climate.engel_vt_chambre_salon` `climate.{appart}_vt_{room_code}`
   - `engel` (partout) `{appart}`
   - `chambre_salon` `{room_code}`
   - `name: Chambre Salon` `name: {room_name}`
   - `name:  Salon` `name:  {room_shortname}`

3. **Sauvegarde** : Écrit le template dans `template.yaml`

**Utilisation :**

```bash
bash regenerate-reference.sh
```

## Interface Web: `index.html`

### Fonctionnalités

Interface interactive pour générer des dashboards à partir du template.

### Structure de l'Interface

#### 1 Sélecteurs (Haut de page)

Deux dropdowns liés en cascade :

- **Appartement** : Choix entre "engel" ou "romains"
- **Pièce** : Liste qui change selon l'appartement

#### 2 Résumé des Valeurs

Affichage en grille des 4 variables générées :

- `{appart}` : Identifiant de l'appartement
- `{room_code}` : Code de la pièce (minuscules avec underscores)
- `{room_name}` : Nom complet de la pièce
- `{room_shortname}` : Nom court (partie après "Chambre")

#### 3 Aperçu des Remplacements

Liste avant/après de tous les remplacements qui vont être effectués

#### 4 Textarea

Zone de texte avec le contenu généré et complet

- Bouton "Sélectionner tout" pour une sélection rapide
- Bouton "Copier dans le presse-papiers" avec confirmation visuelle verte

### Configuration des Appartements

```javascript
const apartments = {
  engel: [
    { name: "Salon", code: "salon" },
    { name: "Chambre Salon", code: "chambre_salon" },
    { name: "Chambre Sud", code: "chambre_sud" },
    { name: "Chambre Ouest", code: "chambre_ouest" },
    { name: "Chambre Nord", code: "chambre_nord" },
  ],
  romains: [
    { name: "Chambre Cuisine", code: "chambre_cuisine" },
    { name: "Chambre Celier", code: "chambre_celier" },
    { name: "Chambre Balcon", code: "chambre_balcon" },
    { name: "Chambre GGauche", code: "chambre_ggauche" },
    { name: "Chambre GDroite", code: "chambre_gdroite" },
    { name: "Salle de bain", code: "salle_de_bain" },
  ],
};
```

### Calcul du room_shortname

Le `room_shortname` est dérivé du `name` :

- Si le nom commence par "Chambre " : on enlève ce préfixe
- Sinon : on utilise le nom complet

**Exemples :**

- "Salon" "Salon"
- "Chambre Salon" "Salon"
- "Chambre Sud" "Sud"
- "Salle de bain" "Salle de bain"

## Template YAML - Structure avec Variables

Le `template.yaml` utilise 4 variables à remplacer :

| Variable           | Exemples                                  | Cas d'usage                                         |
| ------------------ | ----------------------------------------- | --------------------------------------------------- |
| `{appart}`         | `engel`, `romains`                        | Identifiant unique de l'appartement                 |
| `{room_code}`      | `salon`, `chambre_sud`, `chambre_cuisine` | Code pour les entity IDs (minuscules + underscores) |
| `{room_name}`      | `Salon`, `Chambre Sud`                    | Nom affiché à l'utilisateur                         |
| `{room_shortname}` | `Salon`, `Sud`, `Cuisine`                 | Nom court pour les labels/interfaces                |

**Exemple dans le template :**

```yaml
entity: climate.{appart}_vt_{room_code}
name: { room_name }
```

Devient pour "engel/Salon" :

```yaml
entity: climate.engel_vt_salon
name: Salon
```

## Processus d'Utilisation

### 1. Créer un Nouveau Dashboard

- Générer un dashboard via l'interface Lovelace de Home Assistant
- Exporter le YAML

### 2. Créer un Template

- Placer le YAML exporté dans `new-reference-to-paste-here.yaml`
- Exécuter le script : `bash regenerate-reference.sh`
- Le `template.yaml` est généré avec les variables remplacées

### 3. Utiliser le Template

- Ouvrir `index.html` dans un navigateur
- Choisir l'appartement et la pièce
- Copier le contenu généré
- Coller dans Home Assistant

## Maintenance

### Ajouter un Nouvel Appartement

1. Ajouter une entrée dans la configuration JavaScript de `index.html`
2. Modifier le script `regenerate-reference.sh` si nécessaire pour les patterns

### Ajouter une Nouvelle Pièce

1. Ajouter une entrée dans le tableau correspondant de `index.html`
2. S'assurer que le `code` suit le format : minuscules avec underscores

### Mettre à Jour le Template

1. Exporter le nouveau dashboard depuis Home Assistant
2. Placer dans `new-reference-to-paste-here.yaml`
3. Exécuter `bash regenerate-reference.sh`
4. Un backup automatique du template précédent est créé
