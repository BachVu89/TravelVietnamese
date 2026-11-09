"""Original warm painterly colour atlas; no reference image/texture input."""
from pathlib import Path
from PIL import Image, ImageDraw
ROOT=Path(__file__).resolve().parents[1]
COLORS=[
('Road','#70685D'),('Clay shoulder','#AB815B'),('Deep forest','#344F43'),('Leaf mid','#64805A'),
('Leaf sun','#9CAF70'),('Field green','#91A466'),('Rice gold','#CDB773'),('Warm rock','#918673'),
('Far graygreen','#8C9F90'),('Cream','#EFE0B9'),('Warm red','#B96C55'),('Dark metal','#424B49'),
('Skin','#D6AA83'),('Olive cloth','#77815E'),('Ochre pack','#B89962'),('Blue fabric','#647E88'),
('Water cyan','#7CABA3'),('Terracotta','#AA7056'),('Wood','#82664F'),('White mark','#E9DFC2'),
('Sand','#CCB68B'),('Bark shadow','#554D3F'),('Bark light','#A18B66'),('Moss','#78875A'),
('Leaf cool','#5C7968'),('Leaf pale','#B1BF84'),('Ochre soil','#B69A6B'),('Dark clay','#87654F'),
('Stone shade','#706D63'),('Stone light','#B3A58B'),('Cloud cream','#EEE3C7'),('Sky peach','#DFC5A1'),
('Sky blue','#AAC6BF'),('Haze sage','#BAC7AB'),('Flower gold','#D6B565'),('Flower rust','#C28460'),
('Buffalo brown','#62584B'),('Roof shade','#855B48'),('Roof light','#CB9370'),('Rice shade','#A49D60'),
('Rice light','#E2CF90'),('Jade','#658D7A'),('Teal shade','#4C756F'),('Water light','#B1C9B3'),
('Cool cloth','#7D9491'),('Warm cloth','#A39471'),('Leather','#907247'),('Leather dark','#67523C'),
('Dust light','#D6C5A2'),('Dust shade','#AC9B7B'),('Sun light','#F4DDA3'),('Sun gold','#E4C584'),
('Distant hill','#9DAF9C'),('Distant pale','#BDC9AF'),('Valley shade','#7F998A'),('Valley light','#A8BA97'),
('Berry','#9C655E'),('Muted pink','#C59B84'),('Slate','#737E79'),('Charcoal','#3C4540'),
('Paper','#F5E9CA'),('Ink','#34463E'),('Accent orange','#C98C54'),('Accent leaf','#BCCB8D')]
def generate():
 image=Image.new('RGB',(512,512));draw=ImageDraw.Draw(image)
 # UV v=0 is image bottom in Unity. ID row0 must be PNG row7.
 for i,(_,color) in enumerate(COLORS):
  x=(i%8)*64;y=(7-i//8)*64;draw.rectangle((x,y,x+63,y+63),fill=color)
 path=ROOT/'Assets/VietTrail/Resources/Theme/PainterlyPalette.png';path.parent.mkdir(parents=True,exist_ok=True);image.save(path)
 swatch=Image.new('RGB',(800,480),'#F5E9CA');d=ImageDraw.Draw(swatch)
 d.text((12,10),'ORIGINAL PALETTE SWATCHES - NOT A GAME RENDER',fill='#34463E')
 for i,(name,color) in enumerate(COLORS[:16]):
  x=(i%4)*200;y=40+(i//4)*110;d.rectangle((x+10,y,x+190,y+70),fill=color);d.text((x+10,y+75),f'{i}: {name}',fill='#34463E')
 out=ROOT/'Assets/VietTrail/Rendering/PainterlySwatches.png';swatch.save(out)
 print('PALETTE_PASS',path)
if __name__=='__main__':generate()
