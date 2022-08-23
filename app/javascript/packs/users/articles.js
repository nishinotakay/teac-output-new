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
      return hljs.highlight(code, {language: lang, ignoreIllegals: true}).value
      // return hljs.highlightAuto(code, [lang]).value
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
    copybtn(coderef)
    // coderef.next().next().css("background-color", "#364549")
  }
}

window.copybtn = function(prevelem){
  prevelem.after('<div class="code-copy"></div>')
  var codecopy = prevelem.next("div.code-copy")
  codecopy.css({"float": "right", "margin": "5px 10px 0 0", "cursor": "pointer"})
  // codecopy.append('<div class="code-copy__message" style="display: none;">Copied!</div>')
  codecopy.append('<div class="code-copy__check" style="display: none;"></div>')
  codecopy.children('div.code-copy__check').append('<span class="fas fa-clipboard-check">')
  codecopy.append('<div class="code-copy__button"></div>')
  var btn = codecopy.children("div.code-copy__button")
  if($("div.code-copy__button").index(btn) % 2 == 0){
    btn.append('<span class="far fa-clipboard clipboard"></span>')
  }else{
    btn.append('<span class="far fa-clone clipboard"></span>')
  }
  btn.children('span.clipboard').css({"color": "white"})
}


window.codecopy = function(btn){
  const selection = window.getSelection();
  const code = $(btn).parent().next().get(0);
  console.log(code)
  console.log(selection)
  console.log(selection.selectAllChildren($(code)))
  selection.selectAllChildren();
  // selection.extend(code, code.childNodes.length-1);
  document.execCommand('copy');
  $(this).children("div.code-copy__button").css("display", "none")
  $(this).children("div.code-copy__check").css("display", "block")
}
