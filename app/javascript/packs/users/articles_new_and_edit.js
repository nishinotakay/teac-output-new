import { marked } from 'marked'
import "./articles"

$(function(){

  var elem = $('.editor-side .card')
  var height = elem.height() + $('.div-btns').height();
  elem.height(height);
  $('.preview-side .card').height(height);

  var elem = $(".div-textarea");
  var height = elem.position().top + $(".markdown-editor").height();
  elem = $(".div-title-form");
  height -= elem.position().top;
  height -= $(".div-btns").height();
  $(".preview").height(height);
  
  $('.title-form').keyup(function(event){
    var title = $(this).val();
    title ||= "タイトル"
    $('.preview-title').text(title);
  });

  $('.subtitle-form').keyup(function(){
    var subtitle = $(this).val();
    subtitle ||= "サブタイトル"
    $('.preview-subtitle').text(subtitle);
  });

  if($(".markdown-editor").val()){
    var content = $(".markdown-editor").text()
    content = mathtodollars(content);
    content = marked(content)
    var elem = $('.preview-content')
    elem.html(content);
    var pre = elem.find('pre');
    pre.each(function(){
      makecodeblock($(this))
    })
    elem.find("img").each(function(){
      $(this).width("60%")
      $(this).height("60%")
    })
  }

  $('.markdown-editor').keyup(function(event){
    var content = $(this).val()
    content ||= "コンテンツ"
    content = marked(content);
    content ||= "コンテンツ"
    var pre = $('.preview-content')
    pre.html(content);
    pre.find("img").each(function(){
      $(this).width("60%")
      $(this).height("60%")
    })
    pre = pre.find('pre');
    pre.each(function(){
      makecodeblock($(this))
    })
  });
  
  $('.markdown-editor').on('drop', function(e) { //dropのイベントをハンドル
    e.preventDefault(); //元の動きを止める処理
    var image = e.originalEvent.dataTransfer.files[0]; //ドロップされた画像の1件目を取得
    var formData = new FormData();
    formData.append('image', image); // FormDataに画像を追加
    formData.append('user_id', e.target.dataset.userId); // FormDataに画像を追加
    console.log(e)
    console.log(image)

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
    $(".preview-content").html(content);
    resize_img($(".preview-content"))
  }

});
