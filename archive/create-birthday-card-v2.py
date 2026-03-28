from PIL import Image, ImageDraw, ImageFont
import math

# Create image with gradient background
width, height = 800, 1000
img = Image.new('RGB', (width, height), '#FFF8E7')
draw = ImageDraw.Draw(img)

# Draw gradient background (warm peach to cream)
for y in range(height):
    r = int(255 - (y / height) * 20)
    g = int(248 - (y / height) * 15)
    b = int(231 - (y / height) * 10)
    draw.line([(0, y), (width, y)], fill=(r, g, b))

# Load fonts
try:
    font_large = ImageFont.truetype("/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc", 90)
    font_medium = ImageFont.truetype("/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc", 42)
    font_small = ImageFont.truetype("/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc", 32)
    font_eng = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 32)
except:
    font_large = ImageFont.load_default()
    font_medium = font_large
    font_small = font_large
    font_eng = font_large

# Colors
gold = '#C4956A'
dark_text = '#3D2914'
red_accent = '#B85450'
orange = '#E07B39'
light_pink = '#FFD1DC'

# Helper function to draw a balloon
def draw_balloon(draw, x, y, size, color, string_color='#666'):
    # String
    draw.line([(x, y + size), (x, y + size + size//1.5)], fill=string_color, width=2)
    # Balloon body (oval)
    draw.ellipse([x - size//2, y - size, x + size//2, y + size//3], fill=color, outline='#333', width=2)
    # Highlight
    draw.ellipse([x - size//4, y - size//1.5, x - size//8, y - size//2], fill='#FFF', outline=None)

# Draw balloons at top
draw_balloon(draw, 200, 140, 50, '#FF6B6B')  # Red
draw_balloon(draw, 280, 120, 40, '#4ECDC4')  # Teal
draw_balloon(draw, 520, 125, 45, '#FFE66D')  # Yellow
draw_balloon(draw, 600, 145, 55, '#95E1D3')  # Mint

# Draw a simple cake
cake_x, cake_y = width // 2, 200
# Cake base
draw.rectangle([cake_x - 60, cake_y, cake_x + 60, cake_y + 50], fill='#D4A574', outline='#8B6914', width=2)
# Cake top
draw.rectangle([cake_x - 50, cake_y - 30, cake_x + 50, cake_y], fill='#F4E4C1', outline='#8B6914', width=2)
# Candle
draw.rectangle([cake_x - 3, cake_y - 50, cake_x + 3, cake_y - 30], fill='#FF6B6B', outline='#333')
# Flame
draw.ellipse([cake_x - 8, cake_y - 65, cake_x + 8, cake_y - 45], fill='#FFA500', outline='#FF6B00')

# Decorative corner elements
def draw_star(draw, x, y, size, color):
    points = []
    for i in range(10):
        angle = math.pi / 2 + i * math.pi / 5
        r = size if i % 2 == 0 else size // 2
        px = x + r * math.cos(angle)
        py = y - r * math.sin(angle)
        points.append((px, py))
    draw.polygon(points, fill=color, outline='#333')

# Stars around
draw_star(draw, 80, 180, 15, '#FFD700')
draw_star(draw, 720, 170, 12, '#FFD700')
draw_star(draw, 100, 850, 10, '#FFD700')
draw_star(draw, 700, 840, 14, '#FFD700')

# Main title
title = "爸爸生日快乐"
bbox = draw.textbbox((0, 0), title, font=font_large)
title_width = bbox[2] - bbox[0]
draw.text(((width - title_width) // 2, 300), title, font=font_large, fill=red_accent)

# Subtitle
subtitle = "Happy Birthday Dad!"
bbox = draw.textbbox((0, 0), subtitle, font=font_eng)
sub_width = bbox[2] - bbox[0]
draw.text(((width - sub_width) // 2, 410), subtitle, font=font_eng, fill=gold)

# Decorative line with hearts
draw.line([(120, 460), (width//2 - 30, 460)], fill=gold, width=3)
draw.ellipse([width//2 - 15, 450, width//2 + 5, 470], fill='#E74C3C')
draw.ellipse([width//2 + 5, 450, width//2 + 25, 470], fill='#E74C3C')
draw.polygon([(width//2 - 15, 460), (width//2 + 25, 460), (width//2 + 5, 485)], fill='#E74C3C')
draw.line([(width//2 + 30, 460), (width - 120, 460)], fill=gold, width=3)

# Main message - updated with financial support mention, removed signature
message = "谢谢您一直以来对我的支持，\n在学费和设备上给我帮助，\n给我自由和空间做自己喜欢的事。\n我会继续努力的！"
lines = message.split('\n')
y_start = 520
for i, line in enumerate(lines):
    bbox = draw.textbbox((0, 0), line, font=font_medium)
    line_width = bbox[2] - bbox[0]
    draw.text(((width - line_width) // 2, y_start + i * 55), line, font=font_medium, fill=dark_text)

# Bottom hearts decoration (lowered since no signature)
heart_y = 800
for i, x in enumerate([320, 360, 400]):
    size = 20 if i == 1 else 15
    color = '#E74C3C' if i == 1 else '#FFB6C1'
    draw.ellipse([x - size, heart_y - size//2, x, heart_y + size//2], fill=color)
    draw.ellipse([x, heart_y - size//2, x + size, heart_y + size//2], fill=color)
    draw.polygon([(x - size, heart_y), (x + size, heart_y), (x, heart_y + size)], fill=color)

# Border with rounded corners effect
corner_size = 30
border_color = '#C4956A'
border_width = 4
draw.rectangle([40, 40, width-40, height-40], outline=border_color, width=border_width)

# Corner decorations
draw.pieslice([20, 20, 60, 60], 180, 270, fill=None, outline=border_color, width=3)
draw.pieslice([width-60, 20, width-20, 60], 270, 360, fill=None, outline=border_color, width=3)
draw.pieslice([20, height-60, 60, height-20], 90, 180, fill=None, outline=border_color, width=3)
draw.pieslice([width-60, height-60, width-20, height-20], 0, 90, fill=None, outline=border_color, width=3)

# Save
output_path = '/home/qq/.openclaw/workspace/dad-birthday-card-v2.png'
img.save(output_path, quality=95)
print(f"Saved: {output_path}")
