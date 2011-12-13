This code is a quick hack for converting markdown to [Atlassian confluence](http://atlassian.com/confluence) markup language.

It's nowhere near doing a full conversion, but I will continue to improve where possible.

The gem is based on [Kramdown](https://github.com/gettalong/kramdown)

Installation:

__Note:__ This is not yet released as a gem

    $ gem install bundler
    $ git clone git://github.com/jedi4ever/markdown2confluence.git
    $ bundle install vendor

Usage:

`bundle exec bin/markdown2confluence <inputfile>`
