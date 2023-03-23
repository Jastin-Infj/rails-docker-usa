FROM ruby:2.7
ENV RAILS_ENV=production

# CircleCIで設定した環境変数の値を持った変数
ARG RAILS_MASTER_KEY
# ARGで機能した変数RAILS_MASTER_KEY コンテナ内
ENV RAILS_MASTER_KEY $RAILS_MASTER_KEY

# nodejsのダウンロード
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq

# nodejsおよび npm yarn のダウンロード
RUN apt-get install -y nodejs npm yarn 

# nodejs のバージョン高く設定 sass のエラーを防ぐ
RUN npm install n -g
RUN n 14.17.0

WORKDIR /app
COPY ./src /app

# Rubyのパッケージをダウンロード
RUN bundle config --local set path 'vendor/bundle' \
  && bundle install

# vim
RUN apt-get install -y vim

COPY start.sh /start.sh
RUN chmod 744 /start.sh

# MySQL の設定ファイル だが、使えていない？
COPY my.cnf /my.cnf
RUN chmod 744 /my.cnf

CMD ["sh", "/start.sh","mysqld","/my.cnf"]

# Ruby コマンド
RUN bundle exec rails webpacker:install
RUN bundle exec rails webpacker:compile