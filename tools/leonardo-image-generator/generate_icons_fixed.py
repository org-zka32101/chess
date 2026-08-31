# -*- coding: utf-8 -*-
"""192x192の小アイコン6枚は生成が破綻したため、512x512で生成してから
192x192にリサイズする(小さすぎるサイズはPhoenixモデルと相性が悪い)。"""
from pathlib import Path
from PIL import Image
from leonardo_generator import LeonardoGenerator

ICONS = [
    ("icon_home_192x192.png", "Minimalist home icon for mobile app, simple flat design, white icon on transparent background, modern style, single clear symbol, app UI icon, vector style"),
    ("icon_puzzle_192x192.png", "Minimalist puzzle piece icon for mobile app, simple flat design, white icon on transparent background, modern style, single clear symbol, app UI icon, vector style"),
    ("icon_game_192x192.png", "Minimalist multiplayer controller icon for mobile app, simple flat design, white icon on transparent background, modern style, single clear symbol, app UI icon, vector style"),
    ("icon_profile_192x192.png", "Minimalist user profile person icon for mobile app, simple flat design, white icon on transparent background, modern style, single clear symbol, app UI icon, vector style"),
    ("icon_settings_192x192.png", "Minimalist gear settings icon for mobile app, simple flat design, white icon on transparent background, modern style, single clear symbol, app UI icon, vector style"),
    ("icon_leaderboard_192x192.png", "Minimalist trophy leaderboard ranking icon for mobile app, simple flat design, white icon on transparent background, modern style, single clear symbol, app UI icon, vector style"),
]

gen = LeonardoGenerator()

for filename, prompt in ICONS:
    print(f"=== {filename} ===")
    tmp_name = f"_raw_{filename}"
    path = gen.generate_image(
        prompt=prompt, filename=tmp_name,
        width=512, height=512, guidance_scale=7.0,
    )
    if not path:
        print(f"  ❌ 生成失敗: {filename}")
        continue
    img = Image.open(path).convert("RGBA")
    resized = img.resize((192, 192), Image.LANCZOS)
    out_path = gen.output_dir / filename
    resized.save(out_path)
    Path(path).unlink()
    print(f"  ✅ 保存: {out_path}")

print("done")
