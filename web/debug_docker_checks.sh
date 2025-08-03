#!/bin/bash

# Debug script that exactly matches the Docker build checks
# This runs the same command chain as in Dockerfile.dev line 21-27

set -e  # Exit on any error

echo "🐳 Docker Build Debug Script"
echo "Running exact same checks as Dockerfile.dev..."
echo "=============================================="

# Activate virtual environment
if [ -d ".venv" ]; then
    echo "📦 Activating .venv..."
    source .venv/bin/activate
else
    echo "❌ Error: .venv not found. Run 'uv venv' first."
    exit 1
fi

echo ""
echo "🚀 Running the exact Docker command chain:"
echo "python -m pip install . -c constraints.txt && \\"
echo "python -m pytest test/unit/ && \\"
echo "python -m flake8 src/ && \\"
echo "python -m isort src/ --check && \\"
echo "python -m black src/ --check --quiet && \\"
echo "python -m pylint src/ --disable=C0114,C0116,R1705 && \\"
echo "python -m bandit -r src/ --quiet"
echo ""

# For uv environments, skip pip install but run the rest
if command -v uv &> /dev/null; then
    echo "📦 Detected uv environment - skipping pip install"
    python -m pytest test/unit/ && \
    python -m flake8 src/ && \
    python -m isort src/ --check && \
    python -m black src/ --check --quiet && \
    python -m pylint src/ --disable=C0114,C0116,R1705 && \
    python -m bandit -r src/ --quiet
else
    # Run the exact Docker command
    python -m pip install . -c constraints.txt && \
    python -m pytest test/unit/ && \
    python -m flake8 src/ && \
    python -m isort src/ --check && \
    python -m black src/ --check --quiet && \
    python -m pylint src/ --disable=C0114,C0116,R1705 && \
    python -m bandit -r src/ --quiet
fi

echo ""
echo "✅ SUCCESS: All Docker checks passed!"
echo "🐳 Your Docker build should now work."