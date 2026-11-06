#!/usr/bin/env python3
"""Validate the repository's portable team skills without third-party packages."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
SKILLS = ROOT / '.agents' / 'skills'
EXPECTED = {
    'travel-product-owner', 'travel-business-analyst',
    'travel-solution-architect', 'travel-designer',
    'travel-developer', 'travel-tester', 'travel-team-delivery',
}
errors = []
actual = {p.parent.name for p in SKILLS.glob('*/SKILL.md')}
if actual != EXPECTED:
    errors.append(f'Skill inventory differs: missing={EXPECTED-actual}, extra={actual-EXPECTED}')
files = sorted(SKILLS.glob('*/SKILL.md')) + [ROOT / 'docs/skills/README.md']
for path in files:
    text = path.read_text(encoding='utf-8')
    if path.name == 'SKILL.md':
        match = re.match(r'\A---\n(.*?)\n---\n', text, re.S)
        if not match:
            errors.append(f'{path.relative_to(ROOT)}: missing YAML frontmatter')
        else:
            fields = dict(re.findall(r'^(name|description):\s*(.+)$', match[1], re.M))
            if fields.get('name') != path.parent.name:
                errors.append(f'{path.relative_to(ROOT)}: name must match directory')
            if not fields.get('description', '').strip():
                errors.append(f'{path.relative_to(ROOT)}: missing description')
    for target in re.findall(r'\[[^\]]*\]\(([^)]+)\)', text):
        if re.match(r'^[a-z]+://', target) or target.startswith('#'):
            continue
        destination = target.split('#', 1)[0]
        if destination and not (path.parent / destination).exists():
            errors.append(f'{path.relative_to(ROOT)}: broken link {target}')
if errors:
    print('\n'.join(errors), file=sys.stderr)
    sys.exit(1)
print(f'PASS: {len(actual)} team skills; frontmatter and local file links valid.')
