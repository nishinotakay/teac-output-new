import { marked } from 'marked'
import "./articles"

window.onload = function(){

  if($(".article-view").length){
    var article = $(".article-view")
    var content = article.data("article")
    content = marked(content)
    article.html(content);

    var pre = article.find("pre")
    pre.each(function(){
      // if($(this).attr("class") != "debug_dump"){
        makecodeblock($(this))
      // }
    })
  
  }

  $(".code-copy__button").click(function(){
    codecopy(this)
    // const selection = window.getSelection();
    // const code = this.parent().next().childNodes;
    // console.log(code)
    // selection.selectAllChildren(code);
    // // selection.extend(code, code.childNodes.length-1);
    // document.execCommand('copy');
    // $(this).children("div.code-copy__button").css("display", "none")
    // $(this).children("div.code-copy__check").css("display", "block")
  })

}
