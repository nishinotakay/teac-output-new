// Sprocketsを使用している部分
//= require jquery            // jQueryを読み込み
//= require jquery_ujs        // jQuery UJSを読み込み
//= require popper            // Popper.jsを読み込み（Bootstrapの依存関係）
//= require bootstrap-sprockets // Bootstrapを読み込み（Sprockets用）

// Webpackerを使用している部分
// import 'bootstrap' はWebpackerでの読み込みが重複するためコメントアウト
// import 'bootstrap'

// カスタムJavaScriptファイルの読み込み（Webpacker用）
import './count';             // カウント機能を提供するJavaScriptファイル
import './count_t';           // 別のカウント機能を提供するJavaScriptファイル
import './users/chat_gpt';    // チャットGPTに関連するJavaScriptファイル

// スタイルシートのインポート（Webpacker用）
import '../stylesheets/users/inquiries.scss'; // 問い合わせに関連するスタイルシート
import '../stylesheets/users/posts.scss';     // 投稿に関連するスタイルシート
import '../stylesheets/users/e_learning.scss'; // eラーニングに関連するスタイルシート
