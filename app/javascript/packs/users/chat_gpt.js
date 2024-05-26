// app/javascript/packs/users/chat_gpt.js

document.addEventListener('turbolinks:load', function() {
  // 続けて質問するフォームの設定
  const continueButton = document.getElementById('continue_question_button');
  const newPromptField = document.getElementById('new_prompt');
  const loadingSpinner = document.getElementById('loading-spinner');
  let isProcessing = false;
  let enterKeyCount = 0;
  let enterKeyTimeout = null;

  function sendQuestion() {
    if (isProcessing) return;

    const newPrompt = newPromptField.value;
    const chatGptId = window.location.pathname.split('/').pop();

    continueButton.disabled = true;
    loadingSpinner.style.display = 'block';
    isProcessing = true;

    fetch(`/users/chat_gpts/${chatGptId}/continue_question`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      },
      body: JSON.stringify({ new_prompt: newPrompt })
    })
    .then(response => {
      return response.json().then(data => {
        if (!response.ok) {
          throw new Error(data.error || 'Unknown error');
        }
        return data;
      });
    })
    .then(data => {
      if (data.error) {
        alert(data.error);
      } else {
        const contentDiv = document.querySelector('.show-page-card-body');
        contentDiv.innerHTML = data.content.split('\n').map(line => `<p>${line}</p>`).join('');
        newPromptField.value = '';
        contentDiv.scrollTop = contentDiv.scrollHeight; // 一番下にスクロール
      }
    })
    .catch(error => {
      alert('質問の送信に失敗しました。エラーコード: ' + error.message);
    })
    .finally(() => {
      continueButton.disabled = false;
      loadingSpinner.style.display = 'none';
      isProcessing = false;
    });
  }

  if (continueButton && newPromptField) {
    continueButton.addEventListener('click', sendQuestion);

    newPromptField.addEventListener('keydown', function(event) {
      if (event.key === 'Enter' && !event.shiftKey) {
        event.preventDefault();
        if (isProcessing) return; // フォーム送信中なら何もしない

        enterKeyCount++;

        if (enterKeyTimeout) {
          clearTimeout(enterKeyTimeout);
        }

        enterKeyTimeout = setTimeout(() => {
          enterKeyCount = 0;
        }, 1000); // 1秒以内にカウントリセット

        if (enterKeyCount === 2) {
          sendQuestion();
          enterKeyCount = 0; // カウントリセット
        }
      }
    });
  }

  // 新規作成フォームの設定
  const newQuestionButton = document.getElementById('new_question_button');
  const newQuestionForm = document.getElementById('new-question-form');

  function submitNewQuestion() {
    if (isProcessing) return;

    newQuestionButton.disabled = true;
    loadingSpinner.style.display = 'block';
    isProcessing = true;
    newQuestionForm.submit();
  }

  if (newQuestionButton && newPromptField) {
    newPromptField.addEventListener('keydown', function(event) {
      if (event.key === 'Enter' && !event.shiftKey) {
        event.preventDefault();
        if (isProcessing) return; // フォーム送信中なら何もしない

        enterKeyCount++;

        if (enterKeyTimeout) {
          clearTimeout(enterKeyTimeout);
        }

        enterKeyTimeout = setTimeout(() => {
          enterKeyCount = 0;
        }, 1000); // 1秒以内にカウントリセット

        if (enterKeyCount === 2) {
          submitNewQuestion();
          enterKeyCount = 0; // カウントリセット
        }
      }
    });

    newQuestionButton.addEventListener('click', function(event) {
      event.preventDefault();
      submitNewQuestion();
    });
  }
});
