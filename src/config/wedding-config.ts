const uniqueIdentifier = "JWK-WEDDING-TEMPLATE-V1";

// 갤러리 레이아웃 타입 정의
type GalleryLayout = "scroll" | "grid";
type GalleryPosition = "middle" | "bottom";

interface GalleryConfig {
  layout: GalleryLayout;
  position: GalleryPosition;
  images: string[];
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
    venue: "밀할학교 도산홀"
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
    name: "밀할학교 도산홀",
    address: "서울 강남구 일원동 713\n신관 2층 도산홀",
    tel: "02-1234-5678",
    naverMapId: "밀할학교 도산홀", // 네이버 지도 검색용 장소명
    coordinates: {
      latitude: 37.4874,
      longitude: 127.0822,
    },
    placeId: "123456789", // 네이버 지도 장소 ID
    mapZoom: "17", // 지도 줌 레벨
    mapNaverCoordinates: "14141300,4507203,15,0,0,0,dh", // 네이버 지도 길찾기 URL용 좌표 파라미터 (구 형식)
    transportation: {
      subway: "3호선 일원역 2번 출구에서 도보 10분",
      bus: "간선\n 146, 362, 401\n지선\n 3412, 4412",
    },
    parking: "학교 내 주차장 이용 가능",
  },

  // 갤러리
  gallery: {
    layout: "grid" as GalleryLayout, // "scroll" 또는 "grid" 선택
    position: "bottom" as GalleryPosition, // "middle" (현재 위치) 또는 "bottom" (맨 하단) 선택
    images: [
      "/images/gallery/image1.jpg",
      "/images/gallery/image2.jpg",
      "/images/gallery/image3.jpg",
      "/images/gallery/image4.jpg",
      "/images/gallery/image5.jpg",
      "/images/gallery/image6.jpg",
      "/images/gallery/image7.jpg",
      "/images/gallery/image8.jpg",
      "/images/gallery/image9.jpg",
      "/images/gallery/image10.jpg",
      "/images/gallery/image11.jpg",
      "/images/gallery/image12.jpg",
      "/images/gallery/image13.jpg",
      "/images/gallery/image14.jpg",
      "/images/gallery/image15.jpg",
      "/images/gallery/image16.jpg",
      "/images/gallery/image17.jpg",
      "/images/gallery/image18.jpg",
      "/images/gallery/image19.jpg",
      "/images/gallery/image20.jpg",
    ],
  } as GalleryConfig,

  // 초대의 말씀
  invitation: {
    message: "한 줄기 별빛이 되어 만난 인연\n평생을 함께 걸어가려 합니다.\n\n소중한 분들의 축복 속에\n저희 두 사람이 첫 걸음을 내딛습니다.\n\n귀한 시간 내어 함께해 주신다면\n그 어떤 축복보다 값진 선물이 될 것입니다.",
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

  // 계좌번호 (비활성화)
  account: {
    enabled: false, // 계좌번호 섹션 비활성화
    groom: {
      bank: "은행명",
      number: "123-456-789012",
      holder: "김예준",
    },
    bride: {
      bank: "은행명",
      number: "987-654-321098",
      holder: "박영서",
    },
    groomFather: {
      bank: "은행명",
      number: "111-222-333444",
      holder: "김영진",
    },
    groomMother: {
      bank: "은행명",
      number: "555-666-777888",
      holder: "이혜영",
    },
    brideFather: {
      bank: "은행명",
      number: "999-000-111222",
      holder: "박동수",
    },
    brideMother: {
      bank: "은행명",
      number: "333-444-555666",
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
    webhookUrl: process.env.NEXT_PUBLIC_SLACK_WEBHOOK_URL || "",
    channel: "#wedding-response",
    compactMessage: true, // 슬랙 메시지를 간결하게 표시
  },
}; 
