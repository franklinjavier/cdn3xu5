🔬 Testing image transform service...
   Source: https://www.theminimalistdeveloper.com/take-control-of-your-learning-journey/man-hooked-up-to-machines.jpg

⏳ Waiting for all tests to complete...

# Image Transform Test Report

**Source:** `https://www.theminimalistdeveloper.com/take-control-of-your-learning-journey/man-hooked-up-to-machines.jpg`
**Base URL:** `https://d2fhhx9c14fnxb.cloudfront.net`
**Date:** 2026-04-16 15:10 UTC

## Results

| Status | Params | Test | Content-Type | Size (bytes) | Cache |
|--------|--------|------|-------------|-------------|-------|
| **---** | **1. BASELINE** |  |  |  |  |
| ❌ 502 | `` | No transforms (passthrough) | application/json | 21 | Error from cloudfront |
| **---** | **2. WIDTH (w)** |  |  |  |  |
| ✅ | `w_50` | Tiny (50px) | image/jpeg | 1710 | Hit from cloudfront |
| ✅ | `w_200` | Small (200px) | image/jpeg | 12942 | Hit from cloudfront |
| ✅ | `w_800` | Medium (800px) | image/jpeg | 129903 | Hit from cloudfront |
| ✅ | `w_1200` | Large (1200px) | image/jpeg | 190411 | Hit from cloudfront |
| ✅ | `w_2400` | XL (2400px) | image/jpeg | 190411 | Hit from cloudfront |
| ✅ | `w_5000` | Oversized (5000px) — should clamp or error | image/jpeg | 190411 | Hit from cloudfront |
| ✅ | `w_0` | Zero width — should error | image/jpeg | 628 | Hit from cloudfront |
| ✅ | `w_-1` | Negative width — should error | image/jpeg | 190411 | Hit from cloudfront |
| ✅ | `w_abc` | Non-numeric width — should error | image/jpeg | 190411 | Hit from cloudfront |
| ✅ | `w_1.5` | Decimal width — should error or round | image/jpeg | 190411 | Miss from cloudfront |
| ✅ | `w_999999` | Extreme width (DoS vector) | image/jpeg | 190411 | Miss from cloudfront |
| **---** | **3. HEIGHT (h)** |  |  |  |  |
| ✅ | `h_100` | Small height | image/jpeg | 4275 | Hit from cloudfront |
| ✅ | `h_600` | Medium height | image/jpeg | 78110 | Hit from cloudfront |
| ✅ | `h_2400` | XL height | image/jpeg | 190411 | Hit from cloudfront |
| ✅ | `h_0` | Zero height — should error | image/jpeg | 628 | Hit from cloudfront |
| ✅ | `h_-1` | Negative height — should error | image/jpeg | 190411 | Miss from cloudfront |
| ✅ | `h_abc` | Non-numeric height — should error | image/jpeg | 190411 | Miss from cloudfront |
| ✅ | `h_999999` | Extreme height (DoS vector) | image/jpeg | 190411 | Miss from cloudfront |
| **---** | **4. WIDTH + HEIGHT (w + h)** |  |  |  |  |
| ✅ | `w_200,h_200` | Square 200x200 | image/jpeg | 12942 | Hit from cloudfront |
| ✅ | `w_800,h_600` | Landscape 800x600 | image/jpeg | 78110 | Hit from cloudfront |
| ✅ | `w_600,h_800` | Portrait 600x800 | image/jpeg | 78110 | Hit from cloudfront |
| ✅ | `w_1,h_1` | 1x1 pixel | image/jpeg | 628 | Hit from cloudfront |
| ✅ | `w_4000,h_4000` | Very large — should clamp | image/jpeg | 1451901 | Hit from cloudfront |
| ✅ | `w_1,h_10000` | Extreme aspect ratio (1:10000) | image/jpeg | 628 | Miss from cloudfront |
| ✅ | `w_10000,h_1` | Extreme aspect ratio (10000:1) | image/jpeg | 628 | Miss from cloudfront |
| **---** | **5. ASPECT RATIO (ar)** |  |  |  |  |
| ✅ | `w_400,ar_16:9` | 16:9 landscape | image/jpeg | 31963 | Hit from cloudfront |
| ✅ | `w_400,ar_9:16` | 9:16 portrait | image/jpeg | 61593 | Hit from cloudfront |
| ✅ | `w_400,ar_4:3` | 4:3 classic | image/jpeg | 36775 | Hit from cloudfront |
| ✅ | `w_400,ar_1:1` | 1:1 square | image/jpeg | 39919 | Hit from cloudfront |
| ✅ | `w_400,ar_21:9` | 21:9 ultrawide | image/jpeg | 27617 | Miss from cloudfront |
| ✅ | `h_400,ar_16:9` | Height + AR (derive width) | image/jpeg | 80194 | Hit from cloudfront |
| ✅ | `ar_16:9` | AR only (no dimension) — behavior? | image/jpeg | 138705 | Hit from cloudfront |
| ✅ | `w_400,ar_0:0` | Invalid AR 0:0 | image/jpeg | 714 | Hit from cloudfront |
| ✅ | `w_400,ar_abc` | Non-numeric AR | image/jpeg | 39919 | Hit from cloudfront |
| ✅ | `w_400,ar_16:0` | AR with zero denominator | image/jpeg | 714 | Miss from cloudfront |
| ✅ | `w_400,ar_0:9` | AR with zero numerator | image/jpeg | 851 | Miss from cloudfront |
| ✅ | `w_400,ar_-1:1` | Negative AR | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,ar_1.5:1` | Decimal AR | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,h_300,ar_16:9` | Width + Height + AR (conflict) | image/jpeg | 31963 | Miss from cloudfront |
| **---** | **6. GRAVITY (g)** |  |  |  |  |
| ✅ | `w_200,h_200,g_center` | Gravity: center | image/jpeg | 13155 | Hit from cloudfront |
| ✅ | `w_200,h_200,g_north` | Gravity: north | image/jpeg | 4563 | Hit from cloudfront |
| ✅ | `w_200,h_200,g_south` | Gravity: south | image/jpeg | 5987 | Hit from cloudfront |
| ✅ | `w_200,h_200,g_east` | Gravity: east | image/jpeg | 12055 | Hit from cloudfront |
| ✅ | `w_200,h_200,g_west` | Gravity: west | image/jpeg | 13803 | Hit from cloudfront |
| ✅ | `w_200,h_200,g_northeast` | Gravity: northeast | image/jpeg | 4204 | Hit from cloudfront |
| ✅ | `w_200,h_200,g_northwest` | Gravity: northwest | image/jpeg | 3799 | Hit from cloudfront |
| ✅ | `w_200,h_200,g_southeast` | Gravity: southeast | image/jpeg | 5040 | Hit from cloudfront |
| ✅ | `w_200,h_200,g_southwest` | Gravity: southwest | image/jpeg | 4191 | Hit from cloudfront |
| ✅ | `w_200,h_200,g_face` | Gravity: face (smart crop) | image/jpeg | 12942 | Hit from cloudfront |
| ✅ | `w_200,h_200,g_auto` | Gravity: auto (smart crop) | image/jpeg | 12942 | Hit from cloudfront |
| ✅ | `w_200,h_200,g_entropy` | Gravity: entropy (Cloudinary-style) | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,h_200,g_invalid` | Gravity: invalid value | image/jpeg | 12942 | Hit from cloudfront |
| ✅ | `w_200,g_center` | Gravity without both dimensions | image/jpeg | 12942 | Miss from cloudfront |
| **---** | **7. STRATEGY (s)** |  |  |  |  |
| ✅ | `w_200,h_200,s_fit` | Strategy: fit (contain) | image/jpeg | 12942 | Hit from cloudfront |
| ✅ | `w_200,h_200,s_fill` | Strategy: fill (cover + crop) | image/jpeg | 12942 | Hit from cloudfront |
| ✅ | `w_200,h_200,s_scale` | Strategy: scale (stretch) | image/jpeg | 12942 | Hit from cloudfront |
| ✅ | `w_200,h_200,s_pad` | Strategy: pad (letterbox) | image/jpeg | 12942 | Hit from cloudfront |
| ✅ | `w_200,h_200,s_cover` | Strategy: cover (Cloudinary alias) | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,h_200,s_contain` | Strategy: contain (CSS alias) | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,h_200,s_inside` | Strategy: inside (sharp.js style) | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,h_200,s_outside` | Strategy: outside (sharp.js style) | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,s_fit` | Strategy: fit with width only | image/jpeg | 12942 | Hit from cloudfront |
| ✅ | `h_200,s_fit` | Strategy: fit with height only | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,h_200,s_invalid` | Strategy: invalid value | image/jpeg | 12942 | Hit from cloudfront |
| ✅ | `w_200,h_200,s_pad,g_center` | Pad + gravity combination | image/jpeg | 13155 | Miss from cloudfront |
| ✅ | `w_200,h_200,s_fill,g_north` | Fill + gravity (crop from top) | image/jpeg | 4563 | Miss from cloudfront |
| **---** | **8. QUALITY (q)** |  |  |  |  |
| ✅ | `w_400,q_1` | Quality: 1 (minimum) | image/jpeg | 7044 | Hit from cloudfront |
| ✅ | `w_400,q_25` | Quality: 25 (low) | image/jpeg | 16896 | Hit from cloudfront |
| ✅ | `w_400,q_50` | Quality: 50 (medium) | image/jpeg | 23245 | Hit from cloudfront |
| ✅ | `w_400,q_75` | Quality: 75 (default?) | image/jpeg | 31615 | Hit from cloudfront |
| ✅ | `w_400,q_85` | Quality: 85 (high — common default) | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,q_100` | Quality: 100 (maximum) | image/jpeg | 107924 | Hit from cloudfront |
| ✅ | `w_400,q_0` | Quality: 0 — should error | image/jpeg | 7044 | Hit from cloudfront |
| ✅ | `w_400,q_101` | Quality: 101 — should clamp or error | image/jpeg | 107924 | Hit from cloudfront |
| ✅ | `w_400,q_-10` | Quality: negative — should error | image/jpeg | 39919 | Hit from cloudfront |
| ✅ | `w_400,q_auto` | Quality: auto (adaptive quality) | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,q_auto:good` | Quality: auto:good (Cloudinary-style) | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,q_auto:best` | Quality: auto:best (Cloudinary-style) | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,q_auto:low` | Quality: auto:low (Cloudinary-style) | image/jpeg | 39919 | Miss from cloudfront |
| **---** | **9. BLUR (b)** |  |  |  |  |
| ✅ | `w_400,b_1` | Blur: 1 (minimal) | image/jpeg | 26556 | Hit from cloudfront |
| ✅ | `w_400,b_5` | Blur: 5 (moderate) | image/jpeg | 13245 | Hit from cloudfront |
| ✅ | `w_400,b_20` | Blur: 20 (heavy) | image/jpeg | 8877 | Hit from cloudfront |
| ✅ | `w_400,b_100` | Blur: 100 (extreme) | image/jpeg | 7058 | Hit from cloudfront |
| ✅ | `w_400,b_0` | Blur: 0 — should be no-op or error | image/jpeg | 30090 | Hit from cloudfront |
| ❌ 502 | `w_400,b_-1` | Blur: negative — should error | application/json | 21 | Error from cloudfront |
| ✅ | `w_400,b_0.5` | Blur: decimal value | image/jpeg | 35353 | Miss from cloudfront |
| ✅ | `w_400,b_1000` | Blur: extreme value (DoS?) | image/jpeg | 5033 | Miss from cloudfront |
| **---** | **10. FORMAT (f)** |  |  |  |  |
| ✅ | `w_400,f_jpeg` | Format: JPEG | image/jpeg | 39919 | Hit from cloudfront |
| ✅ | `w_400,f_jpg` | Format: JPG (alias?) | image/jpeg | 39919 | Hit from cloudfront |
| ✅ | `w_400,f_png` | Format: PNG | image/png | 155709 | Hit from cloudfront |
| ✅ | `w_400,f_webp` | Format: WebP | image/webp | 28058 | Hit from cloudfront |
| ✅ | `w_400,f_avif` | Format: AVIF | image/avif | 30597 | Hit from cloudfront |
| ✅ | `w_400,f_gif` | Format: GIF | image/gif | 124963 | Hit from cloudfront |
| ✅ | `w_400,f_tiff` | Format: TIFF — may not be supported | image/tiff | 480210 | Hit from cloudfront |
| ✅ | `w_400,f_bmp` | Format: BMP — may not be supported | image/bmp | 480054 | Hit from cloudfront |
| ✅ | `w_400,f_heif` | Format: HEIF — Apple ecosystem | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,f_jxl` | Format: JPEG XL — next-gen | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,f_auto` | Format: auto (content negotiation) | image/jpeg | 39919 | Hit from cloudfront |
| ✅ | `w_400,f_invalid` | Format: invalid value | image/jpeg | 39919 | Hit from cloudfront |
| ✅ | `w_400,f_svg` | Format: SVG (raster→vector — should fail) | image/svg+xml | 71083 | Miss from cloudfront |
| **---** | **11. PROFILE / PRESETS (p)** |  |  |  |  |
| ✅ | `p_thumbnail` | Profile: thumbnail | image/jpeg | 190411 | Hit from cloudfront |
| ✅ | `p_preview` | Profile: preview | image/jpeg | 190411 | Hit from cloudfront |
| ✅ | `p_hero` | Profile: hero | image/jpeg | 190411 | Hit from cloudfront |
| ✅ | `p_og` | Profile: og (Open Graph — 1200x630) | image/jpeg | 190411 | Hit from cloudfront |
| ✅ | `p_avatar` | Profile: avatar | image/jpeg | 190411 | Miss from cloudfront |
| ✅ | `p_card` | Profile: card | image/jpeg | 190411 | Miss from cloudfront |
| ✅ | `p_banner` | Profile: banner | image/jpeg | 190411 | Miss from cloudfront |
| ✅ | `p_favicon` | Profile: favicon | image/jpeg | 190411 | Miss from cloudfront |
| ✅ | `p_invalid` | Profile: invalid name | image/jpeg | 190411 | Hit from cloudfront |
| ✅ | `p_thumbnail,w_100` | Profile + override width | image/jpeg | 4275 | Miss from cloudfront |
| ✅ | `p_og,f_webp` | Profile + format override | image/webp | 130468 | Miss from cloudfront |
| **---** | **12. CROP COORDINATES (x, y)** |  |  |  |  |
| ✅ | `w_200,h_200,x_50,y_50` | Crop at offset 50,50 | image/jpeg | 4093 | Hit from cloudfront |
| ✅ | `w_200,h_200,x_0,y_0` | Crop at origin | image/jpeg | 3799 | Hit from cloudfront |
| ✅ | `w_200,h_200,x_9999,y_9999` | Crop beyond image bounds | image/jpeg | 629 | Hit from cloudfront |
| ✅ | `w_200,h_200,x_-10,y_-10` | Negative crop offset | image/jpeg | 12942 | Hit from cloudfront |
| ✅ | `x_50,y_50` | Crop offset without dimensions | image/jpeg | 190411 | Hit from cloudfront |
| ✅ | `w_200,h_200,x_50` | Crop with x only (no y) | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,h_200,y_50` | Crop with y only (no x) | image/jpeg | 12942 | Miss from cloudfront |
| **---** | **13. DPR (Device Pixel Ratio)** |  |  |  |  |
| ✅ | `w_200,dpr_1` | DPR 1x — should output 200px | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,dpr_1.5` | DPR 1.5x — should output 300px | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,dpr_2` | DPR 2x — should output 400px | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,dpr_3` | DPR 3x — should output 600px | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,dpr_4` | DPR 4x — should output 800px | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,dpr_0` | DPR 0 — should error | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,dpr_-1` | DPR negative — should error | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,dpr_auto` | DPR auto (client hints?) | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,dpr_10` | DPR 10x — extreme, should clamp | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,h_200,dpr_2` | DPR with both dimensions | image/jpeg | 12942 | Miss from cloudfront |
| **---** | **14. ROTATION (rot)** |  |  |  |  |
| ✅ | `w_400,rot_0` | Rotation: 0 degrees | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,rot_90` | Rotation: 90 degrees CW | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,rot_180` | Rotation: 180 degrees | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,rot_270` | Rotation: 270 degrees CW | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,rot_-90` | Rotation: -90 degrees (= 270) | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,rot_45` | Rotation: 45 degrees (non-right angle) | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,rot_360` | Rotation: 360 degrees (= 0) | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,rot_auto` | Rotation: auto (EXIF orientation) | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,rot_abc` | Rotation: invalid value | image/jpeg | 39919 | Miss from cloudfront |
| **---** | **15. FLIP / MIRROR** |  |  |  |  |
| ✅ | `w_400,flip_h` | Flip horizontal (mirror) | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,flip_v` | Flip vertical | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,flip_both` | Flip both axes | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,flip_h,rot_90` | Flip + rotation combo | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,flip_invalid` | Flip: invalid value | image/jpeg | 39919 | Miss from cloudfront |
| **---** | **16. SHARPEN (sh)** |  |  |  |  |
| ✅ | `w_400,sh_1` | Sharpen: 1 (subtle) | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,sh_5` | Sharpen: 5 (moderate) | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,sh_10` | Sharpen: 10 (strong) | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,sh_0` | Sharpen: 0 — no-op | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,sh_-1` | Sharpen: negative — should error | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,sh_100` | Sharpen: extreme | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,sh_5,b_5` | Sharpen + blur combo (conflict?) | image/jpeg | 13245 | Miss from cloudfront |
| **---** | **17. BACKGROUND COLOR (bg)** |  |  |  |  |
| ✅ | `w_200,h_200,s_pad,bg_ffffff` | Pad with white background | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,h_200,s_pad,bg_000000` | Pad with black background | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,h_200,s_pad,bg_ff0000` | Pad with red background | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,h_200,s_pad,bg_transparent` | Pad with transparency | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,h_200,s_pad,bg_fff` | Pad with short hex (3-char) | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,h_200,s_pad,bg_invalid` | Pad with invalid color | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,h_200,s_pad,bg_ff000080` | Pad with RGBA (50% alpha) | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,h_200,bg_ff0000` | Background without pad strategy | image/jpeg | 12942 | Miss from cloudfront |
| **---** | **18. BORDER & CORNERS** |  |  |  |  |
| ✅ | `w_200,h_200,border_2_000000` | Border: 2px black | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,h_200,border_5_ff0000` | Border: 5px red | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,h_200,border_0_000000` | Border: 0px — no-op | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,h_200,r_10` | Round corners: 10px | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,h_200,r_50` | Round corners: 50px | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,h_200,r_max` | Round corners: max (circle crop) | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,h_200,r_10,f_jpeg` | Round corners + JPEG (no alpha — what happens?) | image/jpeg | 12942 | Miss from cloudfront |
| ✅ | `w_200,h_200,r_10,f_png` | Round corners + PNG (has alpha) | image/png | 41228 | Miss from cloudfront |
| **---** | **19. TRIM** |  |  |  |  |
| ✅ | `w_400,trim_true` | Trim: auto-crop whitespace/borders | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,trim_10` | Trim: tolerance 10 | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,trim_50` | Trim: tolerance 50 | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,trim_false` | Trim: disabled | image/jpeg | 39919 | Miss from cloudfront |
| **---** | **20. METADATA / EXIF** |  |  |  |  |
| ✅ | `w_400,strip_true` | Strip all metadata | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,strip_false` | Preserve metadata | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,strip_true,f_jpeg` | Strip EXIF from JPEG | image/jpeg | 39919 | Miss from cloudfront |
| ✅ | `w_400,strip_true,f_png` | Strip metadata from PNG | image/png | 155709 | Miss from cloudfront |
| **---** | **21. PROGRESSIVE / INTERLACE** |  |  |  |  |
| ✅ | `w_800,f_jpeg,progressive_true` | Progressive JPEG | image/jpeg | 129903 | Miss from cloudfront |
| ✅ | `w_800,f_jpeg,progressive_false` | Baseline JPEG | image/jpeg | 129903 | Miss from cloudfront |
| ✅ | `w_800,f_png,progressive_true` | Interlaced PNG | image/png | 579658 | Miss from cloudfront |
| **---** | **22. SOURCE: PNG WITH TRANSPARENCY** |  |  |  |  |
| ❌ 502 | `w_400` | PNG source → default format | application/json | 21 | Error from cloudfront |
| ❌ 502 | `w_400,f_jpeg` | PNG→JPEG (alpha handling?) | application/json | 21 | Error from cloudfront |
| ❌ 502 | `w_400,f_webp` | PNG→WebP (preserve alpha) | application/json | 21 | Error from cloudfront |
| ❌ 502 | `w_400,f_avif` | PNG→AVIF (preserve alpha) | application/json | 21 | Error from cloudfront |
| ❌ 502 | `w_200,h_200,s_pad,bg_ff0000` | PNG + pad with red bg | application/json | 21 | Error from cloudfront |
| **---** | **22b. SOURCE: ANIMATED GIF** |  |  |  |  |
| ❌ 502 | `w_200` | Animated GIF → resize | application/json | 21 | Error from cloudfront |
| ❌ 502 | `w_200,f_webp` | Animated GIF → WebP (animated?) | application/json | 21 | Error from cloudfront |
| ❌ 502 | `w_200,f_png` | Animated GIF → PNG (first frame?) | application/json | 21 | Error from cloudfront |
| ❌ 502 | `w_200,f_jpeg` | Animated GIF → JPEG (first frame?) | application/json | 21 | Error from cloudfront |
| **---** | **22c. SOURCE: WEBP** |  |  |  |  |
| ✅ | `w_400` | WebP source → default format | image/jpeg | 24046 | Miss from cloudfront |
| ✅ | `w_400,f_jpeg` | WebP→JPEG | image/jpeg | 32717 | Miss from cloudfront |
| ✅ | `w_400,f_png` | WebP→PNG | image/png | 175224 | Miss from cloudfront |
| **---** | **22d. SOURCE: SVG** |  |  |  |  |
| ❌ 502 | `w_400` | SVG source → rasterize | application/json | 21 | Error from cloudfront |
| ❌ 502 | `w_400,f_png` | SVG→PNG | application/json | 21 | Error from cloudfront |
| ❌ 502 | `w_800` | SVG rasterize at 800px | application/json | 21 | Error from cloudfront |
| **---** | **22e. SOURCE: VERY SMALL IMAGE** |  |  |  |  |
| ❌ 502 | `w_800` | Upscale 10x10 to 800px — behavior? | application/json | 21 | Error from cloudfront |
| ❌ 502 | `w_10` | Downscale 10x10 to 10px — no-op | application/json | 21 | Error from cloudfront |
| ❌ 502 | `w_400,h_400` | Upscale small image with both dims | application/json | 21 | Error from cloudfront |
| **---** | **22f. SOURCE: VERY LARGE IMAGE** |  |  |  |  |
| ❌ 502 | `w_400` | Large source → 400px (memory test) | application/json | 21 | Error from cloudfront |
| ❌ 502 | `w_100,q_30` | Large source → tiny placeholder | application/json | 21 | Error from cloudfront |
| **---** | **23. CONTENT NEGOTIATION (Accept header)** |  |  |  |  |
| ✅ | `w_400,f_auto` | f_auto + Accept webp only [Accept: image/webp] | image/jpeg | 39919 | Hit from cloudfront |
| ✅ | `w_400,f_auto` | f_auto + Accept avif only [Accept: image/avif] | image/jpeg | 39919 | Hit from cloudfront |
| ✅ | `w_400,f_auto` | f_auto + Accept jpeg only [Accept: image/jpeg] | image/jpeg | 39919 | Hit from cloudfront |
| ✅ | `w_400,f_auto` | f_auto + Accept wildcard [Accept: */*] | image/jpeg | 39919 | Hit from cloudfront |
| ✅ | `w_400,f_auto` | f_auto + Accept text/html (non-image) [Accept: text/html] | image/jpeg | 39919 | Hit from cloudfront |
| ✅ | `w_400,f_auto` | f_auto + No preference [Accept: image/*] | image/jpeg | 39919 | Hit from cloudfront |
| ✅ | `w_400,f_auto` | f_auto + Prefer avif over webp [Accept: image/avif,image/webp;q=0.9,image/jpeg;q=0.8] | image/jpeg | 39919 | Hit from cloudfront |
| ✅ | `w_400,f_auto` | f_auto + Empty Accept [Accept: ] | image/jpeg | 39919 | Hit from cloudfront |
| ✅ | `w_400` | No f_auto + Accept webp (should NOT negotiate) [Accept: image/webp] | image/jpeg | 39919 | Hit from cloudfront |
| **---** | **24. RESPONSE HEADERS** |  |  |  |  |
| ✅ | `w_400` | Content-Length present? | content-length: 39919 | 39919 | image/jpeg |
| ✅ | `w_400` | X-Amz-Cf-Id (CloudFront request ID)? | x-amz-cf-id: Kd3xXk8obaVCqh3NsvUck79HgqD89uHy4wRmIoNJ6E-QLrQJrKRTnQ== | 39919 | image/jpeg |
| **---** | **25. CONDITIONAL REQUESTS** |  |  |  |  |
| ⚠️ 200 (expected 304) | `w_400` | If-None-Match with fake ETag | image/jpeg | 39919 | cond: If-None-Match: "fake-etag-12345" |
| ⚠️ 200 (expected 304) | `w_400` | If-Modified-Since far future | image/jpeg | 39919 | cond: If-Modified-Since: Thu, 01 Jan 2099 00:00:00 GMT |
| ⚠️ 200 (expected 304) | `w_400` | If-Modified-Since far past | image/jpeg | 39919 | cond: If-Modified-Since: Thu, 01 Jan 1970 00:00:00 GMT |
| **---** | **26. HTTP METHODS & RANGE** |  |  |  |  |
| ⏱️ TIMEOUT | `HEAD w_400` | HEAD request — headers only, no body | image/jpeg | 0 | Hit from cloudfront |
| ❌ 403 | `OPTIONS w_400` | OPTIONS request (CORS preflight) | text/html | 1053 | Error from cloudfront |
| ❌ 403 | `POST w_400` | POST request — should be rejected | text/html | 1053 | Error from cloudfront |
| ❌ 403 | `PUT w_400` | PUT request — should be rejected | text/html | 1053 | Error from cloudfront |
| ❌ 403 | `DELETE w_400` | DELETE request — should be rejected | text/html | 1053 | Error from cloudfront |
| ✅ 206 | `w_400` | Range: first 1KB | image/jpeg | 1024 | range: bytes 0-1023/39919 |
| ✅ 206 | `w_400` | Range: last 512 bytes | image/jpeg | 512 | range: bytes 39407-39918/39919 |
| ❌ 416 | `w_400` | Range: beyond content | text/html | 49 | range: bytes */39919 |
| **---** | **27. PARAM ORDERING (cache key)** |  |  |  |  |
| ✅ | `w_200,h_200,q_80` | Order: w,h,q | image/jpeg | 11473 | Miss from cloudfront |
| ✅ | `q_80,h_200,w_200` | Order: q,h,w (reversed) | image/jpeg | 11473 | Miss from cloudfront |
| ✅ | `h_200,w_200,q_80` | Order: h,w,q (mixed) | image/jpeg | 11473 | Miss from cloudfront |
| ✅ | `w_200,q_80,h_200` | Order: w,q,h (interleaved) | image/jpeg | 11473 | Miss from cloudfront |
| **---** | **28. SECURITY: SSRF PROTECTION** |  |  |  |  |
| ⚠️ 502 (blocked but wrong code) | `(raw url)` | AWS metadata endpoint (SSRF) | application/json | 21 | Error from cloudfront |
| ⚠️ 502 (blocked but wrong code) | `(raw url)` | AWS IAM credentials (SSRF) | application/json | 21 | Error from cloudfront |
| ⚠️ 502 (blocked but wrong code) | `(raw url)` | Localhost (SSRF) | application/json | 21 | Error from cloudfront |
| ⚠️ 502 (blocked but wrong code) | `(raw url)` | Localhost with port (SSRF) | application/json | 21 | Error from cloudfront |
| ⚠️ 502 (blocked but wrong code) | `(raw url)` | 0.0.0.0 (SSRF) | application/json | 21 | Error from cloudfront |
| ⚠️ 502 (blocked but wrong code) | `(raw url)` | Hex IP localhost (SSRF bypass) | application/json | 21 | Error from cloudfront |
| ⚠️ 502 (blocked but wrong code) | `(raw url)` | Decimal IP localhost (SSRF bypass) | application/json | 21 | Error from cloudfront |
| ⚠️ 502 (blocked but wrong code) | `(raw url)` | DNS rebinding (localtest.me → 127.0.0.1) | application/json | 21 | Error from cloudfront |
| ⚠️ 502 (blocked but wrong code) | `(raw url)` | file:// scheme (LFI) | application/json | 21 | Error from cloudfront |
| ⚠️ 502 (blocked but wrong code) | `(raw url)` | ftp:// scheme | application/json | 21 | Error from cloudfront |
| ⚠️ 502 (blocked but wrong code) | `(raw url)` | data: URI | application/json | 21 | Error from cloudfront |
| ⚠️ 502 (blocked but wrong code) | `(raw url)` | gopher:// scheme | application/json | 21 | Error from cloudfront |
| **---** | **28b. SECURITY: SOURCE URL ABUSE** |  |  |  |  |
| ⚠️ 502 (blocked but wrong code) | `(raw url)` | Non-existent source (404 handling) | application/json | 21 | Error from cloudfront |
| ⚠️ 502 (blocked but wrong code) | `(raw url)` | Source returns 500 | application/json | 21 | Error from cloudfront |
| ⚠️ 502 (blocked but wrong code) | `(raw url)` | Source returns 301 redirect | application/json | 21 | Error from cloudfront |
| ⚠️ 502 (blocked but wrong code) | `(raw url)` | Slow source (20s delay) | application/json | 21 | Error from cloudfront |
| ⚠️ 502 (blocked but wrong code) | `(raw url)` | Source is HTML, not image | application/json | 21 | Error from cloudfront |
| ⚠️ 502 (blocked but wrong code) | `(raw url)` | Path traversal in URL | application/json | 21 | Error from cloudfront |
| ✅ 400 (blocked) | `(raw url)` | Null byte in URL | text/html | 915 | Error from cloudfront |
| **---** | **29. EDGE CASES: PARAM PARSING** |  |  |  |  |
| ✅ | `w_200,w_400` | Duplicate param (w appears twice) | image/jpeg | 39919 | Hit from cloudfront |
| ✅ | `w_200,,h_200` | Empty param segment | image/jpeg | 12942 | Hit from cloudfront |
| ✅ | `,w_200` | Leading comma | image/jpeg | 12942 | Hit from cloudfront |
| ✅ | `w_200,` | Trailing comma | image/jpeg | 12942 | Hit from cloudfront |
| ✅ | `W_200` | Uppercase param key | image/jpeg | 190411 | Hit from cloudfront |
| ✅ | `w_200,unknown_foo` | Unknown param | image/jpeg | 12942 | Hit from cloudfront |
| ✅ | `w_200%2Ch_200` | URL-encoded comma | image/jpeg | 190411 | Hit from cloudfront |
| ✅ | `w_200;h_200` | Semicolon separator | image/jpeg | 190411 | Miss from cloudfront |
| ✅ | `w=200&h=200` | Query-string style params | image/jpeg | 190411 | Miss from cloudfront |
| ❌ 502 | `w_200/h_200` | Slash-separated params (Cloudinary-style) | application/json | 21 | Error from cloudfront |
| ✅ | `w_` | Key with empty value | image/jpeg | 190411 | Miss from cloudfront |
| ✅ | `_200` | Empty key with value | image/jpeg | 190411 | Miss from cloudfront |
| ❌ 502 | `` | Empty params (passthrough) | application/json | 21 | Error from cloudfront |
| ✅ | `,,,` | Only commas | image/jpeg | 190411 | Miss from cloudfront |
| ✅ | `w_200,h_200,q_80,f_webp,g_center,s_fill,b_5,dpr_2,rot_90,sh_3` | Kitchen sink — all params | image/webp | 1812 | Miss from cloudfront |
| **---** | **29b. EDGE CASES: URL ENCODING** |  |  |  |  |
| ❌ 502 | `w_200` | Source with spaces | application/json | 21 | Error from cloudfront |
| ❌ 502 | `w_200` | Source with unicode | application/json | 21 | Error from cloudfront |
| ✅ | `w_200` | Source with query params | image/jpeg | 12942 | Hit from cloudfront |
| ✅ | `w_200` | Source with fragment | image/jpeg | 12942 | Hit from cloudfront |
| ❌ 502 | `w_200` | Source double-encoded | application/json | 21 | Error from cloudfront |
| **---** | **30. REAL-WORLD COMBINATIONS** |  |  |  |  |
| ✅ | `w_800,h_600,g_center,q_80,f_webp` | Blog hero: 800x600, center, q80, webp | image/webp | 72562 | Hit from cloudfront |
| ✅ | `w_400,h_400,g_face,s_fill,q_85` | Avatar: 400x400, face detect, fill, q85 | image/jpeg | 39919 | Hit from cloudfront |
| ✅ | `w_1200,ar_16:9,g_center,q_90,f_avif` | Hero: 1200w, 16:9, center, q90, avif | image/avif | 129840 | Hit from cloudfront |
| ✅ | `w_100,h_100,b_10,q_30` | LQIP placeholder: 100x100, blurred, low q | image/jpeg | 1087 | Hit from cloudfront |
| ✅ | `w_200,q_75,f_webp` | Thumbnail: 200w, q75, webp | image/webp | 7474 | Hit from cloudfront |
| ✅ | `w_1920,h_1080,s_fit,f_auto,q_85` | Full HD fit | image/jpeg | 219234 | Hit from cloudfront |
| ✅ | `w_40,h_40,q_20,b_20,f_webp` | BlurHash-style micro placeholder | image/webp | 66 | Miss from cloudfront |
| ✅ | `w_1200,h_630,g_center,s_fill,q_85,f_jpeg` | Open Graph image (1200x630) | image/jpeg | 85156 | Miss from cloudfront |
| ✅ | `w_192,h_192,s_fill,g_center,f_png` | PWA icon (192x192) | image/png | 41143 | Miss from cloudfront |
| ✅ | `w_32,h_32,s_fill,g_center,f_png` | Favicon (32x32) | image/png | 1182 | Miss from cloudfront |
| ✅ | `w_400,h_300,s_pad,bg_ffffff,q_85,f_webp` | E-commerce product (padded white bg) | image/webp | 18372 | Miss from cloudfront |
| ✅ | `w_2560,q_85,f_avif` | Retina hero (2560w, avif) | image/avif | 122933 | Miss from cloudfront |
| ✅ | `w_300,ar_1:1,g_face,s_fill,q_80,f_webp` | Social avatar (square face crop) | image/webp | 15988 | Miss from cloudfront |
| ✅ | `w_800,h_450,g_auto,s_fill,q_80,f_webp,sh_2` | Card image (auto crop + sharpen) | image/webp | 28932 | Miss from cloudfront |
| **---** | **31. CACHE STAMPEDE (concurrent identical)** |  |  |  |  |
| ✅ | `w_317,h_179,q_73` | Stampede request #1 | image/jpeg | 8511 | Hit from cloudfront |
| ✅ | `w_317,h_179,q_73` | Stampede request #2 | image/jpeg | 8511 | Hit from cloudfront |
| ✅ | `w_317,h_179,q_73` | Stampede request #3 | image/jpeg | 8511 | Miss from cloudfront |
| ✅ | `w_317,h_179,q_73` | Stampede request #4 | image/jpeg | 8511 | Hit from cloudfront |
| ✅ | `w_317,h_179,q_73` | Stampede request #5 | image/jpeg | 8511 | Hit from cloudfront |

## Summary

- **Pass:** 230
- **Fail:** 30
- **Warnings:** 21
- **Total:** 281

## Suggestions for Improvement

### Input Validation
- [ ] Reject or clamp width/height to a max (e.g., 4096px) to prevent DoS
- [ ] Return 400 for zero, negative, or non-numeric dimension values
- [ ] Validate aspect ratio format (must be `N:M` with positive integers)
- [ ] Clamp quality to 1-100 range, reject values outside
- [ ] Validate gravity against an enum of known values
- [ ] Validate strategy against an enum of known values
- [ ] Reject or ignore unknown parameter keys with a warning header
- [ ] Handle duplicate parameter keys deterministically (last wins, or error)
- [ ] Reject extreme dimensions that could cause OOM (e.g., w_999999)

### Performance
- [ ] Return `Cache-Control` headers with long max-age for immutable transforms
- [ ] Support `If-None-Match` / `ETag` for conditional requests (304)
- [ ] Consider a max file size for source images to prevent OOM
- [ ] Add `Vary: Accept` header when using format auto-negotiation
- [ ] Return `Content-Length` on all responses for progressive rendering
- [ ] Enable CloudFront origin shield to prevent cache stampede
- [ ] Normalize param order for cache key (w,h,q → same key regardless of input order)
- [ ] Support Range requests (206 Partial Content) for large images

### Format & Quality
- [ ] Default to `f_auto` (content negotiation via Accept header) when no format specified
- [ ] Support AVIF as a first-class format (best compression for photos)
- [ ] Consider stripping EXIF metadata by default (privacy + smaller files)
- [ ] Implement progressive JPEG for large images
- [ ] Support JPEG XL (f_jxl) as next-gen format
- [ ] Handle animated GIF/WebP: preserve animation on resize or extract first frame
- [ ] Handle PNG transparency → JPEG: composite onto white/configurable background

### New Transform Features
- [ ] DPR (Device Pixel Ratio): `dpr_2` multiplies dimensions for retina
- [ ] Rotation: `rot_90`, `rot_180`, `rot_270`, `rot_auto` (EXIF-based)
- [ ] Flip/Mirror: `flip_h`, `flip_v`
- [ ] Sharpen: `sh_5` (post-resize sharpening is critical for quality)
- [ ] Background color: `bg_ffffff` (for pad strategy letterboxing)
- [ ] Border: `border_2_000000` (width + color)
- [ ] Round corners: `r_10`, `r_max` (circle crop)
- [ ] Trim: auto-crop whitespace/borders from product images
- [ ] Metadata strip: `strip_true` (remove EXIF, IPTC, XMP)
- [ ] Progressive: `progressive_true` for progressive JPEG
- [ ] Adaptive quality: `q_auto` (vary quality based on image complexity)

### Error Handling
- [ ] Return structured error responses (JSON with error code + message)
- [ ] Use appropriate HTTP status codes: 400 (bad params), 404 (source not found), 422 (unsupported format)
- [ ] Include `X-Transform-Error` header with machine-readable error codes
- [ ] Differentiate between 'source not found' and 'transform failed'
- [ ] Return 400 (not 502) for invalid params — 502 suggests infrastructure failure
- [ ] Handle source server errors gracefully (source returns 500)
- [ ] Timeout handling: return 504 if source fetch exceeds limit

### Security
- [ ] Whitelist allowed source domains (prevent SSRF via arbitrary URLs)
- [ ] Block private IP ranges: 10.x, 172.16-31.x, 192.168.x, 127.x, 169.254.x
- [ ] Block IPv6 loopback (::1) and link-local addresses
- [ ] Block hex/decimal/octal IP encoding tricks (0x7f000001, 2130706433)
- [ ] Block non-HTTP schemes: file://, ftp://, gopher://, data:
- [ ] Block DNS rebinding (resolve DNS and check IP before fetching)
- [ ] Rate-limit unique transform combinations per IP
- [ ] Set `Content-Security-Policy` headers on responses
- [ ] Set `X-Content-Type-Options: nosniff`
- [ ] Set `Strict-Transport-Security` header
- [ ] Validate source URL scheme (only allow https://)
- [ ] Prevent path traversal in source URLs
- [ ] Reject null bytes in URLs
- [ ] Reject POST/PUT/DELETE methods (GET and HEAD only)

### Response Headers
- [ ] `Cache-Control: public, max-age=31536000, immutable` for transformed images
- [ ] `ETag` for conditional request support
- [ ] `Vary: Accept` when format auto-negotiation is used
- [ ] `Content-Length` on all responses
- [ ] `Access-Control-Allow-Origin: *` for cross-origin image usage
- [ ] `X-Content-Type-Options: nosniff`
- [ ] `X-Transform-Duration` (debug: how long the transform took)
- [ ] `X-Original-Size` / `X-Transformed-Size` (debug: compression ratio)

### DX Improvements
- [ ] Add a `_debug` or `_info` param that returns transform metadata as JSON
- [ ] Document supported profiles (p_thumbnail, p_hero, etc.) and their presets
- [ ] Support named presets via config (e.g., `p_card` = w_400,h_300,g_center,f_auto,q_80)
- [ ] Add an `_original` passthrough param that returns original with only format conversion
- [ ] Support chained transforms (e.g., resize then blur) with explicit ordering
- [ ] Support Cloudinary-style slash-separated params: `/w_400/h_300/`
- [ ] Provide responsive image helpers: `srcset` generation endpoint
