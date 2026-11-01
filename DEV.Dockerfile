FROM ruby:3.0.3

# Debian 11 (bullseye) は 2026-08-31 に LTS が終了し、security.debian.org から
# パッケージ本体が削除された（apt-get install 時に 404 Not Found になる）。
# main / updates は archive.debian.org へ切り替え、bullseye-security 行は削除する
# （archive.debian.org には bullseye-security がまだ存在しないため）。
RUN sed -i -e '/bullseye-security/d' \
           -e 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list && \
    apt-get update -y && \
    apt-get install default-mysql-client chromium chromium-driver nodejs npm vim graphviz -y && \
    npm uninstall yarn -g && \
    npm install yarn -g -y

# ルート直下にwebappという名前で作業ディレクトリを作成（コンテナ内のアプリケーションディレクトリ）
RUN mkdir /webapp
WORKDIR /webapp

# ホストのGemfileとGemfile.lockをコンテナにコピー
ADD Gemfile /webapp/Gemfile
ADD Gemfile.lock /webapp/Gemfile.lock

# bundle installの実行
RUN bundle install -j4

# ホストのアプリケーションディレクトリ内をすべてコンテナにコピー
ADD . /webapp

EXPOSE 3000

CMD bash -c "rm -f tmp/pids/server.pid && bundle exec puma -C config/puma.rb"

