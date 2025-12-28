#!/bin/bash

# Docker 빌드 스크립트
set -e

echo "🐳 Building Wedding Invitation Docker Image..."

# 이미지 태그 설정
IMAGE_NAME="wedding-invitation"
TAG=${1:-latest}
FULL_TAG="$IMAGE_NAME:$TAG"

echo "📦 Building image: $FULL_TAG"

# Docker 빌드
docker build -t "$FULL_TAG" .

echo "✅ Build completed successfully!"
echo "📊 Image information:"
docker images "$IMAGE_NAME:$TAG"

echo ""
echo "🚀 To run the container:"
echo "   docker run -d -p 3000:3000 --name wedding-app $FULL_TAG"
echo ""
echo "🔍 To test the container:"
echo "   docker run -it --rm -p 3000:3000 $FULL_TAG"
echo ""
echo "📝 To push to registry (after login):"
echo "   docker tag $FULL_TAG your-registry/wedding-invitation:$TAG"
echo "   docker push your-registry/wedding-invitation:$TAG"
