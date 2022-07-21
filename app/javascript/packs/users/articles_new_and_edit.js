import { marked } from 'marked'

$(function(){

  var me = $(".markdown-editor");
  me.resize(function(){
    $(".preview").width(me.width());
    // $(".preview").css("width", "100%");
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
    var content = marked($(".markdown-editor").text())
    var elem = $('.preview-content')
    elem.html(content);
    elem = elem.find('pre');
    elem.css({"background-color": "#364549", "color": "#e3e3e3"})
  }

  $('.markdown-editor').keyup(function(event){
    var content = $(this).val()
    content ||= "コンテンツ"
    if(event.keyCode == 13){
      addBr($(this))
      console.log($(this).val());
    }
    content = marked(content);
    content ||= "コンテンツ"
    var elem = $('.preview-content')
    elem.html(content);
    elem = elem.find('pre');
    elem.css({"background-color": "#364549", "color": "#e3e3e3"})
  });

  function addBr(elem) {
    var textarea = elem.get(0);
    var sentence = textarea.value;
    var len      = sentence.length;
    var pos      = textarea.selectionStart - 1;
    var before   = sentence.substr(0, pos);
    var a = sentence.substr(pos, pos + 1);
    console.log(a)
    console.log(pos)
    console.log(a == "\n" ? 1 : a)
    var word     = '<br>';
    word     = a == " " ? "" : '  ';
    var after    = sentence.substr(pos, len);
    sentence = before + word + after;
    textarea.value = sentence;
    
    pos += word.length;
    textarea.setSelectionRange(pos + 1, pos + 1);

    var content = marked(textarea.value)
    content = marked(sentence)

    $(".preview-content").html(content);
  }



  // background-color: #364549;
  // color: #e3e3e3;
    
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
});