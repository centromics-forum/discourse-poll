# frozen_string_literal: true

class HotPollSerializer < ApplicationSerializer
  attributes :id,
             :name,
             :type,
             :status,
             :public,
             :post_id,
             :category_name,
             :post_url,
             :post_topic_title,
             :post_topic_overview

  def public
    true
  end

  def post_url
    object.post.url
  end

  def post_topic_title
    object.post&.topic&.title
  end

  def post_topic_overview
    html_string = object.post&.cooked
    doc = Nokogiri::HTML(html_string)
    doc.css('.poll').each(&:remove)
    doc.css('.poll-data-link').each(&:remove)

    doc.to_html
  end
end
