#!/bin/bash
# Local linting script - runs the same checks as GitHub workflow
set -euo pipefail

echo "🔍 Running local bash script validation..."

# Check if shellcheck is available
if ! command -v shellcheck &> /dev/null; then
    echo "❌ shellcheck not found. Install with: sudo pacman -S shellcheck"
    exit 1
fi

echo "✅ shellcheck found"

# 1. ShellCheck on setup.sh
echo "📋 Running ShellCheck on setup.sh..."
shellcheck setup.sh
echo "✅ setup.sh passed ShellCheck"

# 2. ShellCheck on scripts directory
if [ -d scripts ] && [ "$(ls -A scripts)" ]; then
    echo "📋 Running ShellCheck on scripts directory..."
    find scripts -name "*.sh" -type f | while read -r script; do
        echo "  Checking $script"
        shellcheck "$script"
    done
    echo "✅ All scripts passed ShellCheck"
else
    echo "ℹ️  No scripts found to check"
fi

# 3. Syntax check on setup.sh
echo "📋 Running syntax check on setup.sh..."
bash -n setup.sh
echo "✅ setup.sh syntax OK"

# 4. Syntax check on all scripts
if [ -d scripts ] && [ "$(ls -A scripts)" ]; then
    echo "📋 Running syntax check on all scripts..."
    find scripts -name "*.sh" -type f | while read -r script; do
        echo "  Checking syntax: $script"
        bash -n "$script"
    done
    echo "✅ All scripts syntax OK"
else
    echo "ℹ️  No scripts found to check syntax"
fi

# 5. Check script permissions
if [ -d scripts ] && [ "$(ls -A scripts)" ]; then
    echo "📋 Checking script permissions..."
    find scripts -name "*.sh" -type f | while read -r script; do
        if [ ! -x "$script" ]; then
            echo "❌ ERROR: $script is not executable"
            exit 1
        fi
    done
    echo "✅ All scripts are executable"
else
    echo "ℹ️  No scripts found to check permissions"
fi

echo "🎉 All checks passed! Ready to push."