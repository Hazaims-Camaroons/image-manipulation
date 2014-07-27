image-manipulation
==================

Our final project for an introductory iPhone development class, this app manipulates images by adding various distortions.


Distortions
==================
- Pixelate
- Negative
- Flip X
- Flip Y
- Negate Bands
- Blur Box

def negateBands(image):
  """Creates vertical negated bands across the image"""
  bandWidth = int(getWidth(image)/5.0)
  for pixel in getPixels(image):
    """Negates pixels in every other band"""
    X = getX(pixel)    
    if X <= bandWidth:
      negation(pixel)
    elif X <= bandWidth*2:
      setColor(pixel,makeColor(getRed(pixel)+40,getGreen(pixel)+40,getBlue(pixel)+40))
    elif X <= bandWidth*3:
      negation(pixel)
    elif X <= bandWidth*4:
      setColor(pixel,makeColor(getRed(pixel)-40,getGreen(pixel)-40,getBlue(pixel)-40))
    else:
      negation(pixel)

def negation(pixel):
  """Negates pixels recieved from other functions"""
  Red = getRed(pixel)
  Green = getGreen(pixel)
  Blue = getBlue(pixel)
  negColor = makeColor(255-Red,255-Green,255-Blue);
  setColor(pixel,negColor)
