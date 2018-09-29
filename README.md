# Brahin Backend

Experimental wiki software written in Rails and JavaScript - central Rails app.

This is an experiment of a modular, progressive enhancement approach to implement a wiki app.
You start with a HTML page, that can be viewed without any scripting.
The page will contain information about which editor was used to create it,
and that editor will be loaded.
Every functionality is developed as a separate file, which could theoretically be optional,
e.g. linking between pages, single-page-app, storage, tree-navigation, search, etc.

## Installation

This is a simple Rails application.
It uses file storage in development, Redis in production.

    bundle install
    bundle exec rails server

## Deployment

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

## Configuration

### Force SSL

To force redirection to the https endpoint, set the env var:

    FORCE_SSL=1

## Development

The main front-end bits are in `public/modules/`, not part of the Rails asset pipeline.

The editor module is in the [brahin-slate-editor](https://github.com/bagilevi/brahin-slate-editor) repo.

## Licence

MIT - see [LICENCE](./LICENCE) file.
