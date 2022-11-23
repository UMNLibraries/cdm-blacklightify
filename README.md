# cdm-blacklightify
Blacklightify a CONTENTdm collection

### Requirements

1. Ruby (3.1)
2. Ruby on Rails (6.1)
3. Java Runtime Environment (JRE) version 1.8  *for Solr*
4. ImageMagick (http://www.imagemagick.org/script/index.php) due to [carrierwave](https://github.com/carrierwaveuploader/carrierwave#adding-versions)
5. [Oniguruma](https://github.com/stedolan/jq/wiki/FAQ#installation) for `ruby-jq` bindings, used by fast solr export (`brew install oniguruma`, `apt-get install libonig-dev`, `yum install oniguruma-devel` )
6. Redis for sidekiq
7. Git-flow branching workflow tools ([Installation docs](https://github.com/nvie/gitflow/wiki/FAQ))

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

6. Start development services via `foreman`. This will result in Redis being downloaded, compiled, and started up in `tmp/`, Solr being download and/or started via `solr_wrapper` using the config at `.solr_wrapper.yml`, Sidekiq queuing service starting, and finally, the Rails development web server.

```shell
$ bundle exec foreman start
```

OPTIONAL: Starting some services independently is possible if a fast startup is deesired, especially when the Sidekiq job queue won't be needed.

```shell
# Start solr without the whole foreman suite
$ bundle exec solr_wrapper --config .solr_wrapper.yml

# Start Rails/Puma without the whole foreman suite
# (port 3000, limited to only the local network interface)
$ bundle exec rails server -b 127.0.0.1 -p 3000
```

Visit [http://localhost:3000](http://localhost:3000) in your browser to see your locally running instance

#### Harvest Documents

7. Assuming Redis and Sidekiq are running (started with `foreman`), run Harvest rake task

```shell
$ bundle exec rake umedia:index:harvest
```
8. (Optional) Commit to Solr

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

## Example Items

* Moving Image / http://localhost:3000/catalog/p16022coll262:494
* Still Image / http://localhost:3000/catalog/p16022coll208:2288
* Sound / http://localhost:3000/catalog/p16022coll171:610
* Text / http://localhost:3000/catalog/p16022coll282:5610
* Kaltura Audio Playlist / http://localhost:3000/catalog/p16022coll171:3715
