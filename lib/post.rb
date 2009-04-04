require 'maruku'
require 'syntax/convertors/html'

class Post
  include Makura::Model

  properties :title, :body, :slug, :tags, :not_public
  
  layout :tags, :reduce => 'sum_values'
  layout :tags_and_public, :reduce => 'sum_values'
  layout :created_at_and_public, :reduce => 'sum_values'
  
  save # submit design docs to CouchDB
  
  def created_at
    unless self['created_at'].nil?
      self['created_at'] = Time.parse(self['created_at']) unless self['created_at'].respond_to?('year')
    end
    self['created_at']
  end
  
  def url
    d = self.created_at
    "/past/#{d.year}/#{d.month}/#{d.day}/#{slug}/"
  end

  def full_url
    Blog.url_base.gsub(/\/$/, '') + url
  end

  def body_html
    to_html(self['body'])
  end

  def summary
    summary, more = split_content(self['body'])
    summary
  end

  def summary_html
    to_html(summary)
  end

  def more?
    summary, more = split_content(self['body'])
    more
  end

  def linked_tags
    self['tags'].inject([]) do |accum, tag|
      accum << "<a href=\"/past/tags/#{tag}\">#{tag}</a>"
    end.join(", ")
  end

  def self.make_slug(title)
    title.downcase.gsub(/ /, '_').gsub(/[^a-z0-9_]/, '').squeeze('_')
  end

  ########

  def to_html(markdown)
    h = Maruku.new(markdown).to_html
    h.gsub!(/<pre>/, "<pre class=\"prettyprint\">")
    h
  end

  def split_content(string)
    parts = string.gsub(/\r/, '').split("\n\n")
    show = []
    hide = []
    parts.each do |part|
      if show.join.length < 100
        show << part
      else
        hide << part
      end
    end
    [ to_html(show.join("\n\n")), hide.size > 0 ]
  end
end
