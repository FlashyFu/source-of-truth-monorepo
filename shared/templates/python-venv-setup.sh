#!/usr/bin/env bash
# Cross-platform helper to create a venv and pin dependencies with pip-tools.
#
# Usage:
#   ./python-venv-setup.sh venv

VENV_DIR=${1:-.venv}
PYTHON_BIN=${PYTHON_BIN:-python3}

echo "Using Python: $(which $PYTHON_BIN)"
$PYTHON_BIN -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

pip install --upgrade pip setuptools wheel pip-tools

if [[ -f requirements.in ]]; then
  pip-compile --output-file requirements.txt requirements.in
  pip-sync requirements.txt
fi

echo "Virtualenv ready at $VENV_DIR"
echo "Activate with: source $VENV_DIR/bin/activate"
