function(doc) {
  if (doc.type == 'Post' && doc.tags && !doc.not_public) {
    doctags.forEach(function(tag){
      emit(tag, 1);
    });
  }
}