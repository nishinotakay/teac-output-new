// app/javascript/packs/users/chat_gpt.js
document.addEventListener('turbolinks:load', function() {
  console.log("chat_gpt.js is loaded");

  const continueButton = document.getElementById('continue_question_button');
  const newPromptField = document.getElementById('new_prompt');
  const loadingSpinner = document.getElementById('loading-spinner');
  let isProcessing = false;
  let enterPressTimeout = null;

  function sendQuestion() {
    console.log("sendQuestion called");

    // 既に処理中の場合は何もしない
    if (isProcessing) return;

    const newPrompt = newPromptField.value;
    const previousResponse = newPromptField.dataset.previousResponse;
    const chatGptId = window.location.pathname.split('/').pop();

    // ボタンを無効化し、スピナーを表示
    continueButton.disabled = true;
    loadingSpinner.style.display = 'block';
    isProcessing = true;

    fetch(`/users/chat_gpts/${chatGptId}/continue_question`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      },
      body: JSON.stringify({ previous_response: previousResponse, new_prompt: newPrompt })
    })
    .then(response => {
      console.log("Response status:", response.status);
      return response.json().then(data => {
        if (!response.ok) {
          throw new Error(data.error || 'Unknown error (Error code 1)');
        }
        return data;
      });
    })
    .then(data => {
      console.log("Response data:", data);
      if (data.error) {
        alert(data.error + " (Error code 2)");
      } else {
        const contentDiv = document.querySelector('.show-page-card-body');
        contentDiv.innerHTML = data.content.split('\n').map(line => `<p>${line}</p>`).join('');
        newPromptField.value = '';
        newPromptField.dataset.previousResponse = data.content;
      }
    })
    .catch(error => {
      console.error('Error:', error);
      alert('質問の送信に失敗しました。エラーコード 3: ' + error.message);
    })
    .finally(() => {
      // ボタンを有効化し、スピナーを非表示
      continueButton.disabled = false;
      loadingSpinner.style.display = 'none';
      isProcessing = false;
    });
  }

  if (continueButton && newPromptField) {
    continueButton.addEventListener('click', sendQuestion);

    newPromptField.addEventListener('keydown', function(event) {
      if (event.key === 'Enter') {
        console.log("Enter key pressed");
        event.preventDefault();

        if (enterPressTimeout) {
          clearTimeout(enterPressTimeout);
          enterPressTimeout = null;
          sendQuestion();
        } else {
          enterPressTimeout = setTimeout(() => {
            enterPressTimeout = null;
          }, 1000); // 1秒以内に再度Enterキーが押されたら送信
        }
      }
    });
  }
});
