# cdm-blacklightify
Blacklightify a CONTENTdm collection

### Requirements

1. Ruby (3.0.3)
2. Ruby on Rails (6.1)
3. Java Runtime Environment (JRE) version 1.8  *for Solr*
4. ImageMagick (http://www.imagemagick.org/script/index.php) due to [carrierwave](https://github.com/carrierwaveuploader/carrierwave#adding-versions)
5. Redis for sidekiq
6. Git-flow branching workflow tools ([Installation docs](https://github.com/nvie/gitflow/wiki/FAQ))

### Installation

1. Clone the repository

```shell
$ git clone git@github.com:UMNLibraries/cdm-blacklightify.git cdm-blacklightify
$ cd cdm-blacklightify
```

2. Setup git-flow
```shell
$ git flow init
```

Choose branches (accept defaults):
- Release branch: `main`
- Next release development branch: `develop`
- Feature branch prefix: `feature/`
- Hotfix prefix: `hotfix/`
- Release prefix: `release/`
- Support prefix: `support/`
- Version tag prefix: (leave blank)

3. bundle dependencies

```shell
$ bundle install
```

4. Configure DotEnv files

```shell
$ cp .env.example .env
```

Fill in missing env var values (@TODO: share via LastPass?)

5. Prepare development database

Build the project database tables and load our test fixtures for development use.

```shell
$ bundle exec rails db:migrate
$ bundle exec rails db:fixtures:load
```

6. Start Solr server

```shell
$ bundle exec solr_wrapper --config .solr_wrapper.yml
```

7. Start Rails server

```shell
$ bundle exec rails server
```

Go to [http://localhost:3000](http://localhost:3000) in your browser.

#### Harvest Documents

8. Start Sidekiq

```shell
$ bundle exec foreman start
```

9. Run Harvest rake task
```shell
$ bundle exec rake umedia:index:harvest
```
10. (Optional) Commit to Solr

As your harvest is running, you can occasionally sent a `commit` to Solr to see what documents you have harvested.
```shell
$ bundle exec rake umedia:index:commit
```

## Additional Usage
### Thumbnail management

```shell
# Store all thumbs
$ bundle exec umedia:thumbnails:store

# Store specific thumbs by doc id, space separated
$ DOC_IDS='p16022coll262:172 p16022coll262:173' bundle exec rake umedia:thumbnails:store

# Purge all thumbs
$ bundle exec umedia:thumbnails:purge

# Purge thumbs by doc id, space separated
$ DOC_IDS='p16022coll262:172 p16022coll262:173' bundle exec rake umedia:thumbnails:purge
```
