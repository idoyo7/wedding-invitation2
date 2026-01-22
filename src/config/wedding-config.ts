const uniqueIdentifier = "JWK-WEDDING-TEMPLATE-V1";

// 갤러리 레이아웃 타입 정의
type GalleryLayout = "scroll" | "grid";
type GalleryPosition = "middle" | "bottom";

interface GalleryConfig {
  layout: GalleryLayout;
  position: GalleryPosition;
  aspectRatio: "1:1" | "2:3" | "3:2" | "4:3" | "16:9"; // 썸네일 비율
  images: string[];
}

// 이펙트 설정 인터페이스
interface EffectsConfig {
  enabled: boolean; // 전체 이펙트 활성화/비활성화
  pageTransition: boolean; // 페이지 로딩 애니메이션
  scrollAnimation: boolean; // 스크롤 애니메이션  
  imageHover: boolean; // 이미지 호버 효과
  textAnimation: boolean; // 텍스트 애니메이션
  backgroundParticles: boolean; // 배경 파티클
  fallingElements: "none" | "hearts" | "petals" | "snow" | "sparkles" | "minimal" | "geometric"; // 떨어지는 요소들
  galleryAnimation: boolean; // 갤러리 애니메이션
  buttonAnimation: boolean; // 버튼 애니메이션
}

export const weddingConfig = {
  // 메타 정보
  meta: {
    title: "김예준 ❤️ 박영서의 결혼식에 초대합니다",
    description: "결혼식 초대장",
    ogImage: "/images/ha0h-1fsi-bqt3.jpg",
    noIndex: true,
    _jwk_watermark_id: uniqueIdentifier,
  },

  // 메인 화면
  main: {
    title: "Wedding Invitation",
    image: "/images/ha0h-1fsi-bqt3.jpg",
    date: "2026년 2월 28일 토요일 16시",
    venue: "밀알학교 도산홀"
  },

  // 소개글
  intro: {
    title: "",
    text: "서로를 바라보며 걸어온\n소중한 발걸음이\n이제 하나의 길로 이어집니다.\n\n사랑과 믿음으로\n새 가정을 이루는 저희 두 사람의\n작은 시작을 알려드립니다."
  },

  // 결혼식 일정
  date: {
    year: 2026,
    month: 2,
    day: 28,
    hour: 16,
    minute: 0,
    displayDate: "2026.02.28 FRI PM 04:00",
  },
  // 장소 정보
  venue: {
    name: "밀알학교 도산홀",
    address: "서울 강남구 일원로 90\n(일원동 713) 신관 2층 도산홀", 
    tel: "02-1234-5678",
    naverMapId: "밀알학교", // 네이버 지도 검색용 장소명
    coordinates: {
      latitude: 37.4860906,  // 밀알학교 실제 좌표
      longitude: 127.0823399,
    },
    placeId: "11617296",
    mapZoom: "17", // 지도 줌 레벨
    mapNaverCoordinates: "14141300,4507203,15,0,0,0,dh", // 네이버 지도 길찾기 URL용 좌표 파라미터 (구 형식)
    transportation: {
      subway: "3호선 일원역 2번 출구에서 도보 10분",
      bus: "간선\n 146, 362, 401\n지선\n 3412, 4412",
    },
    parking: "학교 내 주차장 이용 가능",
    // 배차 안내 비활성화 (빈 문자열로 설정하여 UI에서 표시되지 않도록 함)
    groomShuttle: {
      location: "",
      departureTime: "",
      contact: {
        name: "",
        tel: ""
      }
    },
    brideShuttle: {
      location: "",
      departureTime: "",
      contact: {
        name: "",
        tel: ""
      }
    }
  },

  // 갤러리
  gallery: {
    layout: "grid" as GalleryLayout, // "scroll" 또는 "grid" 선택
    position: "bottom" as GalleryPosition, // "middle" (현재 위치) 또는 "bottom" (맨 하단) 선택
    aspectRatio: "2:3" as const, // "1:1" (정사각형), "2:3" (세로 사진), "3:2" (가로 사진), "4:3" (디지털), "16:9" (와이드)
    images: [
      "/images/gallery/image1.webp",
      "/images/gallery/image2.webp",
      "/images/gallery/image3.webp",
    ],
  } as GalleryConfig,

  // 초대의 말씀
  invitation: {
    message: "초대합니다.\n서로 다르지만 닮은 두 사람이\n사람들의 축복 아래\n결혼식을 하게 되었습니다.\n\n하나님 안에 새로운 인생을 시작하는\n자리에 오셔서 축복해주세요.\n\n귀한 발걸음으로 오시고, 후의를 베풀어 주신 분들의 마음을 깊이\n간직하겠습니다.\n\n항상 가정에 행복과 건강이\n함께 하시길 기원합니다.",
    groom: {
      name: "김예준",
      label: "아들",
      father: "김영진",
      mother: "이혜영",
    },
    bride: {
      name: "박영서",
      label: "딸",
      father: "박동수",
      mother: "김선미",
    },
  },

  // 계좌번호
  account: {
    enabled: true, // 계좌번호 섹션 활성화
    groom: {
      bank: "신한은행",
      number: "110-435-910271",
      holder: "김예준",
    },
    bride: {
      bank: "신한은행",
      number: "110-495-069227",
      holder: "박영서",
    },
    groomFather: {
      bank: "하나은행",
      number: "152-004674-00107",
      holder: "김영진",
    },
    groomMother: {
      bank: "신한은행",
      number: "110-074-863512",
      holder: "이혜영",
    },
    brideFather: {
      bank: "국민은행",
      number: "546925-01-055438",
      holder: "박동수",
    },
    brideMother: {
      bank: "국민은행",
      number: "465102-01-215246",
      holder: "김선미",
    }
  },

  // RSVP 설정
  rsvp: {
    enabled: false, // RSVP 섹션 표시 여부
    showMealOption: false, // 식사 여부 입력 옵션 표시 여부
  },

  // 슬랙 알림 설정
  slack: {
    webhookUrl: (typeof process !== 'undefined' ? process.env.NEXT_PUBLIC_SLACK_WEBHOOK_URL : '') || "",
    channel: "#wedding-response",
    compactMessage: true, // 슬랙 메시지를 간결하게 표시
  },

  // 이펙트 설정
  effects: {
    enabled: false, // 전체 이펙트 활성화
    pageTransition: false, // 페이지 로딩 애니메이션 (부드러운 fade-in)
    scrollAnimation: false, // 스크롤 시 섹션 등장 애니메이션
    imageHover: false, // 이미지 호버 시 확대/회전 효과 (썸네일 로딩 문제로 비활성화)
    textAnimation: false, // 텍스트 타이핑 애니메이션 (기본 비활성화)
    backgroundParticles: false, // 배경 파티클 효과 (성능상 기본 비활성화)
    fallingElements: "hearts", // 떨어지는 효과 ("none", "hearts", "snow", "sparkles", "minimal", "geometric")
    galleryAnimation: false, // 갤러리 이미지 애니메이션 (썸네일 로딩 문제로 비활성화)
    buttonAnimation: false, // 버튼 호버 애니메이션
  } as EffectsConfig,
}; 
