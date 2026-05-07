#!/bin/bash
# Regenerate manifest.json from contents of photos/ and audio/.
# Run after adding or removing files. The site reads manifest.json at load.

set -e
cd "$(dirname "$0")"

python3 - <<'PY'
import json, os, re

def list_files(folder, exts):
    if not os.path.isdir(folder):
        return []
    out = []
    for name in sorted(os.listdir(folder)):
        if name.startswith('.'):
            continue
        if os.path.splitext(name)[1].lower() in exts:
            out.append(f"{folder}/{name}")
    return out

photos = list_files('photos', {'.jpg', '.jpeg', '.png', '.webp', '.gif'})
audio_files = list_files('audio', {'.mp3', '.ogg', '.m4a', '.wav'})

songs = []
for path in audio_files:
    base = os.path.splitext(os.path.basename(path))[0]
    title = re.sub(r'[-_]+', ' ', base).strip()
    songs.append({'file': path, 'title': title})

with open('manifest.json', 'w') as f:
    json.dump({'photos': photos, 'songs': songs}, f, indent=2)

print(f"manifest.json updated: {len(photos)} photos, {len(songs)} songs")
PY
