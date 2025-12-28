#!/bin/bash

# WebP 이미지 최적화 스크립트
# JPG 원본 이미지들을 WebP로 변환하여 갤러리로 복사

# 스크립트 실행 위치에 관계없이 절대 경로 사용
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ORIGINAL_DIR="$PROJECT_ROOT/public/images/original"
GALLERY_DIR="$PROJECT_ROOT/public/images/gallery"

echo "🖼️  WebP 갤러리 이미지 최적화 시작..."
echo "📂 원본 디렉토리: $ORIGINAL_DIR"
echo "📂 출력 디렉토리: $GALLERY_DIR"

# 갤러리 디렉토리 생성
mkdir -p "$GALLERY_DIR"

# ImageMagick 설치 및 WebP 지원 확인
CONVERT_PATH=""
if command -v convert &> /dev/null; then
    CONVERT_PATH="convert"
elif [ -f "/usr/bin/convert" ]; then
    CONVERT_PATH="/usr/bin/convert"
elif [ -f "/usr/local/bin/convert" ]; then
    CONVERT_PATH="/usr/local/bin/convert"
else
    echo "❌ ImageMagick이 설치되어 있지 않습니다."
    echo "설치 명령: sudo apt-get install imagemagick (Ubuntu/Debian)"
    echo "설치 명령: brew install imagemagick (macOS)"
    exit 1
fi

echo "✅ ImageMagick 발견: $CONVERT_PATH"

# WebP 지원 확인
if ! $CONVERT_PATH -list format | grep -i webp > /dev/null; then
    echo "❌ ImageMagick에서 WebP 포맷을 지원하지 않습니다."
    echo "WebP 지원 ImageMagick 재설치가 필요할 수 있습니다."
    exit 1
fi

echo "✅ WebP 포맷 지원 확인됨"

# WebP 이미지 최적화 함수
optimize_image_webp() {
    local image_num="$1"
    local original_file="$ORIGINAL_DIR/image${image_num}.jpg"
    local output_file="$GALLERY_DIR/image${image_num}.webp"
    local filename="image${image_num}"
    
    # 원본 파일 존재 확인
    if [ ! -f "$original_file" ]; then
        echo "⚠️  원본 파일 없음: $original_file"
        return 1
    fi
    
    # 파일 크기 확인
    local file_size=$(stat -c%s "$original_file" 2>/dev/null || stat -f%z "$original_file")
    local file_size_mb=$((file_size / 1024 / 1024))
    
    echo "📊 처리 중: $filename (원본: ${file_size_mb}MB, JPG → WebP)"
    
    # WebP 변환 (원본 해상도 유지, 품질로만 최적화)
    echo "  🔧 WebP 변환 (원본 해상도 유지): $original_file → $output_file"
    
    # 첫 번째 시도: 품질 90% (원본 해상도 유지)
    $CONVERT_PATH "$original_file" \
        -auto-orient \
        -quality 100 \
        -strip \
        "$output_file.tmp"
    
    # 명령 실행 결과 확인
    if [ $? -ne 0 ]; then
        echo "  ❌ WebP 변환 실패"
        return 1
    fi
    
    # 결과 파일이 실제로 생성되었는지 확인
    if [ ! -f "$output_file.tmp" ] || [ ! -s "$output_file.tmp" ]; then
        echo "  ❌ WebP 파일이 생성되지 않았거나 비어있음"
        return 1
    fi
    
    # 결과 파일 크기 확인
    local new_size=$(stat -c%s "$output_file.tmp" 2>/dev/null || stat -f%z "$output_file.tmp")
    local new_size_mb=$((new_size / 1024 / 1024))
    
    # 목표 크기 (3MB, 원본 해상도 유지 시 더 여유롭게)
    local target_size=$((3072 * 1024)) # 3MB
    
    # 여전히 너무 큰 경우 더 강한 압축 (해상도 유지)
    if [ "$new_size" -gt "$target_size" ]; then
        echo "  🔧 2차 압축 시도 (품질 80%, 해상도 유지)"
        $CONVERT_PATH "$original_file" \
            -auto-orient \
            -quality 90 \
            -strip \
            "$output_file.tmp"
        if [ -s "$output_file.tmp" ]; then
            new_size=$(stat -c%s "$output_file.tmp" 2>/dev/null || stat -f%z "$output_file.tmp")
            new_size_mb=$((new_size / 1024 / 1024))
        fi
    fi
    
    # 그래도 큰 경우 최종 압축 (해상도 유지)
    if [ "$new_size" -gt "$target_size" ]; then
        echo "  🔧 3차 압축 시도 (품질 70%, 해상도 유지)"
        $CONVERT_PATH "$original_file" \
            -auto-orient \
            -quality 80 \
            -strip \
            "$output_file.tmp"
        if [ -s "$output_file.tmp" ]; then
            new_size=$(stat -c%s "$output_file.tmp" 2>/dev/null || stat -f%z "$output_file.tmp")
            new_size_mb=$((new_size / 1024 / 1024))
        fi
    fi
    
    # WebP가 원본보다 작은 경우만 사용, 그렇지 않으면 원본 JPG 유지
    if [ "$new_size" -lt "$file_size" ]; then
        # WebP가 더 작음 - 사용
        mv "$output_file.tmp" "$output_file"
        local compression_ratio=$((100 - (new_size * 100 / file_size)))
        echo "✅ WebP 변환 완료: $filename (${file_size_mb}MB → ${new_size_mb}MB, ${compression_ratio}% 압축)"
    else
        # WebP가 더 큼 - 원본 JPG 사용
        rm -f "$output_file.tmp"
        local jpg_output="${output_file%.webp}.jpg"
        cp "$original_file" "$jpg_output"
        echo "⚠️  WebP가 더 큼 - 원본 JPG 유지: $filename (${file_size_mb}MB)"
    fi
}

# 기존 JPG 파일들 제거 (WebP로 교체)
echo ""
echo "🗑️  기존 JPG 파일 제거 중..."
for i in 1 2 3 4 5 6 7 8 9; do
    jpg_file="$GALLERY_DIR/image${i}.jpg"
    if [ -f "$jpg_file" ]; then
        rm "$jpg_file"
        echo "🗑️  제거됨: image${i}.jpg"
    fi
done

# 1~9번 이미지를 WebP로 변환 (현재 사용 가능한 이미지)
echo ""
for i in 1 2 3 4 5 6 7 8 9; do
    echo "🔄 이미지 $i WebP 변환 시작..."
    optimize_image_webp "$i"
done

# 기존 갤러리의 14~20번 이미지 제거 (JPG, WebP 모두)
echo ""
echo "🗑️  사용하지 않는 이미지 제거 중..."
for i in 14 15 16 17 18 19 20; do
    for ext in jpg webp; do
        old_file="$GALLERY_DIR/image${i}.${ext}"
        if [ -f "$old_file" ]; then
            rm "$old_file"
            echo "🗑️  제거됨: image${i}.${ext}"
        fi
    done
done

# 원본 이미지 제거 (Docker 빌드용 옵션)
if [ "$REMOVE_ORIGINALS" = "true" ]; then
    echo ""
    echo "🗑️  원본 이미지 제거 중 (Docker 빌드 최적화)..."
    for i in 1 2 3 4 5 6 7 8 9; do
        original_file="$ORIGINAL_DIR/image${i}.jpg"
        if [ -f "$original_file" ]; then
            rm "$original_file"
            echo "🗑️  제거됨: $original_file"
        fi
    done
    
    # 원본 디렉토리가 비어있으면 제거
    if [ -d "$ORIGINAL_DIR" ] && [ -z "$(ls -A "$ORIGINAL_DIR")" ]; then
        rmdir "$ORIGINAL_DIR"
        echo "🗑️  빈 디렉토리 제거됨: $ORIGINAL_DIR"
    fi
fi

echo ""
echo "🎉 WebP 이미지 최적화 완료!"
if [ "$REMOVE_ORIGINALS" = "true" ]; then
    echo "📂 원본 이미지: 제거됨 (Docker 최적화)"
else
    echo "📂 원본 이미지: $ORIGINAL_DIR (JPG, 보존됨)"
fi
echo "📂 최적화된 이미지: $GALLERY_DIR (WebP)"
echo ""
echo "📊 최종 결과 (갤러리 WebP):"
for i in 1 2 3 4 5 6 7 8 9; do
    if [ -f "$GALLERY_DIR/image${i}.webp" ]; then
        ls -lh "$GALLERY_DIR/image${i}.webp"
    fi
done

echo ""
echo "🌟 WebP 장점:"
echo "   - 평균 25-35% 더 작은 파일 크기"
echo "   - 동일한 시각적 품질"
echo "   - 모던 브라우저에서 완전 지원"
echo "   - 더 빠른 로딩 속도"

echo ""
echo "🖼️  메인(히어로) 이미지 WebP 생성: ha0h-1fsi-bqt3.jpg → .webp (리사이즈)"
HERO_JPG="$PROJECT_ROOT/public/images/ha0h-1fsi-bqt3.jpg"
HERO_WEBP="$PROJECT_ROOT/public/images/ha0h-1fsi-bqt3.webp"
if [ -f "$HERO_JPG" ]; then
    $CONVERT_PATH "$HERO_JPG" \
        -auto-orient \
        -quality 95 \
        -strip \
        "$HERO_WEBP.tmp"

    if [ -f "$HERO_WEBP.tmp" ] && [ -s "$HERO_WEBP.tmp" ]; then
        mv "$HERO_WEBP.tmp" "$HERO_WEBP"
        echo "✅ 생성됨: $HERO_WEBP"
        ls -lh "$HERO_WEBP" || true
    else
        rm -f "$HERO_WEBP.tmp"
        echo "⚠️  WebP 생성 실패(빈 파일). JPG 유지"
    fi
else
    echo "ℹ️  히어로 JPG 없음: $HERO_JPG"
fi
