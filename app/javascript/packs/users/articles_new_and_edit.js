import { marked } from 'marked'
import "./articles"

$(function(){

  var me = $(".markdown-editor");
  me.resize(function(){
    $(".preview").width(me.width());
    $(".preview").height(window.innerHeight());
  });

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
    var text = $(".markdown-editor").text()
    text = mathtodollars(text);
    text = marked(text)
    var elem = $('.preview-content')
    elem.html(content);
    MathJax.Hub.Typeset(["Typeset",MathJax.Hub, "posts-preview"]); 
    var pre = elem.find('pre');
    pre.each(function(){
      makecodeblock($(this))
    })
    elem.find("img").each(function(){
      $(this).width("70%")
      $(this).height("70%")
    })
  }

  $('.markdown-editor').keyup(function(event){
    var content = $(this).val()
    content ||= "コンテンツ"
    content = marked(content);
    content ||= "コンテンツ"
    var pre = $('.preview-content')
    pre.html(content);
    pre = pre.find('pre');
    pre.each(function(){
      makecodeblock($(this))
    })
    $("img").each(function(){
      $(this).width("70%")
      $(this).height("70%")
    })
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
    var word     = '<img alt="' + name + '" src="' + url + '" width="200px" height="200px">\n';
    word     = '<img alt="' + name + '" src="' + url + '" width="100%" height="100%">\n';
    var after    = sentence.substr(pos, len);
    sentence = before + word + after;
    textarea.value = sentence;
    var content = marked(textarea.value)
    $(".preview-content").html(content);
  }

});
