"""Check the TZ domain/parser line coverage threshold using Flutter's LCOV."""
from pathlib import Path
import sys

path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path('coverage/lcov.info')
included = ('lib/core/', 'lib/domain/', 'lib/data/ofd/')
rows = []
name = None
lines = {}
for line in path.read_text(encoding='utf-8').splitlines():
    if line.startswith('SF:'):
        name = line[3:].replace('\\', '/')
        lines = {}
    elif line.startswith('DA:'):
        number, hits, *_ = line[3:].split(',')
        lines[int(number)] = int(hits)
    elif line == 'end_of_record' and name and any(part in name for part in included):
        rows.append((name, sum(value > 0 for value in lines.values()), len(lines)))
covered = sum(row[1] for row in rows)
total = sum(row[2] for row in rows)
for name, hit, count in rows:
    print(f'{hit}/{count} {name}')
ratio = covered / total if total else 0
print(f'Domain + parsers: {covered}/{total} ({ratio:.1%}); required >= 80%')
sys.exit(0 if ratio >= .8 else 1)
