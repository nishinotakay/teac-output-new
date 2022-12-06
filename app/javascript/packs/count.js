function count (){ 
  const postText = document.getElementById('post_text');

  postText.addEventListener("keyup", () => {
   let titleLength = postText.value.length
   let countTitle = document.getElementById('count_title')
   if (titleLength > 240){
     titleLength = 240
   }
   countTitle.innerHTML = `${titleLength}文字`
  });
}
window.addEventListener('load', count);