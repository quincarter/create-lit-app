#!/usr/bin/env bash

# ==============================================================================
# Lit Element App Shell Architecture Generator
# Scaffolds modular Lit Element applications with optional Routing, Signals,
# Contexts, MFE Loader, Theme Switcher, and Component Showcase Suites.
# ==============================================================================

set -e

# ANSI Color Tokens
BOLD="\033[1m"
GREEN="\033[32m"
BLUE="\033[34m"
CYAN="\033[36m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

log_title() {
  echo -e "\n${BOLD}${CYAN}====================================================${RESET}"
  echo -e "${BOLD}${CYAN}  $1${RESET}"
  echo -e "${BOLD}${CYAN}====================================================${RESET}\n"
}

log_info() {
  echo -e "${BLUE}ℹ${RESET} $1"
}

log_success() {
  echo -e "${GREEN}✔${RESET} $1"
}

log_warn() {
  echo -e "${YELLOW}⚠${RESET} $1"
}

log_error() {
  echo -e "${RED}✖${RESET} $1"
}
