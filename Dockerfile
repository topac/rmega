FROM ruby

RUN apt-get install -y

RUN mkdir app

COPY . /app

RUN cd /app && \
    gem install bundler && \
    bundle install

WORKDIR /app
ENTRYPOINT ["rspec", "-f", "d"]
