import '../../stylesheets/users/tweets'

// 投稿日時に基づいて時刻を表示する関数
const updateTimeAgo = (timestamp) => {
  const now = new Date().getTime() / 1000;
  const secondsAgo = Math.floor(now - timestamp);
  const minutesAgo = Math.floor(secondsAgo / 60);
  const hoursAgo = Math.floor(minutesAgo / 60);
  const daysAgo = Math.floor(hoursAgo / 24);

  if (daysAgo >= 1) {
    const date = new Date(timestamp * 1000);
    const year = date.getFullYear();
    const month = ("0" + (date.getMonth() + 1)).slice(-2);
    const day = ("0" + date.getDate()).slice(-2);
    const hour = ("0" + date.getHours()).slice(-2);
    const minutes = ("0" + date.getMinutes()).slice(-2);
    return `・${year}年${month}月${day}日 ${hour}:${minutes}`;
  } else if (hoursAgo >= 1) {
    return `・${hoursAgo}時間前`;
  } else if (minutesAgo >= 1) {
    return `・${minutesAgo}分前`;
  } else {
    return '・たった今';
  }
};

// コメント一覧の時刻を自動更新する関数
const updateTimestamps = () => {
  const timestampElements = document.querySelectorAll('.timestamp');

  timestampElements.forEach((timestampElement) => {
    const timestamp = parseInt(timestampElement.dataset.time, 10);
    const timeAgo = updateTimeAgo(timestamp);
    timestampElement.textContent = timeAgo;
  });
};

// コメント一覧のページが読み込まれた時に実行される関数
document.addEventListener('DOMContentLoaded', () => {
  setInterval(updateTimestamps); // 「1000分の1秒」ごとに更新する
});

// notification-linkクラスを持つリンクがクリックされたときにフォームが送信される
document.addEventListener('DOMContentLoaded', () => {
  const notificationLinks = document.querySelectorAll('.notification-link');

  notificationLinks.forEach((link) => {
    link.addEventListener('click', (event) => {
      event.preventDefault();
      const form = link.closest('.notification-form');
      form.submit();
    });
  });
});

// つぶやき一覧でつぶやきを押下した際につぶやき詳細画面に遷移するメソッド
$(document).on('turbolinks:load', function() { //Turbolinks がページをロードした後に実行されるイベントリスナー。要はリンクをクリックしてページがロードした後に実行される。
  $('.tweet-post').on('click', function(e) { //tweet-postクラスが適用された要素がクリックされるときに実行されるイベントリスナー
    if (!$(e.target).is('a')) { // クリックされた要素が<a>タグでない場合の条件式
      window.location.href = $(this).data('tweet-url'); // 現在のページのURLを、クリックされたtweet-post要素のdata-tweet-url属性に設定されたURLに変更
    }
  });
});
