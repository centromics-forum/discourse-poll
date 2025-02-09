import { withPluginApi } from "discourse/lib/plugin-api";

function initializeSwiper(api) {

}




export default {
  name: "add-swiper",

  initialize() {
    withPluginApi("1.14.0", initializeSwiper);
  },
};
