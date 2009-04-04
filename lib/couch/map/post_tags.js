function(doc) {
  if (doc.type == 'Post' && doc.tags) {
    doc.tags.forEach(function(tag){
      emit(tag, 1);
    });
  }
}