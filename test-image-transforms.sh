#!/usr/bin/env bash
#
# test-image-transforms.sh — Exhaustive test suite for the CloudFront image transformation service.
#
# Usage:
#   ./test-image-transforms.sh [source_url]
#
# Defaults to a known test image if no URL is provided.
# Outputs a markdown-formatted report with status, response headers, and suggestions.

set -euo pipefail

BASE="https://d2fhhx9c14fnxb.cloudfront.net"
SOURCE="${1:-https://www.theminimalistdeveloper.com/take-control-of-your-learning-journey/man-hooked-up-to-machines.jpg}"

# Alternative source images for multi-format testing
SOURCE_PNG="https://upload.wikimedia.org/wikipedia/commons/4/47/PNG_transparency_demonstration_1.png"
SOURCE_GIF_ANIM="https://upload.wikimedia.org/wikipedia/commons/2/2c/Rotating_earth_%28large%29.gif"
SOURCE_WEBP="https://www.gstatic.com/webp/gallery/1.webp"
SOURCE_SVG="https://upload.wikimedia.org/wikipedia/commons/0/02/SVG_logo.svg"
SOURCE_SMALL="https://via.placeholder.com/10x10.png"
SOURCE_LARGE="https://upload.wikimedia.org/wikipedia/commons/3/3f/Fronalpstock_big.jpg"

# ─── Helpers ──────────────────────────────────────────────────────────────────

TMPDIR_RESULTS=$(mktemp -d)
TEST_INDEX=0

# Standard fetch: uses default Accept header and the main SOURCE
fetch() {
  local params="$1"
  local label="$2"
  local src="${3:-$SOURCE}"
  local url="${BASE}/${params}/${src}"
  local idx=$TEST_INDEX
  ((TEST_INDEX++))

  (
    local tmp headers_tmp
    tmp=$(mktemp)
    headers_tmp=$(mktemp)

    local http_code
    http_code=$(curl -s -o "$tmp" -D "$headers_tmp" -w "%{http_code}" \
      -H "Accept: image/avif,image/webp,image/apng,image/*,*/*;q=0.8" \
      --max-time 15 \
      "$url" 2>/dev/null) || http_code="000"

    local content_type cache_status
    content_type=$(grep -i "^content-type:" "$headers_tmp" 2>/dev/null | head -1 | awk '{print $2}' | tr -d '\r')
    cache_status=$(grep -i "^x-cache:" "$headers_tmp" 2>/dev/null | head -1 | sed 's/^[^:]*: //' | tr -d '\r')

    local file_size
    file_size=$(wc -c < "$tmp" | tr -d ' ')
    rm -f "$tmp" "$headers_tmp"

    local status_icon status_type
    if [[ "$http_code" == "200" ]]; then
      status_icon="✅"
      status_type="PASS"
    elif [[ "$http_code" == "000" ]]; then
      status_icon="⏱️ TIMEOUT"
      status_type="FAIL"
    else
      status_icon="❌ $http_code"
      status_type="FAIL"
    fi

    echo "${status_type}|${status_icon}|\`${params}\`|${label}|${content_type:-?}|${file_size:-?}|${cache_status:-?}" \
      > "$TMPDIR_RESULTS/$idx"
  ) &
}

# Fetch with custom Accept header (for content negotiation tests)
fetch_accept() {
  local params="$1"
  local label="$2"
  local accept_header="$3"
  local src="${4:-$SOURCE}"
  local url="${BASE}/${params}/${src}"
  local idx=$TEST_INDEX
  ((TEST_INDEX++))

  (
    local tmp headers_tmp
    tmp=$(mktemp)
    headers_tmp=$(mktemp)

    local http_code
    http_code=$(curl -s -o "$tmp" -D "$headers_tmp" -w "%{http_code}" \
      -H "Accept: ${accept_header}" \
      --max-time 15 \
      "$url" 2>/dev/null) || http_code="000"

    local content_type cache_status
    content_type=$(grep -i "^content-type:" "$headers_tmp" 2>/dev/null | head -1 | awk '{print $2}' | tr -d '\r')
    cache_status=$(grep -i "^x-cache:" "$headers_tmp" 2>/dev/null | head -1 | sed 's/^[^:]*: //' | tr -d '\r')

    local file_size
    file_size=$(wc -c < "$tmp" | tr -d ' ')
    rm -f "$tmp" "$headers_tmp"

    local status_icon status_type
    if [[ "$http_code" == "200" ]]; then
      status_icon="✅"
      status_type="PASS"
    elif [[ "$http_code" == "000" ]]; then
      status_icon="⏱️ TIMEOUT"
      status_type="FAIL"
    else
      status_icon="❌ $http_code"
      status_type="FAIL"
    fi

    echo "${status_type}|${status_icon}|\`${params}\`|${label} [Accept: ${accept_header}]|${content_type:-?}|${file_size:-?}|${cache_status:-?}" \
      > "$TMPDIR_RESULTS/$idx"
  ) &
}

# Fetch with full header inspection (for header validation tests)
fetch_headers() {
  local params="$1"
  local label="$2"
  local header_check="$3"  # header name to inspect
  local src="${4:-$SOURCE}"
  local url="${BASE}/${params}/${src}"
  local idx=$TEST_INDEX
  ((TEST_INDEX++))

  (
    local tmp headers_tmp
    tmp=$(mktemp)
    headers_tmp=$(mktemp)

    local http_code
    http_code=$(curl -s -o "$tmp" -D "$headers_tmp" -w "%{http_code}" \
      -H "Accept: image/avif,image/webp,image/apng,image/*,*/*;q=0.8" \
      --max-time 15 \
      "$url" 2>/dev/null) || http_code="000"

    local header_value
    header_value=$(grep -i "^${header_check}:" "$headers_tmp" 2>/dev/null | head -1 | sed "s/^[^:]*: //" | tr -d '\r')

    local content_type
    content_type=$(grep -i "^content-type:" "$headers_tmp" 2>/dev/null | head -1 | awk '{print $2}' | tr -d '\r')

    local file_size
    file_size=$(wc -c < "$tmp" | tr -d ' ')
    rm -f "$tmp" "$headers_tmp"

    local status_icon status_type
    if [[ "$http_code" == "200" ]]; then
      status_icon="✅"
      status_type="PASS"
    elif [[ "$http_code" == "000" ]]; then
      status_icon="⏱️ TIMEOUT"
      status_type="FAIL"
    else
      status_icon="❌ $http_code"
      status_type="FAIL"
    fi

    echo "${status_type}|${status_icon}|\`${params}\`|${label}|${header_check}: ${header_value:-MISSING}|${file_size:-?}|${content_type:-?}" \
      > "$TMPDIR_RESULTS/$idx"
  ) &
}

# Fetch with custom HTTP method
fetch_method() {
  local method="$1"
  local params="$2"
  local label="$3"
  local src="${4:-$SOURCE}"
  local url="${BASE}/${params}/${src}"
  local idx=$TEST_INDEX
  ((TEST_INDEX++))

  (
    local tmp headers_tmp
    tmp=$(mktemp)
    headers_tmp=$(mktemp)

    local http_code
    http_code=$(curl -s -o "$tmp" -D "$headers_tmp" -w "%{http_code}" \
      -X "$method" \
      -H "Accept: image/avif,image/webp,image/apng,image/*,*/*;q=0.8" \
      --max-time 15 \
      "$url" 2>/dev/null) || http_code="000"

    local content_type cache_status
    content_type=$(grep -i "^content-type:" "$headers_tmp" 2>/dev/null | head -1 | awk '{print $2}' | tr -d '\r')
    cache_status=$(grep -i "^x-cache:" "$headers_tmp" 2>/dev/null | head -1 | sed 's/^[^:]*: //' | tr -d '\r')

    local file_size
    file_size=$(wc -c < "$tmp" | tr -d ' ')
    rm -f "$tmp" "$headers_tmp"

    local status_icon status_type
    if [[ "$http_code" == "200" || "$http_code" == "304" || "$http_code" == "206" ]]; then
      status_icon="✅ $http_code"
      status_type="PASS"
    elif [[ "$http_code" == "000" ]]; then
      status_icon="⏱️ TIMEOUT"
      status_type="FAIL"
    else
      status_icon="❌ $http_code"
      status_type="FAIL"
    fi

    echo "${status_type}|${status_icon}|\`${method} ${params}\`|${label}|${content_type:-?}|${file_size:-?}|${cache_status:-?}" \
      > "$TMPDIR_RESULTS/$idx"
  ) &
}

# Fetch with conditional request (If-None-Match / If-Modified-Since)
fetch_conditional() {
  local params="$1"
  local label="$2"
  local cond_header="$3"  # e.g. 'If-None-Match: "abc"'
  local src="${4:-$SOURCE}"
  local url="${BASE}/${params}/${src}"
  local idx=$TEST_INDEX
  ((TEST_INDEX++))

  (
    local tmp headers_tmp
    tmp=$(mktemp)
    headers_tmp=$(mktemp)

    local http_code
    http_code=$(curl -s -o "$tmp" -D "$headers_tmp" -w "%{http_code}" \
      -H "Accept: image/avif,image/webp,image/apng,image/*,*/*;q=0.8" \
      -H "${cond_header}" \
      --max-time 15 \
      "$url" 2>/dev/null) || http_code="000"

    local content_type
    content_type=$(grep -i "^content-type:" "$headers_tmp" 2>/dev/null | head -1 | awk '{print $2}' | tr -d '\r')

    local file_size
    file_size=$(wc -c < "$tmp" | tr -d ' ')
    rm -f "$tmp" "$headers_tmp"

    local status_icon status_type
    if [[ "$http_code" == "304" ]]; then
      status_icon="✅ 304"
      status_type="PASS"
    elif [[ "$http_code" == "200" ]]; then
      status_icon="⚠️ 200 (expected 304)"
      status_type="WARN"
    elif [[ "$http_code" == "000" ]]; then
      status_icon="⏱️ TIMEOUT"
      status_type="FAIL"
    else
      status_icon="❌ $http_code"
      status_type="FAIL"
    fi

    echo "${status_type}|${status_icon}|\`${params}\`|${label}|${content_type:-?}|${file_size:-?}|cond: ${cond_header}" \
      > "$TMPDIR_RESULTS/$idx"
  ) &
}

# Fetch with Range header
fetch_range() {
  local params="$1"
  local label="$2"
  local range="$3"
  local src="${4:-$SOURCE}"
  local url="${BASE}/${params}/${src}"
  local idx=$TEST_INDEX
  ((TEST_INDEX++))

  (
    local tmp headers_tmp
    tmp=$(mktemp)
    headers_tmp=$(mktemp)

    local http_code
    http_code=$(curl -s -o "$tmp" -D "$headers_tmp" -w "%{http_code}" \
      -H "Accept: image/avif,image/webp,image/apng,image/*,*/*;q=0.8" \
      -H "Range: bytes=${range}" \
      --max-time 15 \
      "$url" 2>/dev/null) || http_code="000"

    local content_type content_range
    content_type=$(grep -i "^content-type:" "$headers_tmp" 2>/dev/null | head -1 | awk '{print $2}' | tr -d '\r')
    content_range=$(grep -i "^content-range:" "$headers_tmp" 2>/dev/null | head -1 | sed 's/^[^:]*: //' | tr -d '\r')

    local file_size
    file_size=$(wc -c < "$tmp" | tr -d ' ')
    rm -f "$tmp" "$headers_tmp"

    local status_icon status_type
    if [[ "$http_code" == "206" ]]; then
      status_icon="✅ 206"
      status_type="PASS"
    elif [[ "$http_code" == "200" ]]; then
      status_icon="⚠️ 200 (no range support)"
      status_type="WARN"
    elif [[ "$http_code" == "000" ]]; then
      status_icon="⏱️ TIMEOUT"
      status_type="FAIL"
    else
      status_icon="❌ $http_code"
      status_type="FAIL"
    fi

    echo "${status_type}|${status_icon}|\`${params}\`|${label}|${content_type:-?}|${file_size:-?}|range: ${content_range:-none}" \
      > "$TMPDIR_RESULTS/$idx"
  ) &
}

# Fetch a raw URL (for SSRF tests where we construct the full URL ourselves)
fetch_raw() {
  local url="$1"
  local label="$2"
  local idx=$TEST_INDEX
  ((TEST_INDEX++))

  (
    local tmp headers_tmp
    tmp=$(mktemp)
    headers_tmp=$(mktemp)

    local http_code
    http_code=$(curl -s -o "$tmp" -D "$headers_tmp" -w "%{http_code}" \
      -H "Accept: image/avif,image/webp,image/apng,image/*,*/*;q=0.8" \
      --max-time 15 \
      "$url" 2>/dev/null) || http_code="000"

    local content_type cache_status
    content_type=$(grep -i "^content-type:" "$headers_tmp" 2>/dev/null | head -1 | awk '{print $2}' | tr -d '\r')
    cache_status=$(grep -i "^x-cache:" "$headers_tmp" 2>/dev/null | head -1 | sed 's/^[^:]*: //' | tr -d '\r')

    local file_size
    file_size=$(wc -c < "$tmp" | tr -d ' ')
    rm -f "$tmp" "$headers_tmp"

    local status_icon status_type
    # For SSRF tests, we EXPECT failure (4xx)
    if [[ "$http_code" =~ ^4 ]]; then
      status_icon="✅ $http_code (blocked)"
      status_type="PASS"
    elif [[ "$http_code" == "200" ]]; then
      status_icon="🚨 200 (SHOULD BE BLOCKED)"
      status_type="FAIL"
    elif [[ "$http_code" == "502" || "$http_code" == "503" ]]; then
      status_icon="⚠️ $http_code (blocked but wrong code)"
      status_type="WARN"
    elif [[ "$http_code" == "000" ]]; then
      status_icon="⏱️ TIMEOUT"
      status_type="FAIL"
    else
      status_icon="❌ $http_code"
      status_type="FAIL"
    fi

    echo "${status_type}|${status_icon}|\`(raw url)\`|${label}|${content_type:-?}|${file_size:-?}|${cache_status:-?}" \
      > "$TMPDIR_RESULTS/$idx"
  ) &
}

flush() {
  wait
}

section() {
  local idx=$TEST_INDEX
  ((TEST_INDEX++))
  echo "SECTION|**---**|**${1}**||||" > "$TMPDIR_RESULTS/$idx"
}

# ═══════════════════════════════════════════════════════════════════════════════
# TEST CASES
# ═══════════════════════════════════════════════════════════════════════════════

echo "🔬 Testing image transform service..."
echo "   Source: $SOURCE"
echo ""

# ─── 1. BASELINE ─────────────────────────────────────────────────────────────

section "1. BASELINE"
fetch "" "No transforms (passthrough)"

# ─── 2. WIDTH ────────────────────────────────────────────────────────────────

section "2. WIDTH (w)"
fetch "w_50" "Tiny (50px)"
fetch "w_200" "Small (200px)"
fetch "w_800" "Medium (800px)"
fetch "w_1200" "Large (1200px)"
fetch "w_2400" "XL (2400px)"
fetch "w_5000" "Oversized (5000px) — should clamp or error"
fetch "w_0" "Zero width — should error"
fetch "w_-1" "Negative width — should error"
fetch "w_abc" "Non-numeric width — should error"
fetch "w_1.5" "Decimal width — should error or round"
fetch "w_999999" "Extreme width (DoS vector)"

# ─── 3. HEIGHT ───────────────────────────────────────────────────────────────

section "3. HEIGHT (h)"
fetch "h_100" "Small height"
fetch "h_600" "Medium height"
fetch "h_2400" "XL height"
fetch "h_0" "Zero height — should error"
fetch "h_-1" "Negative height — should error"
fetch "h_abc" "Non-numeric height — should error"
fetch "h_999999" "Extreme height (DoS vector)"

# ─── 4. WIDTH + HEIGHT ──────────────────────────────────────────────────────

section "4. WIDTH + HEIGHT (w + h)"
fetch "w_200,h_200" "Square 200x200"
fetch "w_800,h_600" "Landscape 800x600"
fetch "w_600,h_800" "Portrait 600x800"
fetch "w_1,h_1" "1x1 pixel"
fetch "w_4000,h_4000" "Very large — should clamp"
fetch "w_1,h_10000" "Extreme aspect ratio (1:10000)"
fetch "w_10000,h_1" "Extreme aspect ratio (10000:1)"

# ─── 5. ASPECT RATIO ────────────────────────────────────────────────────────

section "5. ASPECT RATIO (ar)"
fetch "w_400,ar_16:9" "16:9 landscape"
fetch "w_400,ar_9:16" "9:16 portrait"
fetch "w_400,ar_4:3" "4:3 classic"
fetch "w_400,ar_1:1" "1:1 square"
fetch "w_400,ar_21:9" "21:9 ultrawide"
fetch "h_400,ar_16:9" "Height + AR (derive width)"
fetch "ar_16:9" "AR only (no dimension) — behavior?"
fetch "w_400,ar_0:0" "Invalid AR 0:0"
fetch "w_400,ar_abc" "Non-numeric AR"
fetch "w_400,ar_16:0" "AR with zero denominator"
fetch "w_400,ar_0:9" "AR with zero numerator"
fetch "w_400,ar_-1:1" "Negative AR"
fetch "w_400,ar_1.5:1" "Decimal AR"
fetch "w_400,h_300,ar_16:9" "Width + Height + AR (conflict)"

# ─── 6. GRAVITY ──────────────────────────────────────────────────────────────

section "6. GRAVITY (g)"
fetch "w_200,h_200,g_center" "Gravity: center"
fetch "w_200,h_200,g_north" "Gravity: north"
fetch "w_200,h_200,g_south" "Gravity: south"
fetch "w_200,h_200,g_east" "Gravity: east"
fetch "w_200,h_200,g_west" "Gravity: west"
fetch "w_200,h_200,g_northeast" "Gravity: northeast"
fetch "w_200,h_200,g_northwest" "Gravity: northwest"
fetch "w_200,h_200,g_southeast" "Gravity: southeast"
fetch "w_200,h_200,g_southwest" "Gravity: southwest"
fetch "w_200,h_200,g_face" "Gravity: face (smart crop)"
fetch "w_200,h_200,g_auto" "Gravity: auto (smart crop)"
fetch "w_200,h_200,g_entropy" "Gravity: entropy (Cloudinary-style)"
fetch "w_200,h_200,g_invalid" "Gravity: invalid value"
fetch "w_200,g_center" "Gravity without both dimensions"

# ─── 7. STRATEGY ─────────────────────────────────────────────────────────────

section "7. STRATEGY (s)"
fetch "w_200,h_200,s_fit" "Strategy: fit (contain)"
fetch "w_200,h_200,s_fill" "Strategy: fill (cover + crop)"
fetch "w_200,h_200,s_scale" "Strategy: scale (stretch)"
fetch "w_200,h_200,s_pad" "Strategy: pad (letterbox)"
fetch "w_200,h_200,s_cover" "Strategy: cover (Cloudinary alias)"
fetch "w_200,h_200,s_contain" "Strategy: contain (CSS alias)"
fetch "w_200,h_200,s_inside" "Strategy: inside (sharp.js style)"
fetch "w_200,h_200,s_outside" "Strategy: outside (sharp.js style)"
fetch "w_200,s_fit" "Strategy: fit with width only"
fetch "h_200,s_fit" "Strategy: fit with height only"
fetch "w_200,h_200,s_invalid" "Strategy: invalid value"
fetch "w_200,h_200,s_pad,g_center" "Pad + gravity combination"
fetch "w_200,h_200,s_fill,g_north" "Fill + gravity (crop from top)"

# ─── 8. QUALITY ──────────────────────────────────────────────────────────────

section "8. QUALITY (q)"
fetch "w_400,q_1" "Quality: 1 (minimum)"
fetch "w_400,q_25" "Quality: 25 (low)"
fetch "w_400,q_50" "Quality: 50 (medium)"
fetch "w_400,q_75" "Quality: 75 (default?)"
fetch "w_400,q_85" "Quality: 85 (high — common default)"
fetch "w_400,q_100" "Quality: 100 (maximum)"
fetch "w_400,q_0" "Quality: 0 — should error"
fetch "w_400,q_101" "Quality: 101 — should clamp or error"
fetch "w_400,q_-10" "Quality: negative — should error"
fetch "w_400,q_auto" "Quality: auto (adaptive quality)"
fetch "w_400,q_auto:good" "Quality: auto:good (Cloudinary-style)"
fetch "w_400,q_auto:best" "Quality: auto:best (Cloudinary-style)"
fetch "w_400,q_auto:low" "Quality: auto:low (Cloudinary-style)"

# ─── 9. BLUR ─────────────────────────────────────────────────────────────────

section "9. BLUR (b)"
fetch "w_400,b_1" "Blur: 1 (minimal)"
fetch "w_400,b_5" "Blur: 5 (moderate)"
fetch "w_400,b_20" "Blur: 20 (heavy)"
fetch "w_400,b_100" "Blur: 100 (extreme)"
fetch "w_400,b_0" "Blur: 0 — should be no-op or error"
fetch "w_400,b_-1" "Blur: negative — should error"
fetch "w_400,b_0.5" "Blur: decimal value"
fetch "w_400,b_1000" "Blur: extreme value (DoS?)"

# ─── 10. FORMAT ──────────────────────────────────────────────────────────────

section "10. FORMAT (f)"
fetch "w_400,f_jpeg" "Format: JPEG"
fetch "w_400,f_jpg" "Format: JPG (alias?)"
fetch "w_400,f_png" "Format: PNG"
fetch "w_400,f_webp" "Format: WebP"
fetch "w_400,f_avif" "Format: AVIF"
fetch "w_400,f_gif" "Format: GIF"
fetch "w_400,f_tiff" "Format: TIFF — may not be supported"
fetch "w_400,f_bmp" "Format: BMP — may not be supported"
fetch "w_400,f_heif" "Format: HEIF — Apple ecosystem"
fetch "w_400,f_jxl" "Format: JPEG XL — next-gen"
fetch "w_400,f_auto" "Format: auto (content negotiation)"
fetch "w_400,f_invalid" "Format: invalid value"
fetch "w_400,f_svg" "Format: SVG (raster→vector — should fail)"

# ─── 11. PROFILE / PRESETS ──────────────────────────────────────────────────

section "11. PROFILE / PRESETS (p)"
fetch "p_thumbnail" "Profile: thumbnail"
fetch "p_preview" "Profile: preview"
fetch "p_hero" "Profile: hero"
fetch "p_og" "Profile: og (Open Graph — 1200x630)"
fetch "p_avatar" "Profile: avatar"
fetch "p_card" "Profile: card"
fetch "p_banner" "Profile: banner"
fetch "p_favicon" "Profile: favicon"
fetch "p_invalid" "Profile: invalid name"
fetch "p_thumbnail,w_100" "Profile + override width"
fetch "p_og,f_webp" "Profile + format override"

# ─── 12. CROP COORDINATES ───────────────────────────────────────────────────

section "12. CROP COORDINATES (x, y)"
fetch "w_200,h_200,x_50,y_50" "Crop at offset 50,50"
fetch "w_200,h_200,x_0,y_0" "Crop at origin"
fetch "w_200,h_200,x_9999,y_9999" "Crop beyond image bounds"
fetch "w_200,h_200,x_-10,y_-10" "Negative crop offset"
fetch "x_50,y_50" "Crop offset without dimensions"
fetch "w_200,h_200,x_50" "Crop with x only (no y)"
fetch "w_200,h_200,y_50" "Crop with y only (no x)"

# ─── 13. DPR (Device Pixel Ratio) ───────────────────────────────────────────

section "13. DPR (Device Pixel Ratio)"
fetch "w_200,dpr_1" "DPR 1x — should output 200px"
fetch "w_200,dpr_1.5" "DPR 1.5x — should output 300px"
fetch "w_200,dpr_2" "DPR 2x — should output 400px"
fetch "w_200,dpr_3" "DPR 3x — should output 600px"
fetch "w_200,dpr_4" "DPR 4x — should output 800px"
fetch "w_200,dpr_0" "DPR 0 — should error"
fetch "w_200,dpr_-1" "DPR negative — should error"
fetch "w_200,dpr_auto" "DPR auto (client hints?)"
fetch "w_200,dpr_10" "DPR 10x — extreme, should clamp"
fetch "w_200,h_200,dpr_2" "DPR with both dimensions"

# ─── 14. ROTATION ───────────────────────────────────────────────────────────

section "14. ROTATION (rot)"
fetch "w_400,rot_0" "Rotation: 0 degrees"
fetch "w_400,rot_90" "Rotation: 90 degrees CW"
fetch "w_400,rot_180" "Rotation: 180 degrees"
fetch "w_400,rot_270" "Rotation: 270 degrees CW"
fetch "w_400,rot_-90" "Rotation: -90 degrees (= 270)"
fetch "w_400,rot_45" "Rotation: 45 degrees (non-right angle)"
fetch "w_400,rot_360" "Rotation: 360 degrees (= 0)"
fetch "w_400,rot_auto" "Rotation: auto (EXIF orientation)"
fetch "w_400,rot_abc" "Rotation: invalid value"

# ─── 15. FLIP / MIRROR ──────────────────────────────────────────────────────

section "15. FLIP / MIRROR"
fetch "w_400,flip_h" "Flip horizontal (mirror)"
fetch "w_400,flip_v" "Flip vertical"
fetch "w_400,flip_both" "Flip both axes"
fetch "w_400,flip_h,rot_90" "Flip + rotation combo"
fetch "w_400,flip_invalid" "Flip: invalid value"

# ─── 16. SHARPEN ─────────────────────────────────────────────────────────────

section "16. SHARPEN (sh)"
fetch "w_400,sh_1" "Sharpen: 1 (subtle)"
fetch "w_400,sh_5" "Sharpen: 5 (moderate)"
fetch "w_400,sh_10" "Sharpen: 10 (strong)"
fetch "w_400,sh_0" "Sharpen: 0 — no-op"
fetch "w_400,sh_-1" "Sharpen: negative — should error"
fetch "w_400,sh_100" "Sharpen: extreme"
fetch "w_400,sh_5,b_5" "Sharpen + blur combo (conflict?)"

# ─── 17. BACKGROUND COLOR (for pad strategy) ────────────────────────────────

section "17. BACKGROUND COLOR (bg)"
fetch "w_200,h_200,s_pad,bg_ffffff" "Pad with white background"
fetch "w_200,h_200,s_pad,bg_000000" "Pad with black background"
fetch "w_200,h_200,s_pad,bg_ff0000" "Pad with red background"
fetch "w_200,h_200,s_pad,bg_transparent" "Pad with transparency"
fetch "w_200,h_200,s_pad,bg_fff" "Pad with short hex (3-char)"
fetch "w_200,h_200,s_pad,bg_invalid" "Pad with invalid color"
fetch "w_200,h_200,s_pad,bg_ff000080" "Pad with RGBA (50% alpha)"
fetch "w_200,h_200,bg_ff0000" "Background without pad strategy"

# ─── 18. BORDER / ROUND CORNERS ─────────────────────────────────────────────

section "18. BORDER & CORNERS"
fetch "w_200,h_200,border_2_000000" "Border: 2px black"
fetch "w_200,h_200,border_5_ff0000" "Border: 5px red"
fetch "w_200,h_200,border_0_000000" "Border: 0px — no-op"
fetch "w_200,h_200,r_10" "Round corners: 10px"
fetch "w_200,h_200,r_50" "Round corners: 50px"
fetch "w_200,h_200,r_max" "Round corners: max (circle crop)"
fetch "w_200,h_200,r_10,f_jpeg" "Round corners + JPEG (no alpha — what happens?)"
fetch "w_200,h_200,r_10,f_png" "Round corners + PNG (has alpha)"

# ─── 19. TRIM (auto-crop whitespace) ────────────────────────────────────────

section "19. TRIM"
fetch "w_400,trim_true" "Trim: auto-crop whitespace/borders"
fetch "w_400,trim_10" "Trim: tolerance 10"
fetch "w_400,trim_50" "Trim: tolerance 50"
fetch "w_400,trim_false" "Trim: disabled"

# ─── 20. METADATA / EXIF ────────────────────────────────────────────────────

section "20. METADATA / EXIF"
fetch "w_400,strip_true" "Strip all metadata"
fetch "w_400,strip_false" "Preserve metadata"
fetch "w_400,strip_true,f_jpeg" "Strip EXIF from JPEG"
fetch "w_400,strip_true,f_png" "Strip metadata from PNG"

# ─── 21. PROGRESSIVE / INTERLACE ────────────────────────────────────────────

section "21. PROGRESSIVE / INTERLACE"
fetch "w_800,f_jpeg,progressive_true" "Progressive JPEG"
fetch "w_800,f_jpeg,progressive_false" "Baseline JPEG"
fetch "w_800,f_png,progressive_true" "Interlaced PNG"

# ─── 22. DIFFERENT SOURCE IMAGE TYPES ───────────────────────────────────────

section "22. SOURCE: PNG WITH TRANSPARENCY"
fetch "w_400" "PNG source → default format" "$SOURCE_PNG"
fetch "w_400,f_jpeg" "PNG→JPEG (alpha handling?)" "$SOURCE_PNG"
fetch "w_400,f_webp" "PNG→WebP (preserve alpha)" "$SOURCE_PNG"
fetch "w_400,f_avif" "PNG→AVIF (preserve alpha)" "$SOURCE_PNG"
fetch "w_200,h_200,s_pad,bg_ff0000" "PNG + pad with red bg" "$SOURCE_PNG"

section "22b. SOURCE: ANIMATED GIF"
fetch "w_200" "Animated GIF → resize" "$SOURCE_GIF_ANIM"
fetch "w_200,f_webp" "Animated GIF → WebP (animated?)" "$SOURCE_GIF_ANIM"
fetch "w_200,f_png" "Animated GIF → PNG (first frame?)" "$SOURCE_GIF_ANIM"
fetch "w_200,f_jpeg" "Animated GIF → JPEG (first frame?)" "$SOURCE_GIF_ANIM"

section "22c. SOURCE: WEBP"
fetch "w_400" "WebP source → default format" "$SOURCE_WEBP"
fetch "w_400,f_jpeg" "WebP→JPEG" "$SOURCE_WEBP"
fetch "w_400,f_png" "WebP→PNG" "$SOURCE_WEBP"

section "22d. SOURCE: SVG"
fetch "w_400" "SVG source → rasterize" "$SOURCE_SVG"
fetch "w_400,f_png" "SVG→PNG" "$SOURCE_SVG"
fetch "w_800" "SVG rasterize at 800px" "$SOURCE_SVG"

section "22e. SOURCE: VERY SMALL IMAGE"
fetch "w_800" "Upscale 10x10 to 800px — behavior?" "$SOURCE_SMALL"
fetch "w_10" "Downscale 10x10 to 10px — no-op" "$SOURCE_SMALL"
fetch "w_400,h_400" "Upscale small image with both dims" "$SOURCE_SMALL"

section "22f. SOURCE: VERY LARGE IMAGE"
fetch "w_400" "Large source → 400px (memory test)" "$SOURCE_LARGE"
fetch "w_100,q_30" "Large source → tiny placeholder" "$SOURCE_LARGE"

# ─── 23. CONTENT NEGOTIATION (Accept header) ────────────────────────────────

section "23. CONTENT NEGOTIATION (Accept header)"
fetch_accept "w_400,f_auto" "f_auto + Accept webp only" "image/webp"
fetch_accept "w_400,f_auto" "f_auto + Accept avif only" "image/avif"
fetch_accept "w_400,f_auto" "f_auto + Accept jpeg only" "image/jpeg"
fetch_accept "w_400,f_auto" "f_auto + Accept wildcard" "*/*"
fetch_accept "w_400,f_auto" "f_auto + Accept text/html (non-image)" "text/html"
fetch_accept "w_400,f_auto" "f_auto + No preference" "image/*"
fetch_accept "w_400,f_auto" "f_auto + Prefer avif over webp" "image/avif,image/webp;q=0.9,image/jpeg;q=0.8"
fetch_accept "w_400,f_auto" "f_auto + Empty Accept" ""
fetch_accept "w_400" "No f_auto + Accept webp (should NOT negotiate)" "image/webp"

# ─── 24. RESPONSE HEADER VALIDATION ─────────────────────────────────────────

section "24. RESPONSE HEADERS"
fetch_headers "w_400" "Cache-Control header present?" "cache-control"
fetch_headers "w_400" "ETag header present?" "etag"
fetch_headers "w_400" "Last-Modified header present?" "last-modified"
fetch_headers "w_400,f_auto" "Vary: Accept for auto format?" "vary"
fetch_headers "w_400" "Content-Length present?" "content-length"
fetch_headers "w_400" "Content-Disposition header?" "content-disposition"
fetch_headers "w_400" "Access-Control-Allow-Origin (CORS)?" "access-control-allow-origin"
fetch_headers "w_400" "X-Amz-Cf-Id (CloudFront request ID)?" "x-amz-cf-id"
fetch_headers "w_400" "Server header?" "server"
fetch_headers "w_400" "Age header (cache age)?" "age"
fetch_headers "w_400" "X-Transform-Duration?" "x-transform-duration"
fetch_headers "w_400" "X-Original-Size?" "x-original-size"
fetch_headers "w_400" "X-Transformed-Size?" "x-transformed-size"
fetch_headers "w_400" "Content-Security-Policy?" "content-security-policy"
fetch_headers "w_400" "Strict-Transport-Security?" "strict-transport-security"
fetch_headers "w_400" "X-Content-Type-Options?" "x-content-type-options"

# ─── 25. CONDITIONAL REQUESTS ───────────────────────────────────────────────

section "25. CONDITIONAL REQUESTS"
# First, get the ETag from a normal request (this is a special two-step test)
# We test with a fake ETag — a real test would need the actual ETag from step 1
fetch_conditional "w_400" "If-None-Match with fake ETag" 'If-None-Match: "fake-etag-12345"'
fetch_conditional "w_400" "If-Modified-Since far future" "If-Modified-Since: Thu, 01 Jan 2099 00:00:00 GMT"
fetch_conditional "w_400" "If-Modified-Since far past" "If-Modified-Since: Thu, 01 Jan 1970 00:00:00 GMT"

# ─── 26. HEAD & RANGE REQUESTS ──────────────────────────────────────────────

section "26. HTTP METHODS & RANGE"
fetch_method "HEAD" "w_400" "HEAD request — headers only, no body"
fetch_method "OPTIONS" "w_400" "OPTIONS request (CORS preflight)"
fetch_method "POST" "w_400" "POST request — should be rejected"
fetch_method "PUT" "w_400" "PUT request — should be rejected"
fetch_method "DELETE" "w_400" "DELETE request — should be rejected"
fetch_range "w_400" "Range: first 1KB" "0-1023"
fetch_range "w_400" "Range: last 512 bytes" "-512"
fetch_range "w_400" "Range: beyond content" "999999-9999999"

# ─── 27. PARAM ORDERING INVARIANCE ──────────────────────────────────────────

section "27. PARAM ORDERING (cache key)"
fetch "w_200,h_200,q_80" "Order: w,h,q"
fetch "q_80,h_200,w_200" "Order: q,h,w (reversed)"
fetch "h_200,w_200,q_80" "Order: h,w,q (mixed)"
fetch "w_200,q_80,h_200" "Order: w,q,h (interleaved)"

# ─── 28. SECURITY — SSRF PROTECTION ─────────────────────────────────────────

section "28. SECURITY: SSRF PROTECTION"
fetch_raw "${BASE}/w_200/http://169.254.169.254/latest/meta-data/" "AWS metadata endpoint (SSRF)"
fetch_raw "${BASE}/w_200/http://169.254.169.254/latest/meta-data/iam/security-credentials/" "AWS IAM credentials (SSRF)"
fetch_raw "${BASE}/w_200/http://127.0.0.1/" "Localhost (SSRF)"
fetch_raw "${BASE}/w_200/http://127.0.0.1:8080/image.png" "Localhost with port (SSRF)"
fetch_raw "${BASE}/w_200/http://0.0.0.0/" "0.0.0.0 (SSRF)"
fetch_raw "${BASE}/w_200/http://10.0.0.1/" "Private IP 10.x (SSRF)"
fetch_raw "${BASE}/w_200/http://192.168.1.1/" "Private IP 192.168.x (SSRF)"
fetch_raw "${BASE}/w_200/http://172.16.0.1/" "Private IP 172.16.x (SSRF)"
fetch_raw "${BASE}/w_200/http://[::1]/" "IPv6 localhost (SSRF)"
fetch_raw "${BASE}/w_200/http://0x7f000001/" "Hex IP localhost (SSRF bypass)"
fetch_raw "${BASE}/w_200/http://2130706433/" "Decimal IP localhost (SSRF bypass)"
fetch_raw "${BASE}/w_200/http://localtest.me/" "DNS rebinding (localtest.me → 127.0.0.1)"
fetch_raw "${BASE}/w_200/file:///etc/passwd" "file:// scheme (LFI)"
fetch_raw "${BASE}/w_200/ftp://ftp.example.com/image.jpg" "ftp:// scheme"
fetch_raw "${BASE}/w_200/data:image/png;base64,iVBOR" "data: URI"
fetch_raw "${BASE}/w_200/gopher://evil.com/" "gopher:// scheme"

section "28b. SECURITY: SOURCE URL ABUSE"
fetch_raw "${BASE}/w_200/https://example.com/nonexistent.jpg" "Non-existent source (404 handling)"
fetch_raw "${BASE}/w_200/https://httpstat.us/500" "Source returns 500"
fetch_raw "${BASE}/w_200/https://httpstat.us/301" "Source returns 301 redirect"
fetch_raw "${BASE}/w_200/https://httpstat.us/200?sleep=20000" "Slow source (20s delay)"
fetch_raw "${BASE}/w_200/https://example.com/" "Source is HTML, not image"
fetch_raw "${BASE}/w_200/https://example.com/../../../../etc/passwd" "Path traversal in URL"
fetch_raw "${BASE}/w_200/https://evil.com/image.jpg%00.png" "Null byte in URL"

# ─── 29. EDGE CASES ─────────────────────────────────────────────────────────

section "29. EDGE CASES: PARAM PARSING"
fetch "w_200,w_400" "Duplicate param (w appears twice)"
fetch "w_200,,h_200" "Empty param segment"
fetch ",w_200" "Leading comma"
fetch "w_200," "Trailing comma"
fetch "W_200" "Uppercase param key"
fetch "w_200,unknown_foo" "Unknown param"
fetch "w_200, h_200" "Space in params"
fetch "w_200%2Ch_200" "URL-encoded comma"
fetch "w_200;h_200" "Semicolon separator"
fetch "w=200&h=200" "Query-string style params"
fetch "w_200/h_200" "Slash-separated params (Cloudinary-style)"
fetch "w_" "Key with empty value"
fetch "_200" "Empty key with value"
fetch "" "Empty params (passthrough)"
fetch ",,," "Only commas"
fetch "w_200,h_200,q_80,f_webp,g_center,s_fill,b_5,dpr_2,rot_90,sh_3" "Kitchen sink — all params"

section "29b. EDGE CASES: URL ENCODING"
fetch "w_200" "Source with spaces" "https://example.com/my%20image.jpg"
fetch "w_200" "Source with unicode" "https://example.com/imagem-%C3%A9.jpg"
fetch "w_200" "Source with query params" "https://www.theminimalistdeveloper.com/take-control-of-your-learning-journey/man-hooked-up-to-machines.jpg?v=2&token=abc"
fetch "w_200" "Source with fragment" "https://www.theminimalistdeveloper.com/take-control-of-your-learning-journey/man-hooked-up-to-machines.jpg#section"
fetch "w_200" "Source double-encoded" "https%3A%2F%2Fwww.theminimalistdeveloper.com%2Ftake-control-of-your-learning-journey%2Fman-hooked-up-to-machines.jpg"

# ─── 30. COMBINATIONS (real-world scenarios) ────────────────────────────────

section "30. REAL-WORLD COMBINATIONS"
fetch "w_800,h_600,g_center,q_80,f_webp" "Blog hero: 800x600, center, q80, webp"
fetch "w_400,h_400,g_face,s_fill,q_85" "Avatar: 400x400, face detect, fill, q85"
fetch "w_1200,ar_16:9,g_center,q_90,f_avif" "Hero: 1200w, 16:9, center, q90, avif"
fetch "w_100,h_100,b_10,q_30" "LQIP placeholder: 100x100, blurred, low q"
fetch "w_200,q_75,f_webp" "Thumbnail: 200w, q75, webp"
fetch "w_1920,h_1080,s_fit,f_auto,q_85" "Full HD fit"
fetch "w_40,h_40,q_20,b_20,f_webp" "BlurHash-style micro placeholder"
fetch "w_1200,h_630,g_center,s_fill,q_85,f_jpeg" "Open Graph image (1200x630)"
fetch "w_192,h_192,s_fill,g_center,f_png" "PWA icon (192x192)"
fetch "w_32,h_32,s_fill,g_center,f_png" "Favicon (32x32)"
fetch "w_400,h_300,s_pad,bg_ffffff,q_85,f_webp" "E-commerce product (padded white bg)"
fetch "w_2560,q_85,f_avif" "Retina hero (2560w, avif)"
fetch "w_300,ar_1:1,g_face,s_fill,q_80,f_webp" "Social avatar (square face crop)"
fetch "w_800,h_450,g_auto,s_fill,q_80,f_webp,sh_2" "Card image (auto crop + sharpen)"

# ─── 31. CACHE STAMPEDE ─────────────────────────────────────────────────────

section "31. CACHE STAMPEDE (concurrent identical)"
# Fire 5 identical requests for a unique transform (add timestamp to bust cache)
STAMPEDE_PARAMS="w_317,h_179,q_73"
for i in {1..5}; do
  fetch "$STAMPEDE_PARAMS" "Stampede request #$i"
done

# ═══════════════════════════════════════════════════════════════════════════════
# WAIT + REPORT
# ═══════════════════════════════════════════════════════════════════════════════

echo "⏳ Waiting for all tests to complete..."
flush

PASS=0
FAIL=0
WARN=0

echo ""
echo "# Image Transform Test Report"
echo ""
echo "**Source:** \`$SOURCE\`"
echo "**Base URL:** \`$BASE\`"
echo "**Date:** $(date -u '+%Y-%m-%d %H:%M UTC')"
echo ""
echo "## Results"
echo ""
echo "| Status | Params | Test | Content-Type | Size (bytes) | Cache |"
echo "|--------|--------|------|-------------|-------------|-------|"

for i in $(seq 0 $((TEST_INDEX - 1))); do
  if [[ -f "$TMPDIR_RESULTS/$i" ]]; then
    line=$(cat "$TMPDIR_RESULTS/$i")
    IFS='|' read -r stype icon params label ctype size cache <<< "$line"
    if [[ "$stype" == "PASS" ]]; then ((PASS++));
    elif [[ "$stype" == "FAIL" ]]; then ((FAIL++));
    elif [[ "$stype" == "WARN" ]]; then ((WARN++)); fi
    echo "| $icon | $params | $label | $ctype | $size | $cache |"
  fi
done

rm -rf "$TMPDIR_RESULTS"

echo ""
echo "## Summary"
echo ""
echo "- **Pass:** $PASS"
echo "- **Fail:** $FAIL"
echo "- **Warnings:** $WARN"
echo "- **Total:** $((PASS + FAIL + WARN))"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# SUGGESTIONS
# ═══════════════════════════════════════════════════════════════════════════════

echo "## Suggestions for Improvement"
echo ""
echo "### Input Validation"
echo "- [ ] Reject or clamp width/height to a max (e.g., 4096px) to prevent DoS"
echo "- [ ] Return 400 for zero, negative, or non-numeric dimension values"
echo "- [ ] Validate aspect ratio format (must be \`N:M\` with positive integers)"
echo "- [ ] Clamp quality to 1-100 range, reject values outside"
echo "- [ ] Validate gravity against an enum of known values"
echo "- [ ] Validate strategy against an enum of known values"
echo "- [ ] Reject or ignore unknown parameter keys with a warning header"
echo "- [ ] Handle duplicate parameter keys deterministically (last wins, or error)"
echo "- [ ] Reject extreme dimensions that could cause OOM (e.g., w_999999)"
echo ""
echo "### Performance"
echo "- [ ] Return \`Cache-Control\` headers with long max-age for immutable transforms"
echo "- [ ] Support \`If-None-Match\` / \`ETag\` for conditional requests (304)"
echo "- [ ] Consider a max file size for source images to prevent OOM"
echo "- [ ] Add \`Vary: Accept\` header when using format auto-negotiation"
echo "- [ ] Return \`Content-Length\` on all responses for progressive rendering"
echo "- [ ] Enable CloudFront origin shield to prevent cache stampede"
echo "- [ ] Normalize param order for cache key (w,h,q → same key regardless of input order)"
echo "- [ ] Support Range requests (206 Partial Content) for large images"
echo ""
echo "### Format & Quality"
echo "- [ ] Default to \`f_auto\` (content negotiation via Accept header) when no format specified"
echo "- [ ] Support AVIF as a first-class format (best compression for photos)"
echo "- [ ] Consider stripping EXIF metadata by default (privacy + smaller files)"
echo "- [ ] Implement progressive JPEG for large images"
echo "- [ ] Support JPEG XL (f_jxl) as next-gen format"
echo "- [ ] Handle animated GIF/WebP: preserve animation on resize or extract first frame"
echo "- [ ] Handle PNG transparency → JPEG: composite onto white/configurable background"
echo ""
echo "### New Transform Features"
echo "- [ ] DPR (Device Pixel Ratio): \`dpr_2\` multiplies dimensions for retina"
echo "- [ ] Rotation: \`rot_90\`, \`rot_180\`, \`rot_270\`, \`rot_auto\` (EXIF-based)"
echo "- [ ] Flip/Mirror: \`flip_h\`, \`flip_v\`"
echo "- [ ] Sharpen: \`sh_5\` (post-resize sharpening is critical for quality)"
echo "- [ ] Background color: \`bg_ffffff\` (for pad strategy letterboxing)"
echo "- [ ] Border: \`border_2_000000\` (width + color)"
echo "- [ ] Round corners: \`r_10\`, \`r_max\` (circle crop)"
echo "- [ ] Trim: auto-crop whitespace/borders from product images"
echo "- [ ] Metadata strip: \`strip_true\` (remove EXIF, IPTC, XMP)"
echo "- [ ] Progressive: \`progressive_true\` for progressive JPEG"
echo "- [ ] Adaptive quality: \`q_auto\` (vary quality based on image complexity)"
echo ""
echo "### Error Handling"
echo "- [ ] Return structured error responses (JSON with error code + message)"
echo "- [ ] Use appropriate HTTP status codes: 400 (bad params), 404 (source not found), 422 (unsupported format)"
echo "- [ ] Include \`X-Transform-Error\` header with machine-readable error codes"
echo "- [ ] Differentiate between 'source not found' and 'transform failed'"
echo "- [ ] Return 400 (not 502) for invalid params — 502 suggests infrastructure failure"
echo "- [ ] Handle source server errors gracefully (source returns 500)"
echo "- [ ] Timeout handling: return 504 if source fetch exceeds limit"
echo ""
echo "### Security"
echo "- [ ] Whitelist allowed source domains (prevent SSRF via arbitrary URLs)"
echo "- [ ] Block private IP ranges: 10.x, 172.16-31.x, 192.168.x, 127.x, 169.254.x"
echo "- [ ] Block IPv6 loopback (::1) and link-local addresses"
echo "- [ ] Block hex/decimal/octal IP encoding tricks (0x7f000001, 2130706433)"
echo "- [ ] Block non-HTTP schemes: file://, ftp://, gopher://, data:"
echo "- [ ] Block DNS rebinding (resolve DNS and check IP before fetching)"
echo "- [ ] Rate-limit unique transform combinations per IP"
echo "- [ ] Set \`Content-Security-Policy\` headers on responses"
echo "- [ ] Set \`X-Content-Type-Options: nosniff\`"
echo "- [ ] Set \`Strict-Transport-Security\` header"
echo "- [ ] Validate source URL scheme (only allow https://)"
echo "- [ ] Prevent path traversal in source URLs"
echo "- [ ] Reject null bytes in URLs"
echo "- [ ] Reject POST/PUT/DELETE methods (GET and HEAD only)"
echo ""
echo "### Response Headers"
echo "- [ ] \`Cache-Control: public, max-age=31536000, immutable\` for transformed images"
echo "- [ ] \`ETag\` for conditional request support"
echo "- [ ] \`Vary: Accept\` when format auto-negotiation is used"
echo "- [ ] \`Content-Length\` on all responses"
echo "- [ ] \`Access-Control-Allow-Origin: *\` for cross-origin image usage"
echo "- [ ] \`X-Content-Type-Options: nosniff\`"
echo "- [ ] \`X-Transform-Duration\` (debug: how long the transform took)"
echo "- [ ] \`X-Original-Size\` / \`X-Transformed-Size\` (debug: compression ratio)"
echo ""
echo "### DX Improvements"
echo "- [ ] Add a \`_debug\` or \`_info\` param that returns transform metadata as JSON"
echo "- [ ] Document supported profiles (p_thumbnail, p_hero, etc.) and their presets"
echo "- [ ] Support named presets via config (e.g., \`p_card\` = w_400,h_300,g_center,f_auto,q_80)"
echo "- [ ] Add an \`_original\` passthrough param that returns original with only format conversion"
echo "- [ ] Support chained transforms (e.g., resize then blur) with explicit ordering"
echo "- [ ] Support Cloudinary-style slash-separated params: \`/w_400/h_300/\`"
echo "- [ ] Provide responsive image helpers: \`srcset\` generation endpoint"
