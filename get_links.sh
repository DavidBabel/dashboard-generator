#!/bin/bash
# Wrapper pour lancer get_links depuis n'importe où
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "$SCRIPT_DIR/.githooks/get_links.sh"
