# 014-regex-cheatsheet.md

Common regex patterns and examples (PCRE-like syntax):

## Basics

- `.`        : any char except newline
- `^`        : start of string
- `$`        : end of string
- `\d`       : digit [0-9]
- `\w`       : word char [A-Za-z0-9_]
- `\s`       : whitespace
- `* + ? {n,m}` : quantifiers

## Examples

- Email (simple): `^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$`
- URL (basic): `^https?:\/\/[^\s/$.?#].[^\s]*$`
- UUID v4: `/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i`
- IPv4: `^(?:(?:25[0-5]|2[0-4]\d|[01]?\d?\d)\.){3}(?:25[0-5]|2[0-4]\d|[01]?\d?\d)$`
- Time HH:MM 24hr: `^([01]\d|2[0-3]):([0-5]\d)$`
- Strong password (min 8, upper, lower, digit, special): `(?=.{8,})(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[^A-Za-z0-9])`

## Tips

- Prefer building regex step-by-step and testing with tools (regex101, regextester).
- Avoid catastrophic backtracking by using non-capturing groups `(?: )` and atomic groups when supported.
- Use named capture groups for readability: `(?P<name>pattern)` or `(?<name>pattern)` depending on engine.
