/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  compiler: {
    styledComponents: true,
  },
  
  // 이미지 최적화 설정
  // - 기본값은 런타임 최적화 비활성화(저사양 서버에서 첫 방문 CPU 스파이크 방지)
  // - 필요하면 NEXT_PUBLIC_ENABLE_NEXT_IMAGE_OPTIMIZATION=true 로 켜서 비교/튜닝 가능
  images: {
    unoptimized: process.env.NEXT_PUBLIC_ENABLE_NEXT_IMAGE_OPTIMIZATION !== 'true',
    formats: ['image/avif', 'image/webp'],
    // 런타임 최적화를 켰을 때만 의미 있는 설정들(캐시/리사이즈 폭 제한)
    minimumCacheTTL: 60 * 60 * 24 * 30, // 30일
    deviceSizes: [360, 390, 414, 430, 768, 1024, 1280],
    imageSizes: [150, 250, 300, 400, 600, 800, 1200, 1600, 1920],
    // Next.js 16 기본값은 [75]로 축소됨. 코드가 quality={85}/{90}을 명시적으로 쓰므로
    // 허용 목록에 포함해 자동 클램프(화질 저하)를 막는다.
    qualities: [75, 85, 90],
  },
  
  // 성능 최적화 설정
  // Next.js 15에서는 swcMinify 옵션이 제거되었습니다
  
  // 외부 이미지 도메인 설정 (필요시 추가)
  // images: {
  //   domains: ['example.com'],
  // },
  
  // 환경 변수 설정
  env: {
    NEXT_PUBLIC_SITE_URL: process.env.NEXT_PUBLIC_SITE_URL,
    NEXT_PUBLIC_NAVER_MAP_CLIENT_ID: process.env.NEXT_PUBLIC_NAVER_MAP_CLIENT_ID,
  },
  
  // 캐시 정책을 더 스마트하게 설정
  async headers() {
    return [
      // HTML 파일들은 짧은 캐시 (즉시 업데이트 반영)
      {
        source: '/',
        headers: [
          {
            key: 'Cache-Control',
            value: 'public, max-age=0, must-revalidate',
          },
        ],
      },
      {
        source: '/:path*',
        has: [
          {
            type: 'header',
            key: 'accept',
            value: 'text/html.*',
          },
        ],
        headers: [
          {
            key: 'Cache-Control',
            value: 'public, max-age=0, must-revalidate',
          },
        ],
      },
      // 정적 에셋들 (이미지, 폰트 등)은 장기간 캐시
      {
        source: '/images/:path*',
        headers: [
          {
            key: 'Cache-Control',
            value: 'public, max-age=31536000, immutable',
          },
        ],
      },
      {
        source: '/fonts/:path*',
        headers: [
          {
            key: 'Cache-Control',
            value: 'public, max-age=31536000, immutable',
          },
        ],
      },
      // JS/CSS 파일들 (Next.js가 자동으로 해시 추가)
      {
        source: '/_next/static/:path*',
        headers: [
          {
            key: 'Cache-Control',
            value: 'public, max-age=31536000, immutable',
          },
        ],
      },
      // next/image 최적화 결과 캐싱(동일 url+w+q 조합은 사실상 immutable)
      {
        source: '/_next/image',
        headers: [
          {
            key: 'Cache-Control',
            value: 'public, max-age=31536000, immutable',
          },
        ],
      },
      // API 라우트는 캐시하지 않음
      {
        source: '/api/:path*',
        headers: [
          {
            key: 'Cache-Control',
            value: 'no-cache, no-store, max-age=0, must-revalidate',
          },
        ],
      },
    ];
  },
};

export default nextConfig;
