#!/usr/bin/env python3
"""Pack original Meshy metallic/roughness maps for Unity; preserve original files."""
from pathlib import Path
from PIL import Image, ImageChops
import argparse, hashlib, json
ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--asset-dir',type=Path,default=ROOT/'unity/TravelVietnamese/Assets/TravelVietnamese/Art/Imported/Meshy/Milestone')
a=p.parse_args();folder=a.asset_dir
metal=next(folder.glob('*_metallic.png'));rough=next(folder.glob('*_roughness.png'))
m=Image.open(metal).convert('L');r=Image.open(rough).convert('L')
if m.size!=r.size:raise SystemExit('Map dimensions differ; no output written')
out=folder/'Unity_Mask.png'
Image.merge('RGBA',(m,Image.new('L',m.size,255),Image.new('L',m.size,128),ImageChops.invert(r))).save(out)
(folder/'unity-mask-provenance.json').write_text(json.dumps({'generator':'scripts/art/pack-meshy-mask.py','output':out.name,'sha256':hashlib.sha256(out.read_bytes()).hexdigest(),'inputs':[{'file':p.name,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in [metal,rough]],'channels':{'R':'source metallic','G':'255 (no AO supplied)','B':'128 (neutral HDRP detail)','A':'255 - source roughness'}},ensure_ascii=False,indent=2)+'\n')
print('Packed mask:',out, m.size)
