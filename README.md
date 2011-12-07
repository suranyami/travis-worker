# About travis-worker #

This is home for the next generation of Travis CI worker. It is a WIP and is still very rough around the edges
for broader community of contributors to jump in.

## Getting started ##

You will need JRuby:

  rvm install jruby
  rvm  use jruby

Install Bundler:

    gem install bundler

Pull down dependencies:

    bundle install

Copy the example worker file:

    cp config/worker.example.yml config/worker.yml
    
and edit the AMQP section:

    amqp:
      host: localhost
      port: 5672
      username: guest
      password: guest
      virtual_host: travis
      
In the directory above travis-worker you need to have cloned travis-boxes:

    cd ..
    git clone https://github.com/travis-ci/travis-boxes.git
    cd travis-boxes

Then create a staging environment:

    thor travis:box:build -d staging

Pull down submodules (Travis cookbooks, et cetera):

    git submodule update --init

Spin up a new Vagrant VM that will be provisioned with Opscode Chef:

    vagrant init
    vagrant up

## Running the worker

    nohup thor travis:worker:boot >> log/worker.log 2>&1 &
    JRUBY_OPTS="-J-Dcom.sun.management.jmxremote.port=1099 -J-Dcom.sun.management.jmxremote.authenticate=false -J-Dcom.sun.management.jmxremote.ssl=false -J-Djava.rmi.server.hostname=127.0.0.1" nohup thor travis:worker:boot >> log/worker.log 2>&1 &

## Running the Thor console

    ruby -Ilib -rubygems lib/thor/console.rb


## Running tests ##

In JRuby:

    rspec spec


## License & copyright information ##

See LICENSE file.

Copyright (c) 2011 [Travis CI development team](https://github.com/travis-ci).
