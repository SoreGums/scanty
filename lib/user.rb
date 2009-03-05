class FeedUser < CouchRest::ExtendedDocument
  use_database CouchRest.database!((Blog.url_base_database || '') + Blog.database_name)
  
  property :last_access
  
  view_by :last_access
  
  def self.exists?(_id)
    false if FeedUser.by_uid.first.nil?
  end
  
  couchrest_type = 'FeedUser'
end
