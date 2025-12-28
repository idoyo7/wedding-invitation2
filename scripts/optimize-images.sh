#!/bin/bash

# 이미지 최적화 스크립트
# 원본 이미지들을 2MB 이하로 리사이징해서 갤러리로 복사

# 스크립트 실행 위치에 관계없이 절대 경로 사용
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ORIGINAL_DIR="$PROJECT_ROOT/public/images/original"
GALLERY_DIR="$PROJECT_ROOT/public/images/gallery"

echo "🖼️  갤러리 이미지 최적화 시작..."
echo "📂 원본 디렉토리: $ORIGINAL_DIR"
echo "📂 출력 디렉토리: $GALLERY_DIR"

# 갤러리 디렉토리 생성
mkdir -p "$GALLERY_DIR"

# ImageMagick 설치 확인
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

# jpegoptim도 확인 (backup 옵션)
JPEGOPTIM_PATH=""
if command -v jpegoptim &> /dev/null; then
    JPEGOPTIM_PATH="jpegoptim"
    echo "✅ jpegoptim도 사용 가능 (backup 옵션)"
elif [ -f "/usr/bin/jpegoptim" ]; then
    JPEGOPTIM_PATH="/usr/bin/jpegoptim"
    echo "✅ jpegoptim도 사용 가능 (backup 옵션)"
fi

# 이미지 최적화 함수
optimize_image() {
    local image_num="$1"
    local original_file="$ORIGINAL_DIR/image${image_num}.jpg"
    local output_file="$GALLERY_DIR/image${image_num}.jpg"
    local filename="image${image_num}.jpg"
    
    # 원본 파일 존재 확인
    if [ ! -f "$original_file" ]; then
        echo "⚠️  원본 파일 없음: $original_file"
        return 1
    fi
    
    # 파일 크기 확인
    local file_size=$(stat -c%s "$original_file" 2>/dev/null || stat -f%z "$original_file")
    local file_size_mb=$((file_size / 1024 / 1024))
    
    echo "📊 처리 중: $filename (원본: ${file_size_mb}MB)"
    
    # 2MB (2097152 bytes) 보다 큰 경우에만 리사이징
    if [ "$file_size" -gt 2097152 ]; then
        # 품질 80%로 리사이징하면서 최대 2MB 목표
        echo "  🔧 ImageMagick 실행: $CONVERT_PATH '$original_file' -> '$output_file.tmp'"
        $CONVERT_PATH "$original_file" \
            -auto-orient \
            -quality 80 \
            -resize '1920x1920>' \
            -strip \
            "$output_file.tmp"
        
        # 명령 실행 결과 확인
        if [ $? -ne 0 ]; then
            echo "  ❌ ImageMagick 명령 실패"
            return 1
        fi
        
        # 결과 파일이 실제로 생성되었는지 확인
        if [ ! -f "$output_file.tmp" ] || [ ! -s "$output_file.tmp" ]; then
            echo "  ❌ 출력 파일이 생성되지 않았거나 비어있음"
            return 1
        fi
        
        # 결과 파일 크기 확인
        local new_size=$(stat -c%s "$output_file.tmp" 2>/dev/null || stat -f%z "$output_file.tmp")
        local new_size_mb=$((new_size / 1024 / 1024))
        
        # 여전히 2MB보다 큰 경우 더 강한 압축
        if [ "$new_size" -gt 2097152 ]; then
            echo "  🔧 2차 압축 시도 (품질 70%)"
            $CONVERT_PATH "$original_file" \
                -auto-orient \
                -quality 70 \
                -resize '1600x1600>' \
                -strip \
                "$output_file.tmp"
            if [ -s "$output_file.tmp" ]; then
                new_size=$(stat -c%s "$output_file.tmp" 2>/dev/null || stat -f%z "$output_file.tmp")
                new_size_mb=$((new_size / 1024 / 1024))
            fi
        fi
        
        # 그래도 2MB보다 큰 경우 더 작게
        if [ "$new_size" -gt 2097152 ]; then
            echo "  🔧 3차 압축 시도 (품질 60%)"
            $CONVERT_PATH "$original_file" \
                -auto-orient \
                -quality 60 \
                -resize '1400x1400>' \
                -strip \
                "$output_file.tmp"
            if [ -s "$output_file.tmp" ]; then
                new_size=$(stat -c%s "$output_file.tmp" 2>/dev/null || stat -f%z "$output_file.tmp")
                new_size_mb=$((new_size / 1024 / 1024))
            fi
        fi
        
        # 최종 파일 크기가 여전히 문제가 있다면 jpegoptim 시도
        if [ "$new_size" -eq 0 ] && [ -n "$JPEGOPTIM_PATH" ]; then
            echo "  🔄 ImageMagick 실패, jpegoptim으로 fallback"
            cp "$original_file" "$output_file"
            $JPEGOPTIM_PATH --max=75 --strip-all "$output_file"
            if [ -s "$output_file" ]; then
                new_size=$(stat -c%s "$output_file" 2>/dev/null || stat -f%z "$output_file")
                new_size_mb=$((new_size / 1024 / 1024))
                echo "✅ jpegoptim으로 완료: $filename (${file_size_mb}MB → ${new_size_mb}MB)"
            else
                echo "❌ jpegoptim도 실패, 원본 복사"
                cp "$original_file" "$output_file"
            fi
        else
            # 최적화된 파일을 최종 위치로 이동
            mv "$output_file.tmp" "$output_file"
            echo "✅ 최적화 완료: $filename (${file_size_mb}MB → ${new_size_mb}MB)"
        fi
    else
        # 2MB 이하인 경우 그냥 복사
        cp "$original_file" "$output_file"
        echo "✅ 복사 완료: $filename (${file_size_mb}MB - 이미 적절한 크기)"
    fi
}

# 1~13번 이미지만 처리
echo ""
for i in 0 1 2 3 4 5 6 7 8 9 10 11 12 13; do
    echo "🔄 이미지 $i 처리 시작..."
    optimize_image "$i"
done

# 기존 갤러리의 14~20번 이미지 제거 (혹시 있다면)
echo ""
echo "🗑️  사용하지 않는 이미지 제거 중..."
for i in 14 15 16 17 18 19 20; do
    gallery_file="$GALLERY_DIR/image${i}.jpg"
    if [ -f "$gallery_file" ]; then
        rm "$gallery_file"
        echo "🗑️  제거됨: image${i}.jpg"
    fi
done

echo ""
echo "🎉 이미지 최적화 완료!"
echo "📂 원본 이미지: $ORIGINAL_DIR"
echo "📂 최적화된 이미지: $GALLERY_DIR"
echo ""
echo "📊 최종 결과 (갤러리):"
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13; do
    if [ -f "$GALLERY_DIR/image${i}.jpg" ]; then
        ls -lh "$GALLERY_DIR/image${i}.jpg"
    fi
done
