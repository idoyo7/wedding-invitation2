import { NextResponse } from 'next/server';
import fs from 'fs';
import path from 'path';
import { weddingConfig } from '../../../src/config/wedding-config';

export async function GET() {
  try {
    // 갤러리 폴더 경로
    const galleryDir = path.join(process.cwd(), 'public/images/gallery');
    
    // 폴더가 존재하지 않는 경우
    if (!fs.existsSync(galleryDir)) {
      return NextResponse.json({ images: weddingConfig.gallery.images });
    }
    
    // 폴더 내 파일 목록 읽기
    const files = fs.readdirSync(galleryDir);
    
    // 스마트 이미지 선택: 각 번호별로 WebP 또는 JPG 중 최적 선택
    const smartImages: string[] = [];
    
    // image1~image9까지 확인
    for (let i = 1; i <= 9; i++) {
      const webpFile = `image${i}.webp`;
      const jpgFile = `image${i}.jpg`;
      
      if (files.includes(webpFile)) {
        // WebP가 존재하면 WebP 사용
        smartImages.push(`/images/gallery/${webpFile}`);
      } else if (files.includes(jpgFile)) {
        // WebP가 없고 JPG가 존재하면 JPG 사용
        smartImages.push(`/images/gallery/${jpgFile}`);
      }
    }
    
    return NextResponse.json({ images: smartImages });
  } catch (error) {
    console.error('갤러리 이미지 로드 오류:', error);
    return NextResponse.json(
      { 
        error: '갤러리 이미지를 불러오는 중 오류가 발생했습니다.',
        images: weddingConfig.gallery.images // 에러 시 config 설정 반환
      }, 
      { status: 500 }
    );
  }
} 