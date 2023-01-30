import { marked } from 'marked'
import "./articles"

$(function(){

  if($(".article-content").length){
    var article = $(".article-content")
    var content = article.data("article")
    if($.type(content) == "string"){
      content = mathtodollars(content);
      content = marked(content)
    }
    article.html(content);
    // MathJax.Hub.Typeset(["Typeset",MathJax.Hub, "posts-preview"]); 
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
      $('.zoomin-modal').append($(this).children('img').clone())
    })
  });

  $(".code-copy__button").click(function(){
    var codecopy = $(this).parent(".code-copy")
    var code = codecopy.next(".highlight").find("pre");
    window.getSelection().selectAllChildren(code[0])
    document.execCommand('copy');
    window.getSelection().removeAllRanges();  
    var btn = $(codecopy).children("div.code-copy__button")
    btn.css("display", "none")
    var done = btn.next("div")
    done.show()
    var check = done.children(".check")
    check.show()
    btn.delay(1500).queue(function(){
      done.hide()
      check.hide()
      $(this).css("display", "block")
    });
  })
})

function copybtn(coderef){
  coderef.after('<div class="code-copy"></div>')
  var codecopy = coderef.next("div.code-copy")
  codecopy.css({"float": "right", "margin": "5px 20px 0 0", "cursor": "pointer"})
  codecopy.append('<div class="code-copy__button"></div>')
  var btn = codecopy.children("div.code-copy__button")
  btn.append('<span class="far fa-copy clipboard"></span>')
  codecopy.append('<div class="code-copy__message" style="display: none;"></div>')
  codecopy.children('div.code-copy__message').append('<span class="check">Copied!</span>')
  codecopy.children('div.code-copy__message').css({"font-size": "smaller", "margin": "0 0 0 0"})
  btn.next("div").css({"color": "white"})
  btn.children('span.clipboard').css({"color": "white"})
}
