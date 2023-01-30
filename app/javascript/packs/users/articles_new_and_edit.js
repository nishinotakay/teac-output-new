import { marked } from 'marked'
import "./articles"

$(function(){
  
  var m_editor = $(".markdown-editor");
  var preview = $(".preview");
  preview.height(m_editor.height());
  preview.html(preview.data("preview-content"));
  $('.editor-side .card').height($('.preview-side .card').height())
  
  if($(".markdown-editor").val()){
    var content = $(".markdown-editor").text()
    if($.type(content) == "string"){
      content = mathtodollars(content);
      content = marked(content)
    }
    // content ||= ''
    // content = mathtodollars(content);
    // content = marked(content)
    var preview = $('.preview')
    preview.html(content);
    var pre = preview.find('pre');
    pre.each(function(){
      makecodeblock($(this))
    })
    // preview.find("img").each(function(){
    //   $(this).width("100%")
    //   $(this).height("60%")
    // })
    resize_img(preview)
  }

  $('.markdown-editor').keyup(function(event){
    var content = $(this).val()
    if($.type(content) == "string"){
      content = mathtodollars(content);
      content = marked(content)
    }
    // content ||= preview.data("preview-content")
    // content = marked(content);
    // content ||= preview.data("preview-content")
    var preview = $('.preview')
    preview.html(content);
    // preview.find("img").each(function(){
    //   $(this).width("100%")
    //   $(this).height("100%")
    // })
    preview = preview.find('pre');
    preview.each(function(){
      makecodeblock($(this))
    })
    resize_img(preview)
  });
  
  $('.markdown-editor').on('drop', function(e) { //dropのイベントをハンドル
    e.preventDefault(); //元の動きを止める処理
    var image = e.originalEvent.dataTransfer.files[0]; //ドロップされた画像の1件目を取得
    var formData = new FormData();
    formData.append('image', image); // FormDataに画像を追加
    formData.append('user_id', e.target.dataset.userId); // FormDataに画像を追加

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
    var word     = '<img alt="' + name + '" src="' + url + '">';
    var after    = sentence.substr(pos, len);
    sentence = before + word + after;
    textarea.value = sentence;
    var content = marked(textarea.value)
    $(".preview").html(content);
    resize_img($(".preview"))
  }

});
