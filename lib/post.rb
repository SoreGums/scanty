require 'maruku'
require 'syntax/convertors/html'

class Post < CouchRest::ExtendedDocument
  use_database CouchRest.database!((Blog.url_base_database || '') + Blog.database_name)

  property :title
  property :body
  property :slug
  property :tags, :default => []
  property :not_public
    
  view_by :created_at, :descending=>true
  view_by :slug
  view_by :not_public
  view_by :created_at_and_public, :descending=>true,
    :map =>
      "function(doc) {
        if(doc['couchrest-type'] == 'Post' && !doc['not_public']) {
          emit(doc['created_at'],1);
        }
      }",
    :reduce => 
      "function(keys, values, rereduce) {
        return sum(values);
      }"

  view_by :tags,
    :map => 
      "function(doc) {
        if (doc['couchrest-type'] == 'Post' && doc['tags']) {
          doc['tags'].forEach(function(tag){
            emit(tag, 1);
          });
        }
      }",
    :reduce => 
      "function(keys, values, rereduce) {
        return sum(values);
    }" 
  
  view_by :tags_and_public,
    :map => 
      "function(doc) {
        if (doc['couchrest-type'] == 'Post' && doc['tags'] && !doc['not_public']) {
          doc['tags'].forEach(function(tag){
            emit(tag, 1);
          });
        }
      }",
    :reduce => 
      "function(keys, values, rereduce) {
        return sum(values);
    }"
  
  timestamps!
  
  couchrest_type = 'Post'  
  
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
