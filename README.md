# Pruner

## Description

The service fetches a remote upstream representing sample data about a country
population in a form of tree. Given `indicator_ids` the Pruner is capable of
filtering the data.

## Configuration

Service config lies in `.env` file. Configurable params are:

- `UPSTREAM_FETCH_ATTEMPTS`, default is `5`, how many times do we retry before considering upstream to be down
- `UPSTREAM_FETCH_RETRY_DELAY`, default is `0.3`, a delay in-between calls to the remote upstream is the previous response was 500
- `UPSTREAM_BASE_URL`, default is `https://kf6xwyykee.execute-api.us-east-1.amazonaws.com/production/tree/`
- `TREE_NODE_NAMES`, default is `sub_themes,categories,indicators`, tells the service how to dig into the tree

## API

The service exposes only one endpoint

- `tree/:name`

and accepts an array of `indicators` as params.

## How to start

The service utilizes `bundler` and the gems used lie within a `Gemfile`.

The service uses `Rack` middleware and `Puma` as a server, there are no specific configs for it, so it runs
with the default configuration. The basic command is `bundle exec rackup -p *port* -E *environment*`

### Example

- `bundle`
- `bundle exec rackup -p 4321 -E production`
- `curl "http://0.0.0.0:4321/tree/input?indicator_ids[]=1&indicator_ids[]=2" -g`

## How to run tests

As simple as `bundle exec rspec`

