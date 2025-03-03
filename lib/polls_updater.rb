# frozen_string_literal: true

module DiscoursePoll
  class PollsUpdater
    POLL_ATTRIBUTES ||= %w[close_at max min results status step type visibility title groups score]
    POLL_DATA_LINK_ATTRIBUTES ||= %w[title url content]

    def self.update(post, polls)
      ::Poll.transaction do
        has_changed = false
        edit_window = SiteSetting.poll_edit_window_mins

        old_poll_names = ::Poll.where(post: post).pluck(:name)
        new_poll_names = polls.keys

        deleted_poll_names = old_poll_names - new_poll_names
        created_poll_names = new_poll_names - old_poll_names

        # delete polls
        if deleted_poll_names.present?
          ::Poll.where(post: post, name: deleted_poll_names).destroy_all
        end

        # create polls
        if created_poll_names.present?
          has_changed = true
          polls.slice(*created_poll_names).values.each { |poll| Poll.create!(post.id, poll) }
        end

        pp "############## pollupdatr #{polls}"

        # update polls
        ::Poll
          .includes(:poll_votes, :poll_options, :poll_data_links)
          .where(post: post)
          .find_each do |old_poll|
            new_poll = polls[old_poll.name]
            new_poll_options = new_poll["options"]
            new_poll_data_links = new_poll["data_links"]

            attributes = new_poll.slice(*POLL_ATTRIBUTES)
            attributes["visibility"] = new_poll["public"] == "true" ? "everyone" : "secret"
            attributes["close_at"] = begin
              Time.zone.parse(new_poll["close"])
            rescue StandardError
              nil
            end
            attributes["status"] = old_poll["status"]
            attributes["groups"] = new_poll["groups"]
            poll = ::Poll.new(attributes)

            pp "poll: name:#{old_poll.name} #{attributes.inspect}"
            pp "new_poll: name:#{new_poll['name']} #{new_poll_options.inspect}"

            if is_different?(old_poll, poll, new_poll_options, new_poll_data_links)
              # only prevent changes when there's at least 1 vote
              if old_poll.poll_votes.size > 0
                # can't change after edit window (when enabled)
                if edit_window > 0 && old_poll.created_at < edit_window.minutes.ago
                  # NOTE: (투표수가 있을때) 처음 5분 후에는 폴링을 변경할 수 없습니다. 오류로 인해서 election stage 변경이 안됩니다.
                  #       무시하게 다음을 주석처리함.
                  # 참고: discourse-election-plugin: election-save-current-stage.js#save()

                  # error =
                  #   (
                  #     if poll.name == DiscoursePoll::DEFAULT_POLL_NAME
                  #       I18n.t(
                  #         "poll.edit_window_expired.cannot_edit_default_poll_with_votes",
                  #         minutes: edit_window,
                  #       )
                  #     else
                  #       I18n.t(
                  #         "poll.edit_window_expired.cannot_edit_named_poll_with_votes",
                  #         minutes: edit_window,
                  #         name: poll.name,
                  #       )
                  #     end
                  #   )

                  # post.errors.add(:base, error)
                  # # rubocop:disable Lint/NonLocalExitFromIterator
                  # return
                  # rubocop:enable Lint/NonLocalExitFromIterator
                end
              end

              # update poll
              POLL_ATTRIBUTES.each do |attr|
                old_poll.public_send("#{attr}=", poll.public_send(attr))
              end

              old_poll.save!

              # keep track of anonymous votes
              anonymous_votes =
                old_poll.poll_options.map { |pv| [pv.digest, pv.anonymous_votes] }.to_h

              # destroy existing options & votes
              ::PollOption.where(poll: old_poll).destroy_all

              # create new options
              new_poll_options.each do |option|
                ::PollOption.create!(
                  poll: old_poll,
                  correct: option["correct"],
                  digest: option["id"],
                  html: option["html"].strip,
                  anonymous_votes: anonymous_votes[option["id"]],
                )
              end

              # etna
              # destroy existing data links
              ::PollDataLink.where(poll: old_poll).destroy_all

              # create new options
              new_poll_data_links.each do |data_link|
                ::PollDataLink.create!(
                  poll: old_poll,
                  title: data_link["title"],
                  url: data_link["url"],
                  content: data_link["content"].strip,
                )
              end

              has_changed = true
            end
          end

        if ::Poll.exists?(post: post)
          post.custom_fields[HAS_POLLS] = true
        else
          post.custom_fields.delete(HAS_POLLS)
        end

        post.save_custom_fields(true)

        if has_changed
          polls = ::Poll.includes(poll_options: :poll_votes).where(post: post)
          polls =
            ActiveModel::ArraySerializer.new(
              polls,
              each_serializer: PollSerializer,
              root: false,
              scope: Guardian.new(nil),
            ).as_json
          post.publish_message!("/polls/#{post.topic_id}", post_id: post.id, polls: polls)
        end
      end
    end

    private

    def self.is_different?(old_poll, new_poll, new_options, new_poll_data_links)
#pp "is_different: #{new_options} #{new_poll_data_links}"

      # an attribute was changed?
      POLL_ATTRIBUTES.each do |attr|
        return true if old_poll.public_send(attr) != new_poll.public_send(attr)
      end

      sorted_old_options = old_poll.poll_options.map { |o| o.digest }.sort
      sorted_new_options = new_options.map { |o| o["id"] }.sort

      return true if sorted_old_options != sorted_new_options

      sorted_old_data_links = old_poll.poll_data_links.map { |o| o.url }.sort
      sorted_new_data_links = new_poll_data_links.map { |o| o['url'] }.sort

      # pp "##########sorted_old_data_links #{sorted_old_data_links}"

      # pp "##########sorted_new_data_links #{sorted_new_data_links}"

      return true if sorted_old_data_links != sorted_new_data_links

      #pp "##########new_poll_data_links2 #{old_poll.poll_data_links}"

      false
    end
  end
end
