#!/usr/bin/env python3
"""
图片尺寸统一工具
用于将多个文件夹中的PNG图片统一到相同的尺寸

使用方法:
    python unify_image_size.py <目标宽度> <目标高度> <文件夹路径1> [文件夹路径2] ...
    
示例:
    python unify_image_size.py 256 256 resources/animation/character/idle resources/animation/character/walk
    
参数说明:
    --align <center|bottom|top>: 内容对齐方式 (默认: bottom，适合角色动画)
    --padding <color>: 填充颜色，格式为 R,G,B,A (默认: 0,0,0,0 透明)
    --output <dir>: 输出目录 (默认: 覆盖原文件)
    --dry-run: 仅分析不修改，显示各文件夹图片尺寸信息
"""

import os
import sys
import argparse
from pathlib import Path
from typing import Optional, Tuple, List

try:
    from PIL import Image
except ImportError:
    print("错误: 需要安装 Pillow 库")
    print("请运行: pip install Pillow")
    sys.exit(1)


def get_image_files(directory: str) -> List[Path]:
    """获取目录下所有PNG图片"""
    dir_path = Path(directory)
    if not dir_path.exists():
        print(f"警告: 目录不存在 - {directory}")
        return []
    
    return sorted(dir_path.glob("*.png"))


def analyze_images(directories: List[str]) -> dict:
    """分析各目录图片尺寸信息"""
    results = {}
    
    for directory in directories:
        images = get_image_files(directory)
        if not images:
            continue
            
        sizes = []
        for img_path in images:
            try:
                with Image.open(img_path) as img:
                    sizes.append(img.size)
            except Exception as e:
                print(f"  无法读取: {img_path.name} - {e}")
        
        if sizes:
            widths = [s[0] for s in sizes]
            heights = [s[1] for s in sizes]
            
            results[directory] = {
                'count': len(sizes),
                'min_size': (min(widths), min(heights)),
                'max_size': (max(widths), max(heights)),
                'sizes': set(sizes)
            }
    
    return results


def calculate_target_position(
    original_size: Tuple[int, int],
    target_size: Tuple[int, int],
    align: str
) -> Tuple[int, int]:
    """计算内容在目标画布中的位置"""
    orig_w, orig_h = original_size
    target_w, target_h = target_size
    
    x = (target_w - orig_w) // 2
    
    if align == 'top':
        y = 0
    elif align == 'center':
        y = (target_h - orig_h) // 2
    else:
        y = target_h - orig_h
    
    return (x, y)


def resize_image(
    input_path: Path,
    output_path: Path,
    target_size: Tuple[int, int],
    align: str,
    padding_color: Tuple[int, int, int, int],
    scale_content: bool = False,
    target_height: Optional[int] = None
) -> bool:
    """调整单个图片尺寸"""
    try:
        with Image.open(input_path) as img:
            if img.mode != 'RGBA':
                img = img.convert('RGBA')
            
            orig_size = img.size
            
            if scale_content and target_height:
                scale_ratio = target_height / orig_size[1]
                new_w = int(orig_size[0] * scale_ratio)
                new_h = target_height
                img = img.resize((new_w, new_h), Image.Resampling.LANCZOS)
                orig_size = (new_w, new_h)
                
                if orig_size == target_size:
                    output_path.parent.mkdir(parents=True, exist_ok=True)
                    img.save(output_path)
                    return True
            
            if orig_size == target_size:
                if input_path != output_path:
                    img.save(output_path)
                return True
            
            new_img = Image.new('RGBA', target_size, padding_color)
            
            position = calculate_target_position(orig_size, target_size, align)
            
            new_img.paste(img, position, img if img.mode == 'RGBA' else None)
            
            output_path.parent.mkdir(parents=True, exist_ok=True)
            new_img.save(output_path)
            
            return True
    except Exception as e:
        print(f"  处理失败: {input_path.name} - {e}")
        return False


def process_directory(
    directory: str,
    target_size: Tuple[int, int],
    align: str,
    padding_color: Tuple[int, int, int, int],
    output_dir: Optional[str],
    scale_content: bool = False,
    target_height: Optional[int] = None
) -> Tuple[int, int]:
    """处理单个目录"""
    images = get_image_files(directory)
    if not images:
        return (0, 0)
    
    success_count = 0
    fail_count = 0
    
    dir_path = Path(directory)
    
    for img_path in images:
        if output_dir:
            out_path = Path(output_dir) / img_path.name
        else:
            out_path = img_path
        
        if resize_image(img_path, out_path, target_size, align, padding_color, scale_content, target_height):
            success_count += 1
        else:
            fail_count += 1
    
    return (success_count, fail_count)


def parse_color(color_str: str) -> Tuple[int, int, int, int]:
    """解析颜色字符串"""
    parts = color_str.split(',')
    if len(parts) == 4:
        return tuple(int(p.strip()) for p in parts)
    elif len(parts) == 3:
        return tuple(int(p.strip()) for p in parts) + (255,)
    else:
        print(f"警告: 无效的颜色格式 '{color_str}'，使用透明")
        return (0, 0, 0, 0)


def main():
    parser = argparse.ArgumentParser(
        description='图片尺寸统一工具 - 将多个文件夹中的PNG图片统一到相同尺寸',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  %(prog)s 256 256 resources/animation/character/idle resources/animation/character/walk
  %(prog)s --align bottom --dry-run 256 256 resources/animation/character/idle
  %(prog)s --output ./output 256 256 resources/animation/character/idle
        """
    )
    
    parser.add_argument('width', type=int, nargs='?', help='目标宽度')
    parser.add_argument('height', type=int, nargs='?', help='目标高度')
    parser.add_argument('directories', nargs='*', help='要处理的文件夹路径')
    parser.add_argument('--align', choices=['center', 'bottom', 'top'], default='bottom',
                       help='内容对齐方式 (默认: bottom，适合角色动画)')
    parser.add_argument('--padding', default='0,0,0,0',
                       help='填充颜色 R,G,B,A (默认: 0,0,0,0 透明)')
    parser.add_argument('--output', help='输出目录 (默认: 覆盖原文件)')
    parser.add_argument('--dry-run', action='store_true',
                       help='仅分析不修改，显示各文件夹图片尺寸信息')
    parser.add_argument('--scale-height', type=int,
                       help='按比例缩放图片到指定高度')
    
    args = parser.parse_args()
    
    if not args.directories:
        args.directories = ['resources/animation/character/idle', 
                           'resources/animation/character/walk']
        print(f"未指定目录，使用默认目录:")
        for d in args.directories:
            print(f"  - {d}")
        print()
    
    print("=" * 60)
    print("图片尺寸分析")
    print("=" * 60)
    
    analysis = analyze_images(args.directories)
    
    if not analysis:
        print("未找到任何PNG图片")
        return
    
    all_sizes = set()
    for directory, info in analysis.items():
        print(f"\n目录: {directory}")
        print(f"  图片数量: {info['count']}")
        print(f"  最小尺寸: {info['min_size']}")
        print(f"  最大尺寸: {info['max_size']}")
        if len(info['sizes']) > 1:
            print(f"  尺寸种类: {len(info['sizes'])} 种不同尺寸")
            for size in sorted(info['sizes']):
                print(f"    - {size[0]}x{size[1]}")
        else:
            print(f"  统一尺寸: {list(info['sizes'])[0][0]}x{list(info['sizes'])[0][1]}")
        all_sizes.update(info['sizes'])
    
    if args.dry_run:
        print("\n" + "=" * 60)
        print("建议的目标尺寸:")
        max_w = max(s[0] for s in all_sizes)
        max_h = max(s[1] for s in all_sizes)
        print(f"  最大宽度 x 最大高度 = {max_w}x{max_h}")
        if args.scale_height:
            print(f"\n  如按高度 {args.scale_height} 缩放:")
            for directory, info in analysis.items():
                sample_size = list(info['sizes'])[0]
                scale_ratio = args.scale_height / sample_size[1]
                new_w = int(sample_size[0] * scale_ratio)
                print(f"    {directory}: {sample_size[0]}x{sample_size[1]} -> {new_w}x{args.scale_height}")
        print("=" * 60)
        return
    
    scale_content = args.scale_height is not None
    target_height = args.scale_height
    
    if scale_content:
        max_w = 0
        for directory, info in analysis.items():
            sample_size = list(info['sizes'])[0]
            scale_ratio = target_height / sample_size[1]
            scaled_w = int(sample_size[0] * scale_ratio)
            max_w = max(max_w, scaled_w)
        target_size = (max_w, target_height)
        print(f"\n按高度 {target_height} 缩放，目标画布尺寸: {max_w}x{target_height}")
    else:
        if not args.width or not args.height:
            max_w = max(s[0] for s in all_sizes)
            max_h = max(s[1] for s in all_sizes)
            args.width = max_w
            args.height = max_h
            print(f"\n未指定目标尺寸，自动使用最大尺寸: {max_w}x{max_h}")
        target_size = (args.width, args.height)
    padding_color = parse_color(args.padding)
    
    print("\n" + "=" * 60)
    print("开始处理")
    print("=" * 60)
    print(f"目标尺寸: {target_size[0]}x{target_size[1]}")
    if scale_content:
        print(f"缩放模式: 按高度 {target_height} 等比缩放")
    print(f"对齐方式: {args.align}")
    print(f"填充颜色: RGBA{padding_color}")
    if args.output:
        print(f"输出目录: {args.output}")
    else:
        print("输出方式: 覆盖原文件")
    print()
    
    total_success = 0
    total_fail = 0
    
    for directory in args.directories:
        if directory not in analysis:
            continue
        
        print(f"处理: {directory}")
        success, fail = process_directory(
            directory, target_size, args.align, 
            padding_color, args.output, scale_content, target_height
        )
        total_success += success
        total_fail += fail
        print(f"  完成: {success} 张成功, {fail} 张失败")
    
    print("\n" + "=" * 60)
    print(f"处理完成: 共 {total_success} 张成功, {total_fail} 张失败")
    print("=" * 60)


if __name__ == '__main__':
    main()
