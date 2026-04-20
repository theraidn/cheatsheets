# Bash One-liners — Common Patterns

- Find largest files in current tree:
```bash
find . -type f -exec du -h {} + | sort -hr | head -n 20
```

- Show top processes by memory:
```bash
ps aux --sort=-%mem | head -n 15
```

- Extract unique URLs from text:
```bash
grep -Eo '(http|https)://[^ "\'\)]+ ' file.txt | sort -u
```

- Replace in many files (preview first):
```bash
# Preview
grep -R --line-number "OLD" .
# Replace (careful)
sed -i.bak 's/OLD/NEW/g' $(grep -R --files-with-matches "OLD" .)
```

- Quick HTTP health-checks:
```bash
while IFS= read -r u; do curl -sSf "http://$u/health" || echo "DOWN: $u"; done < hosts.txt
```
