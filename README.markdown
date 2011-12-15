This code is a quick hack for converting markdown to [Atlassian confluence](http://atlassian.com/confluence) markup language.
It's nowhere near doing a full conversion, but I will continue to improve where possible.

The gem is based on [Kramdown](https://github.com/gettalong/kramdown)

### Installation:

#### Via gem

    $ gem install markdown2confluence

#### From github:

    $ gem install bundler
    $ git clone git://github.com/jedi4ever/markdown2confluence.git
    $ bundle install vendor

### Usage:

If using Gem:

    $ markdown2confluence <inputfile>

If using bundler:

    $ bundle exec bin/markdown2confluence <inputfile>

### Extending/Improving it:

there is really one class to edit - see lib/markdown2confluence/convertor/confluence.rb
Feel free to enhance or improve tag handling.
