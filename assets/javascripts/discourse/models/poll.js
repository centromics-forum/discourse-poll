import { tracked } from "@glimmer/tracking";
import I18n from "I18n";

export default class Poll {
  static create(args = {}) {
    return new Poll(args);
  }

  @tracked id;
  @tracked createdAt;
  @tracked updatedAt;
  @tracked createdById;
  @tracked excludedGroupsIds;
  @tracked includedGroupsIds;
  @tracked visibleToGroupsIds;
  @tracked forCategoryId;
  @tracked fromDate;
  @tracked toDate;
  @tracked name;
  @tracked period;

  constructor(args = {}) {
    this.id = args.id;
    this.createdAt = args.created_at;
    this.updatedAt = args.updated_at;
    this.createdById = args.created_by_id;
    this.excludedGroupsIds = args.excluded_groups_ids;
    this.includedGroupsIds = args.included_groups_ids;
    this.visibleToGroupsIds = args.visible_to_groups_ids;
    this.forCategoryId = args.for_category_id;
    this.fromDate = args.from_date;
    this.toDate = args.to_date;
    this.name = args.name;
    this.period = args.period;
  }
}
