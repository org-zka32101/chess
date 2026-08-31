# -*- coding: utf-8 -*-
"""Phoenixモデルの解像度上限(1536px)を超える3枚を、アスペクト比を保った
最大サイズで生成してから、Pillowで最終寸法にリサイズする。"""
import sys
from pathlib import Path
from PIL import Image
from leonardo_generator import LeonardoGenerator

MAX_DIM = 1536

TARGETS = [
    {
        "filename": "splash_ios_1170x2532.png",
        "final_w": 1170, "final_h": 2532,
        "guidance_scale": 7.0,
        "prompt": "Chess tactics master app splash screen, elegant dark background, professional chess pieces, modern iOS design, luxury aesthetic, vertical portrait composition",
    },
    {
        "filename": "feature_graphic_1242x2688.png",
        "final_w": 1242, "final_h": 2688,
        "guidance_scale": 7.5,
        "prompt": "Chess tactics master game feature graphic for play store listing, professional design, shows gameplay and features, modern style, attractive, vertical portrait composition",
    },
]

gen = LeonardoGenerator()

for t in TARGETS:
    ratio = t["final_w"] / t["final_h"]
    gen_h = MAX_DIM
    gen_w = round(MAX_DIM * ratio)
    gen_w = max(32, min(1536, gen_w))
    gen_w = (gen_w // 8) * 8  # Leonardo APIは8の倍数を要求
    print(f"=== {t['filename']}: 生成{gen_w}x{gen_h} -> 最終{t['final_w']}x{t['final_h']} ===")

    tmp_name = f"_raw_{t['filename']}"
    path = gen.generate_image(
        prompt=t["prompt"], filename=tmp_name,
        width=gen_w, height=gen_h, guidance_scale=t["guidance_scale"],
    )
    if not path:
        print(f"  ❌ 生成失敗: {t['filename']}")
        continue

    img = Image.open(path).convert("RGB")
    resized = img.resize((t["final_w"], t["final_h"]), Image.LANCZOS)
    out_path = gen.output_dir / t["filename"]
    resized.save(out_path)
    Path(path).unlink()
    print(f"  ✅ 保存: {out_path}")

print("done")
