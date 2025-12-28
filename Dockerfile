# Multi-stage build for Next.js production - Node.js 24 TEST VERSION
FROM node:24-alpine AS base

# Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json package-lock.json* ./

# 의존성 설치 (프로덕션 + 개발 의존성)
RUN \
  if [ -f package-lock.json ]; then \
    npm ci; \
  else \
    echo "Lockfile not found." && exit 1; \
  fi

# Rebuild the source code only when needed
FROM base AS builder
RUN apk add --no-cache imagemagick imagemagick-jpeg imagemagick-webp libjpeg-turbo-dev
WORKDIR /app

# Build arguments (빌드 시점에 전달되는 시크릿)
ARG NEXT_PUBLIC_NAVER_MAP_CLIENT_ID
ENV NEXT_PUBLIC_NAVER_MAP_CLIENT_ID=$NEXT_PUBLIC_NAVER_MAP_CLIENT_ID

COPY --from=deps /app/node_modules ./node_modules
COPY . .

# WebP 이미지 최적화 (원본 JPG → WebP 갤러리로 변환, 원본 제거)
RUN echo "🖼️ WebP 이미지 최적화 시작..." && \
    mkdir -p public/images/gallery && \
    if command -v convert >/dev/null 2>&1; then \
        echo "✅ ImageMagick 발견"; \
        for i in 1 2 3 4 5 6 7 8 9; do \
            if [ -f "public/images/original/image${i}.jpg" ]; then \
                echo "🔄 처리 중: image${i}.jpg → image${i}.webp (원본 해상도 유지)"; \
                convert "public/images/original/image${i}.jpg" \
                    -auto-orient \
                    -quality 90 \
                    -strip \
                    "public/images/gallery/image${i}.webp.tmp"; \
                # WebP가 원본보다 작은 경우만 사용 \
                orig_size=$(stat -c%s "public/images/original/image${i}.jpg" 2>/dev/null || echo 0); \
                webp_size=$(stat -c%s "public/images/gallery/image${i}.webp.tmp" 2>/dev/null || echo 0); \
                if [ "$webp_size" -gt 0 ] && [ "$webp_size" -lt "$orig_size" ]; then \
                    mv "public/images/gallery/image${i}.webp.tmp" "public/images/gallery/image${i}.webp"; \
                    rm -f "public/images/original/image${i}.jpg"; \
                    echo "✅ WebP 사용: image${i} (압축됨, 원본 제거)"; \
                else \
                    rm -f "public/images/gallery/image${i}.webp.tmp"; \
                    cp "public/images/original/image${i}.jpg" "public/images/gallery/image${i}.jpg"; \
                    rm -f "public/images/original/image${i}.jpg"; \
                    echo "⚠️ JPG 유지: image${i} (WebP가 더 큼, 원본 제거)"; \
                fi; \
            fi; \
        done; \
        # 원본 디렉토리가 비어있으면 제거 \
        if [ -d "public/images/original" ] && [ -z "$(ls -A public/images/original)" ]; then \
            rmdir public/images/original; \
            echo "🗑️ 빈 원본 디렉토리 제거됨"; \
        fi; \
    else \
        echo "❌ ImageMagick 없음, 원본 JPG 유지"; \
    fi && \
    echo "🖼️ Hero 이미지 WebP 생성 (ha0h-1fsi-bqt3.jpg → .webp, 리사이즈)..." && \
    if command -v convert >/dev/null 2>&1 && [ -f "public/images/ha0h-1fsi-bqt3.jpg" ]; then \
        convert "public/images/ha0h-1fsi-bqt3.jpg" \
            -auto-orient \
            -quality 95 \
            -strip \
            "public/images/ha0h-1fsi-bqt3.webp.tmp" && \
        if [ -s "public/images/ha0h-1fsi-bqt3.webp.tmp" ]; then \
            mv "public/images/ha0h-1fsi-bqt3.webp.tmp" "public/images/ha0h-1fsi-bqt3.webp"; \
            echo "✅ Hero WebP 생성됨: public/images/ha0h-1fsi-bqt3.webp"; \
        else \
            rm -f "public/images/ha0h-1fsi-bqt3.webp.tmp"; \
            echo "⚠️ Hero WebP 생성 실패(빈 파일). JPG 유지"; \
        fi; \
    else \
        echo "ℹ️ Hero JPG 없음 또는 ImageMagick 없음. 스킵"; \
    fi && \
    echo "🎉 WebP 최적화 완료" && \
    ls -lh public/images/gallery/ || echo "갤러리 디렉토리 없음"

# Environment variables for build
ENV NEXT_TELEMETRY_DISABLED=1

# Build the application
RUN npm run build

# Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Create non-root user
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy the public folder (원본 이미지는 이미 제거됨, WebP만 포함)
COPY --from=builder /app/public ./public

# Set the correct permission for prerender cache
RUN mkdir .next
RUN chown nextjs:nodejs .next

# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Start the application
CMD ["node", "server.js"]
