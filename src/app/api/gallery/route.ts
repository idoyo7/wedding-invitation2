import { NextResponse } from 'next/server';

export async function GET() {
  try {
    // 3개의 갤러리 이미지 설정
    const images = [
      '/images/gallery/image1.webp',
      '/images/gallery/image2.webp',
      '/images/gallery/image3.webp',
    ];

    const thumbs = [
      '/images/gallery/thumbs/image1.webp',
      '/images/gallery/thumbs/image2.webp', 
      '/images/gallery/thumbs/image3.webp',
    ];

    return NextResponse.json({
      images,
      thumbs,
      count: images.length
    });
  } catch (error) {
    console.error('Gallery API Error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch gallery images' },
      { status: 500 }
    );
  }
}