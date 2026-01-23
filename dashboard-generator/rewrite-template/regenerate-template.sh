#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Portable in-place sed (GNU sed on Linux/WSL vs BSD sed on macOS)
sed_inplace() {
    local expr="$1"
    local file="$2"

    if sed --version >/dev/null 2>&1; then
        # GNU sed
        sed -i "$expr" "$file"
    else
        # BSD sed (macOS)
        sed -i '' "$expr" "$file"
    fi
}

require_sed() {
    local label="$1"
    shift
    sed_inplace "$@" || {
        echo -e "${RED}✗ sed failed during: ${label}${NC}"
        exit 1
    }
}

perl_inplace() {
    local script="$1"
    local file="$2"
    perl -0777 -i -pe "$script" "$file"
}

require_perl() {
    local label="$1"
    shift
    perl_inplace "$@" || {
        echo -e "${RED}✗ perl failed during: ${label}${NC}"
        exit 1
    }
}

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Paths
TEMPLATE_FILE="$PROJECT_DIR/template.yaml"
REFERENCE_FILE="$SCRIPT_DIR/new-reference-to-paste-here.yaml"
HISTORY_DIR="$PROJECT_DIR/history"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
BACKUP_FILE="$HISTORY_DIR/template_backup_${TIMESTAMP}.yaml"

echo -e "${BLUE}=== Dashboard Template Generator ===${NC}\n"

# Step 1: Backup template.yaml
echo -e "${YELLOW}Step 1: Creating backup...${NC}"
mkdir -p "$HISTORY_DIR"

if [ -f "$TEMPLATE_FILE" ]; then
    cp "$TEMPLATE_FILE" "$BACKUP_FILE"
    echo -e "${GREEN}✓ Backup created: $BACKUP_FILE${NC}\n"
else
    echo -e "${YELLOW}⚠ No existing template.yaml to backup${NC}\n"
fi

# Step 2: Auto-detect apartment and room from reference
echo -e "${YELLOW}Step 2: Detecting apartment and room from template...${NC}"

# Create temporary file for the templated content
TEMP_FILE=$(mktemp)
cp "$REFERENCE_FILE" "$TEMP_FILE"

# Extract apartment identifier (e.g., "engel" from "climate.chauffage_vt_engel_chambre_salon")
# macOS compatible version using sed
APARTMENT=$(grep "climate.chauffage_vt_" "$REFERENCE_FILE" | head -1 | sed 's/.*climate\.chauffage_vt_\([a-z]*\)_.*/\1/')

# Extract room code (e.g., "chambre_salon" from "climate.chauffage_vt_engel_chambre_salon")
ROOM_CODE=$(grep "climate.chauffage_vt_" "$REFERENCE_FILE" | head -1 | sed "s/.*climate\.chauffage_vt_${APARTMENT}_//" | sed 's/[^a-z_].*//')

# Extract room name (e.g., "Salon" from "title: 🛋️ Salon")
# Use title line which appears first and is most reliable (now at root level without views:)
ROOM_NAME=$(grep "^title:" "$REFERENCE_FILE" | head -1 | sed 's/^title: //' | sed 's/^[^a-zA-Z]* //')

if [ -z "$APARTMENT" ] || [ -z "$ROOM_CODE" ] || [ -z "$ROOM_NAME" ]; then
    echo -e "${RED}✗ Could not auto-detect apartment and room from template file${NC}"
    echo -e "${RED}  Please ensure the template file contains valid patterns:${NC}"
    echo -e "${RED}  - climate.chauffage_vt_<apartment>_<room_code>${NC}"
    echo -e "${RED}  - title: <Room Name>${NC}"
    exit 1
fi

ROOM_NAME=$(echo "$ROOM_NAME" | xargs) # Trim whitespace

echo -e "${GREEN}✓ Detected apartment: ${APARTMENT}${NC}"
echo -e "${GREEN}✓ Detected room code: ${ROOM_CODE}${NC}"
echo -e "${GREEN}✓ Detected room name: ${ROOM_NAME}${NC}\n"

# Step 3: Create templated version from reference
echo -e "${YELLOW}Step 3: Creating templated version...${NC}"

# Replace apartment/room-specific patterns (portable across macOS + Linux/WSL)
# 1. Replace VT entity prefixes while preserving the suffix (critical).
#    - First: replace the detected (correct) room code as a simple substring.
#    - Then: patch-up any other room code that may be present in VT entities (e.g. chambre_salon)
#      for common VT suffix patterns.
require_sed "chauffage_vt exact room" "s/chauffage_vt_${APARTMENT}_${ROOM_CODE}/chauffage_vt_{appart}_{room_code}/g" "$TEMP_FILE"
require_sed "chauffage_vt preset suffix" "s/\(chauffage_vt_\)${APARTMENT}_[a-z_][a-z_]*\(_preset_[a-z0-9_]*\)/\1{appart}_{room_code}\2/g" "$TEMP_FILE"
require_sed "chauffage_vt ema suffix" "s/\(chauffage_vt_\)${APARTMENT}_[a-z_][a-z_]*\(_ema_[a-z0-9_]*\)/\1{appart}_{room_code}\2/g" "$TEMP_FILE"
require_sed "chauffage_vt regulated suffix" "s/\(chauffage_vt_\)${APARTMENT}_[a-z_][a-z_]*\(_regulated_[a-z0-9_]*\)/\1{appart}_{room_code}\2/g" "$TEMP_FILE"
require_sed "chauffage_vt mode_detail" "s/\(chauffage_vt_\)${APARTMENT}_[a-z_][a-z_]*\(_mode_detail\)/\1{appart}_{room_code}\2/g" "$TEMP_FILE"
require_sed "chauffage_vt mode" "s/\(chauffage_vt_\)${APARTMENT}_[a-z_][a-z_]*\(_mode\)/\1{appart}_{room_code}\2/g" "$TEMP_FILE"
require_sed "chauffage_vt presence_state" "s/\(chauffage_vt_\)${APARTMENT}_[a-z_][a-z_]*\(_presence_state\)/\1{appart}_{room_code}\2/g" "$TEMP_FILE"
require_sed "chauffage_vt window_state" "s/\(chauffage_vt_\)${APARTMENT}_[a-z_][a-z_]*\(_window_state\)/\1{appart}_{room_code}\2/g" "$TEMP_FILE"

# 2. Replace all instances of the detected <room_code> with {room_code} (entities that don't include apartment)
require_sed "room_code" "s/${ROOM_CODE}/{room_code}/g" "$TEMP_FILE"

# 2a. Ensure path is a plain string (avoid YAML flow-map like: path: { room_code })
# This fixes broken URLs like /dashboard-chauffage/[object%20Object]
require_sed "path room_code quoted" "s/^path:[[:space:]]*{[[:space:]]*room_code[[:space:]]*}[[:space:]]*$/path: \"{room_code}\"/g" "$TEMP_FILE"

# 3. Replace all instances of <apartment> with {appart}
require_sed "apartment" "s/${APARTMENT}/{appart}/g" "$TEMP_FILE"

# 4. Replace "title:" line with "{room_name}" (with quotes)
# Handle both emoji prefix in title and plain room name
require_sed "title" "s/^title: .*${ROOM_NAME}.*/title: \"{room_name}\"/g" "$TEMP_FILE"

# 4a. Replace headings like "heading: Config <Room Name>" OR "heading: Config 🛌 <Room Name>" → "heading: Config {room_name}"
# Keep indentation intact.
require_sed "heading config room_name" "s/^\([[:space:]]*heading:[[:space:]]*Config\)[[:space:]]*.*${ROOM_NAME}$/\1 {room_name}/g" "$TEMP_FILE"

# 4b. Replace room name in "name:" lines, even when there's text before (like "Automatisme Chambre <Room Name>")
# This handles cases where the room name appears in the middle of a name field
require_sed "name room_name" "s/\(name: .*\)${ROOM_NAME}/\1{room_name}/g" "$TEMP_FILE"

# 4c. Add quotes around {room_name} when it's alone after "name: "
require_sed "quote room_name" "s/name: {room_name}$/name: \"{room_name}\"/g" "$TEMP_FILE"

# 5. Replace emoji + room name patterns with "{room_shortname}" (with quotes)
# This catches patterns like "name: 🛋️ Salon" or "name: 🛌 Sud"
require_sed "emoji shortname 🛋️" "s/name: 🛋️ .*/name: \"{room_shortname}\"/g" "$TEMP_FILE"
require_sed "emoji shortname 🛁" "s/name: 🛁 .*/name: \"{room_shortname}\"/g" "$TEMP_FILE"
require_sed "emoji shortname 💼" "s/name: 💼 .*/name: \"{room_shortname}\"/g" "$TEMP_FILE"
require_sed "emoji shortname 🛌" "s/name: 🛌 .*/name: \"{room_shortname}\"/g" "$TEMP_FILE"
require_sed "emoji shortname 🍳" "s/name: 🍳 .*/name: \"{room_shortname}\"/g" "$TEMP_FILE"

# 6. Replace patterns like "name: Automatisme 🛌 Chambre Salon" with "name: Automatisme {room_shortname}"
# This handles cases where there's text before the emoji
require_sed "emoji shortname prefix 🛋️" "s/\(name: .*\)🛋️ .*/\1{room_shortname}/g" "$TEMP_FILE"
require_sed "emoji shortname prefix 🛁" "s/\(name: .*\)🛁 .*/\1{room_shortname}/g" "$TEMP_FILE"
require_sed "emoji shortname prefix 💼" "s/\(name: .*\)💼 .*/\1{room_shortname}/g" "$TEMP_FILE"
require_sed "emoji shortname prefix 🛌" "s/\(name: .*\)🛌 .*/\1{room_shortname}/g" "$TEMP_FILE"
require_sed "emoji shortname prefix 🍳" "s/\(name: .*\)🍳 .*/\1{room_shortname}/g" "$TEMP_FILE"

# 7. Templatize Schedule card entities.
# Convert the schedule-state-card entities block to a generic placeholder. The UI (index.html)
# will decide the concrete schedule via {room_schedule}.
require_perl "schedule-state-card room_schedule" 's/(type:\s*custom:schedule-state-card[^\r\n]*\R)([ \t]*)entities:\s*\R.*?(?=\R(?:\2(?:colors:|grid_options:|show_state_in_title:)|[ \t]*- type:)|\z)/${1}${2}entities:\n${2}  - entity: sensor.schedule_{room_schedule}\n${2}    name: Schedule {room_name}\n${2}    icon: mdi:thermometer\n/sg' "$TEMP_FILE"

echo -e "${GREEN}✓ Template patterns applied${NC}\n"

# Step 4: Copy to template.yaml
echo -e "${YELLOW}Step 4: Copying to template.yaml...${NC}"
cp "$TEMP_FILE" "$TEMPLATE_FILE"
rm "$TEMP_FILE"

echo -e "${GREEN}✓ Template saved to: $TEMPLATE_FILE${NC}\n"

# Summary
echo -e "${BLUE}=== Complete ===${NC}"
echo -e "${GREEN}✓ Backup: $BACKUP_FILE${NC}"
echo -e "${GREEN}✓ Template: $TEMPLATE_FILE${NC}"
echo -e "\n${YELLOW}Replacements made:${NC}"
echo -e "  climate.chauffage_vt_${APARTMENT}_${ROOM_CODE} → climate.chauffage_vt_{appart}_{room_code}"
echo -e "  ${ROOM_CODE} → {room_code}"
echo -e "  ${APARTMENT} → {appart}"
echo -e "  name: ${ROOM_NAME} → name: {room_name}"
echo -e "  name: [emoji] ${ROOM_NAME##* } → name: {room_shortname}"
echo -e "\n${YELLOW}Variables used in template:${NC}"
echo "  - {appart}: Apartment identifier (replaces '${APARTMENT}')"
echo "  - {room_code}: Room code (replaces '${ROOM_CODE}')"
echo "  - {room_name}: Full room name (replaces '${ROOM_NAME}')"
echo "  - {room_shortname}: Short room name with emoji"
