window.hljs = require('highlight.js');
import "highlight.js/scss/github-dark.scss";
import { marked } from 'marked'
import '../../stylesheets/users/articles'

marked.setOptions({
  breaks: true,
  highlight: function (code, lang) {
    if(lang && lang.indexOf(":") >= 0){
      lang = lang.split(":")[0]
      if(lang != "math"){
        lang ||= "plaintext"
        try{
          return hljs.highlight(code, {language: lang, ignoreIllegals: true}).value
        }catch(e){
        }
      }
    }
  }
});

const renderer = {
  heading(text, level) {
    return `
      <h${level} class="marked-heading">
        ${text}
      </h${level}>`;
  }
};

marked.use({ renderer });

window.makecodeblock = function(pre){
  pre.wrap('<div class="code-frame"></div>')
  pre.parent().css("background-color", "#364549")
  pre.wrap('<div class="highlight"></div>')
  var code = pre.children("code")
  code.css("color", "white")
  var codeclass = code.attr("class")
  if(codeclass && codeclass.indexOf(":") >= 0){
    codeclass = codeclass.split(":")
    var lang = codeclass.shift()
    pre.parent().before("<div class='code-ref'></div>")
    var coderef = pre.parent().prev()
    coderef.text(codeclass)
    coderef.css({"color": "#eee", "display": "inline-block", "background-color": "#777", "padding": "0 5px", "word-break": "break-all", "margin-left": "15px"})
  }
}

window.mathtodollars = function(content){
  var math_pos = content.indexOf("```math")
  while(math_pos >= 0){
    var before_str = content.slice(math_pos - 2, math_pos)
    if(!before_str || !before_str.match(/\S/g)){
      var before = content.slice(0, math_pos)
      var finish_math = content.indexOf("```", math_pos + 7)
      var middle = content.slice(math_pos, finish_math)
      middle = middle.replace("```math", "$")
      var after = content.slice(finish_math, content.length)
      after = after.replace("```", "$")
      content = before + middle + after
    }
    math_pos = content.indexOf("```math", math_pos + 7)
  }
  return content
}

window.resize_img = function(parent){
  parent.find("img").each(function(){
    $(this).bind("load", function(){
      var parent_wide = $(this).parent().width()
      if($(this).width() >= $(this).height()){
        $(this).width() > parent_wide ? $(this).width(parent_wide) : $(this).width()
      }else{
        $(this).height() > parent_wide ? $(this).height(parent_wide) : $(this).height()
      }
    })
  })

}
