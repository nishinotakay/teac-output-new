import '../../stylesheets/users/tweets'

$(function(){
  //各種ボタン要素を取得しておく
  var dialog = document.getElementById('dialog');
  var btn = document.getElementById('btn');
  var yes = document.getElementById('yes');
  var no = document.getElementById('no');
  var cancel = document.getElementById('cancel');
  
  
  //ボタンがクリックされたらダイアログを表示する
  btn.addEventListener('click', function() {
      dialog.style.display = 'block';
      this.style.display = 'none';
  })
  
  //「はい」がクリックされたら
  yes.addEventListener('click', function(){ console.log('yes') });
  
  //「いいえ」がクリックされたら
  no.addEventListener('click', function(){ console.log('no') });
  
  //「キャンセル」がクリックされたら
  cancel.addEventListener('click', function(){ console.log('cancel') });



})
