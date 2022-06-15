import { marked } from 'marked'

// articles/new.html.erb
$(function(){
  $('.title-form').keyup(function(){
    var title = $(this).val();
    $('.preview-title').text(title);
  });
});

$(function(){
  $('.markdown-editor').keyup(function(){
    var content = marked($(this).val());
    $('.preview-content').html(content);
  });
});

// articles/show.html.erb
$(function(){
  // var content = marked($(".markdown-preview").text())
  // $(".markdown-preview").html(content);
});

// articles/edit.html.erb
$(function(){
  if($(".markdown-editor").val()){
    console.log($(this).val())
    console.log(1)
    // var content = marked($(".preview-content").text())
    var content = marked($(".markdown-editor").text())
    $(".preview-content").html(content);
  }
});

