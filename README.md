# cdm-blacklightify
Blacklightify a CONTENTdm collection

### Requirements

1. Ruby (3.0.3)
2. Ruby on Rails (6.1)
3. Java Runtime Environment (JRE) version 1.8  *for Solr*
4. ImageMagick (http://www.imagemagick.org/script/index.php) due to [carrierwave](https://github.com/carrierwaveuploader/carrierwave#adding-versions)

### Installation

1. Clone the repository

`git clone git@github.com:UMNLibraries/cdm-blacklightify.git cdm-blacklightify`
`cd cdm-blacklightify`

2. bundle dependencies

`bundle install`

3. Prepare development database

`bundle exec rails db:migrate

4. Start Solr server

`bundle exec solr_wrapper`

5. Start Rails server

`bundle exec rails server`

Go to [http://localhost:3000](http://localhost:3000) in your browser.
