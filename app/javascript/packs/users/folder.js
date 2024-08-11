import '../../stylesheets/users/articles'

if (!$('.articles-table').length) {
  $('.sort-modal-btn,.filter-modal-btn').hide();
} else {
  $('.sort-modal-btn,.filter-modal-btn').show();
}
  
$('.folder-article').on('dragstart', function(e) {
  const articleTitle = $(this).text().trim();
  console.log(articleTitle);

  e.originalEvent.dataTransfer.setData('text/plain', articleTitle)
  console.log(articleTitle);

  const dragIcon = $('<div class="dragging-icon-wrapper"><div class="dragging-icon"><i class="fa fa-file-alt"></i><div class="dragging-text">' + articleTitle + '</div></div></div>');
  $('body').append(dragIcon);
  e.originalEvent.dataTransfer.setDragImage(dragIcon[0],0,0)
});

$('.folder-article').on('dragend', function(e) {
  $('.dragging-icon-wrapper').remove();
});
