from PIL import Image, ImageDraw, ImageFont
import random

# Create image
width, height = 800, 1000
img = Image.new('RGB', (width, height), '#FFF8E7')  # Warm cream background
draw = ImageDraw.Draw(img)

# Load fonts
try:
    font_large = ImageFont.truetype("/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc", 80)
    font_medium = ImageFont.truetype("/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc", 48)
    font_small = ImageFont.truetype("/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc", 36)
except:
    font_large = ImageFont.load_default()
    font_medium = font_large
    font_small = font_large

# Colors
gold = '#D4A574'
dark_text = '#4A3728'
red_accent = '#C85A54'

# Draw decorative border
border_width = 20
draw.rectangle([border_width, border_width, width-border_width, height-border_width], 
               outline=gold, width=4)

# Inner border
draw.rectangle([border_width+15, border_width+15, width-border_width-15, height-border_width-15], 
               outline=gold, width=2)

# Top decoration - balloons emoji
draw.text((width//2 - 100, 80), "🎈", font=font_large, fill=dark_text)
draw.text((width//2 + 20, 80), "🎂", font=font_large, fill=dark_text)
draw.text((width//2 + 140, 80), "🎈", font=font_large, fill=dark_text)

# Main title
title = "老爸生日快乐"
bbox = draw.textbbox((0, 0), title, font=font_large)
title_width = bbox[2] - bbox[0]
draw.text(((width - title_width) // 2, 250), title, font=font_large, fill=red_accent)

# Subtitle
subtitle = "Happy Birthday Dad!"
try:
    font_eng = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 36)
except:
    font_eng = font_small
bbox = draw.textbbox((0, 0), subtitle, font=font_eng)
sub_width = bbox[2] - bbox[0]
draw.text(((width - sub_width) // 2, 360), subtitle, font=font_eng, fill=gold)

# Decorative line
draw.line([(150, 430), (width-150, 430)], fill=gold, width=3)

# Main message
message = "谢谢您一直支持我学编程，\n给我自由和空间做自己喜欢的事。\n我会继续努力的！"
lines = message.split('\n')
y_start = 480
for i, line in enumerate(lines):
    bbox = draw.textbbox((0, 0), line, font=font_medium)
    line_width = bbox[2] - bbox[0]
    draw.text(((width - line_width) // 2, y_start + i * 70), line, font=font_medium, fill=dark_text)

# Bottom decoration
draw.text((width//2 - 60, 750), "❤️", font=font_large, fill=red_accent)
draw.text((width//2 + 40, 750), "🎁", font=font_large, fill=dark_text)

# From
from_text = "—— 儿子"
bbox = draw.textbbox((0, 0), from_text, font=font_small)
from_width = bbox[2] - bbox[0]
draw.text(((width - from_width) // 2, 880), from_text, font=font_small, fill=dark_text)

# Save
output_path = '/home/qq/.openclaw/workspace/dad-birthday-card.png'
img.save(output_path, quality=95)
print(f"Saved: {output_path}")
