# Pytest example demonstrating fixtures, parametrization, and simple unit tests.

import pytest

# Example fixture that provides a temporary resource
@pytest.fixture
def temp_list():
    return []

def add_item(lst, item):
    lst.append(item)
    return lst

def test_add_item_basic(temp_list):
    result = add_item(temp_list, 1)
    assert result == [1]
    assert len(result) == 1

@pytest.mark.parametrize("start, item, expected", [
    ([], 5, [5]),
    ([1,2], 3, [1,2,3]),
])
def test_add_item_param(start, item, expected):
    assert add_item(start, item) == expected

def test_failure_example():
    with pytest.raises(IndexError):
        _ = [][0]

# To run: pytest -q
# To measure coverage: pytest --cov=yourpackage
