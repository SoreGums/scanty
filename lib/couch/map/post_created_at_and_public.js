function(doc) {
  if(doc.type == 'Post' && !doc.not_public) {
    emit(doc.created_at,1);
  }
}