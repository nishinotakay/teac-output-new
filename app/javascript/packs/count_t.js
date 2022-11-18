function count_t (){ 
  const postText = document.getElementById('post_title');

  postText.addEventListener("keyup", () => {
   let titleLength = postText.value.length
   let countTitle = document.getElementById('count_title_t')
   if (titleLength > 30){
     titleLength = 30
   }
   countTitle.innerHTML = `${titleLength}文字`
  });
}
window.addEventListener('load', count_t);