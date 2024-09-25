import '../../stylesheets/users/articles';  // ユーザー用のスタイルシートをインポート

$(function(){
  // タイトル要素とボタンのラッピング
  var title = $('h1');
  title.wrap('<div class="form-inline title-and-buttons">');
  var t_and_btns = $('.title-and-buttons');
  t_and_btns.parent().removeClass('col-sm-6');
  t_and_btns.parent().addClass('col-sm-8');

  // 各ボタンの要素を取得し、タイトルの後に配置
  var reset = $('.reset-btn');
  var filter = $('.filter-modal-btn');
  var sort = $('.sort-modal-btn');
  title.after(reset);
  title.after(filter);
  title.after(sort);
  $('.title-and-buttons').children().css({'display': 'inline'});

  // 並べ替えモーダル表示
  sort.on('click', function(){
    $('.modal-title').text('並べ替え');
    $('.submit-btn').text('並べ替える');
    $('.sort-modal').show();
  });

  // フィルターモーダル表示
  filter.on('click', function(){
    $('.modal-title').text('絞り込み検索');
    $('.submit-btn').text('検索する');
    $('.filter-modal').show();
  });

  // モーダルを閉じる処理
  $('.modal-close').on('click', function(){
    $('.sort-modal').hide();
    $('.filter-modal').hide();
  });

  // 管理者用のリセットボタンの配置と動作
  if ($('.reset-btn-admin').length) {
    $('.reset-btn-admin').insertAfter('.filter-modal-btn');
  }

  $('.reset-btn-admin').on('click', function(){
    var searchParams = new URLSearchParams(window.location.search);
    
    var order = searchParams.get('order') === 'DESC' ? 'DESC' : 'ASC';
    searchParams.set('order', order);

    // 検索パラメータのリセット
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

  // リセットボタンの動作
  $('.reset-btn').on('click', function(){
    var search = location.search;
    if(search.indexOf("order=") != -1){
      window.location.search = search.indexOf("DESC") != -1 ? 'order=DESC' : 'order=ASC';
    } else {
      window.location.search = '';
    }
  });

  // 並べ替えとフィルタの実行
  $('.submit-btn-admin').on('click', function(){
    var search = "order=DESC";
    var values = ['author', 'title', 'subtitle', 'content', 'start', 'finish' ,'body'];
    $.each(values, function(index, value){
      var input = $('#input-' + value).val();
      if(input){
        search += '&' + value + '=' + input;
        search += search.indexOf('reset=') != -1 ? '' : '&reset=true';
      }
    });
    window.location.search = search;
  });

  // 管理者用の検索実行
  $('.submit-btn').on('click', function(){
    var sort = $('#sort-select option:selected').val();
    var search = "order=" + sort;
    var values = ['author', 'title', 'subtitle', 'content', 'start', 'finish' ,'body', 'post'];
    $.each(values, function(index, value){
      var input = $('#input-' + value).val();
      if(input){
        search += '&' + value + '=' + input;
        search += search.indexOf('reset=') != -1 ? '' : '&reset=true';
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
});
