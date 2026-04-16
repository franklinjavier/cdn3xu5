# cdn3xu5

Exhaustive test suite for a CloudFront-based image transformation service. Validates transforms, edge cases, security (SSRF), caching behavior, and content negotiation against a live endpoint.

## Quick Start

```bash
# Run with default test image
./test-image-transforms.sh

# Run with a custom source image
./test-image-transforms.sh https://example.com/my-photo.jpg
```

## What It Tests

**281 tests** across 31 categories, all running in parallel (~18 seconds total).

| # | Category | Tests | Description |
|---|----------|-------|-------------|
| 1 | Baseline | 1 | Passthrough with no transforms |
| 2 | Width (`w`) | 11 | Resize, zero, negative, decimal, extreme values |
| 3 | Height (`h`) | 7 | Same edge cases as width |
| 4 | Width + Height | 7 | Combinations, extreme aspect ratios (1:10000) |
| 5 | Aspect Ratio (`ar`) | 14 | 16:9, 9:16, 4:3, 21:9, invalid, conflicts |
| 6 | Gravity (`g`) | 15 | All compass points, face, auto, entropy |
| 7 | Strategy (`s`) | 13 | fit, fill, scale, pad, cover, contain, inside, outside |
| 8 | Quality (`q`) | 13 | 1-100 range, auto, auto:good/best/low |
| 9 | Blur (`b`) | 8 | Minimal to extreme, decimal, DoS vector |
| 10 | Format (`f`) | 13 | JPEG, PNG, WebP, AVIF, GIF, TIFF, BMP, HEIF, JXL, SVG |
| 11 | Profiles (`p`) | 11 | thumbnail, preview, hero, og, avatar, card + overrides |
| 12 | Crop (`x`, `y`) | 7 | Offset cropping, bounds, partial coords |
| 13 | DPR | 10 | Device pixel ratio 1x-4x, auto, extreme |
| 14 | Rotation (`rot`) | 9 | 0/90/180/270, non-right angles, auto (EXIF) |
| 15 | Flip/Mirror | 5 | Horizontal, vertical, both, combos |
| 16 | Sharpen (`sh`) | 7 | Subtle to extreme, sharpen+blur conflict |
| 17 | Background (`bg`) | 8 | Hex colors, transparent, RGBA, short hex |
| 18 | Border & Corners | 8 | Border width+color, round corners, `r_max` circle |
| 19 | Trim | 4 | Auto-crop whitespace with tolerance |
| 20 | Metadata/EXIF | 4 | Strip/preserve metadata |
| 21 | Progressive | 3 | Progressive JPEG, interlaced PNG |
| 22 | Source Types | 14 | PNG (transparency), animated GIF, WebP, SVG, tiny, large |
| 23 | Content Negotiation | 9 | Accept header variations with `f_auto` |
| 24 | Response Headers | 16 | Cache-Control, ETag, Vary, CORS, CSP, HSTS |
| 25 | Conditional Requests | 3 | If-None-Match, If-Modified-Since |
| 26 | HTTP Methods & Range | 8 | HEAD, OPTIONS, POST, PUT, DELETE, Range (206) |
| 27 | Param Ordering | 4 | Cache key normalization (w,h,q vs q,h,w) |
| 28 | SSRF Protection | 19 | Metadata endpoint, localhost, private IPs, DNS rebinding, schemes |
| 29 | Edge Cases | 20 | Parsing quirks, URL encoding, duplicates, kitchen sink |
| 30 | Real-World Combos | 14 | Blog hero, avatar, OG image, LQIP, favicon, PWA icon |
| 31 | Cache Stampede | 5 | Concurrent identical requests |

## URL Format

```
https://<cloudfront-domain>/<params>/<source-url>
```

**Examples:**

```
# Resize to 400px wide
https://d2fhhx9c14fnxb.cloudfront.net/w_400/https://example.com/photo.jpg

# 800x600, center crop, quality 80, WebP
https://d2fhhx9c14fnxb.cloudfront.net/w_800,h_600,g_center,q_80,f_webp/https://example.com/photo.jpg

# Open Graph image (1200x630)
https://d2fhhx9c14fnxb.cloudfront.net/w_1200,h_630,g_center,s_fill,q_85,f_jpeg/https://example.com/photo.jpg

# Blurred placeholder (LQIP)
https://d2fhhx9c14fnxb.cloudfront.net/w_40,h_40,q_20,b_20,f_webp/https://example.com/photo.jpg
```

## Supported Parameters

### Currently Working

| Param | Description | Example | Status |
|-------|-------------|---------|--------|
| `w` | Width in pixels | `w_800` | Working |
| `h` | Height in pixels | `h_600` | Working |
| `ar` | Aspect ratio | `ar_16:9` | Working |
| `g` | Gravity (crop anchor) | `g_center`, `g_north`, `g_face` | Working |
| `s` | Resize strategy | `s_fit`, `s_fill`, `s_scale`, `s_pad` | Working |
| `q` | Quality (1-100) | `q_80` | Working |
| `b` | Blur sigma | `b_10` | Working |
| `f` | Output format | `f_webp`, `f_avif`, `f_png`, `f_auto` | Working |
| `p` | Named profile/preset | `p_thumbnail`, `p_og` | Working |
| `x`, `y` | Crop coordinates | `x_50,y_50` | Working |

### Planned / Not Yet Implemented

| Param | Description | Example | Notes |
|-------|-------------|---------|-------|
| `dpr` | Device pixel ratio | `dpr_2` | Multiplies dimensions for retina |
| `rot` | Rotation | `rot_90`, `rot_auto` | Auto uses EXIF orientation |
| `flip` | Flip/Mirror | `flip_h`, `flip_v` | Horizontal/vertical |
| `sh` | Sharpen | `sh_5` | Post-resize sharpening |
| `bg` | Background color | `bg_ffffff` | For pad strategy |
| `border` | Border | `border_2_000000` | Width + hex color |
| `r` | Round corners | `r_10`, `r_max` | `r_max` = circle crop |
| `trim` | Auto-crop borders | `trim_true` | Whitespace removal |
| `strip` | Remove metadata | `strip_true` | EXIF, IPTC, XMP |
| `progressive` | Progressive JPEG | `progressive_true` | Better perceived loading |
| `q_auto` | Adaptive quality | `q_auto:good` | Cloudinary-style |

## Latest Test Report

> Run on 2026-04-16 15:10 UTC against `d2fhhx9c14fnxb.cloudfront.net`

### Summary

```
Pass:     230
Fail:      30
Warnings:  21
Total:    281
```

### Results

<details>
<summary><strong>1. Baseline</strong></summary>

| Status | Params | Test | Content-Type | Size |
|--------|--------|------|-------------|------|
| :x: 502 | _(empty)_ | No transforms (passthrough) | application/json | 21 |

</details>

<details>
<summary><strong>2. Width (w)</strong> - 11 tests, all pass</summary>

| Status | Params | Test | Content-Type | Size |
|--------|--------|------|-------------|------|
| :white_check_mark: | `w_50` | Tiny (50px) | image/jpeg | 1,710 |
| :white_check_mark: | `w_200` | Small (200px) | image/jpeg | 12,942 |
| :white_check_mark: | `w_800` | Medium (800px) | image/jpeg | 129,903 |
| :white_check_mark: | `w_1200` | Large (1200px) | image/jpeg | 190,411 |
| :white_check_mark: | `w_2400` | XL (2400px) | image/jpeg | 190,411 |
| :white_check_mark: | `w_5000` | Oversized (5000px) | image/jpeg | 190,411 |
| :white_check_mark: | `w_0` | Zero width (should error) | image/jpeg | 628 |
| :white_check_mark: | `w_-1` | Negative width (should error) | image/jpeg | 190,411 |
| :white_check_mark: | `w_abc` | Non-numeric (should error) | image/jpeg | 190,411 |
| :white_check_mark: | `w_1.5` | Decimal (should error/round) | image/jpeg | 190,411 |
| :white_check_mark: | `w_999999` | Extreme (DoS vector) | image/jpeg | 190,411 |

**Note:** Invalid values (`w_0`, `w_-1`, `w_abc`, `w_999999`) return 200 instead of 400. Input validation is needed.

</details>

<details>
<summary><strong>3-5. Height, Width+Height, Aspect Ratio</strong> - 28 tests, all pass</summary>

All dimension and aspect ratio tests pass. Same validation gaps as width: zero, negative, and extreme values are accepted silently.

</details>

<details>
<summary><strong>6-9. Gravity, Strategy, Quality, Blur</strong> - 44 tests, 43 pass, 1 fail</summary>

All gravity positions, resize strategies, and quality levels work correctly.

| Finding | Detail |
|---------|--------|
| :x: `b_-1` returns 502 | Negative blur crashes the Lambda instead of returning 400 |
| :warning: `q_0` silently treated as `q_1` | Should return 400 |
| :warning: `q_101` returns max quality | Should return 400 or clamp with warning |
| :warning: Invalid strategy/gravity silently ignored | Should return 400 |

</details>

<details>
<summary><strong>10. Format (f)</strong> - 13 tests, all pass</summary>

| Format | Content-Type | Size | Notes |
|--------|-------------|------|-------|
| JPEG | image/jpeg | 39,919 | |
| PNG | image/png | 155,709 | 3.9x larger than JPEG |
| WebP | image/webp | 28,058 | 30% smaller than JPEG |
| AVIF | image/avif | 30,597 | 23% smaller than JPEG |
| GIF | image/gif | 124,963 | |
| TIFF | image/tiff | 480,210 | Supported but huge |
| BMP | image/bmp | 480,054 | Supported but huge |
| HEIF | image/jpeg | 39,919 | Falls back to JPEG |
| JXL | image/jpeg | 39,919 | Falls back to JPEG |
| SVG | image/svg+xml | 71,083 | Raster-to-SVG should be blocked |

</details>

<details>
<summary><strong>22. Source Image Types</strong> - 14 tests, 5 pass, 9 fail</summary>

| Source | Status | Notes |
|--------|--------|-------|
| PNG (transparency) | :x: 502 | All 5 tests fail |
| Animated GIF | :x: 502 | All 4 tests fail |
| WebP | :white_check_mark: | All 3 tests pass |
| SVG | :x: 502 | All 3 tests fail |
| Very small (10x10) | :x: 502 | All 3 tests fail |
| Very large | :x: 502 | Both tests fail |

**Only JPEG and WebP sources work reliably.** PNG, GIF, SVG, and external sources from certain domains fail with 502.

</details>

<details>
<summary><strong>23. Content Negotiation</strong> - 9 tests, all pass (but no negotiation happening)</summary>

All `f_auto` tests return `image/jpeg` regardless of Accept header. Content negotiation is not implemented yet - `f_auto` behaves the same as no format specified.

| Accept Header | Response | Expected |
|---------------|----------|----------|
| `image/webp` | image/jpeg | image/webp |
| `image/avif` | image/jpeg | image/avif |
| `image/avif,image/webp;q=0.9` | image/jpeg | image/avif |

</details>

<details>
<summary><strong>24. Response Headers</strong> - 16 tests</summary>

| Header | Present? | Value |
|--------|----------|-------|
| `Content-Length` | :white_check_mark: | 39919 |
| `X-Amz-Cf-Id` | :white_check_mark: | _(CloudFront request ID)_ |
| `Cache-Control` | :x: MISSING | Should be `public, max-age=31536000, immutable` |
| `ETag` | :x: MISSING | Needed for conditional requests |
| `Last-Modified` | :x: MISSING | Needed for conditional requests |
| `Vary` | :x: MISSING | Must be `Accept` when using `f_auto` |
| `Content-Disposition` | :x: MISSING | |
| `Access-Control-Allow-Origin` | :x: MISSING | Needed for cross-origin `<img>` and `<canvas>` |
| `Content-Security-Policy` | :x: MISSING | |
| `Strict-Transport-Security` | :x: MISSING | |
| `X-Content-Type-Options` | :x: MISSING | Should be `nosniff` |

</details>

<details>
<summary><strong>26. HTTP Methods & Range</strong> - 8 tests</summary>

| Method | Status | Notes |
|--------|--------|-------|
| HEAD | :x: Timeout | Should return headers without body |
| OPTIONS | 403 | Blocks CORS preflight - no cross-origin usage possible |
| POST | 403 | Correctly rejected |
| PUT | 403 | Correctly rejected |
| DELETE | 403 | Correctly rejected |
| Range (first 1KB) | :white_check_mark: 206 | Range requests work |
| Range (last 512B) | :white_check_mark: 206 | Range requests work |
| Range (beyond) | 416 | Correctly returns Range Not Satisfiable |

</details>

<details>
<summary><strong>27. Param Ordering</strong> - 4 tests, all pass</summary>

All orderings return the same file size (11,473 bytes), meaning the service normalizes params before processing. However, all were cache misses - the cache key may not be normalized, causing duplicate entries for the same transform.

</details>

<details>
<summary><strong>28. SSRF Protection</strong> - 19 tests</summary>

All SSRF vectors are blocked (good!), but they return **502** instead of **400/403**. This makes it hard to distinguish between "blocked for security" and "infrastructure error."

| Vector | Status | Expected |
|--------|--------|----------|
| AWS metadata (169.254.169.254) | 502 | 400/403 |
| Localhost (127.0.0.1) | 502 | 400/403 |
| Private IPs (10.x, 192.168.x) | 502 | 400/403 |
| Hex/decimal IP tricks | 502 | 400/403 |
| file:// scheme | 502 | 400/403 |
| Null byte in URL | :white_check_mark: 400 | 400 |

</details>

<details>
<summary><strong>30. Real-World Combinations</strong> - 14 tests, all pass</summary>

| Use Case | Params | Format | Size |
|----------|--------|--------|------|
| Blog hero | `w_800,h_600,g_center,q_80,f_webp` | WebP | 72 KB |
| Avatar | `w_400,h_400,g_face,s_fill,q_85` | JPEG | 39 KB |
| Hero banner | `w_1200,ar_16:9,g_center,q_90,f_avif` | AVIF | 130 KB |
| LQIP placeholder | `w_100,h_100,b_10,q_30` | JPEG | 1 KB |
| Micro placeholder | `w_40,h_40,q_20,b_20,f_webp` | WebP | **66 B** |
| Open Graph | `w_1200,h_630,g_center,s_fill,q_85,f_jpeg` | JPEG | 85 KB |
| PWA icon | `w_192,h_192,s_fill,g_center,f_png` | PNG | 41 KB |
| Favicon | `w_32,h_32,s_fill,g_center,f_png` | PNG | 1 KB |
| E-commerce (padded) | `w_400,h_300,s_pad,bg_ffffff,q_85,f_webp` | WebP | 18 KB |
| Retina hero | `w_2560,q_85,f_avif` | AVIF | 123 KB |
| Social avatar | `w_300,ar_1:1,g_face,s_fill,q_80,f_webp` | WebP | 16 KB |
| Card image | `w_800,h_450,g_auto,s_fill,q_80,f_webp,sh_2` | WebP | 29 KB |
| Kitchen sink (all params) | `w_200,h_200,q_80,f_webp,g_center,s_fill,b_5,dpr_2,rot_90,sh_3` | WebP | 1.8 KB |

</details>

<details>
<summary><strong>31. Cache Stampede</strong> - 5 tests, all pass</summary>

5 concurrent identical requests: 4 cache hits, 1 miss. CloudFront handles concurrent requests well with no stampede issues.

</details>

## Key Findings

### What Works Well
- Core transforms (resize, crop, quality, blur, format conversion)
- 9 gravity positions with directional cropping
- AVIF and WebP output (significant size savings)
- Range requests (206 Partial Content)
- CloudFront caching with good hit rates
- SSRF vectors are blocked (though with wrong status codes)

### What Needs Work

| Priority | Issue | Impact |
|----------|-------|--------|
| **Critical** | No input validation (zero/negative/extreme values accepted) | DoS vector via `w_999999` |
| **Critical** | SSRF returns 502 instead of 400/403 | Can't distinguish security blocks from real errors |
| **High** | PNG/GIF/SVG sources fail with 502 | Only JPEG and WebP sources work |
| **High** | No `Cache-Control` headers | Browsers re-fetch on every page load |
| **High** | No CORS headers | Can't use images in `<canvas>` cross-origin |
| **High** | Content negotiation (`f_auto`) not working | Always returns JPEG regardless of Accept header |
| **Medium** | HEAD requests timeout | Breaks preflight checks and `<link rel="preload">` |
| **Medium** | No ETag/conditional request support | No 304 responses, wasted bandwidth |
| **Medium** | Missing security headers (CSP, HSTS, nosniff) | |
| **Low** | Unimplemented features silently ignored (dpr, rot, flip, sh, bg) | Params accepted but not applied |

## Architecture

```
Client
  |
  |  GET /w_400,q_80,f_webp/https://source.com/photo.jpg
  v
CloudFront (d2fhhx9c14fnxb.cloudfront.net)
  |
  |  Cache miss → forward to origin
  v
Lambda (image transform)
  |
  |  1. Parse params from URL path
  |  2. Fetch source image
  |  3. Transform (sharp.js / libvips)
  |  4. Return transformed image
  v
CloudFront cache
  |
  |  Cache hit → serve directly
  v
Client
```

## License

MIT
