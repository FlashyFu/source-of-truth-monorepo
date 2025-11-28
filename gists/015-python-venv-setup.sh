#!/bin/bash
# ============================================================================
# 015-python-venv-setup.sh
# Reproducible Python venv & pip-tools setup script
# ============================================================================
#
# HOW TO USE:
#   1. Copy to your project root
#   2. Make executable: chmod +x python-venv-setup.sh
#   3. Run: ./python-venv-setup.sh
#   4. Activate: source .venv/bin/activate
#
# FEATURES:
#   - Creates virtual environment with specific Python version
#   - Installs pip-tools for dependency management
#   - Sets up requirements.in/requirements.txt workflow
#   - Creates development and production dependency separation
#
# ============================================================================

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

readonly SCRIPT_NAME="$(basename "$0")"
readonly PROJECT_DIR="$(pwd)"
readonly VENV_DIR="${VENV_DIR:-.venv}"
readonly PYTHON_VERSION="${PYTHON_VERSION:-python3}"
readonly REQUIREMENTS_IN="${REQUIREMENTS_IN:-requirements.in}"
readonly REQUIREMENTS_TXT="${REQUIREMENTS_TXT:-requirements.txt}"
readonly DEV_REQUIREMENTS_IN="${DEV_REQUIREMENTS_IN:-requirements-dev.in}"
readonly DEV_REQUIREMENTS_TXT="${DEV_REQUIREMENTS_TXT:-requirements-dev.txt}"

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# ============================================================================
# Functions
# ============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

check_python() {
    if ! command -v "${PYTHON_VERSION}" &> /dev/null; then
        echo "Error: ${PYTHON_VERSION} not found"
        echo "Please install Python 3.8+ first"
        exit 1
    fi
    
    local version
    version=$("${PYTHON_VERSION}" --version 2>&1 | cut -d' ' -f2)
    log_info "Found Python ${version}"
}

create_venv() {
    if [[ -d "${VENV_DIR}" ]]; then
        log_warn "Virtual environment already exists at ${VENV_DIR}"
        read -p "Remove and recreate? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "${VENV_DIR}"
        else
            return 0
        fi
    fi
    
    log_info "Creating virtual environment in ${VENV_DIR}..."
    "${PYTHON_VERSION}" -m venv "${VENV_DIR}"
    log_success "Virtual environment created"
}

activate_venv() {
    log_info "Activating virtual environment..."
    # shellcheck disable=SC1091
    source "${VENV_DIR}/bin/activate"
}

upgrade_pip() {
    log_info "Upgrading pip..."
    pip install --upgrade pip wheel setuptools
}

install_pip_tools() {
    log_info "Installing pip-tools..."
    pip install pip-tools
    log_success "pip-tools installed"
}

create_requirements_files() {
    # Create requirements.in if it doesn't exist
    if [[ ! -f "${REQUIREMENTS_IN}" ]]; then
        log_info "Creating ${REQUIREMENTS_IN}..."
        cat > "${REQUIREMENTS_IN}" << 'EOF'
# =============================================================================
# Production Dependencies
# =============================================================================
# Add your production dependencies here, one per line.
# Use >= for minimum versions, or pin exact versions for reproducibility.
#
# Examples:
# flask>=3.0
# sqlalchemy>=2.0
# requests>=2.31
# pydantic>=2.0
#
# For local packages:
# -e .
#
# =============================================================================

# Add your dependencies below this line:

EOF
        log_success "Created ${REQUIREMENTS_IN}"
    else
        log_info "${REQUIREMENTS_IN} already exists, skipping"
    fi
    
    # Create requirements-dev.in if it doesn't exist
    if [[ ! -f "${DEV_REQUIREMENTS_IN}" ]]; then
        log_info "Creating ${DEV_REQUIREMENTS_IN}..."
        cat > "${DEV_REQUIREMENTS_IN}" << 'EOF'
# =============================================================================
# Development Dependencies
# =============================================================================
# Include production requirements first
-r requirements.txt

# =============================================================================
# Testing
# =============================================================================
pytest>=8.0
pytest-cov>=4.0
pytest-asyncio>=0.23
hypothesis>=6.0

# =============================================================================
# Linting & Formatting
# =============================================================================
ruff>=0.1
black>=24.0
isort>=5.0
mypy>=1.0

# =============================================================================
# Development Tools
# =============================================================================
pre-commit>=3.0
ipython>=8.0
python-dotenv>=1.0

# =============================================================================
# Documentation (optional)
# =============================================================================
# mkdocs>=1.5
# mkdocs-material>=9.0

EOF
        log_success "Created ${DEV_REQUIREMENTS_IN}"
    else
        log_info "${DEV_REQUIREMENTS_IN} already exists, skipping"
    fi
}

compile_requirements() {
    log_info "Compiling requirements..."
    
    # Compile production requirements
    if [[ -f "${REQUIREMENTS_IN}" ]]; then
        pip-compile \
            --quiet \
            --generate-hashes \
            --output-file="${REQUIREMENTS_TXT}" \
            "${REQUIREMENTS_IN}"
        log_success "Compiled ${REQUIREMENTS_TXT}"
    fi
    
    # Compile dev requirements
    if [[ -f "${DEV_REQUIREMENTS_IN}" ]]; then
        pip-compile \
            --quiet \
            --generate-hashes \
            --output-file="${DEV_REQUIREMENTS_TXT}" \
            "${DEV_REQUIREMENTS_IN}"
        log_success "Compiled ${DEV_REQUIREMENTS_TXT}"
    fi
}

install_dependencies() {
    local req_file="${1:-${REQUIREMENTS_TXT}}"
    
    if [[ -f "${req_file}" ]]; then
        log_info "Installing dependencies from ${req_file}..."
        pip-sync "${req_file}"
        log_success "Dependencies installed"
    else
        log_warn "No ${req_file} found, skipping installation"
    fi
}

create_gitignore() {
    if [[ ! -f ".gitignore" ]]; then
        log_info "Creating .gitignore..."
        cat > ".gitignore" << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Virtual Environment
.venv/
venv/
ENV/

# IDE
.idea/
.vscode/
*.swp
*.swo
*~

# Testing
.tox/
.coverage
.coverage.*
htmlcov/
.pytest_cache/
.mypy_cache/

# Environment
.env
.env.local
*.local

# Jupyter
.ipynb_checkpoints/

# OS
.DS_Store
Thumbs.db
EOF
        log_success "Created .gitignore"
    fi
}

create_pyproject_toml() {
    if [[ ! -f "pyproject.toml" ]]; then
        log_info "Creating pyproject.toml..."
        cat > "pyproject.toml" << 'EOF'
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "myproject"
version = "0.1.0"
description = "My Python project"
readme = "README.md"
requires-python = ">=3.8"
license = {text = "MIT"}
authors = [
    {name = "Your Name", email = "you@example.com"}
]
classifiers = [
    "Development Status :: 3 - Alpha",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.8",
    "Programming Language :: Python :: 3.9",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0",
    "pytest-cov>=4.0",
    "ruff>=0.1",
    "black>=24.0",
    "mypy>=1.0",
]

[project.urls]
Homepage = "https://github.com/username/project"
Documentation = "https://github.com/username/project#readme"
Repository = "https://github.com/username/project.git"
Issues = "https://github.com/username/project/issues"

[tool.setuptools.packages.find]
where = ["src"]

[tool.black]
line-length = 88
target-version = ["py38", "py39", "py310", "py311", "py312"]

[tool.ruff]
line-length = 88
select = [
    "E",    # pycodestyle errors
    "W",    # pycodestyle warnings
    "F",    # Pyflakes
    "I",    # isort
    "B",    # flake8-bugbear
    "C4",   # flake8-comprehensions
    "UP",   # pyupgrade
]
ignore = ["E501"]  # line too long (handled by black)

[tool.mypy]
python_version = "3.8"
strict = true
warn_return_any = true
warn_unused_ignores = true

[tool.pytest.ini_options]
testpaths = ["tests"]
pythonpath = ["src"]
addopts = "-v --cov=src --cov-report=term-missing"

[tool.coverage.run]
source = ["src"]
branch = true

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "raise AssertionError",
    "raise NotImplementedError",
    "if __name__ == .__main__.:",
]
EOF
        log_success "Created pyproject.toml"
    fi
}

print_usage() {
    cat << EOF

${GREEN}=== Setup Complete! ===${NC}

${BLUE}Activate the virtual environment:${NC}
    source ${VENV_DIR}/bin/activate

${BLUE}Add dependencies to ${REQUIREMENTS_IN}, then:${NC}
    pip-compile ${REQUIREMENTS_IN}
    pip-sync ${REQUIREMENTS_TXT}

${BLUE}For development dependencies:${NC}
    pip-compile ${DEV_REQUIREMENTS_IN}
    pip-sync ${DEV_REQUIREMENTS_TXT}

${BLUE}Update all dependencies:${NC}
    pip-compile --upgrade ${REQUIREMENTS_IN}
    pip-compile --upgrade ${DEV_REQUIREMENTS_IN}
    pip-sync ${DEV_REQUIREMENTS_TXT}

${BLUE}Common commands:${NC}
    deactivate              # Exit virtual environment
    pip list                # List installed packages
    pip show <package>      # Show package details

${BLUE}Project structure:${NC}
    ${PROJECT_DIR}/
    ├── ${VENV_DIR}/
    ├── src/                # Your source code
    ├── tests/              # Test files
    ├── ${REQUIREMENTS_IN}
    ├── ${REQUIREMENTS_TXT}
    ├── ${DEV_REQUIREMENTS_IN}
    ├── ${DEV_REQUIREMENTS_TXT}
    └── pyproject.toml

EOF
}

# ============================================================================
# Main
# ============================================================================

main() {
    echo "=============================================="
    echo "Python Virtual Environment Setup"
    echo "=============================================="
    echo
    
    check_python
    create_venv
    activate_venv
    upgrade_pip
    install_pip_tools
    create_requirements_files
    create_gitignore
    create_pyproject_toml
    
    # Compile and install if requirements.in has content
    if [[ -f "${REQUIREMENTS_IN}" ]] && grep -q '^[^#]' "${REQUIREMENTS_IN}"; then
        compile_requirements
        install_dependencies "${DEV_REQUIREMENTS_TXT}"
    fi
    
    print_usage
}

# Show help
if [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
    cat << EOF
Usage: ${SCRIPT_NAME} [options]

Options:
    -h, --help      Show this help message
    
Environment Variables:
    VENV_DIR            Virtual environment directory (default: .venv)
    PYTHON_VERSION      Python interpreter (default: python3)
    REQUIREMENTS_IN     Input requirements file (default: requirements.in)
    
Examples:
    ${SCRIPT_NAME}
    PYTHON_VERSION=python3.11 ${SCRIPT_NAME}
    VENV_DIR=.env ${SCRIPT_NAME}
EOF
    exit 0
fi

main

# ============================================================================
# NOTES:
# - pip-tools provides pip-compile and pip-sync for dependency management
# - requirements.in contains your direct dependencies
# - requirements.txt is generated with pinned versions and hashes
# - Use pip-sync to install exactly what's in requirements.txt
# - --generate-hashes adds security by verifying package integrity
#
# PRODUCTION BEST PRACTICES:
# - [ ] Pin Python version in pyproject.toml
# - [ ] Use --generate-hashes for security
# - [ ] Separate dev and prod dependencies
# - [ ] Include requirements.txt in version control
# - [ ] Update dependencies regularly with pip-compile --upgrade
# - [ ] Use pre-commit hooks for linting
# - [ ] Set up CI/CD with tox or nox
# ============================================================================
