# from PIL import ImageFont, ImageDraw
#
# # 37.79527559055 是一个不正确的转换系数。正确的转换系数是每厘米的像素数。例如，如果图像的分辨率为 72 DPI，
# # 则可以通过将 DPI 除以 2.54（每厘米的英寸数）来计算每厘米的像素数。
#
# # pixels_per_centimeter = 72 / 2.54 进而width_in_cm = width / pixels_per_centimeter
#
# #ggplot2
# #字号1 inch = 72.27 point = 25.4 mm, ggplot2::.pt = 72.27/25.4
# #线宽1 inch = 72.27 point = 96 pixel
# 10*72.27/96
#
# #ImageFont
# #字号 pixel
#
# #AI
# #1px=1pt
#

#
# font_family = font_manager.FontProperties(family='Times New Roman', weight='regular')
# font_family_file = font_manager.findfont(font_family)
# print(font_family_file)
# line = 'fontsize = 10/.pt' #(0, 3, 60, 17),   22.0605 mm, 6.2592 mm
# for i in ['fontsize = 10/.pt', 'hdksalsajl', 'fontsize = 10']:
#     res = ImageFont.truetype(font_family_file, 28, 0)
#     box_px = res.getbbox(i)
#     print(box_px)
#
# pixels_per_centimeter = 96 / 25.4 #96 px = 25.4 mm
# width_in_cm = box_px[2] / pixels_per_centimeter
# heigth_in_cm = box_px[3] / pixels_per_centimeter
#
# res.getlength(line) #17.195767195767196
#
# # dpi is the pixel density or dots per inch.
# # 96 dpi means there are 96 pixels per inch.
# # 1 inch is equal to 2.54 centimeters.
#
# #1 inches = 2.54 cm
# font_size_pt = font_size*96/72

from matplotlib import font_manager
from PIL import Image, ImageDraw, ImageFont
import os

def pill_strwh(string, family, fontface, size, fonts_path):
    """
    :param string: str
    :param family: str, "serif"
    :param fontface: int, "regular"
    :param size: int or float, px
    :param work_path: str, work path, work_path+"/fonts/ttf"
    :return: int, px
    """

    fontface_dict = {1: ["normal", "regular"], 2: ["normal", "bold"], 3: ["italic", "normal"], 4: ["italic", "bold"]}

    # 加载字体
    directory_fonts = fonts_path
    tmp = font_manager.FontManager()
    font_files = font_manager.findSystemFonts(fontpaths=directory_fonts)
    for font_file in font_files:
        try:
            tmp.addfont(path=font_file)
        except Exception as ex:
            print(font_file, ex)
            pass

    font_family = font_manager.FontProperties(family=family, style=fontface_dict[fontface][0],
                                              weight=fontface_dict[fontface][1])
    font_family_file = tmp.findfont(font_family, directory=directory_fonts, rebuild_if_missing=True)
    print(font_family_file)
    res = ImageFont.truetype(font_family_file, size, 0)
    box_px = res.getbbox(string)
    return(box_px[2])
  
  
