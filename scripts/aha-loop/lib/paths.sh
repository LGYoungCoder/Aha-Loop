#!/bin/bash
# Aha Loop Path Resolution Library
# Provides unified path resolution for workspace and standalone modes
#
# Usage:
#   source scripts/aha-loop/lib/paths.sh
#   init_paths [--workspace /path/to/project]
#   export_paths
#
# Environment Variables (after export_paths):
#   AHA_LOOP_HOME      - Aha Loop installation directory
#   WORKSPACE_ROOT     - User project directory (same as AHA_LOOP_HOME in standalone mode)
#   AHA_LOOP_DIR       - Working directory for Aha Loop files (.aha-loop/ or scripts/aha-loop/)
#   WORKSPACE_MODE     - "true" if operating on external workspace, "false" otherwise

# Resolve the Aha Loop installation directory
# This is where skills, scripts, and templates live
resolve_aha_loop_home() {
  local script_source="${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}"
  local script_dir
  script_dir="$(cd "$(dirname "$script_source")" && pwd)"

  # Navigate up from lib/ to scripts/aha-loop/ to project root
  if [[ "$script_dir" == */lib ]]; then
    echo "$(cd "$script_dir/../../.." && pwd)"
  elif [[ "$script_dir" == */scripts/aha-loop ]]; then
    echo "$(cd "$script_dir/../.." && pwd)"
  elif [[ "$script_dir" == */scripts/god ]]; then
    echo "$(cd "$script_dir/../.." && pwd)"
  else
    # Fallback: assume we're somewhere in the Aha Loop tree
    echo "$(cd "$script_dir" && pwd)"
  fi
}

# Resolve the workspace root directory
# Priority: CLI arg > env var > detect .aha-loop/ > search up > standalone mode
resolve_workspace_root() {
  local cli_workspace="${1:-}"

  # Priority 1: CLI argument
  if [[ -n "$cli_workspace" ]]; then
    if [[ -d "$cli_workspace" ]]; then
      echo "$(cd "$cli_workspace" && pwd)"
      return 0
    else
      echo "Error: Workspace directory does not exist: $cli_workspace" >&2
      return 1
    fi
  fi

  # Priority 2: Environment variable
  if [[ -n "${AHA_LOOP_WORKSPACE:-}" ]]; then
    if [[ -d "$AHA_LOOP_WORKSPACE" ]]; then
      echo "$(cd "$AHA_LOOP_WORKSPACE" && pwd)"
      return 0
    else
      echo "Error: AHA_LOOP_WORKSPACE directory does not exist: $AHA_LOOP_WORKSPACE" >&2
      return 1
    fi
  fi

  # Priority 3: Current directory contains .aha-loop/
  if [[ -d ".aha-loop" ]]; then
    pwd
    return 0
  fi

  # Priority 4: Search up directory tree for .aha-loop/
  local current_dir
  current_dir="$(pwd)"
  while [[ "$current_dir" != "/" ]]; do
    if [[ -d "$current_dir/.aha-loop" ]]; then
      echo "$current_dir"
      return 0
    fi
    current_dir="$(dirname "$current_dir")"
  done

  # Priority 5: Standalone mode - use Aha Loop home as workspace
  echo ""
  return 0
}

# Check if we're in workspace mode
is_workspace_mode() {
  local workspace_root="${1:-}"
  local aha_loop_home="${2:-}"

  # If workspace_root is empty or same as aha_loop_home, we're in standalone mode
  if [[ -z "$workspace_root" ]] || [[ "$workspace_root" == "$aha_loop_home" ]]; then
    echo "false"
  else
    echo "true"
  fi
}

# Get the .aha-loop/ directory path (or scripts/aha-loop/ in standalone mode)
get_aha_loop_dir() {
  local workspace_root="${1:-}"
  local aha_loop_home="${2:-}"
  local workspace_mode="${3:-}"

  if [[ "$workspace_mode" == "true" ]]; then
    echo "$workspace_root/.aha-loop"
  else
    echo "$aha_loop_home/scripts/aha-loop"
  fi
}

# Alias for get_aha_loop_dir (for clarity in some contexts)
get_working_dir() {
  get_aha_loop_dir "$@"
}

# Get the skills directory
# In workspace mode: $WORKSPACE_ROOT/.claude/skills (copied during init)
# In standalone mode: $AHA_LOOP_HOME/.claude/skills
get_skills_dir() {
  local workspace_root="${1:-}"
  local aha_loop_home="${2:-}"
  local workspace_mode="${3:-}"

  if [[ "$workspace_mode" == "true" ]]; then
    echo "$workspace_root/.claude/skills"
  else
    echo "$aha_loop_home/.claude/skills"
  fi
}

# Get the templates directory
# In workspace mode: $AHA_LOOP_DIR/templates (copied during init)
# In standalone mode: $AHA_LOOP_HOME/scripts/aha-loop/templates
get_templates_dir() {
  local aha_loop_dir="${1:-}"
  local aha_loop_home="${2:-}"
  local workspace_mode="${3:-}"

  if [[ "$workspace_mode" == "true" ]]; then
    echo "$aha_loop_dir/templates"
  else
    echo "$aha_loop_home/scripts/aha-loop/templates"
  fi
}

# Get the God Committee directory
get_god_dir() {
  local workspace_root="${1:-}"
  local aha_loop_home="${2:-}"
  local workspace_mode="${3:-}"

  if [[ "$workspace_mode" == "true" ]]; then
    echo "$workspace_root/.aha-loop/.god"
  else
    echo "$aha_loop_home/.god"
  fi
}

# Get the knowledge directory
get_knowledge_dir() {
  local workspace_root="${1:-}"
  local aha_loop_home="${2:-}"
  local workspace_mode="${3:-}"

  if [[ "$workspace_mode" == "true" ]]; then
    echo "$workspace_root/.aha-loop/knowledge"
  else
    echo "$aha_loop_home/knowledge"
  fi
}

# Get the logs directory
get_logs_dir() {
  local workspace_root="${1:-}"
  local aha_loop_home="${2:-}"
  local workspace_mode="${3:-}"

  if [[ "$workspace_mode" == "true" ]]; then
    echo "$workspace_root/.aha-loop/logs"
  else
    echo "$aha_loop_home/logs"
  fi
}

# Get the research directory
get_research_dir() {
  local aha_loop_dir="${1:-}"
  echo "$aha_loop_dir/research"
}

# Get the exploration directory
get_exploration_dir() {
  local aha_loop_dir="${1:-}"
  echo "$aha_loop_dir/exploration"
}

# Get the archive directory
get_archive_dir() {
  local aha_loop_dir="${1:-}"
  echo "$aha_loop_dir/archive"
}

# Get the tasks directory
get_tasks_dir() {
  local aha_loop_dir="${1:-}"
  echo "$aha_loop_dir/tasks"
}

# Get the worktrees directory
get_worktrees_dir() {
  local workspace_root="${1:-}"
  local aha_loop_home="${2:-}"
  local workspace_mode="${3:-}"

  if [[ "$workspace_mode" == "true" ]]; then
    echo "$workspace_root/.aha-loop/.worktrees"
  else
    echo "$aha_loop_home/.worktrees"
  fi
}

# Get the vendor directory
get_vendor_dir() {
  local workspace_root="${1:-}"
  local aha_loop_home="${2:-}"
  local workspace_mode="${3:-}"

  if [[ "$workspace_mode" == "true" ]]; then
    echo "$workspace_root/.aha-loop/.vendor"
  else
    echo "$aha_loop_home/.vendor"
  fi
}

# Initialize workspace directory structure
# Args:
#   $1 - workspace_root: The target workspace directory
#   $2 - aha_loop_home: The Aha Loop installation directory (for copying resources)
init_workspace() {
  local workspace_root="${1:-}"
  local aha_loop_home="${2:-}"

  if [[ -z "$workspace_root" ]]; then
    echo "Error: Workspace root required" >&2
    return 1
  fi

  if [[ -z "$aha_loop_home" ]]; then
    echo "Error: Aha Loop home required for resource copying" >&2
    return 1
  fi

  local aha_loop_dir="$workspace_root/.aha-loop"

  echo "Initializing Aha Loop workspace at: $workspace_root"
  echo "Using Aha Loop installation: $aha_loop_home"
  echo ""

  # Create directory structure
  mkdir -p "$aha_loop_dir"
  mkdir -p "$aha_loop_dir/research"
  mkdir -p "$aha_loop_dir/exploration"
  mkdir -p "$aha_loop_dir/archive"
  mkdir -p "$aha_loop_dir/tasks"
  mkdir -p "$aha_loop_dir/knowledge/project"
  mkdir -p "$aha_loop_dir/knowledge/domain"
  mkdir -p "$aha_loop_dir/logs"
  mkdir -p "$aha_loop_dir/.worktrees"
  mkdir -p "$aha_loop_dir/.vendor"
  mkdir -p "$aha_loop_dir/.god/council"
  mkdir -p "$aha_loop_dir/.god/decisions"
  mkdir -p "$aha_loop_dir/.god/snapshots"
  mkdir -p "$aha_loop_dir/.god/observation"
  mkdir -p "$aha_loop_dir/.god/members/alpha"
  mkdir -p "$aha_loop_dir/.god/members/beta"
  mkdir -p "$aha_loop_dir/.god/members/gamma"

  # === Copy resources from Aha Loop installation ===
  echo "Copying resources from Aha Loop installation..."

  # Copy skills to workspace root (.claude/skills/)
  # This is required because Claude Code and other AI agents load skills from WORKSPACE_ROOT/.claude/skills/
  # Use -L to follow symlinks (since .claude/skills may be a symlink to .agents/skills)
  mkdir -p "$workspace_root/.claude"
  if [[ -e "$aha_loop_home/.claude/skills" ]]; then
    cp -rL "$aha_loop_home/.claude/skills" "$workspace_root/.claude/"
    echo "  Copied: .claude/skills/"
  elif [[ -d "$aha_loop_home/.agents/skills" ]]; then
    # Fallback: copy from .agents/skills directly
    cp -rL "$aha_loop_home/.agents/skills" "$workspace_root/.claude/"
    echo "  Copied: .claude/skills/ (from .agents/skills)"
  else
    echo "  Warning: Skills directory not found in Aha Loop installation"
  fi

  # Copy templates to .aha-loop/templates/
  if [[ -d "$aha_loop_home/scripts/aha-loop/templates" ]]; then
    cp -rL "$aha_loop_home/scripts/aha-loop/templates" "$aha_loop_dir/"
    echo "  Copied: .aha-loop/templates/"
  else
    echo "  Warning: Templates directory not found"
  fi

  # Copy AI instructions to .aha-loop/
  if [[ -f "$aha_loop_home/scripts/aha-loop/CLAUDE.md" ]]; then
    cp "$aha_loop_home/scripts/aha-loop/CLAUDE.md" "$aha_loop_dir/"
    echo "  Copied: .aha-loop/CLAUDE.md"
  fi

  if [[ -f "$aha_loop_home/scripts/aha-loop/prompt.md" ]]; then
    cp "$aha_loop_home/scripts/aha-loop/prompt.md" "$aha_loop_dir/"
    echo "  Copied: .aha-loop/prompt.md"
  fi

  # Copy example files
  local example_count=0
  for example_file in "$aha_loop_home/scripts/aha-loop"/*.example; do
    if [[ -f "$example_file" ]]; then
      cp "$example_file" "$aha_loop_dir/"
      example_count=$((example_count + 1))
    fi
  done
  if [[ $example_count -gt 0 ]]; then
    echo "  Copied: $example_count example file(s)"
  fi

  echo ""

  # Create default config.json if not exists
  if [[ ! -f "$aha_loop_dir/config.json" ]]; then
    cat > "$aha_loop_dir/config.json" << 'EOF'
{
  "version": 1,
  "workspace": true,
  "phases": {
    "research": {
      "enabled": true,
      "fetchSourceCode": true
    },
    "exploration": {
      "enabled": true
    },
    "planReview": {
      "enabled": true
    },
    "qualityReview": {
      "enabled": true
    }
  },
  "safeguards": {
    "maxIterationsPerStory": 10
  },
  "orchestrator": {
    "maxPRDsPerRun": 10
  },
  "parallelExploration": {
    "maxConcurrent": 10,
    "evaluationAgents": 3
  },
  "observability": {
    "enabled": true,
    "level": "normal"
  },
  "docMaintenance": {
    "enabled": true
  }
}
EOF
    echo "  Created: $aha_loop_dir/config.json"
  fi

  # Create progress.txt if not exists
  if [[ ! -f "$aha_loop_dir/progress.txt" ]]; then
    cat > "$aha_loop_dir/progress.txt" << EOF
# Aha Loop Progress Log
Started: $(date)
---
EOF
    echo "  Created: $aha_loop_dir/progress.txt"
  fi

  # Create ai-thoughts.md if not exists
  if [[ ! -f "$aha_loop_dir/logs/ai-thoughts.md" ]]; then
    cat > "$aha_loop_dir/logs/ai-thoughts.md" << EOF
# AI Thoughts Log

This file contains AI decision-making logs for observability.

---
EOF
    echo "  Created: $aha_loop_dir/logs/ai-thoughts.md"
  fi

  # Initialize God Committee files
  if [[ ! -f "$aha_loop_dir/.god/directives.json" ]]; then
    cat > "$aha_loop_dir/.god/directives.json" << 'EOF'
{
  "version": 1,
  "directives": [],
  "guidance": [],
  "summaries": []
}
EOF
    echo "  Created: $aha_loop_dir/.god/directives.json"
  fi

  if [[ ! -f "$aha_loop_dir/.god/config.json" ]]; then
    cat > "$aha_loop_dir/.god/config.json" << 'EOF'
{
  "version": 1,
  "observation": {
    "watchPaths": ["src", "lib", "tests"],
    "alertPatterns": ["error", "failed", "panic", "exception"]
  },
  "awakening": {
    "randomInterval": 3600,
    "commitHook": true
  }
}
EOF
    echo "  Created: $aha_loop_dir/.god/config.json"
  fi

  # Initialize observation files
  if [[ ! -f "$aha_loop_dir/.god/observation/timeline.json" ]]; then
    echo '{"events": []}' > "$aha_loop_dir/.god/observation/timeline.json"
    echo "  Created: $aha_loop_dir/.god/observation/timeline.json"
  fi

  if [[ ! -f "$aha_loop_dir/.god/observation/anomalies.json" ]]; then
    echo '{"anomalies": []}' > "$aha_loop_dir/.god/observation/anomalies.json"
    echo "  Created: $aha_loop_dir/.god/observation/anomalies.json"
  fi

  if [[ ! -f "$aha_loop_dir/.god/observation/system-state.json" ]]; then
    echo '{}' > "$aha_loop_dir/.god/observation/system-state.json"
    echo "  Created: $aha_loop_dir/.god/observation/system-state.json"
  fi

  # Initialize council files
  if [[ ! -f "$aha_loop_dir/.god/council/messages.json" ]]; then
    echo '{"messages": []}' > "$aha_loop_dir/.god/council/messages.json"
    echo "  Created: $aha_loop_dir/.god/council/messages.json"
  fi

  if [[ ! -f "$aha_loop_dir/.god/council/decisions.json" ]]; then
    echo '{"decisions": []}' > "$aha_loop_dir/.god/council/decisions.json"
    echo "  Created: $aha_loop_dir/.god/council/decisions.json"
  fi

  if [[ ! -f "$aha_loop_dir/.god/council/status.json" ]]; then
    cat > "$aha_loop_dir/.god/council/status.json" << 'EOF'
{
  "sessionActive": false,
  "currentSpeaker": null,
  "speakerLock": null,
  "lastActivity": null
}
EOF
    echo "  Created: $aha_loop_dir/.god/council/status.json"
  fi

  # Initialize member status files
  for member in alpha beta gamma; do
    if [[ ! -f "$aha_loop_dir/.god/members/$member/status.json" ]]; then
      cat > "$aha_loop_dir/.god/members/$member/status.json" << EOF
{
  "id": "$member",
  "status": "sleeping",
  "lastAwakened": null,
  "lastAction": null
}
EOF
      echo "  Created: $aha_loop_dir/.god/members/$member/status.json"
    fi
  done

  echo ""
  echo "Workspace initialized successfully!"
  echo ""
  echo "Directory structure:"
  echo "  $workspace_root/"
  echo "  ├── .claude/"
  echo "  │   └── skills/              # AI skills (copied from Aha Loop)"
  echo "  └── .aha-loop/"
  echo "      ├── config.json"
  echo "      ├── progress.txt"
  echo "      ├── CLAUDE.md            # AI instructions"
  echo "      ├── prompt.md            # AI prompt"
  echo "      ├── templates/           # Document templates"
  echo "      ├── research/"
  echo "      ├── exploration/"
  echo "      ├── archive/"
  echo "      ├── tasks/"
  echo "      ├── knowledge/"
  echo "      │   ├── project/"
  echo "      │   └── domain/"
  echo "      ├── logs/"
  echo "      ├── .worktrees/"
  echo "      ├── .vendor/"
  echo "      └── .god/"
  echo "          ├── council/"
  echo "          ├── decisions/"
  echo "          ├── observation/"
  echo "          └── members/"
  echo ""
  echo "Next steps:"
  echo "  1. Create project.vision.md or run: orchestrator.sh --build-vision"
  echo "  2. Run: orchestrator.sh --workspace $workspace_root"

  return 0
}

# Initialize and export all path variables
# Call this after parsing CLI arguments
init_paths() {
  local cli_workspace=""

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --workspace)
        cli_workspace="$2"
        shift 2
        ;;
      --workspace=*)
        cli_workspace="${1#*=}"
        shift
        ;;
      *)
        shift
        ;;
    esac
  done

  # Resolve paths
  _AHA_LOOP_HOME=$(resolve_aha_loop_home)
  _WORKSPACE_ROOT=$(resolve_workspace_root "$cli_workspace")

  # If workspace_root is empty, use aha_loop_home (standalone mode)
  if [[ -z "$_WORKSPACE_ROOT" ]]; then
    _WORKSPACE_ROOT="$_AHA_LOOP_HOME"
  fi

  _WORKSPACE_MODE=$(is_workspace_mode "$_WORKSPACE_ROOT" "$_AHA_LOOP_HOME")
  _AHA_LOOP_DIR=$(get_aha_loop_dir "$_WORKSPACE_ROOT" "$_AHA_LOOP_HOME" "$_WORKSPACE_MODE")

  # Export for use by calling script
  export AHA_LOOP_HOME="$_AHA_LOOP_HOME"
  export WORKSPACE_ROOT="$_WORKSPACE_ROOT"
  export WORKSPACE_MODE="$_WORKSPACE_MODE"
  export AHA_LOOP_DIR="$_AHA_LOOP_DIR"
}

# Export all derived paths as environment variables
export_paths() {
  # Ensure init_paths was called
  if [[ -z "${AHA_LOOP_HOME:-}" ]]; then
    echo "Error: init_paths must be called before export_paths" >&2
    return 1
  fi

  # Core directories
  export SKILLS_DIR=$(get_skills_dir "$WORKSPACE_ROOT" "$AHA_LOOP_HOME" "$WORKSPACE_MODE")
  export TEMPLATES_DIR=$(get_templates_dir "$AHA_LOOP_DIR" "$AHA_LOOP_HOME" "$WORKSPACE_MODE")
  export GOD_DIR=$(get_god_dir "$WORKSPACE_ROOT" "$AHA_LOOP_HOME" "$WORKSPACE_MODE")
  export KNOWLEDGE_DIR=$(get_knowledge_dir "$WORKSPACE_ROOT" "$AHA_LOOP_HOME" "$WORKSPACE_MODE")
  export LOGS_DIR=$(get_logs_dir "$WORKSPACE_ROOT" "$AHA_LOOP_HOME" "$WORKSPACE_MODE")
  export RESEARCH_DIR=$(get_research_dir "$AHA_LOOP_DIR")
  export EXPLORATION_DIR=$(get_exploration_dir "$AHA_LOOP_DIR")
  export ARCHIVE_DIR=$(get_archive_dir "$AHA_LOOP_DIR")
  export TASKS_DIR=$(get_tasks_dir "$AHA_LOOP_DIR")
  export WORKTREES_DIR=$(get_worktrees_dir "$WORKSPACE_ROOT" "$AHA_LOOP_HOME" "$WORKSPACE_MODE")
  export VENDOR_DIR=$(get_vendor_dir "$WORKSPACE_ROOT" "$AHA_LOOP_HOME" "$WORKSPACE_MODE")

  # Common files
  export CONFIG_FILE="$AHA_LOOP_DIR/config.json"
  export PRD_FILE="$AHA_LOOP_DIR/prd.json"
  export PROGRESS_FILE="$AHA_LOOP_DIR/progress.txt"
  export LOG_FILE="$LOGS_DIR/ai-thoughts.md"
  export LAST_BRANCH_FILE="$AHA_LOOP_DIR/.last-branch"
  export DIRECTIVES_FILE="$GOD_DIR/directives.json"

  # Project files (in workspace root for workspace mode, in aha_loop_home for standalone)
  if [[ "$WORKSPACE_MODE" == "true" ]]; then
    export VISION_FILE="$AHA_LOOP_DIR/project.vision.md"
    export VISION_ANALYSIS="$AHA_LOOP_DIR/project.vision-analysis.md"
    export ARCHITECTURE_FILE="$AHA_LOOP_DIR/project.architecture.md"
    export ROADMAP_FILE="$AHA_LOOP_DIR/project.roadmap.json"
  else
    export VISION_FILE="$WORKSPACE_ROOT/project.vision.md"
    export VISION_ANALYSIS="$WORKSPACE_ROOT/project.vision-analysis.md"
    export ARCHITECTURE_FILE="$WORKSPACE_ROOT/project.architecture.md"
    export ROADMAP_FILE="$WORKSPACE_ROOT/project.roadmap.json"
  fi

  # Scripts (always in AHA_LOOP_HOME)
  export COUNCIL_SCRIPT="$AHA_LOOP_HOME/scripts/god/council.sh"
  export OBSERVER_SCRIPT="$AHA_LOOP_HOME/scripts/god/observer.sh"
  export POWERS_SCRIPT="$AHA_LOOP_HOME/scripts/god/powers.sh"
  export AWAKENER_SCRIPT="$AHA_LOOP_HOME/scripts/god/awakener.sh"

  # God Committee observation directory
  export OBS_DIR="$GOD_DIR/observation"
}

# Print current path configuration (for debugging)
print_paths() {
  echo "=== Aha Loop Path Configuration ==="
  echo ""
  echo "Mode: $([ "$WORKSPACE_MODE" == "true" ] && echo "Workspace" || echo "Standalone")"
  echo ""
  echo "Core Paths:"
  echo "  AHA_LOOP_HOME:    ${AHA_LOOP_HOME:-<not set>}"
  echo "  WORKSPACE_ROOT:   ${WORKSPACE_ROOT:-<not set>}"
  echo "  AHA_LOOP_DIR:     ${AHA_LOOP_DIR:-<not set>}"
  echo ""
  echo "Directories:"
  echo "  SKILLS_DIR:       ${SKILLS_DIR:-<not set>}"
  echo "  TEMPLATES_DIR:    ${TEMPLATES_DIR:-<not set>}"
  echo "  GOD_DIR:          ${GOD_DIR:-<not set>}"
  echo "  KNOWLEDGE_DIR:    ${KNOWLEDGE_DIR:-<not set>}"
  echo "  LOGS_DIR:         ${LOGS_DIR:-<not set>}"
  echo "  RESEARCH_DIR:     ${RESEARCH_DIR:-<not set>}"
  echo "  EXPLORATION_DIR:  ${EXPLORATION_DIR:-<not set>}"
  echo "  ARCHIVE_DIR:      ${ARCHIVE_DIR:-<not set>}"
  echo "  TASKS_DIR:        ${TASKS_DIR:-<not set>}"
  echo "  WORKTREES_DIR:    ${WORKTREES_DIR:-<not set>}"
  echo "  VENDOR_DIR:       ${VENDOR_DIR:-<not set>}"
  echo ""
  echo "Files:"
  echo "  CONFIG_FILE:      ${CONFIG_FILE:-<not set>}"
  echo "  PRD_FILE:         ${PRD_FILE:-<not set>}"
  echo "  PROGRESS_FILE:    ${PROGRESS_FILE:-<not set>}"
  echo "  LOG_FILE:         ${LOG_FILE:-<not set>}"
  echo "  VISION_FILE:      ${VISION_FILE:-<not set>}"
  echo "  ROADMAP_FILE:     ${ROADMAP_FILE:-<not set>}"
  echo "  DIRECTIVES_FILE:  ${DIRECTIVES_FILE:-<not set>}"
  echo ""
}

# Generate workspace context for AI prompts
generate_workspace_context() {
  if [[ "$WORKSPACE_MODE" != "true" ]]; then
    echo ""
    return
  fi

  cat << EOF
## Workspace Context

You are working in workspace mode:
- **Workspace**: $WORKSPACE_ROOT
- **Aha Loop Home**: $AHA_LOOP_HOME
- **Aha Loop Dir**: $AHA_LOOP_DIR

All Aha Loop files are in .aha-loop/ directory:
- prd.json: $PRD_FILE
- progress.txt: $PROGRESS_FILE
- project.vision.md: $VISION_FILE
- project.roadmap.json: $ROADMAP_FILE
- research/: $RESEARCH_DIR
- exploration/: $EXPLORATION_DIR
- knowledge/: $KNOWLEDGE_DIR
- logs/: $LOGS_DIR
- .god/: $GOD_DIR
- skills: $SKILLS_DIR (in Aha Loop installation)

EOF
}
