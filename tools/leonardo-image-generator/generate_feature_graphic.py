# -*- coding: utf-8 -*-
"""feature_graphicを文字なしプロンプトで再生成する
(AI画像生成は文字レンダリングが不得手で文字化けするため、テキストは含めない。
 実際のロゴ・コピーはデザインツールで別途重ねる想定)"""
from pathlib import Path
from PIL import Image
from leonardo_generator import LeonardoGenerator

FINAL_W, FINAL_H = 1242, 2688
MAX_DIM = 1536

gen = LeonardoGenerator()

ratio = FINAL_W / FINAL_H
gen_h = MAX_DIM
gen_w = round(MAX_DIM * ratio)
gen_w = (gen_w // 8) * 8

prompt = (
    "Chess tactics mobile game promotional artwork, no text, no letters, no UI, "
    "premium dark navy and gold color scheme, dramatic 3D chess pieces on a "
    "marble and wood chessboard, cinematic lighting, elegant atmosphere, "
    "vertical portrait composition, professional app store quality background art"
)

path = gen.generate_image(
    prompt=prompt, filename="_raw_feature_graphic.png",
    width=gen_w, height=gen_h, guidance_scale=7.5,
)
if path:
    img = Image.open(path).convert("RGB")
    resized = img.resize((FINAL_W, FINAL_H), Image.LANCZOS)
    out_path = gen.output_dir / "feature_graphic_1242x2688.png"
    resized.save(out_path)
    Path(path).unlink()
    print(f"✅ 保存: {out_path}")
else:
    print("❌ 生成失敗")
