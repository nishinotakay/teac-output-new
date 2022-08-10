import { marked } from 'marked'



// articles/index.html.erb
$(document).on ("turbolinks:load", function(){
  $('tr[data-href]').click(function(e){
    if (!$(e.target).is('a')) {
      // window.location = $(e.target).data('href');
      window.location = $(this).data('href');
    };
  })
})


// articles/new articles/edit

$(document).on ("turbolinks:load", function(){

  if($(".title-form").length || $(".markdown-editor").length){
  
    $('.title-form').keyup(function(){
      var title = $(this).val();
      $('.preview-title').text(title);
    });
      
    var drop = 0
    console.log(drop)
    $('.markdown-editor').keyup(function(){
      var content = marked($(this).val());
      console.log(0)
      console.log(content)
      $('.preview-content').html(content);
    });
      
    if($(".markdown-editor").val()){
      var content = marked($(".markdown-editor").text())
      console.log(1)
      console.log(content)
      $(".preview-content").html(content);
    }

    // drag&drop
    $('.markdown-editor').on('drop', function(e) { //dropのイベントをハンドル
      dragAndDrop(e)
    });

    function dragAndDrop(e){
      e.preventDefault(); //元の動きを止める処理
      var image = e.originalEvent.dataTransfer.files[0]; //ドロップされた画像の1件目を取得
      // var f = e.originalEvent.dataTransfer.files[1]
      var formData = new FormData();
      formData.append('image', image); // FormDataに画像を追加

      // ajaxで画像をアップロード
      $.ajax({
        url: "/users/articles/image",
        type: "POST",
        data: formData,
        dataType: "json",
        contentType: false,
        processData: false
      })
      .done(function(data, textStatus, jqXHR){
        setImage(data['name'], data['url'])
        // var textarea = $('textarea').get(0);
        // var textarea = $('textarea');
        // var content = textarea.text()
        // content = marked(content)
      })
      .fail(function(jqXHR, textStatus, errorThrown){
        // alert("画像の挿入に失敗しました。");
        // console.log(jqXHR)
        // console.log(textStatus)
        // console.log(errorThrown)
      });
    }

    // テキストエリアに画像タグを追加する関数
    function setImage(name, url) {
      var textarea = $('textarea').get(0);
      var sentence = textarea.value;
      var len      = sentence.length;
      var pos      = textarea.selectionStart;
      var before   = sentence.substr(0, pos);
      // var word     = '![' + name + '](' + url + ')';
      var word     = '<img alt="' + name + '" src="' + url + '" width="200px" height="200px">\n';
      var after    = sentence.substr(pos, len);

      sentence = before + word + after;

      textarea.value = sentence;

      var content = marked(textarea.value)

      $(".preview-content").html(content);

    }
  }
});


// articles/show.html.erb
$(window).on("load", function(){
  if($(".article-view").length){
    var content = $(".article-view").data("article")
    content = marked(content)
    $(".article-view").html(content);
  }
});
