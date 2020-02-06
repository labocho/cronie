# Cronie

## Installation

Add this line to your application's Gemfile:

    gem 'cronie', git: 'https://github.com/labocho/cronie.git'

And then execute:

    $ bundle

## Usage

Create `Croniefile`.

    # Optional time zone setting
    set_utc_offset "+09:00"

    # Define task
    task "Daily task at 00:30", "0 30 * * *" do
      do_monthly_task
    end

    # Omit title
    task "0 * * * *" do
      do_hourly_task
    end

    # Omit schedule (run every minute)
    task do
      do_hourly_task
    end

In your application.

    require "cronie"
    Cronie.load("./Croniefile")
    Cronie.run(Time.now)

## Work with ActiveJob

In your application.

    require "resque/active_job"
    Cronie.load("./Croniefile")

Register job via Ruby.

    Cronie.perform_later(Time.now.to_i)

## Work with Resque

If you use resque, you can add job via redis-cli.

    $ redis-cli sadd resque:queues cronie
    $ redis-cli rpush resque:queue:cronie '{"class":"Cronie","args":'`date +%s`'}'

Run worker that processes `cronie` queue.

    $ rake resque:work QUEUE=cronie

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
