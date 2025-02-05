import { withPluginApi } from "discourse/lib/plugin-api";

function initializeSwiper(api) {
  api.onPageChange(() => {
    if (!window.Swiper) {
      $.getScript("https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.js", () => {
        initSwiper();
      });
    } else {
      initSwiper();
    }
  });
}

function initSwiper() {
  new Swiper('.swiper', {
    loop: false,
    slidesPerView: 3, // 한 번에 3개씩 표시
    spaceBetween: 10, // 슬라이드 간 간격
    centeredSlides: false, // 중앙 정렬 해제 (필요 시 true로 변경)
    navigation: {
      nextEl: '.swiper-button-next',
      prevEl: '.swiper-button-prev',
    },
    pagination: {
      el: '.swiper-pagination',
      clickable: true,
      dynamicBullets: true,
    },
  });
}


export default {
  name: "add-swiper",

  initialize() {
    withPluginApi("1.14.0", initializeSwiper);
  },
};
