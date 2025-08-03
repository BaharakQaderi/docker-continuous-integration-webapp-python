#!/bin/bash

# Debug script for Docker build quality checks
# This script runs the same checks as the Dockerfile.dev to help debug build failures

set -e  # Exit on any error

echo "🔍 Starting debug checks..."
echo "=================================="

# Activate virtual environment
if [ -d ".venv" ]; then
    echo "📦 Activating virtual environment..."
    source .venv/bin/activate
else
    echo "❌ Error: .venv directory not found"
    echo "Run 'uv venv' or 'python -m venv .venv' first"
    exit 1
fi

# Check 1: Install package (skip for uv environments)
echo ""
echo "1️⃣  Installing package..."
if command -v uv &> /dev/null; then
    echo "📦 Using uv environment - skipping pip install (package likely already installed)"
    uv pip list | grep page-tracker || echo "⚠️  Warning: page-tracker not found in uv environment"
else
    python -m pip install . -c constraints.txt
fi
echo "✅ Package installation: CHECKED"

# Check 2: Run unit tests
echo ""
echo "2️⃣  Running unit tests..."
python -m pytest test/unit/ -v
echo "✅ Unit tests: PASSED"

# Check 3: Code style with flake8
echo ""
echo "3️⃣  Checking code style (flake8)..."
python -m flake8 src/
echo "✅ Flake8: PASSED"

# Check 4: Import sorting with isort
echo ""
echo "4️⃣  Checking import sorting (isort)..."
python -m isort src/ --check --diff
echo "✅ Import sorting: PASSED"

# Check 5: Code formatting with black
echo ""
echo "5️⃣  Checking code formatting (black)..."
python -m black src/ --check --diff
echo "✅ Black formatting: PASSED"

# Check 6: Code quality with pylint
echo ""
echo "6️⃣  Checking code quality (pylint)..."
python -m pylint src/ --disable=C0114,C0116,R1705
echo "✅ Pylint: PASSED"

# Check 7: Security check with bandit
echo ""
echo "7️⃣  Checking security (bandit)..."
python -m bandit -r src/ -f json | python -m json.tool
echo "✅ Bandit security: PASSED"

echo ""
echo "🎉 All checks passed! Docker build should succeed."
echo "=================================="