import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import i18n from "discourse-common/helpers/i18n";
import I18n from "discourse-i18n";
import CategoryChooser from "select-kit/components/category-chooser";
import { htmlSafe } from "@ember/template";
import Category from "discourse/models/category";

import PollListItemWidget from "./poll-list-item-widget"
import PollListTab from "./poll-list-tab";


const dateOptions = {
  year: "numeric",
  month: "short",
  day: "numeric",
};

export default class PollListWidgetComponent extends Component {
  //@tracked poll;
  @tracked polls = [];
  @tracked hotPolls = [];
  @tracked inFrontpage = false;
  @service router;
  @service pollsService;
  @service pollsHotService;
  @service siteSettings;
  @tracked categoryId = this.pollsService.category;
  @tracked currentCategory = null;
  @service site;
  @tracked site_description;
  @tracked short_site_description;

  constructor() {
    super(...arguments);
    this.loadCurrentCategory();

    fetch('/about.json')
      .then(response => response.json())
      .then(data => {
        this.site_description=data.about.description;
      });

    this.categories=[];
    this.site.categories.forEach(category => {
      if (!category.topic_count) {
        return; // 다음 반복으로 넘어감
      }

      // console.log(category);
      this.categories.push(category);
    });
  }

  async loadCurrentCategory() {
    this.currentCategory = await Category.findById(this.categoryId);
  }

  // Fetch and update polls
  get getPolls() {
    return this.pollsService.polls;
  }

  get getHotPolls() {
    return this.pollsHotService.polls;
  }

  @action
  fetchPolls(element) {
    this.getHotPolls.then((result) => {
      let polls = result.polls.filter((poll) => poll.public === true);
      // polls = polls.map((poll) => {
      //   return {
      //     ...poll,
      //     post_topic_title_truncated: this.truncateString(poll.post_topic_title, 45),
      //   };
      // });
      // if (polls.length > 0) {
      //   this.poll = polls[0];
      // }
      this.hotPolls = polls;
      console.log("Fetched polls:", polls[0]);
    });

    this.getPolls.then((result) => {
      let polls = result.polls.filter((poll) => poll.public === true);
      // polls = polls.map((poll) => {
      //   return {
      //     ...poll,
      //     post_topic_title_truncated: this.truncateString(poll.post_topic_title, 45),
      //   };
      // });
      // if (polls.length > 0) {
      //   this.poll = polls[0];
      // }
      this.polls = polls;
      //console.log("Fetched polls:", polls);
    });
  }

  @action
  getCloseDateFormat(date_o) {
    return htmlSafe(
      '<span class="close-date">' + this.dateFormat(date_o) + "</span>"
    );
  }

  @action
  getOpenDateFormat(date_o) {
    return htmlSafe(
      '<span class="open-date">' + this.dateFormat(date_o) + "</span>"
    );
  }

  @action
  changeCategory(category) {
    this.pollsService.setCategory(category);
    this.fetchPolls();
    this.categoryId = category;

    this.loadCurrentCategory();
  }

  get isFrontpage() {
    return (
      this.router.currentRouteName === "discovery.latest" ||
      this.router.currentRouteName === "index"
    );
  }

  get showInFrontend() {
    return this.isFrontpage && this.siteSettings.poll_show_in_frontpage;
  }

  dateFormat(date_o) {
    if(date_o === undefined)
      return '';
    return new Date(date_o).toLocaleDateString(I18n.currentLocale(), dateOptions);
  }

  truncateString(str, len = 40) {
    if(!str)
      return str;
    else if (str.length > len) {
      return str.slice(0, len) + "...";
    }

    return str;
  }

  datePercentage(startDate, endDate) {
    const d1 = new Date(startDate);
    const d2 = new Date(endDate);

    const timeDifference = Math.abs(d2 - d1);
    const dayDifference = Math.ceil(timeDifference / (1000 * 60 * 60 * 24));

    const d3 = new Date(startDate);
    const d4 = new Date();

    const timeDifference2 = Math.abs(d4 - d3);
    const dayDifference2 = Math.ceil(timeDifference2 / (1000 * 60 * 60 * 24));

    const numValue = Number(dayDifference2);
    const numTotal = Number(dayDifference);

    // console.log(numValue)
    // console.log(numTotal)

    if (isNaN(numValue) || isNaN(numTotal) || numTotal === 0) {
      return 0;
    }

    const percentage = (numValue / numTotal) * 100;

    let return_value = Math.round(percentage);

    if(return_value >= 95) {
      return_value = 95;
    }

    return return_value;
 }

  <template>
    {{#if this.showInFrontend}}
      <div class="poll-widget-main" {{didInsert this.fetchPolls}}>
        <section>
          <h1>{{this.siteSettings.title}}</h1>
          <p>{{this.site_description}}</p>
        </section>


        <!-- Slider main container -->
          <section id="main-hot-polls" class="swiper">
            <h2><span>quiz</span> in progress</h2>
          <!-- Additional required wrapper -->
          <div class="swiper-wrapper">
            {{#if this.hotPolls.length}}
              <!-- Slides -->
              {{#each this.hotPolls as |poll index|}}
                <article class="swiper-slide">
                  <h3 class="text-with-line"><span>{{poll.category_name}}</span></h3>
                  <h3><span>{{poll.post_topic_title}}</span></h3>
                  <div>
                    {{{poll.post_topic_overview}}}
                  </div>
                  <a href="{{poll.post_url}}">Vote</a>
                </article>
          {{/each}}
        {{/if}}
          </div>
          <!-- If we need pagination -->
          <div class="swiper-pagination"></div>

          <!-- If we need navigation buttons -->
          <div class="swiper-button-next"></div>

          <!-- If we need scrollbar -->
          <div class="swiper-scrollbar"></div>
        </section>

        <section id="main-poll-category">
          {{#if this.categories.length}}
            {{#each this.categories as |category index|}}
              <article style="background-color:#{{category.color}}">
                <a href="{{category.url}}"> {{category.name}}<span style="color:#{{category.color}}">&gt;</span></a>
              </article>
            {{/each}}
          {{/if}}
        </section>

        <section id="main-polls">
          <h1 class="cv-title">
            <span class="black white-text">
              <CategoryChooser
                @value={{this.categoryId}}
                @onChange={{this.changeCategory}}
                class="leaderboard__period-chooser"
              />
            </span>
          </h1>
          <div class="poll-category-more">
            <a href="{{this.currentCategory.url}}">
              {{this.currentCategory.name}} {{i18n "poll.admin.more"}}
            </a><br>
            <a href="{{@siteURL}}/leaderboard/1?category={{this.categoryId}}">{{this.currentCategory.name}} {{i18n "poll.admin.leaderboard"}}</a>
          </div>
          {{#if this.polls.length}}
            {{#each this.polls as |poll index|}}
              <article class="item">
                <i class="vertical-line"></i>
                <h2 class="card-title">
                  <a href="{{poll.post_url}}">{{this.truncateString poll.post_topic_title 45}}<br>{{if poll.title poll.title}}</a>
                </h2>
                <div class="card-panel">
                  <h3 class="item-date">
                    {{(this.getOpenDateFormat poll.created_at)}}
                    {{#if poll.close}}
                      <span class="close-percentage" data="">
                        <span class="arrow" style="left: {{this.datePercentage poll.created_at poll.close}}%">&nbsp;</span>
                      </span>
                      {{this.getCloseDateFormat poll.close}}
                    {{/if}}
                   </h3>
                  <div class='poll-list-widget-wrap'>
                    {{!-- {{{poll.post_topic_poll}}} --}}
                    <PollListItemWidget @poll={{poll}} />
                  </div>
                  <PollListTab @poll={{poll}} />
                </div>
              </article>
            {{/each}}
            <div class="last-item">
              <i class="vertical-line"></i>
            </div>
          {{else}}
            <p>{{i18n "poll.admin.none"}}</p>
          {{/if}}
        </section>
      </div>
    {{/if}}
  </template>
}
