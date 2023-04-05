import { marked } from 'marked'
import "./articles"

function resize_img(article){
  article.find("img").each(function(){ // 取得されたimg要素に対してeachメソッドで繰り返し処理
    $(this).addClass('img-margin'); // img要素に対してimg-marginクラスを追加
  })
}

$(function(){

  if($(".article-content").length){
    var article = $(".article-content")
    var content = article.data("article")
    if($.type(content) == "string"){
      content = mathtodollars(content);
      content = marked(content)
    }
    article.html(content);
    var pre = article.find("pre")
    pre.each(function(){
      makecodeblock($(this))
      var coderef = $(this).parent().prev()
      copybtn(coderef)
    })
    resize_img(article)
  }

  $(window).on('load', function () {
    $(".article-content").find("img").each(function(){
      $(this).wrap('<a href="" class="zoomin-img" data-bs-toggle="modal" data-bs-target="#zoominImgModal"></a>')
    })

    $('.zoomin-img').on('click', function(){
      var img = $('.zoomin-modal').children()
      if(img.length){
        img.remove()
      }
      var src = $(this).children('img').attr('src') 
      $('.zoomin-modal').append('<img src="' + src + '" width="100%" height="100%">')
    })
  });

  $(".btn-messe").click(function(){
    var codecopy = $(this).parent(".code-copy")
    var pre = codecopy.next(".highlight").find("pre");
    var btn = codecopy.children(".btn-messe").children(".clipboard")
    var messe = codecopy.children(".btn-messe").children(".messe")
    btn.hide()
    messe.show()
    navigator.clipboard.writeText(pre.contents().text()).then(
      success => messe.show(),
      error => alert('コピーに失敗しました。')
    );
    setTimeout(function(){
      messe.hide()
      btn.show()
    },1500);    
  })
})

function copybtn(coderef){
  coderef.after('<div class="code-copy"></div>')
  var codecopy = coderef.next(".code-copy")
  codecopy.css({"float": "right", "margin": "5px 20px 0 0", "cursor": "pointer", "color": "white"})
  codecopy.append('<div class="btn-messe"><span class="far fa-copy clipboard"></span><span class="messe" style="display: none;">Copied!</span></div>')
  codecopy.children('.btn-messe').children('.messe').css({"font-size": "smaller", "margin": "5px"})
}
