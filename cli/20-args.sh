# Helper for CLI Flag Parsing
parse_args() {
  for arg in "$@"; do
    case $arg in
      --name=*)
        APP_NAME="${arg#*=}"
        ;;
      --template=*)
        TEMPLATE="${arg#*=}"
        ;;
      --router) ENABLE_ROUTER=true ;;
      --no-router) ENABLE_ROUTER=false ;;
      --context) ENABLE_CONTEXT=true ;;
      --no-context) ENABLE_CONTEXT=false ;;
      --signals) ENABLE_SIGNALS=true ;;
      --no-signals) ENABLE_SIGNALS=false ;;
      --header) ENABLE_HEADER=true ;;
      --no-header) ENABLE_HEADER=false ;;
      --theme-switcher) ENABLE_THEME_SWITCHER=true ;;
      --no-theme-switcher) ENABLE_THEME_SWITCHER=false ;;
      --mfe-loader) ENABLE_MFE_LOADER=true ;;
      --no-mfe-loader) ENABLE_MFE_LOADER=false ;;
      --todos) ENABLE_TODOS=true; ENABLE_SIGNALS=true ;;
      --no-todos) ENABLE_TODOS=false ;;
      --cards) ENABLE_CARDS=true ;;
      --no-cards) ENABLE_CARDS=false ;;
      --charts) ENABLE_CHARTS=true ;;
      --no-charts) ENABLE_CHARTS=false ;;
      --pm=*)
        pm_val="${arg#*=}"
        if [[ "$pm_val" =~ ^(yarn|npm|pnpm)$ ]]; then
          PACKAGE_MANAGER="$pm_val"
        else
          log_error "Invalid package manager: $pm_val (must be yarn, npm, or pnpm)"
          exit 1
        fi
        ;;
      --git) INIT_GIT=true ;;
      --no-git) INIT_GIT=false ;;
      --install) RUN_INSTALL=true ;;
      --no-install) RUN_INSTALL=false ;;
      -y|--yes) NON_INTERACTIVE=true ;;
      -v|--version)
        echo "@quincarter/create-lit-app v1.0.12"
        exit 0
        ;;
      --help|-h)
        echo -e "\n${BOLD}${CYAN}⚡ Lit Element App Shell Architecture Generator ⚡${RESET}"
        echo -e "${BLUE}Scaffold modular Lit Element applications with signals, context, routing, and UI suites.${RESET}\n"

        echo -e "${BOLD}${YELLOW}USAGE:${RESET}"
        echo -e "  ${GREEN}npx @quincarter/create-lit-app${RESET} [app-name] [options]\n"

        echo -e "${BOLD}${YELLOW}PROJECT CONFIGURATION:${RESET}"
        printf "  ${CYAN}%-32s${RESET} %s\n" "[app-name], --name=<name>" "Project directory / package name"
        printf "  ${CYAN}%-32s${RESET} %s\n" "--template=<type>" "Starter template: full | blank | custom (default: full)"
        printf "  ${CYAN}%-32s${RESET} %s\n" "--pm=<yarn|npm|pnpm>" "Package manager to use (default: yarn)"
        echo ""

        echo -e "${BOLD}${YELLOW}CORE ARCHITECTURE & STATE:${RESET}"
        printf "  ${CYAN}%-32s${RESET} %s\n" "--router | --no-router" "Enable/disable @lit-labs/router (auto-enables @lit/context)"
        printf "  ${CYAN}%-32s${RESET} %s\n" "--context | --no-context" "Enable/disable @lit/context dependency injection"
        printf "  ${CYAN}%-32s${RESET} %s\n" "--signals | --no-signals" "Enable/disable Preact Signals & IndexedDB store"
        echo ""

        echo -e "${BOLD}${YELLOW}UI COMPONENTS & SHOWCASES:${RESET}"
        printf "  ${CYAN}%-32s${RESET} %s\n" "--header | --no-header" "Enable/disable AppShellHeader component"
        printf "  ${CYAN}%-32s${RESET} %s\n" "--theme-switcher | --no-theme-switcher" "Enable/disable Theme Switcher component"
        printf "  ${CYAN}%-32s${RESET} %s\n" "--todos | --no-todos" "Enable/disable Signals Todo List component & view"
        printf "  ${CYAN}%-32s${RESET} %s\n" "--cards | --no-cards" "Enable/disable Generic Card component & view"
        printf "  ${CYAN}%-32s${RESET} %s\n" "--charts | --no-charts" "Enable/disable Chart.js wrapper & view"
        printf "  ${CYAN}%-32s${RESET} %s\n" "--mfe-loader | --no-mfe-loader" "Enable/disable Micro-Frontend (MFE) loader utility"
        echo ""

        echo -e "${BOLD}${YELLOW}WORKFLOW & SETUP:${RESET}"
        printf "  ${CYAN}%-32s${RESET} %s\n" "--git | --no-git" "Initialize Git repository (default: true)"
        printf "  ${CYAN}%-32s${RESET} %s\n" "--install | --no-install" "Run dependency installation step (default: false)"
        printf "  ${CYAN}%-32s${RESET} %s\n" "-y, --yes" "Run non-interactively with current flags"
        printf "  ${CYAN}%-32s${RESET} %s\n" "-v, --version" "Display version number"
        printf "  ${CYAN}%-32s${RESET} %s\n" "-h, --help" "Display this help menu"
        echo ""
        exit 0
        ;;
      -*)
        ;;
      *)
        if [ -z "$APP_NAME" ]; then
          APP_NAME="$arg"
        fi
        ;;
    esac
  done
}
