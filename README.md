# Cronie

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'cronie'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cronie

## Usage

TODO: Write usage instructions here

## Work with Resque

Register job via Ruby.

    Cronie.run_async(Time.now)

Register job via redis-cli.

    $ redis-cli sadd resque:queues cronie
    $ redis-cli rpush resque:queue:cronie '{"class":"Cronie","args":'`date +%s`'}'

Run worker that process `cronie` queue.

    $ rake resque:work QUEUE=cronie

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
