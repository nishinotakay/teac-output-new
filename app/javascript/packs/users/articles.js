import { marked } from 'marked'

// _article_form_and_preview.html.erb
$(function(){
  $('.title-form').keyup(function(){
    var title = $(this).val();
    $('.preview-title').text(title);
  });
});

$(function(){
  $('.markdown-editor').keyup(function(){
    var content = marked($(this).val());
    $('.preview-content').html(content);
  });
});

$(function(){
  if($(".markdown-editor").val()){
    console.log($(this).val())
    console.log(1)
    // var content = marked($(".preview-content").text())
    var content = marked($(".markdown-editor").text())
    $(".preview-content").html(content);
  }
});

// drag&drop
$(function() {
  $('.markdown-editor').on('drop', function(e) { //dropのイベントをハンドル
    e.preventDefault(); //元の動きを止める処理
    var f = e.originalEvent.dataTransfer.files[0]; //ドロップされた画像の1件目を取得
    // var formData = new FormData($(".markdown-editor").get(0));
    var formData = new FormData();
    formData.append('image', f); // FormDataに画像を追加

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
    })
    .fail(function(jqXHR, textStatus, errorThrown){
      alert("画像の挿入に失敗しました。");
    });
  });

  // テキストエリアに画像タグを追加する関数
  function setImage(name, url) {
    var textarea = $('textarea').get(0);
    var sentence = textarea.value;
    var len      = sentence.length;
    var pos      = textarea.selectionStart;
    var before   = sentence.substr(0, pos);
    // var word     = '![' + name + '](' + url + ')';
    var word     = '<img alt="' + name + '" src="' + url + '" width="200px" height="200px">';
    var after    = sentence.substr(pos, len);

    sentence = before + word + after;

    textarea.value = sentence;

  }
});



// articles/show.html.erb
$(function(){
  // var content = marked($(".markdown-preview").text())
  // $(".markdown-preview").html(content);
});

// articles/edit.html.erb
