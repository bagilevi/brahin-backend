# Memonite-Brahin

Experimental wiki software written in Rails and JavaScript - central Rails app.

This application is the central place for the _Brahin_ iteration.

The _Brahin_ iteration is an experiment of a modular, progressive enhancement approach.
You start with a HTML page, that can be viewed without any scripting.
The page will contain information about which editor was used to create it,
and that editor will be loaded.
Every functionality is developed as a separate file, which could theretically be optional,
e.g. linking between pages, single-page-app, storage, tree-navigation, search, etc.

## Installation

This is a simple Rails application.
It uses file storage in development, Redis in production.

    bundle install
    bundle exec rails server

## Deployment

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

## Development

The main front-end bits are in `public/modules/`, not part of the Rails asset pipeline.
