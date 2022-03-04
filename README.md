# cdm-blacklightify
Blacklightify a CONTENTdm collection

### Requirements

1. Ruby (3.0.3)
2. Ruby on Rails (6.1)
3. Java Runtime Environment (JRE) version 1.8  *for Solr*
4. ImageMagick (http://www.imagemagick.org/script/index.php) due to [carrierwave](https://github.com/carrierwaveuploader/carrierwave#adding-versions)
5. Redis for sidekiq

### Installation

1. Clone the repository

`git clone git@github.com:UMNLibraries/cdm-blacklightify.git cdm-blacklightify`
`cd cdm-blacklightify`

2. bundle dependencies

`bundle install`

3. Configure DotEnv files

`cp .env.example .env`

Fill in missing env var values (@TODO: share via LastPass?)

4. Prepare development database

`bundle exec rails db:migrate

5. Start Solr server

`bundle exec solr_wrapper --config .solr_wrapper.yml`

6. Start Rails server

`bundle exec rails server`

Go to [http://localhost:3000](http://localhost:3000) in your browser.

#### Harvest Documents

7. Start Sidekiq

`bundle exec foreman start`

8. Run Harvest rake task

`bundle exec rake umedia:index:harvest`

8. (Optional) Commit to Solr

As your harvest is running, you can occasionally sent a `commit` to Solr to see what documents you have harvested.

`bundle exec rake umedia:index:commit `
