Basic prerequisites:
-----------------------
    bundle gem (sudo gem install bundle)

    mysql (or postgresql?) with a database for DontLoseTrack!

    memcached (if you want caching, or store openid nonces in memcache)

    ruby (and rubygems)

    pygments (for syntax highlighting)

    make (GNU make)


Prerequisites for optimization:
------------------------

To later optimize the static files, you'll need the following

    node.js (nodejs)



Installation:
----------------------
Grab a copy of DontLoseTrack

    git clone git://github.com/bwalex/DontLoseTrack.git
    cd DontLoseTrack
    git checkout backbone


Grab the required ruby gems by running:

    bundle install



Basic configuration:
-----------------------

Now look at config/config.yml and adjust to your liking; openid can use both memcache
or filesystem stores - an example for each is provided.

Caching requires memcache, but you can disable it by commenting out the whole cache:
section.


For the database configuration, open config/database.yml. It's a regular ActiveRecord
style configuration file. Adjust adapter, user, password, host, database to match
your configuration.


Change the port and the listen address in the unicorn.rb file. See unicorn documentation
for more details.



Bootstrap:
-------------------

Build templates and CSS files:

    make tmpl css


Create database tables:

    make db



Optimize (optional):
---------------------

Generate optimized static files (minified and unified javascript, etc) by running:

    make optimize

and setting

    optimized: true

in the configuration file config/config.yml.




Run:
------------------

DontLoseTrack! depends on unicorn as an application server. It is possible to use a
different one such as thin or rainbow by creating an appropriate config file for it
that establishes and cleans the ActiveRecord connections (see unicorn.rb).

To run, type:

    bundle exec unicorn -c unicorn.rb