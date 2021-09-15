# BozosBuckets

![image](https://user-images.githubusercontent.com/1747322/133355305-081def1a-f48b-4ded-9cc9-9126a8df0601.png)

BozosBuckets is a low overhead implementation of a [token bucket](https://en.wikipedia.org/wiki/Token_bucket)
for rate limiting. BozosBuckets uses a simple abstraction of tokens and buckets
instead of arrays or linked list, and therefore has a tiny memory footprint.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bozos_buckets'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install bozos_buckets

## Usage

### Instantiating a bucket

```ruby
# By default, the constructor returns a bucket with 100 initial tokens,
# 100 max tokens, with a refill rate of 1 token per second
bucket = BozosBuckets::Bucket.new

# Or you can configure the bucket to match your use case
more_restrictive_bucket = BozosBuckets::Bucket.new(
    initial_token_count: 25,
    refill_rate: 0.001,
    max_token_count: 50
)
```

### Using tokens

Once you have a bucket initialized, simply call `use_tokens` along with
whatever functionality you want to rate limit.

```ruby
def my_rate_limited_method
  # This will return `true` if tokens are available and remove 1
  # token from the bucket
  if bucket.use_tokens
    do_something_useful
  else
    # If the bucket has no tokens, you can raise an exception,
    # return an HTTP 429, whatever
    raise LimitExceededException
  end
end

def do_multiple_things(things: 5)
  # You can also spend multiple tokens if necessary
  if bucket.use_tokens(count: things)
    (0..things).each { |thing| puts thing}
  end
end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alexdglover/bozos_buckets.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
