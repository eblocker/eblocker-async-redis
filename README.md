# Eblocker::Async::Redis

* async-io based connector
* simple connection ppol

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'eblocker-async-redis'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install eblocker-async-redis

## Usage
Create a pool somewhere:
    
    logger = Logger.new($stderr).tap{|logger| logger.level = Logger::DEBUG}
    @redis_pool = RedisPool.new({ :host => '127.0.0.1', :port => '6379'}, logger)

Use it:
    
    @redis_pool.connection do |redis|
        redis.rpush("hello", "world")
    end


## Development

https://github.com/eblocker/eblocker-async-redis
