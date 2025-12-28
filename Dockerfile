# Multi-stage build for Next.js production - Node.js 24 TEST VERSION
FROM node:24-alpine AS base

# Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Install dependencies based on the preferred package manager
COPY package.json package-lock.json* ./
RUN \
  if [ -f package-lock.json ]; then npm ci; \
  else echo "Lockfile not found." && exit 1; \
  fi

# Rebuild the source code only when needed
FROM base AS builder
RUN apk add --no-cache imagemagick
WORKDIR /app

# Build arguments (빌드 시점에 전달되는 시크릿)
ARG NEXT_PUBLIC_NAVER_MAP_CLIENT_ID
ENV NEXT_PUBLIC_NAVER_MAP_CLIENT_ID=$NEXT_PUBLIC_NAVER_MAP_CLIENT_ID

COPY --from=deps /app/node_modules ./node_modules
COPY . .

# 이미지 최적화 (원본 → 갤러리로 2MB 이하 리사이징)
RUN echo "🖼️ 갤러리 이미지 최적화 중..." && \
    mkdir -p public/images/gallery && \
    for i in $(seq 1 13); do \
        if [ -f "public/images/original/image${i}.jpg" ]; then \
            echo "처리 중: image${i}.jpg"; \
            /usr/bin/convert "public/images/original/image${i}.jpg" \
                -quality 75 \
                -resize '1600x1600>' \
                -strip \
                "public/images/gallery/image${i}.jpg"; \
            # 2MB 이하인지 확인하고, 아니면 더 압축 \
            if [ $(stat -c%s "public/images/gallery/image${i}.jpg") -gt 2097152 ]; then \
                /usr/bin/convert "public/images/original/image${i}.jpg" \
                    -quality 60 \
                    -resize '1400x1400>' \
                    -strip \
                    "public/images/gallery/image${i}.jpg"; \
            fi; \
        fi; \
    done && \
    # 갤러리에서 사용하지 않는 이미지 제거 \
    for i in $(seq 14 20); do \
        rm -f "public/images/gallery/image${i}.jpg"; \
    done && \
    echo "✅ 이미지 최적화 완료"

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

# Copy the public folder
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
