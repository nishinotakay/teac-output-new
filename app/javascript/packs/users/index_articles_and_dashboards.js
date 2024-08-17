import '../../stylesheets/users/articles'

$(function(){
  var title = $('h1')
  title.wrap('<div class="form-inline title-and-buttons">')
  var t_and_btns = $('.title-and-buttons')
  t_and_btns.parent().removeClass('col-sm-6')
  t_and_btns.parent().addClass('col-md-12')
  var reset = $('.reset-btn')
  var filter = $('.filter-modal-btn')
  var sort = $('.sort-modal-btn')
  title.after(reset)
  title.after(filter)
  title.after(sort)
  $('.title-and-buttons').children().css({'display': 'inline'})

  sort.on('click', function(){
    $('.modal-title').text('並べ替え')
    $('.submit-btn').text('並べ替える')
    $('.sort-modal').show()
  })

  filter.on('click', function(){
    $('.modal-title').text('絞り込み検索')
    $('.submit-btn').text('検索する')
    $('.filter-modal').show()
  })

  $('.modal-close').on('click', function(){
    $('.sort-modal').hide()
    $('.filter-modal').hide()
  })

  if ($('.reset-btn-admin').length) {
    $('.reset-btn-admin').insertAfter('.filter-modal-btn');
  }

  $('.reset-btn').on('click', function(){
    var search = location.search
    if(search.indexOf("order=") != -1){
      window.location.search = search.indexOf("DESC") != -1 ? 'order=DESC' : 'order=ASC'
    }else{
      window.location.search = ''
    }
  })

  $('.reset-btn-admin').on('click',function(){
    var searchParams = new URLSearchParams(window.location.search);
    var userId = searchParams.get('user_id');

    if (userId) {
      searchParams.set('user_id', userId);
    }

    var order = searchParams.get('order') === 'DESC' ? 'DESC' : 'ASC';
    searchParams.set('order', order);

    searchParams.delete('author');
    searchParams.delete('title');
    searchParams.delete('subtitle');
    searchParams.delete('content');
    searchParams.delete('created_at');
    searchParams.delete('start');
    searchParams.delete('finish');

    searchParams.delete('reset_admin');

    window.location.search = searchParams.toString();
  });

  // テーブルにコンテンツを追加するときにコメントイン
  // $('.link-tr').hover(function(){
  //   var classname = $(this).next().attr('class');
  //   if(classname == 'content-tr'){
  //     // $(this).next().hover()
  //     // $(this).next().css('background-color', 'var(--bs-table-hover-color)')
  //     $(this).next().css('background-color', 'red')
  //   }
  // })

  $('.submit-btn').on('click', function(){
    var sort = $('#sort-select option:selected').val()
    var search = "order=" + sort
    var values = ['author', 'title', 'subtitle', 'content', 'start', 'finish' ,'body', 'post']
    $.each(values, function(index, value){
      var input = $('#input-' + value).val()
      if(input){
        search += '&' + value + '=' + input
        search += search.indexOf('reset=') != -1 ? '' : '&reset=true'
      }
    });

    if ($('#sort-select-admin').length) {
      var sortValueAdmin = $('#sort-select-admin option:selected').val();
      var searchParams = new URLSearchParams();
      searchParams.set('order', sortValueAdmin);
  
      var userId = new URLSearchParams(window.location.search).get('user_id');
      if (userId) {
        searchParams.set('user_id', userId);
      }
  
      var values = ['author', 'title', 'subtitle', 'content', 'start', 'finish', 'body', 'post'];
      $.each(values, function(index, value) {
        var input = $('#input-' + value).val();
        if (input) {
          searchParams.set(value, input);
          searchParams.set('reset_admin', 'true');
        }
      });
  
      window.location.search = searchParams.toString();
    } else {
      window.location.search = search;
    }
  });

  $('.submit-btn-admin').on('click', function(){
    var search = "order=DESC"
    var values = ['author', 'title', 'subtitle', 'content', 'start', 'finish' ,'body']
    $.each(values, function(index, value){
      var input = $('#input-' + value).val()
      if(input){
        search += '&' + value + '=' + input
        search += search.indexOf('reset=') != -1 ? '' : '&reset=true'
      }
    })
    window.location.search = search
  })

  $('#js-hamburger-menu').on('click', function () {
    $('.folder-wrapper').slideToggle(500)
    $('.hamburger-menu').toggleClass('hamburger-menu--open')
  });

  var articleID;
  var oldFolderID;
  var draggedArticle;

  $(document).on('dragstart', '.link-td[draggable="true"]', function(e) {
      draggedArticle = $(this).closest('tr');
      console.log('dragstart start')
      articleID = $(this).closest('td').attr('data-article-id');
      console.log("articleID:", articleID);

      oldFolderID = $(this).closest('td').attr('data-folder-id');
      console.log("oldFolderID:", oldFolderID);

    if (articleID) {
      console.log('if article ID dragstart');
      console.log(articleID);

      const articleTitle = $(this).text().trim();
      console.log(articleTitle);

      e.originalEvent.dataTransfer.setData('text/plain', articleTitle)
      console.log(articleTitle);

      const dragIcon = $('<div class="dragging-icon-wrapper"><div class="dragging-icon"><i class="fa fa-file-alt"></i><div class="dragging-text">' + articleTitle + '</div></div></div>');
      $('body').append(dragIcon);
      e.originalEvent.dataTransfer.setDragImage(dragIcon[0],0,0)
    } else {
      console.log('not found article_id');
    }
  });

  $('.folder-list-item').on('dragenter', function(e) {
    console.log('dragenter');
    $(this).addClass('folder-dragging');
  });

  $('.folder-list-item').on('dragleave', function(e) {
    console.log('dragleave');
    $(this).removeClass('folder-dragging');
  });

  $('.folder-list-item').on('dragover', function(e) {
    e.preventDefault();
    console.log('dragover');
  });

  $('.folder-list-item').off('drop').on('drop', function(e) {
    e.preventDefault();
    console.log('drop event');
    const folderID = $(this).data("folder-id");

    console.log(folderID)
    $(this).removeClass('folder-dragging');
    console.log(articleID);

    const newFolderID = $(this).data('folder-id');

    fetch('/users/articles/' + articleID + '/assign_folder/' + folderID , {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
      },
      body: JSON.stringify({
        article_id: articleID,
        old_folder_id: oldFolderID,
        folder_id: folderID
      })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        draggedArticle.remove();
      } else {
        console.error('Failed to move article:', data.errors);
      }
    })
    .catch((error) => {
      console.error('Error:', error);
    });
  });

  $('.link-td[draggable="true"]').on('dragend',function(e) {
    console.log('dragend');
    $(this).removeClass('dragging-element');
    $('.dragging-icon-wrapper').remove();
    console.log('remove element');
  });

  $('.folder-link').on('click', function(event) {
    const folderName = $(this).text();
    $('h1').text(folderName);
    if (!$('.editFolderbtn,.editFolderbtn').length){
      $('h1').wrap('<div class="heading-wrapper col-2"></div>')
      $('.filter-modal-btn').after('<button type="button" class="btn btn-danger ml-3 mr-5 destroyFolderbtn" data-bs-toggle="modal" data-bs-target="#destroyFolderModal">フォルダ削除</button>');
      $('.filter-modal-btn').after('<button type="button" class="btn btn-secondary ml-5 float-end editFolderbtn" data-bs-toggle="modal" data-bs-target="#editFolderModal">フォルダ編集</button>');
      $('.filter-modal-btn').after('<div class="flex-spacer"></div>');
    }
  });

});
