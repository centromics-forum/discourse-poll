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
  new Swiper('.swiper1', {
    loop: false,
    centeredSlides: false, // 중앙 정렬 해제 (필요 시 true로 변경)
    resizeObserver: false,
    navigation: {
      nextEl: '.swiper-button-next',
      prevEl: '.swiper-button-prev',
    },
    scrollbar: {
      el: '.swiper-scrollbar',
      draggable: true, // 스크롤바를 드래그 가능하게 설정
    },
  });

  new Swiper('.swiper2', {
    loop: false,
    centeredSlides: false, // 중앙 정렬 해제 (필요 시 true로 변경)
    resizeObserver: false,
    navigation: {
      nextEl: '.swiper-button-next',
      prevEl: '.swiper-button-prev',
    },
    scrollbar: {
      el: '.swiper-scrollbar2',
      draggable: true, // 스크롤바를 드래그 가능하게 설정
    },
  });
}


export default {
  name: "add-swiper",

  initialize() {
    withPluginApi("1.14.0", initializeSwiper);
  },
};
