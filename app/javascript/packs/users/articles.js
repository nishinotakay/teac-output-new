window.hljs = require('highlight.js');
import 
  // "highlight.js/scss/vs.scss";
  // "highlight.js/scss/a11y-dark.scss";
  // "highlight.js/scss/atom-one-dark.scss";
  // "highlight.js/scss/atom-one-dark-reasonable.scss";
  // "highlight.js/scss/github-dark-dimmed.scss";
  "highlight.js/scss/github-dark.scss";
  // "highlight.js/scss/isbl-editor-dark.scss";
  // "highlight.js/scss/dark.scss";
  // "highlight.js/scss/gradient-dark.scss";
  // "highlight.js/scss/kimbie-dark.scss";
  // "highlight.js/scss/nnfx-dark.scss";
  // "highlight.js/scss/panda-syntax-dark.scss";
  // "highlight.js/scss/paraiso-dark.scss";
  // "highlight.js/scss/qtcreator-dark.scss";
  // "highlight.js/scss/stackoverflow-dark.scss";
  // "highlight.js/scss/tokyo-night-dark.scss";


import { marked } from 'marked'
marked.setOptions({
  highlight: function (code, lang) {
    if(lang && lang.indexOf(":") >= 0){
      lang = lang.split(":")[0]
      if(lang != "math"){
        lang ||= "plaintext"
        // MathJax = {
        //   chtml: {
        //     matchFontHeight: false
        //   },
        //   tex: {
        //     inlineMath: [['$', '$']]
        //   }
        // };
        // MathJax.Hub.Queue(["Typeset",MathJax.Hub,"quMain"]);
        try{
          return hljs.highlight(code, {language: lang, ignoreIllegals: true}).value
        }catch(e){
          console.log(DOMException())
          console.error(e.name, e.message)
          // return hljs.highlightAuto(code).value
        }
      }
    }
  }
});

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
    // copybtn(coderef)
    // coderef.next().next().css("background-color", "#364549")
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
