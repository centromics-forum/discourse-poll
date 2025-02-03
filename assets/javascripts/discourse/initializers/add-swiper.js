import { withPluginApi } from "discourse/lib/plugin-api";
// import Swiper from '../../vendor/swiper/swiper-bundle.mjs';

function initializeSwiper(api) {
  api.onPageChange(() => {
    const loadSwiper = async () => {

      const { default: Swiper } = await import("https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.mjs");
      const container = document.querySelector(".swiper");

      console.log('asdfasd');

      if (container) {
        new Swiper(container, {
          loop: true,
          pagination: { el: ".swiper-pagination", clickable: true },
          navigation: {
            nextEl: ".swiper-button-next",
          },
        });
      }
    };

  });
};


export default {
  name: "add-swiper",

  initialize() {
    withPluginApi("1.14.0", initializeSwiper);
  },
};
