# ------------------------------------------------------------------------------
# Post-Generation Steps
# ------------------------------------------------------------------------------
if [ "$INIT_GIT" = true ]; then
  log_info "Initializing git repository..."
  git init -q
  log_success "Git repository initialized."
fi

if [ "$RUN_INSTALL" = true ]; then
  log_info "Installing dependencies with $PACKAGE_MANAGER..."
  $PACKAGE_MANAGER install
  log_success "Dependencies installed."
fi

log_title "App Shell Scaffolding Complete!"
echo -e "${GREEN}Project successfully created at:${RESET} ${BOLD}$TARGET_DIR${RESET}\n"

START_CMD="$PACKAGE_MANAGER start"

if [ "$NON_INTERACTIVE" = false ]; then
  read -rp "Would you like to cd into '$APP_NAME' and run '$START_CMD' now? (y/N): " AUTO_START
  if [[ "$AUTO_START" =~ ^[Yy]$ ]]; then
    echo -e "\n${CYAN}Directory changed to:${RESET} ${BOLD}$TARGET_DIR${RESET}"
    echo -e "${CYAN}Launching dev server with:${RESET} ${BOLD}$START_CMD${RESET}\n"
    cd "$TARGET_DIR" || exit 1
    if [ "$RUN_INSTALL" = false ]; then
      log_info "Installing dependencies first..."
      $PACKAGE_MANAGER install
    fi
    exec $PACKAGE_MANAGER start
  fi
fi

echo -e "Next steps:"
echo -e "  cd ${BOLD}$APP_NAME${RESET}"
if [ "$RUN_INSTALL" = false ]; then
  echo -e "  ${BOLD}$PACKAGE_MANAGER install${RESET}"
fi
echo -e "  ${BOLD}$START_CMD${RESET}\n"
