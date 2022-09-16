import { marked } from 'marked'
import "./articles"

window.onload = function(){

  if($(".article-view").length){
    var article = $(".article-view")
    var content = article.data("article")

    content = mathtodollars(content);

    content = marked(content)
    article.html(content);
    MathJax.Hub.Typeset(["Typeset",MathJax.Hub, "posts-preview"]); 

    var pre = article.find("pre")
    pre.each(function(){
      makecodeblock($(this))
      var coderef = $(this).parent().prev()
      copybtn(coderef)
    })

    article.find("img").each(function(){
      $(this).width("70%")
      $(this).height("70%")
    })
  }

  function copybtn(coderef){
    coderef.after('<div class="code-copy"></div>')
    var codecopy = coderef.next("div.code-copy")
    codecopy.css({"float": "right", "margin": "5px 20px 0 0", "cursor": "pointer"})
    codecopy.append('<div class="code-copy__button"></div>')
    var btn = codecopy.children("div.code-copy__button")
    // if($("div.code-copy__button").index(btn) % 2 == 0){
    //   btn.append('<span class="far fa-clipboard clipboard"></span>')
    //   codecopy.append('<div class="code-copy__check" style="display: none;"></div>')
    //   codecopy.children('div.code-copy__check').append('<span class="fas fa-clipboard-check check"></span>')
    // }else{
      btn.append('<span class="far fa-copy clipboard"></span>')
      codecopy.append('<div class="code-copy__message" style="display: none;"></div>')
      codecopy.children('div.code-copy__message').append('<span class="check">Copied!</span>')
      // codecopy.find(".check").css({"font-size": "smaller", "margin": "0 0 0 0"})
      codecopy.children('div.code-copy__message').css({"font-size": "smaller", "margin": "0 0 0 0"})
      // codecopy.append('<div class="code-copy__check" style="display: none;"></div>')
      // codecopy.children('div.code-copy__check').append('<span class="fas fa-check check"></span>')
      // codecopy.children('div.code-copy__check').append('<span class="far fa-check-circle check"></span>')
      // codecopy.children('div.code-copy__check').append('<span class="far fa-check-square check"></span>')
    // }
    btn.next("div").css({"color": "white"})
    // btn.next("div").children('span').css({"color": "white"})
    // btn.parent().css({"color": "white"})
    btn.children('span.clipboard').css({"color": "white"})
  }


  $(".code-copy__button").click(function(){
    var codecopy = $(this).parent(".code-copy")
    var code = codecopy.next(".highlight").find("pre");
    window.getSelection().selectAllChildren(code[0])
    document.execCommand('copy');
    window.getSelection().removeAllRanges();  
    var btn = $(codecopy).children("div.code-copy__button")
    btn.css("display", "none")
    var done = btn.next("div")
    // done.css("display", "block")
    done.show()
    var check = done.children(".check")
    // check.css("display", "inline")
    check.show()
    btn.delay(1500).queue(function(){
      // done.css("display", "none")
      // check.css("display", "none")
      done.hide()
      check.hide()
      $(this).css("display", "block")
    });
  })
  

}
