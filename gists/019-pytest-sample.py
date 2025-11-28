"""
============================================================================
019-pytest-sample.py
Pytest layout, fixtures, parametrization, and coverage example
============================================================================

HOW TO USE:
    1. Install pytest: pip install pytest pytest-cov pytest-asyncio
    2. Create tests in tests/ directory
    3. Run: pytest
    4. Run with coverage: pytest --cov=src --cov-report=html

PROJECT STRUCTURE:
    project/
    ├── src/
    │   ├── __init__.py
    │   └── calculator.py
    ├── tests/
    │   ├── __init__.py
    │   ├── conftest.py          # Shared fixtures
    │   ├── test_calculator.py   # Unit tests
    │   └── integration/
    │       └── test_api.py      # Integration tests
    ├── pyproject.toml
    └── pytest.ini

============================================================================
"""

import pytest
from typing import List, Dict, Any
from unittest.mock import Mock, patch, AsyncMock
import asyncio


# ============================================================================
# Example Module to Test (src/calculator.py)
# ============================================================================

class Calculator:
    """Simple calculator for demonstration."""
    
    def __init__(self, precision: int = 2):
        self.precision = precision
        self.history: List[str] = []
    
    def add(self, a: float, b: float) -> float:
        result = round(a + b, self.precision)
        self.history.append(f"{a} + {b} = {result}")
        return result
    
    def subtract(self, a: float, b: float) -> float:
        result = round(a - b, self.precision)
        self.history.append(f"{a} - {b} = {result}")
        return result
    
    def multiply(self, a: float, b: float) -> float:
        result = round(a * b, self.precision)
        self.history.append(f"{a} * {b} = {result}")
        return result
    
    def divide(self, a: float, b: float) -> float:
        if b == 0:
            raise ValueError("Cannot divide by zero")
        result = round(a / b, self.precision)
        self.history.append(f"{a} / {b} = {result}")
        return result
    
    def clear_history(self) -> None:
        self.history.clear()


class AsyncCalculator:
    """Async calculator for async testing demonstration."""
    
    async def add(self, a: float, b: float) -> float:
        await asyncio.sleep(0.01)  # Simulate async operation
        return a + b
    
    async def fetch_and_add(self, a: float, api_url: str) -> float:
        # In real code, this would fetch from API
        await asyncio.sleep(0.01)
        return a + 10  # Simulated


# ============================================================================
# Fixtures (conftest.py)
# ============================================================================

@pytest.fixture
def calculator():
    """Provide a fresh calculator instance for each test."""
    return Calculator()


@pytest.fixture
def calculator_with_precision():
    """Factory fixture for calculators with different precision."""
    def _create(precision: int = 2):
        return Calculator(precision=precision)
    return _create


@pytest.fixture
def async_calculator():
    """Provide async calculator instance."""
    return AsyncCalculator()


@pytest.fixture
def sample_data() -> Dict[str, Any]:
    """Sample data for testing."""
    return {
        "numbers": [1, 2, 3, 4, 5],
        "expected_sum": 15,
        "expected_product": 120
    }


@pytest.fixture(scope="module")
def expensive_resource():
    """
    Module-scoped fixture - created once per module.
    Good for database connections, API clients, etc.
    """
    print("\nSetting up expensive resource...")
    resource = {"connection": "established"}
    yield resource
    print("\nTearing down expensive resource...")


@pytest.fixture(autouse=True)
def reset_environment():
    """Auto-use fixture that runs before/after every test."""
    # Setup
    yield
    # Teardown (runs after each test)


# ============================================================================
# Basic Tests
# ============================================================================

class TestCalculatorBasic:
    """Basic calculator tests."""
    
    def test_add_positive_numbers(self, calculator):
        """Test adding two positive numbers."""
        result = calculator.add(2, 3)
        assert result == 5
    
    def test_add_negative_numbers(self, calculator):
        """Test adding negative numbers."""
        result = calculator.add(-2, -3)
        assert result == -5
    
    def test_add_mixed_numbers(self, calculator):
        """Test adding positive and negative numbers."""
        result = calculator.add(5, -3)
        assert result == 2
    
    def test_subtract(self, calculator):
        """Test subtraction."""
        result = calculator.subtract(10, 3)
        assert result == 7
    
    def test_multiply(self, calculator):
        """Test multiplication."""
        result = calculator.multiply(4, 5)
        assert result == 20
    
    def test_divide(self, calculator):
        """Test division."""
        result = calculator.divide(10, 2)
        assert result == 5


# ============================================================================
# Exception Testing
# ============================================================================

class TestCalculatorExceptions:
    """Test exception handling."""
    
    def test_divide_by_zero_raises_error(self, calculator):
        """Test that dividing by zero raises ValueError."""
        with pytest.raises(ValueError) as exc_info:
            calculator.divide(10, 0)
        
        assert "Cannot divide by zero" in str(exc_info.value)
    
    def test_divide_by_zero_raises_error_alternative(self, calculator):
        """Alternative way to test exceptions."""
        with pytest.raises(ValueError, match="Cannot divide by zero"):
            calculator.divide(10, 0)


# ============================================================================
# Parametrized Tests
# ============================================================================

class TestCalculatorParametrized:
    """Parametrized tests for comprehensive coverage."""
    
    @pytest.mark.parametrize("a, b, expected", [
        (1, 1, 2),
        (0, 0, 0),
        (-1, 1, 0),
        (1.5, 2.5, 4.0),
        (100, 200, 300),
    ])
    def test_add_parametrized(self, calculator, a, b, expected):
        """Test addition with multiple input combinations."""
        assert calculator.add(a, b) == expected
    
    @pytest.mark.parametrize("a, b, expected", [
        (10, 2, 5),
        (9, 3, 3),
        (7, 2, 3.5),
        (1, 3, 0.33),
    ])
    def test_divide_parametrized(self, calculator, a, b, expected):
        """Test division with multiple inputs."""
        assert calculator.divide(a, b) == expected
    
    @pytest.mark.parametrize("precision, a, b, expected", [
        (0, 1.555, 2.445, 4),
        (1, 1.555, 2.445, 4.0),
        (2, 1.555, 2.445, 4.0),
        (3, 1.555, 2.445, 4.0),
    ])
    def test_precision(self, calculator_with_precision, precision, a, b, expected):
        """Test different precision levels."""
        calc = calculator_with_precision(precision)
        assert calc.add(a, b) == expected


# ============================================================================
# Fixtures and State Tests
# ============================================================================

class TestCalculatorHistory:
    """Test calculator history functionality."""
    
    def test_history_records_operations(self, calculator):
        """Test that operations are recorded in history."""
        calculator.add(2, 3)
        calculator.subtract(10, 5)
        
        assert len(calculator.history) == 2
        assert "2 + 3 = 5" in calculator.history
        assert "10 - 5 = 5" in calculator.history
    
    def test_clear_history(self, calculator):
        """Test clearing history."""
        calculator.add(1, 1)
        calculator.add(2, 2)
        
        calculator.clear_history()
        
        assert len(calculator.history) == 0


# ============================================================================
# Mocking Tests
# ============================================================================

class TestWithMocking:
    """Tests demonstrating mocking techniques."""
    
    def test_with_mock_object(self):
        """Test using Mock objects."""
        mock_calc = Mock(spec=Calculator)
        mock_calc.add.return_value = 100
        
        result = mock_calc.add(2, 3)
        
        assert result == 100
        mock_calc.add.assert_called_once_with(2, 3)
    
    def test_with_patch_decorator(self):
        """Test using patch decorator."""
        with patch.object(Calculator, 'add', return_value=999):
            calc = Calculator()
            result = calc.add(1, 1)
            assert result == 999
    
    def test_mock_side_effects(self):
        """Test mock with side effects."""
        mock_calc = Mock(spec=Calculator)
        mock_calc.divide.side_effect = ValueError("Mocked error")
        
        with pytest.raises(ValueError, match="Mocked error"):
            mock_calc.divide(10, 0)


# ============================================================================
# Async Tests
# ============================================================================

class TestAsyncCalculator:
    """Tests for async functionality."""
    
    @pytest.mark.asyncio
    async def test_async_add(self, async_calculator):
        """Test async addition."""
        result = await async_calculator.add(2, 3)
        assert result == 5
    
    @pytest.mark.asyncio
    async def test_async_with_mock(self):
        """Test async with mocking."""
        calc = AsyncCalculator()
        
        with patch.object(calc, 'fetch_and_add', new_callable=AsyncMock) as mock:
            mock.return_value = 42
            
            result = await calc.fetch_and_add(10, "https://api.example.com")
            
            assert result == 42
            mock.assert_called_once_with(10, "https://api.example.com")


# ============================================================================
# Markers
# ============================================================================

@pytest.mark.slow
def test_slow_operation():
    """Marked as slow - can be excluded with: pytest -m 'not slow'"""
    import time
    time.sleep(0.1)
    assert True


@pytest.mark.skip(reason="Feature not implemented yet")
def test_future_feature():
    """Skipped test."""
    pass


@pytest.mark.skipif(
    not hasattr(asyncio, 'TaskGroup'),
    reason="Requires Python 3.11+"
)
def test_python311_feature():
    """Conditionally skipped test."""
    pass


@pytest.mark.xfail(reason="Known bug, will be fixed in v2.0")
def test_known_bug():
    """Expected to fail."""
    assert 1 == 2


# ============================================================================
# Fixtures with Cleanup
# ============================================================================

@pytest.fixture
def temp_file(tmp_path):
    """Create temporary file for testing."""
    file = tmp_path / "test_file.txt"
    file.write_text("test content")
    yield file
    # Cleanup happens automatically with tmp_path


def test_file_operations(temp_file):
    """Test using temporary file."""
    assert temp_file.exists()
    assert temp_file.read_text() == "test content"


# ============================================================================
# Test Organization - conftest.py example
# ============================================================================

"""
# conftest.py - shared fixtures across tests

import pytest

@pytest.fixture(scope="session")
def database():
    '''Session-scoped database fixture.'''
    # Setup
    db = create_test_database()
    yield db
    # Teardown
    db.drop_all()

@pytest.fixture
def authenticated_client(client, database):
    '''Client with authentication.'''
    client.login("test@example.com", "password")
    yield client
    client.logout()
"""

# ============================================================================
# pyproject.toml configuration
# ============================================================================

"""
[tool.pytest.ini_options]
minversion = "7.0"
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = [
    "-v",
    "--strict-markers",
    "-ra",
    "--cov=src",
    "--cov-report=term-missing",
    "--cov-report=html",
    "--cov-fail-under=80",
]
markers = [
    "slow: marks tests as slow (deselect with '-m \"not slow\"')",
    "integration: marks tests as integration tests",
    "unit: marks tests as unit tests",
]
asyncio_mode = "auto"

[tool.coverage.run]
source = ["src"]
branch = true
omit = ["tests/*", "*/__init__.py"]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "raise NotImplementedError",
    "if TYPE_CHECKING:",
]
fail_under = 80
show_missing = true
"""

# ============================================================================
# Running Tests
# ============================================================================

"""
Common pytest commands:

# Run all tests
pytest

# Run with verbose output
pytest -v

# Run specific test file
pytest tests/test_calculator.py

# Run specific test class
pytest tests/test_calculator.py::TestCalculatorBasic

# Run specific test function
pytest tests/test_calculator.py::TestCalculatorBasic::test_add_positive_numbers

# Run tests matching pattern
pytest -k "add"

# Run tests with specific marker
pytest -m "slow"
pytest -m "not slow"

# Run with coverage
pytest --cov=src --cov-report=html

# Run parallel tests (requires pytest-xdist)
pytest -n auto

# Stop on first failure
pytest -x

# Run failed tests from last run
pytest --lf

# Show slowest tests
pytest --durations=10
"""

if __name__ == "__main__":
    pytest.main([__file__, "-v"])
