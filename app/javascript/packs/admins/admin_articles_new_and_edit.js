import { marked } from 'marked'
import "./admin_articles"

function auto_line_break_img(article) {
  article.find("img").each(function () { // 取得されたimg要素に対してeachメソッドで繰り返し処理
    $(this).addClass("img-margin"); // img要素に対してimg-marginクラスを追加
  });
}

// 特定の要素をsanitizeするメソッド
function sanitizeContent(content) {
  content = content.replace(/<script[\s\S]*?<\/script>/gi, ''); //script要素を空欄に置き換える。
  content = content.replace(/<iframe[\s\S]*?<\/iframe>/gi, ''); //iframe要素を空欄に置き換える。
  return content;
}

function markdown_preview(content) {
  if ($.type(content) == "string") {
    content = sanitizeContent(content); //contentからscriptタグ,iframeタグを除去。
    content = mathtodollars(content);
    content = marked(content); // マークダウン形式のテキストHTMLに変換。
  }

  var virtualPreview = $("<div>"); // 新しい仮想DOM要素を作成
  virtualPreview.html(content);

  // プレビューコンテンツから<style>タグを抽出し、プレビュー用の<div>要素に適用する
  const styles = virtualPreview.find("style");
  styles.each(function () {
    const styleContent = $(this).html(); // thisはstyles.each()関数の中で現在の反復（イテレーション）の対象となっている<style>タグ要素を指しています
    const scopedStyleContent = styleContent.replace(/(^|\})\s*([^{]+)/g, '$1.preview $2');
    $(this).html(scopedStyleContent);
  });

  var pre = virtualPreview.find("pre");
  pre.each(function () {
    makecodeblock($(this));
  });
  resize_img(virtualPreview);
  auto_line_break_img(virtualPreview);

  // 最後にプレビュー用のdiv要素の中身を置き換えます。
  $(".preview").html(virtualPreview.html());
};



$(function(){
  
  var editor = $(".markdown-editor");
  var preview = $(".preview");
  preview.height(editor.height());
  $('.editor-side .card').height($('.preview-side .card').height());
  
  if($(".markdown-editor").val()){
    var content = $(".markdown-editor").text()
    markdown_preview(content);
  }

  $('.markdown-editor').keyup(function(event){
    var content = $(this).val()
    markdown_preview(content)
  });

  $('.markdown-editor').on('drop', function(e) { //dropのイベントをハンドル
    e.preventDefault(); //元の動きを止める処理
    var image = e.originalEvent.dataTransfer.files[0]; //ドロップされた画像の1件目を取得
    var formData = new FormData();
    formData.append('image', image); // FormDataに画像を追加
    formData.append('user_id', e.target.dataset.userId); // FormDataに画像を追加

    // CSRFトークンを取得
    var token = $('meta[name="csrf-token"]').attr('content');

    // ajaxで画像をアップロード
    $.ajax({
      url: "/users/articles/image",
      type: "POST",
      data: formData,
      dataType: "json",
      contentType: false,
      processData: false,
      headers: { 
        'X-CSRF-Token': token  // こちらでトークンをヘッダーに追加
      }
    })
    .done(function(data, textStatus, jqXHR){
      setImage(data['name'], data['url'])
      resize_img($(".preview"))
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
  }

});
