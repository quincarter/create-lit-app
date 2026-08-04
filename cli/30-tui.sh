# Terminal Raw Mode & Input Helpers for TUI
OLD_STTY=""

cleanup_tui() {
  echo -ne "\033[?25h" # Restore cursor
  if [ -n "$OLD_STTY" ]; then
    stty "$OLD_STTY" 2>/dev/null || true
    OLD_STTY=""
  fi
}

trap cleanup_tui EXIT INT TERM

read_key() {
  local key subkey
  IFS= read -r -s -n1 key 2>/dev/null || true
  if [[ "$key" == $'\x1b' ]]; then
    stty min 0 time 1 2>/dev/null || true
    read -r -s -n2 subkey 2>/dev/null || true
    stty min 1 time 0 2>/dev/null || true
    case "$subkey" in
      "[A"|"OA") echo "UP" ;;
      "[B"|"OB") echo "DOWN" ;;
      "[C"|"OC") echo "RIGHT" ;;
      "[D"|"OD") echo "LEFT" ;;
      *) echo "ESC" ;;
    esac
  elif [[ "$key" == "" ]]; then
    echo "ENTER"
  elif [[ "$key" == " " ]]; then
    echo "SPACE"
  elif [[ "$key" == "k" ]]; then
    echo "UP"
  elif [[ "$key" == "j" ]]; then
    echo "DOWN"
  elif [[ "$key" =~ [1-9] ]]; then
    echo "NUM_$key"
  else
    echo "OTHER"
  fi
}

RADIO_INDEX=0
RADIO_VALUE=""

prompt_radio_menu() {
  local title="$1"
  local default_idx="$2"
  shift 2
  local options=("$@")
  local num_options=${#options[@]}
  local current=$default_idx

  if [ -n "$TERM" ] && [ -t 0 ]; then
    OLD_STTY=$(stty -g 2>/dev/null)
    stty -echo -icanon min 1 time 0 2>/dev/null || true
  fi

  echo -ne "\033[?25l" # Hide cursor

  local rendered=false
  local total_lines=$((num_options + 2))

  while true; do
    if [ "$rendered" = true ]; then
      echo -ne "\033[${total_lines}A"
    fi

    echo -e "${BOLD}${CYAN}$title${RESET}\033[K"
    for i in "${!options[@]}"; do
      local opt="${options[$i]}"
      if [ "$i" -eq "$current" ]; then
        echo -e "  ${CYAN}❯${RESET} ${BOLD}${GREEN}(*) $opt${RESET}\033[K"
      else
        echo -e "    ${BLUE}( )${RESET} $opt\033[K"
      fi
    done
    echo -e "${YELLOW}(Use ↑/↓ or j/k to navigate, Enter to select)${RESET}\033[K"
    rendered=true

    local key
    key=$(read_key)
    case "$key" in
      UP)
        current=$(( (current - 1 + num_options) % num_options ))
        ;;
      DOWN)
        current=$(( (current + 1) % num_options ))
        ;;
      NUM_*)
        local idx=${key#NUM_}
        idx=$((idx - 1))
        if [ "$idx" -ge 0 ] && [ "$idx" -lt "$num_options" ]; then
          current=$idx
        fi
        ;;
      ENTER|SPACE)
        break
        ;;
    esac
  done

  if [ "$rendered" = true ]; then
    echo -ne "\033[${total_lines}A"
    for ((l=0; l<total_lines; l++)); do
      echo -ne "\033[2K\r\033[B"
    done
    echo -ne "\033[${total_lines}A"
  fi

  cleanup_tui

  RADIO_INDEX=$current
  RADIO_VALUE="${options[$current]}"
}

prompt_checkbox_menu() {
  local title="$1"
  shift 1
  local options=(
    "Routing (@lit-labs/router)"
    "Lit Context (@lit/context)"
    "Preact Signals & IndexedDB Stores (@lit-labs/preact-signals)"
    "Signals Showcase (Todo List Component & Store)"
    "Generic Card Component & Examples Page"
    "Chart.js Wrapper Component & Examples Page"
    "App Shell Header Component"
    "Theme Switcher Component"
    "Micro-Frontend (MFE) Loader Utility"
  )
  local num_options=${#options[@]}
  local current=0
  local status_msg=""

  # Default state: all features checked
  local checked_states=(1 1 1 1 1 1 1 1 1)

  enforce_deps() {
    # Rule: If Routing (0) is selected, Context (1) MUST be enabled
    if [ "${checked_states[0]}" -eq 1 ]; then
      checked_states[1]=1
    fi
    # Rule: If Todos Showcase (3) is selected, Signals (2) MUST be enabled
    if [ "${checked_states[3]}" -eq 1 ]; then
      checked_states[2]=1
    fi
  }

  enforce_deps

  if [ -n "$TERM" ] && [ -t 0 ]; then
    OLD_STTY=$(stty -g 2>/dev/null)
    stty -echo -icanon min 1 time 0 2>/dev/null || true
  fi

  echo -ne "\033[?25l" # Hide cursor

  local rendered=false
  local total_lines=$((num_options + 3))

  while true; do
    if [ "$rendered" = true ]; then
      echo -ne "\033[${total_lines}A"
    fi

    echo -e "${BOLD}${CYAN}$title${RESET}\033[K"
    for i in "${!options[@]}"; do
      local opt="${options[$i]}"
      local chk="${checked_states[$i]}"
      local lock_info=""

      if [ "$i" -eq 1 ] && [ "${checked_states[0]}" -eq 1 ]; then
        lock_info=" ${YELLOW}(required by Routing)${RESET}"
      elif [ "$i" -eq 2 ] && [ "${checked_states[3]}" -eq 1 ]; then
        lock_info=" ${YELLOW}(required by Todos Showcase)${RESET}"
      fi

      local box_str="[ ]"
      if [ "$chk" -eq 1 ]; then
        box_str="${GREEN}[X]${RESET}"
      else
        box_str="[ ]"
      fi

      if [ "$i" -eq "$current" ]; then
        echo -e "  ${CYAN}❯${RESET} ${BOLD}${box_str} ${opt}${RESET}${lock_info}\033[K"
      else
        echo -e "    ${box_str} ${opt}${lock_info}\033[K"
      fi
    done

    if [ -n "$status_msg" ]; then
      echo -e "${YELLOW}⚠ $status_msg${RESET}\033[K"
    else
      echo -e "\033[K"
    fi

    echo -e "${YELLOW}(Use ↑/↓ or j/k to navigate, Space to toggle, Enter to confirm)${RESET}\033[K"
    rendered=true

    status_msg=""
    local key
    key=$(read_key)
    case "$key" in
      UP)
        current=$(( (current - 1 + num_options) % num_options ))
        ;;
      DOWN)
        current=$(( (current + 1) % num_options ))
        ;;
      NUM_*)
        local idx=${key#NUM_}
        idx=$((idx - 1))
        if [ "$idx" -ge 0 ] && [ "$idx" -lt "$num_options" ]; then
          current=$idx
        fi
        ;;
      SPACE)
        if [ "$current" -eq 1 ] && [ "${checked_states[0]}" -eq 1 ]; then
          status_msg="Lit Context is required when Routing is enabled."
        elif [ "$current" -eq 2 ] && [ "${checked_states[3]}" -eq 1 ]; then
          status_msg="Preact Signals is required when Todos Showcase is enabled."
        else
          checked_states[$current]=$(( 1 - checked_states[$current] ))
          enforce_deps
        fi
        ;;
      ENTER)
        break
        ;;
    esac
  done

  if [ "$rendered" = true ]; then
    echo -ne "\033[${total_lines}A"
    for ((l=0; l<total_lines; l++)); do
      echo -ne "\033[2K\r\033[B"
    done
    echo -ne "\033[${total_lines}A"
  fi

  cleanup_tui

  ENABLE_ROUTER=$([ "${checked_states[0]}" -eq 1 ] && echo true || echo false)
  ENABLE_CONTEXT=$([ "${checked_states[1]}" -eq 1 ] && echo true || echo false)
  ENABLE_SIGNALS=$([ "${checked_states[2]}" -eq 1 ] && echo true || echo false)
  ENABLE_TODOS=$([ "${checked_states[3]}" -eq 1 ] && echo true || echo false)
  ENABLE_CARDS=$([ "${checked_states[4]}" -eq 1 ] && echo true || echo false)
  ENABLE_CHARTS=$([ "${checked_states[5]}" -eq 1 ] && echo true || echo false)
  ENABLE_HEADER=$([ "${checked_states[6]}" -eq 1 ] && echo true || echo false)
  ENABLE_THEME_SWITCHER=$([ "${checked_states[7]}" -eq 1 ] && echo true || echo false)
  ENABLE_MFE_LOADER=$([ "${checked_states[8]}" -eq 1 ] && echo true || echo false)
}

prompt_user() {
  log_title "Lit Element App Shell Generator"

  if [ -z "$APP_NAME" ]; then
    read -rp "Enter app name (default: my-app-shell): " input_name
    APP_NAME=${input_name:-my-app-shell}
  else
    echo -e "Creating app: ${BOLD}${CYAN}$APP_NAME${RESET}\n"
  fi

  prompt_radio_menu "Choose starter template preset:" 0 \
    "Full App Shell (Header, Navigation, Router, Contexts, Signals, Todos Showcase, Cards, Charts, MFEs)" \
    "Blank App Shell (Minimal Lit App Host)" \
    "Custom Selection (Select specific features interactively)"

  case $RADIO_INDEX in
    1)
      TEMPLATE="blank"
      ENABLE_ROUTER=false
      ENABLE_CONTEXT=false
      ENABLE_SIGNALS=false
      ENABLE_HEADER=false
      ENABLE_THEME_SWITCHER=false
      ENABLE_MFE_LOADER=false
      ENABLE_TODOS=false
      ENABLE_CARDS=false
      ENABLE_CHARTS=false
      log_success "Template preset: Blank App Shell"
      ;;
    2)
      TEMPLATE="custom"
      log_success "Template preset: Custom Selection"
      prompt_checkbox_menu "Select features to include in your App Shell:"
      log_success "Custom features configured."
      ;;
    *)
      TEMPLATE="full"
      ENABLE_ROUTER=true
      ENABLE_CONTEXT=true
      ENABLE_SIGNALS=true
      ENABLE_HEADER=true
      ENABLE_THEME_SWITCHER=true
      ENABLE_MFE_LOADER=true
      ENABLE_TODOS=true
      ENABLE_CARDS=true
      ENABLE_CHARTS=true
      log_success "Template preset: Full App Shell"
      ;;
  esac

  prompt_radio_menu "Choose package manager:" 0 "yarn" "npm" "pnpm"
  PACKAGE_MANAGER="$RADIO_VALUE"
  log_success "Package manager selected: $PACKAGE_MANAGER"

  prompt_radio_menu "Initialize Git repository?" 0 "Yes (Initialize Git repository)" "No"
  if [ "$RADIO_INDEX" -eq 0 ]; then
    INIT_GIT=true
    log_success "Git repository: Yes"
  else
    INIT_GIT=false
    log_success "Git repository: No"
  fi

  prompt_radio_menu "Run dependency installation now?" 0 "No (Skip dependency installation)" "Yes (Install dependencies now)"
  if [ "$RADIO_INDEX" -eq 1 ]; then
    RUN_INSTALL=true
    log_success "Install dependencies: Yes"
  else
    RUN_INSTALL=false
    log_success "Install dependencies: No"
  fi
}

parse_args "$@"

if [ "$NON_INTERACTIVE" = false ] && [ -t 0 ]; then
  prompt_user
else
  if [ -z "$APP_NAME" ]; then
    APP_NAME="my-app-shell"
  fi
  if [ "$TEMPLATE" = "blank" ]; then
    ENABLE_ROUTER=false
    ENABLE_CONTEXT=false
    ENABLE_SIGNALS=false
    ENABLE_HEADER=false
    ENABLE_THEME_SWITCHER=false
    ENABLE_MFE_LOADER=false
    ENABLE_TODOS=false
    ENABLE_CARDS=false
    ENABLE_CHARTS=false
  fi
fi

# Mandatory Dependency Rules
if [ "$ENABLE_ROUTER" = true ]; then
  ENABLE_CONTEXT=true
fi
if [ "$ENABLE_TODOS" = true ]; then
  ENABLE_SIGNALS=true
fi

TARGET_DIR="$(pwd)/$APP_NAME"

if [ -d "$TARGET_DIR" ]; then
  log_error "Target directory '$APP_NAME' already exists."
  exit 1
fi

log_info "Creating project directory: $TARGET_DIR"
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"
