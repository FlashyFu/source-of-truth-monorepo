# Regex Cheatsheet

Common regex patterns and examples (PCRE-like syntax).

## Basics

| Pattern | Description |
|---------|-------------|
| `.` | Any character except newline |
| `\d` | Digit `[0-9]` |
| `\D` | Non-digit `[^0-9]` |
| `\w` | Word character `[a-zA-Z0-9_]` |
| `\W` | Non-word character |
| `\s` | Whitespace `[\t\n\r\f\v ]` |
| `\S` | Non-whitespace |

## Anchors

| Pattern | Description |
|---------|-------------|
| `^` | Start of string/line |
| `$` | End of string/line |
| `\b` | Word boundary |
| `\B` | Non-word boundary |

## Quantifiers

| Pattern | Description |
|---------|-------------|
| `*` | 0 or more |
| `+` | 1 or more |
| `?` | 0 or 1 |
| `{n}` | Exactly n |
| `{n,}` | n or more |
| `{n,m}` | Between n and m |
| `*?` | 0 or more (non-greedy) |
| `+?` | 1 or more (non-greedy) |

## Character Classes

| Pattern | Description |
|---------|-------------|
| `[abc]` | Match a, b, or c |
| `[^abc]` | Match anything except a, b, c |
| `[a-z]` | Match a to z |
| `[A-Z]` | Match A to Z |
| `[0-9]` | Match 0 to 9 |

## Groups

| Pattern | Description |
|---------|-------------|
| `(abc)` | Capturing group |
| `(?:abc)` | Non-capturing group |
| `(?<name>abc)` | Named capturing group |
| `\1` | Backreference to group 1 |

## Lookahead/Lookbehind

| Pattern | Description |
|---------|-------------|
| `(?=abc)` | Positive lookahead |
| `(?!abc)` | Negative lookahead |
| `(?<=abc)` | Positive lookbehind |
| `(?<!abc)` | Negative lookbehind |

## Common Patterns

### Email

```regex
^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$
```

### URL

```regex
https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)
```

### Phone Number (US)

```regex
^(\+1)?[-.\s]?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}$
```

### Date (YYYY-MM-DD)

```regex
^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$
```

### Time (HH:MM:SS)

```regex
^([01]\d|2[0-3]):([0-5]\d):([0-5]\d)$
```

### IPv4 Address

```regex
^((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[01]?\d\d?)$
```

### Password Strength

Minimum 8 characters, at least one uppercase, one lowercase, one number:

```regex
^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$
```

### Slug (URL-friendly string)

```regex
^[a-z0-9]+(?:-[a-z0-9]+)*$
```

### Credit Card

```regex
^(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|3[47][0-9]{13})$
```

### UUID

```regex
^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$
```

## Flags

| Flag | Description |
|------|-------------|
| `i` | Case insensitive |
| `g` | Global (find all matches) |
| `m` | Multiline mode |
| `s` | Dotall (`.` matches newlines) |
| `u` | Unicode support |

## Examples in JavaScript

```javascript
// Test if string matches
const regex = /^\d{3}-\d{4}$/;
regex.test('123-4567'); // true

// Find all matches
const text = 'cat bat rat';
text.match(/\b\w+at\b/g); // ['cat', 'bat', 'rat']

// Replace
text.replace(/at/g, 'og'); // 'cog bog rog'

// Split
'one,two;three'.split(/[,;]/); // ['one', 'two', 'three']
```

## Examples in Python

```python
import re

# Match
pattern = r'^\d{3}-\d{4}$'
re.match(pattern, '123-4567')  # Match object

# Find all
text = 'cat bat rat'
re.findall(r'\b\w+at\b', text)  # ['cat', 'bat', 'rat']

# Replace
re.sub(r'at', 'og', text)  # 'cog bog rog'

# Split
re.split(r'[,;]', 'one,two;three')  # ['one', 'two', 'three']
```
