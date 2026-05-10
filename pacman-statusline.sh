#!/bin/bash
# Claude Code Native Statusline - Starship catppuccin mocha inspired theme

read -t 5 json_data 2>/dev/null || exit 0

# Get git info directly
git_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
git_dirty=0
git_ahead=0
git_behind=0

if [ -n "$git_branch" ] && [ "$git_branch" != "HEAD" ]; then
    if ! git diff --quiet 2>/dev/null || [ -n "$(git status --porcelain)" ]; then
        git_dirty=1
    fi
    upstream=$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null)
    ret=$?
    if [ $ret -eq 0 ] && [ -n "$upstream" ]; then
        ahead_behind=$(git rev-list --left-right --count "HEAD...${upstream}" 2>/dev/null)
        if [ -n "$ahead_behind" ] && echo "$ahead_behind" | grep -qE '^[0-9]+[[:space:]]+[0-9]+$'; then
            git_ahead=$(echo -e "$ahead_behind" | cut -f1)
            git_behind=$(echo -e "$ahead_behind" | cut -f2)
        fi
    fi
fi

# Detect runtime environment
RUNTIME_INFO=""
cwd="${PWD}"

# Java
if [ -f "$cwd/pom.xml" ] || [ -f "$cwd/build.gradle" ] || [ -f "$cwd/build.gradle.kts" ]; then
    if command -v java &>/dev/null; then
        java_ver=$(java -version 2>&1 | head -1 | cut -d'"' -f2)
        RUNTIME_INFO=" Java $java_ver"
    fi
fi

# Python
if [ -f "$cwd/requirements.txt" ] || [ -f "$cwd/pyproject.toml" ] || [ -f "$cwd/Pipfile" ] || [ -f "$cwd/.python-version" ]; then
    if command -v python3 &>/dev/null; then
        py_ver=$(python3 --version 2>&1 | cut -d' ' -f2)
        [ -z "$RUNTIME_INFO" ] && RUNTIME_INFO="󰌠 Python $py_ver"
    fi
fi

# Node.js
if [ -f "$cwd/package.json" ] || [ -f "$cwd/yarn.lock" ] || [ -f "$cwd/pnpm-lock.yaml" ]; then
    if command -v node &>/dev/null; then
        node_ver=$(node --version 2>&1)
        [ -z "$RUNTIME_INFO" ] && RUNTIME_INFO=" Node $node_ver"
    fi
fi

# Go
if [ -f "$cwd/go.mod" ]; then
    if command -v go &>/dev/null; then
        go_ver=$(go version 2>&1 | cut -d' ' -f3)
        [ -z "$RUNTIME_INFO" ] && RUNTIME_INFO="\U000F07D3 Go $go_ver"
    fi
fi

# Rust
if [ -f "$cwd/Cargo.toml" ]; then
    if command -v rustc &>/dev/null; then
        rust_ver=$(rustc --version 2>&1 | cut -d' ' -f2)
        [ -z "$RUNTIME_INFO" ] && RUNTIME_INFO="󱘗 Rust $rust_ver"
    fi
fi

python3 - "$json_data" "$git_branch" "$git_dirty" "$git_ahead" "$git_behind" "$RUNTIME_INFO" << 'PYTHON_EOF'
import sys
import json

json_data = sys.argv[1]
git_branch = sys.argv[2] if len(sys.argv) > 2 else ""
git_dirty = int(sys.argv[3]) if len(sys.argv) > 3 else 0
git_ahead = int(sys.argv[4]) if len(sys.argv) > 4 else 0
git_behind = int(sys.argv[5]) if len(sys.argv) > 5 else 0
runtime_info = sys.argv[6] if len(sys.argv) > 6 else ""

try:
    data = json.loads(json_data)
except:
    sys.exit(0)

# Catppuccin Mocha Color Palette
RESET = '\033[0m'
# Base colors
SURFACE0 = '\033[38;2;49;50;68m'       # #313244 - Surface
SURFACE1 = '\033[38;2;69;71;90m'       # #45475A - Elevated surface
# Text colors
TEXT = '\033[38;2;205;214;244m'         # #CDD6F4 - Primary text
SUBTEXT = '\033[38;2;186;194;222m'     # #BAC2DE - Secondary text
# Accent colors
ROSEWATER = '\033[38;2;245;224;220m'   # #F5E0DC
FLAMINGO = '\033[38;2;242;205;205m'    # #F2CDCD
PINK = '\033[38;2;245;194;231m'        # #F5C2E7
MAUVE = '\033[38;2;203;166;247m'       # #CBA6F7
RED = '\033[38;2;243;139;168m'         # #F38BA8
MAROON = '\033[38;2;235;160;172m'     # #EBA0AC
PEACH = '\033[38;2;250;179;135m'       # #FAB387
YELLOW = '\033[38;2;249;226;175m'      # #F9E2AF
GREEN = '\033[38;2;166;227;161m'      # #A6E3A1
TEAL = '\033[38;2;148;226;213m'        # #94E2D5
SKY = '\033[38;2;137;220;235m'         # #89DCEB
SAPPHIRE = '\033[38;2;116;199;236m'   # #74C7EC
BLUE = '\033[38;2;137;180;250m'       # #89B4FA
LAVENDER = '\033[38;2;180;190;254m'   # #B4BEFE
# Dark gray for eaten dots
DARK = '\033[38;2;99;100;104m'         # #636E7B

def get_user():
    return ""

def get_directory():
    cwd = data.get('workspace', {}).get('current_dir', '')
    if cwd:
        return f"{PEACH}\U000F0770 {cwd.split('/')[-1]}{RESET}"
    return ""

def get_git_info():
    parts = []
    if git_branch:
        parts.append(f"{BLUE} {git_branch}{RESET}")
    if git_dirty:
        parts.append(f"{YELLOW}{RESET}")
    if git_ahead > 0:
        parts.append(f"{GREEN}↑{git_ahead}{RESET}")
    if git_behind > 0:
        parts.append(f"{RED}↓{git_behind}{RESET}")
    return ' '.join(parts) if parts else ""

def get_model():
    model = data.get('model', {})
    return f"{MAUVE} {model.get('display_name', '')}{RESET}"

def get_context_bar():
    remaining = data.get('context_window', {}).get('remaining_percentage', None)
    if remaining is not None:
        used = 100 - int(remaining)
        dots = 9
        pac_idx = int(used * dots / 100)

        def dot_color(i):
            if i < 5:
                return GREEN
            elif i < 7:
                return YELLOW
            else:
                return RED

        def percent_color(used):
            if used < 60:
                return GREEN
            elif used < 80:
                return YELLOW
            else:
                return RED

        result = ""
        for i in range(dots):
            if i < pac_idx:
                result += f"{DARK}·{RESET}"
            elif i == pac_idx:
                result += f"{SAPPHIRE}󰮯{RESET}"
            else:
                result += f"{dot_color(i)}•{RESET}"
        return f"[{result}] {percent_color(used)}{used}%{RESET}"
    return ""

def get_runtime_info():
    if not runtime_info:
        return ""
    parts = runtime_info.split('|')
    return ' '.join(parts)

parts = [get_user()]
directory = get_directory()
if directory:
    parts.append(directory)
git_info = get_git_info()
if git_info:
    parts.append(git_info)
model = get_model()
if model:
    parts.append(model)
context = get_context_bar()
if context:
    parts.append(context)

# Line 2: Runtime environment
runtime = get_runtime_info()
if runtime:
    runtime_line = f"{TEAL}{runtime}{RESET}"
else:
    runtime_line = ""

print('  '.join(parts))
if runtime_line:
    print(runtime_line)
PYTHON_EOF
