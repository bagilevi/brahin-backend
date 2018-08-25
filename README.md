# Memonite-Brahin

Experimental wiki software written in Rails and JavaScript - central Rails app.

This application is the central place for the _Brahin_ iteration.

The _Brahin_ iteration is an experiment of a modular, progressive enhancement approach.
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

### Password-protect

By default, everyone who has the URL can view and edit documents.

To add simple password-protection, set the `HTTP_BASIC_AUTHENTICATION`
environment variable.
This can contain multiple entries delimited by ";",
each entry must contain 3 items - permission (read|write), username, password -
delimited by ":".
The wildcard "\*" may be used instead of a username to give the public
that permission.

Allow everyone to view (read) but not edit (write):

    HTTP_BASIC_AUTHENTICATION="read:*:*;write:mary:Pass1"

Allow reading with one password, editing with another:

    HTTP_BASIC_AUTHENTICATION="read:joe:Pass1;write:mary:Pass1"

### Force SSL

To force redirection to the https endpoint, set the env var:

    FORCE_SSL=1

## Development

The main front-end bits are in `public/modules/`, not part of the Rails asset pipeline.
