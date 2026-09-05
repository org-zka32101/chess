#!/usr/bin/env python3
"""
Leonardo.ai API を使用してアセット画像を生成
複数のプロジェクトで再利用可能な汎用ツール
"""

import os
import json
import time
import requests
from pathlib import Path
from dotenv import load_dotenv
from typing import Dict, List, Optional


class LeonardoGenerator:
    """Leonardo.ai API を使用した画像生成クラス"""

    def __init__(self, env_file: Optional[str] = None):
        """
        初期化

        Args:
            env_file: .env ファイルのパス（デフォルト: .env）
        """
        if env_file:
            load_dotenv(env_file)
        else:
            load_dotenv()

        self.api_key = os.getenv('LEONARDO_API_KEY')
        self.base_url = os.getenv('LEONARDO_BASE_URL', 'https://api.leonardo.ai/v1')
        self.output_dir = Path(os.getenv('OUTPUT_DIR', './generated_assets'))

        if not self.api_key:
            raise ValueError("❌ LEONARDO_API_KEY が設定されていません")

        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.headers = {
            'Authorization': f'Bearer {self.api_key}',
            'Content-Type': 'application/json'
        }

    PHOENIX_MODEL_ID = 'de7d3faf-762f-48e0-b3b7-9d0ac3a3fcf3'  # Leonardo Phoenix 1.0

    def generate_image(self, prompt: str, filename: str,
                      width: int = 1024, height: int = 1024,
                      model: str = None,
                      guidance_scale: float = 7.0) -> Optional[str]:
        """
        単一の画像を生成

        Args:
            prompt: 画像説明プロンプト
            filename: 出力ファイル名
            width: 画像幅（ピクセル）
            height: 画像高さ（ピクセル）
            model: 使用モデル ('phoenix', 'phoenix-v2' など)
            guidance_scale: ガイダンススケール（品質調整）

        Returns:
            生成された画像パス、またはNone
        """
        endpoint = f'{self.base_url}/generations'
        model = model or self.PHOENIX_MODEL_ID

        # Leonardo.ai API (cloud.leonardo.ai) はモデル名でなく modelId(UUID) を要求する。
        # Phoenix 1.0 の modelId: de7d3faf-762f-48e0-b3b7-9d0ac3a3fcf3
        payload = {
            'prompt': prompt,
            'height': height,
            'width': width,
            'num_images': 1,
            'guidance_scale': guidance_scale,
            'modelId': model,
            'alchemy': True
        }

        print(f"🎨 生成中: {filename}")
        print(f"   プロンプト: {prompt[:60]}...")

        try:
            response = requests.post(endpoint, json=payload, headers=self.headers, timeout=30)

            if response.status_code != 200:
                print(f"❌ エラー {response.status_code}: {response.text}")
                return None

            data = response.json()
            generation_id = data.get('sdGenerationJob', {}).get('generationId')

            if not generation_id:
                print("❌ 生成IDが取得できませんでした")
                return None

            return self._wait_for_generation(generation_id, filename)

        except requests.RequestException as e:
            print(f"❌ リクエストエラー: {e}")
            return None

    def _wait_for_generation(self, generation_id: str, filename: str,
                            max_wait: int = 300, poll_interval: int = 2) -> Optional[str]:
        """
        生成完了をポーリング

        Args:
            generation_id: 生成ID
            filename: 出力ファイル名
            max_wait: 最大待機時間（秒）
            poll_interval: ポーリング間隔（秒）

        Returns:
            生成された画像パス、またはNone
        """
        endpoint = f'{self.base_url}/generations/{generation_id}'
        start_time = time.time()
        elapsed = 0

        while elapsed < max_wait:
            try:
                response = requests.get(endpoint, headers=self.headers, timeout=30)

                if response.status_code == 200:
                    data = response.json()
                    generation = data.get('generations_by_pk', {})

                    if generation.get('status') == 'COMPLETE':
                        images = generation.get('generated_images', [])
                        image_url = images[0].get('url') if images else None
                        if image_url:
                            return self._download_image(image_url, filename)
                        else:
                            print("❌ 画像URLが見つかりません")
                            return None
                    elif generation.get('status') == 'FAILED':
                        print("❌ 生成に失敗しました（ステータス: FAILED）")
                        return None

                elapsed = time.time() - start_time
                print(f"   待機中... ({elapsed:.0f}秒)")
                time.sleep(poll_interval)

            except requests.RequestException as e:
                print(f"❌ ポーリングエラー: {e}")
                return None

        print(f"⏱️ タイムアウト（{max_wait}秒）: {generation_id}")
        return None

    def _download_image(self, url: str, filename: str) -> Optional[str]:
        """
        生成された画像をダウンロード

        Args:
            url: 画像URL
            filename: 出力ファイル名

        Returns:
            保存されたファイルパス、またはNone
        """
        try:
            response = requests.get(url, timeout=30)

            if response.status_code == 200:
                file_path = self.output_dir / filename
                with open(file_path, 'wb') as f:
                    f.write(response.content)

                print(f"✅ 保存完了: {file_path}")
                return str(file_path)
            else:
                print(f"❌ ダウンロード失敗: ステータス {response.status_code}")

        except requests.RequestException as e:
            print(f"❌ ダウンロードエラー: {e}")

        return None

    def batch_generate(self, assets: List[Dict]) -> Dict[str, str]:
        """
        複数のアセットを一括生成

        Args:
            assets: アセット定義リスト
                [
                    {
                        'prompt': '画像説明',
                        'filename': '出力ファイル名',
                        'width': 1024,
                        'height': 1024,
                        'guidance_scale': 7.0  (オプション)
                    },
                    ...
                ]

        Returns:
            {filename: path, ...} の辞書
        """
        results = {}
        total = len(assets)

        for i, asset in enumerate(assets, 1):
            print(f"\n[{i}/{total}] {asset['filename']}")
            print("=" * 60)

            path = self.generate_image(
                prompt=asset['prompt'],
                filename=asset['filename'],
                width=asset.get('width', 1024),
                height=asset.get('height', 1024),
                guidance_scale=asset.get('guidance_scale', 7.0)
            )

            if path:
                results[asset['filename']] = path

            # APIレート制限対策
            if i < total:
                print(f"⏳ 次の画像生成まで2秒待機...")
                time.sleep(2)

        return results

    def load_config(self, config_file: str) -> List[Dict]:
        """
        JSON設定ファイルからアセット定義を読み込み

        Args:
            config_file: 設定ファイルのパス

        Returns:
            アセット定義リスト
        """
        try:
            with open(config_file, 'r', encoding='utf-8') as f:
                config = json.load(f)
            return config.get('assets', [])
        except Exception as e:
            print(f"❌ 設定ファイル読み込みエラー: {e}")
            return []

    def save_results(self, results: Dict[str, str], output_file: str = 'generation_results.json'):
        """
        生成結果をJSON形式で保存

        Args:
            results: 生成結果辞書
            output_file: 出力ファイル名
        """
        try:
            output_path = self.output_dir / output_file
            with open(output_path, 'w', encoding='utf-8') as f:
                json.dump(results, f, indent=2, ensure_ascii=False)
            print(f"\n✅ 結果を保存: {output_path}")
        except Exception as e:
            print(f"❌ 結果保存エラー: {e}")


# CLI インターフェース
if __name__ == '__main__':
    import sys
    import argparse

    parser = argparse.ArgumentParser(
        description='Leonardo.ai APIを使用して画像を生成',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
使用例:
  # 設定ファイルから生成
  python leonardo_generator.py --config assets_config.json

  # 単一画像を生成
  python leonardo_generator.py --prompt "Beautiful chess board" --filename board.png

  # カスタム出力ディレクトリを指定
  python leonardo_generator.py --config config.json --output ./my_assets
        """
    )

    parser.add_argument(
        '--config',
        help='JSON設定ファイルのパス'
    )
    parser.add_argument(
        '--prompt',
        help='画像生成プロンプト'
    )
    parser.add_argument(
        '--filename',
        default='output.png',
        help='出力ファイル名（デフォルト: output.png）'
    )
    parser.add_argument(
        '--width',
        type=int,
        default=1024,
        help='画像幅（デフォルト: 1024）'
    )
    parser.add_argument(
        '--height',
        type=int,
        default=1024,
        help='画像高さ（デフォルト: 1024）'
    )
    parser.add_argument(
        '--output',
        help='出力ディレクトリ（.env の OUTPUT_DIR を上書き）'
    )
    parser.add_argument(
        '--env',
        help='.env ファイルのパス'
    )

    args = parser.parse_args()

    try:
        generator = LeonardoGenerator(env_file=args.env)

        # 出力ディレクトリを上書き
        if args.output:
            generator.output_dir = Path(args.output)
            generator.output_dir.mkdir(parents=True, exist_ok=True)

        if args.config:
            # 設定ファイルから生成
            print(f"📋 設定ファイルを読み込み: {args.config}\n")
            assets = generator.load_config(args.config)

            if not assets:
                print("❌ アセットが見つかりません")
                sys.exit(1)

            results = generator.batch_generate(assets)
            generator.save_results(results)

        elif args.prompt:
            # 単一画像生成
            path = generator.generate_image(
                prompt=args.prompt,
                filename=args.filename,
                width=args.width,
                height=args.height
            )

            if path:
                print(f"\n✅ 生成完了: {path}")
            else:
                print("\n❌ 生成失敗")
                sys.exit(1)

        else:
            parser.print_help()
            sys.exit(1)

    except Exception as e:
        print(f"❌ エラー: {e}")
        sys.exit(1)
