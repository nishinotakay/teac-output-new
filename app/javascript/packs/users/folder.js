import '../../stylesheets/users/articles'

if (!$('.articles-table').length) {
  $('.sort-modal-btn,.filter-modal-btn').hide();
} else {
  $('.sort-modal-btn,.filter-modal-btn').show();
}
