import { marked } from 'marked'

window.onload = function(){
  if($(".article-view").length){
    var content = $(".article-view").data("article")
    content = marked(content)
    $(".article-view").html(content);
  }
  var elem = $(".article-view")
  elem = elem.find('pre');
  // elem = $('.preview-content pre')
  elem.css({"background-color": "#364549", "color": "#e3e3e3"})
}

$(function(){
  var elem = $(".article-view")
  elem = elem.find('pre');
  // elem = $('.preview-content pre')
  elem.css({"background-color": "#364549", "color": "#e3e3e3"})
});