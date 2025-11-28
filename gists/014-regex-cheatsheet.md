# Regex Cheatsheet

> Common regular expression patterns and examples for everyday use

## Table of Contents

- [Basics](#basics)
- [Character Classes](#character-classes)
- [Quantifiers](#quantifiers)
- [Anchors & Boundaries](#anchors--boundaries)
- [Groups & References](#groups--references)
- [Lookahead & Lookbehind](#lookahead--lookbehind)
- [Common Patterns](#common-patterns)
- [Language-Specific Notes](#language-specific-notes)
- [Testing Tools](#testing-tools)

---

## Basics

### Metacharacters

| Character | Description | Example | Matches |
|-----------|-------------|---------|---------|
| `.` | Any character (except newline) | `a.c` | "abc", "a1c" |
| `\` | Escape special character | `\.` | "." |
| `\|` | Alternation (OR) | `cat\|dog` | "cat" or "dog" |
| `()` | Grouping | `(ab)+` | "ab", "abab" |
| `[]` | Character class | `[aeiou]` | any vowel |

### Literal Characters

```regex
# Most characters match themselves
hello       → matches "hello"
123         → matches "123"

# Escape special characters with \
\.\*\+\?    → matches ".*+?"
\[\]        → matches "[]"
\\          → matches "\"
```

---

## Character Classes

### Predefined Classes

| Pattern | Description | Equivalent |
|---------|-------------|------------|
| `\d` | Digit | `[0-9]` |
| `\D` | Non-digit | `[^0-9]` |
| `\w` | Word character | `[a-zA-Z0-9_]` |
| `\W` | Non-word character | `[^a-zA-Z0-9_]` |
| `\s` | Whitespace | `[ \t\n\r\f\v]` |
| `\S` | Non-whitespace | `[^ \t\n\r\f\v]` |

### Custom Classes

```regex
# Match any character in set
[abc]           → 'a', 'b', or 'c'
[a-z]           → any lowercase letter
[A-Z]           → any uppercase letter
[0-9]           → any digit
[a-zA-Z0-9]     → any alphanumeric

# Negation (match anything NOT in set)
[^abc]          → anything except 'a', 'b', 'c'
[^0-9]          → any non-digit

# Special characters in class (don't need escaping)
[.?+*]          → literal '.', '?', '+', '*'
[-abc]          → '-', 'a', 'b', 'c' (dash at start/end)
[abc-]          → same as above
[a\-z]          → 'a', '-', 'z' (escaped dash)
```

---

## Quantifiers

### Basic Quantifiers

| Pattern | Description | Example | Matches |
|---------|-------------|---------|---------|
| `*` | 0 or more | `ab*c` | "ac", "abc", "abbc" |
| `+` | 1 or more | `ab+c` | "abc", "abbc" |
| `?` | 0 or 1 | `colou?r` | "color", "colour" |
| `{n}` | Exactly n | `a{3}` | "aaa" |
| `{n,}` | n or more | `a{2,}` | "aa", "aaa", "aaaa" |
| `{n,m}` | n to m | `a{2,4}` | "aa", "aaa", "aaaa" |

### Greedy vs Lazy

```regex
# Greedy (default) - match as much as possible
<.*>        on "<div>text</div>" → "<div>text</div>"

# Lazy (add ?) - match as little as possible
<.*?>       on "<div>text</div>" → "<div>"

# Lazy quantifiers
*?          → 0 or more (lazy)
+?          → 1 or more (lazy)
??          → 0 or 1 (lazy)
{n,m}?      → n to m (lazy)
```

---

## Anchors & Boundaries

### Position Anchors

| Pattern | Description |
|---------|-------------|
| `^` | Start of string/line |
| `$` | End of string/line |
| `\A` | Start of string (ignores multiline) |
| `\Z` | End of string (ignores multiline) |

### Word Boundaries

| Pattern | Description |
|---------|-------------|
| `\b` | Word boundary |
| `\B` | Non-word boundary |

```regex
# Examples
^hello          → "hello world" (at start)
world$          → "hello world" (at end)
^hello$         → exactly "hello"

\bword\b        → "word" as whole word
\Bword\B        → "sword" (not at boundary)
```

---

## Groups & References

### Capturing Groups

```regex
# Basic group
(abc)           → captures "abc"

# Named group (syntax varies by language)
(?<name>abc)    → named group (JavaScript, C#, Python)
(?P<name>abc)   → named group (Python)
(?'name'abc)    → named group (C#, .NET)

# Non-capturing group
(?:abc)         → groups but doesn't capture

# Backreference
(abc)\1         → matches "abcabc"
(?<word>\w+)\s+\k<word>  → matches "the the"
```

### Examples

```regex
# Match repeated words
\b(\w+)\s+\1\b
# Matches: "the the", "is is"

# Match HTML tags
<(\w+)>.*?</\1>
# Matches: "<div>content</div>"

# Swap first and last name
(\w+)\s+(\w+) → $2, $1
# "John Smith" → "Smith, John"
```

---

## Lookahead & Lookbehind

### Lookahead

```regex
# Positive lookahead (?=...)
# Match only if followed by...
foo(?=bar)      → "foo" only if followed by "bar"

# Negative lookahead (?!...)
# Match only if NOT followed by...
foo(?!bar)      → "foo" only if NOT followed by "bar"

# Examples
\d+(?=%)        → digits followed by %
\d+(?!%)        → digits NOT followed by %
```

### Lookbehind

```regex
# Positive lookbehind (?<=...)
# Match only if preceded by...
(?<=@)\w+       → word after @

# Negative lookbehind (?<!...)
# Match only if NOT preceded by...
(?<!@)\w+       → word not after @

# Examples
(?<=\$)\d+      → digits after $
(?<!\$)\d+      → digits not after $
```

---

## Common Patterns

### Validation Patterns

```regex
# Email (simplified)
^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}$

# Email (more complete)
^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$

# URL
^https?:\/\/[\w.-]+(?:\/[\w./-]*)?(?:\?[\w=&]*)?$

# Phone (US)
^\(?[0-9]{3}\)?[-.\s]?[0-9]{3}[-.\s]?[0-9]{4}$

# Phone (International)
^\+?[1-9]\d{1,14}$

# Date (YYYY-MM-DD)
^\d{4}-(?:0[1-9]|1[0-2])-(?:0[1-9]|[12]\d|3[01])$

# Date (MM/DD/YYYY)
^(?:0[1-9]|1[0-2])\/(?:0[1-9]|[12]\d|3[01])\/\d{4}$

# Time (24h)
^(?:[01]\d|2[0-3]):[0-5]\d(?::[0-5]\d)?$

# Time (12h)
^(?:0?[1-9]|1[0-2]):[0-5]\d\s?(?:AM|PM|am|pm)$
```

### Password Validation

```regex
# At least 8 characters
^.{8,}$

# At least 8 chars with uppercase, lowercase, digit
^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$

# Strong password (8+ chars, upper, lower, digit, special)
^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$
```

### Data Extraction

```regex
# IP Address (IPv4)
^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$

# IPv4 (simpler, less strict)
^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$

# MAC Address
^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$

# UUID
^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$

# Credit Card (basic)
^(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|3[47][0-9]{13})$

# Hex Color
^#?([a-fA-F0-9]{6}|[a-fA-F0-9]{3})$

# Slug
^[a-z0-9]+(?:-[a-z0-9]+)*$
```

### Text Processing

```regex
# HTML Tag
<\/?[\w\s]*>|<.+[\W]>

# HTML Comments
<!--[\s\S]*?-->

# Whitespace (leading/trailing)
^\s+|\s+$

# Multiple spaces to single
\s+

# Empty lines
^\s*$

# File extension
\.([a-zA-Z0-9]+)$

# Filename from path
[^\/\\]+$

# Markdown Links
\[([^\]]+)\]\(([^)]+)\)

# Find and extract JSON keys
"([^"]+)"\s*:
```

---

## Language-Specific Notes

### JavaScript

```javascript
// Literal syntax
const regex = /pattern/flags;

// Constructor syntax
const regex = new RegExp('pattern', 'flags');

// Flags
// g - global (find all matches)
// i - case-insensitive
// m - multiline (^ and $ match line boundaries)
// s - dotAll (. matches newline)
// u - unicode
// y - sticky

// Methods
regex.test(string);        // Returns boolean
regex.exec(string);        // Returns match array or null
string.match(regex);       // Returns matches
string.matchAll(regex);    // Returns iterator (requires /g)
string.replace(regex, replacement);
string.split(regex);

// Named groups
const regex = /(?<year>\d{4})-(?<month>\d{2})/;
const match = regex.exec('2024-01');
console.log(match.groups.year);  // "2024"
```

### Python

```python
import re

# Compile pattern
pattern = re.compile(r'pattern', flags)

# Flags
# re.I or re.IGNORECASE
# re.M or re.MULTILINE
# re.S or re.DOTALL
# re.X or re.VERBOSE

# Methods
re.match(pattern, string)   # Match at start
re.search(pattern, string)  # Search anywhere
re.findall(pattern, string) # Find all matches
re.finditer(pattern, string) # Iterator of matches
re.sub(pattern, repl, string) # Replace
re.split(pattern, string)   # Split

# Named groups
pattern = r'(?P<year>\d{4})-(?P<month>\d{2})'
match = re.search(pattern, '2024-01')
print(match.group('year'))  # "2024"
```

### Go

```go
import "regexp"

// Compile pattern
regex := regexp.MustCompile(`pattern`)

// Methods
regex.MatchString(string)    // Returns bool
regex.FindString(string)     // First match
regex.FindAllString(string, n) // All matches
regex.ReplaceAllString(string, repl)
regex.Split(string, n)

// Named groups
regex := regexp.MustCompile(`(?P<year>\d{4})-(?P<month>\d{2})`)
match := regex.FindStringSubmatch("2024-01")
// Use regex.SubexpNames() to get group names
```

---

## Testing Tools

### Online Testers

- [regex101.com](https://regex101.com) - Multi-language, with debugger
- [regexr.com](https://regexr.com) - JavaScript focused
- [rubular.com](https://rubular.com) - Ruby focused
- [regexpal.com](https://www.regexpal.com) - Simple tester

### CLI Tools

```bash
# grep (basic regex)
grep 'pattern' file.txt
grep -E 'pattern' file.txt    # Extended regex
grep -P 'pattern' file.txt    # Perl regex

# sed
sed 's/pattern/replacement/g' file.txt

# awk
awk '/pattern/ {print}' file.txt

# ripgrep (fast)
rg 'pattern' file.txt
```

### Tips for Writing Regex

1. **Start simple** - Build up complexity gradually
2. **Use raw strings** - Avoid escaping issues (`r''` in Python)
3. **Be specific** - Avoid overly broad patterns
4. **Use anchors** - `^` and `$` prevent unexpected matches
5. **Use non-capturing groups** - `(?:)` when you don't need the capture
6. **Test edge cases** - Empty strings, special characters
7. **Comment complex patterns** - Use verbose mode if available

---

**Last Updated**: 2024-01-15  
**Maintainer**: FlashFusion Team
