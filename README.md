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

## Benchmark

What's the runtime cost of adding bozos_buckets to your code?

```ruby
[1] pry(main)> require 'benchmark/ips'
[2] pry(main)> require_relative 'lib/bozos_buckets'

[3] pry(main)> inexhaustible_bucket = BozosBuckets::Bucket.new(initial_token_count: 500, refill_rate: 999999999, max_token_count: 999999999)

=> #<BozosBuckets::Bucket:0x0000563a8dafbd38
 @current_token_count=500,
 @last_refilled=1632581059,
 @max_token_count=999999999,
 @refill_rate=999999999>

[4] pry(main)> easily_exhaustible_bucket = BozosBuckets::Bucket.new(initial_token_count: 10, refill_rate: 0, max_token_count: 10)
=> #<BozosBuckets::Bucket:0x0000563a8dab6030
 @current_token_count=10,
 @last_refilled=1632581077,
 @max_token_count=10,
 @refill_rate=0>
[5] pry(main)> Benchmark.ips do |x|
[5] pry(main)*   x.report("without bozos_buckets") { 1+1 }
[5] pry(main)*   x.report("with bozos_buckets, no limits") { 1+1 if inexhaustible_bucket.use_tokens }
[5] pry(main)*   x.report("with bozos_buckets, limit quickly exceeded") { 1+1 if easily_exhaustible_bucket.use_tokens }
[5] pry(main)*   x.compare!
[5] pry(main)* end
Warming up --------------------------------------
without bozos_buckets
                         2.003M i/100ms
with bozos_buckets, no limits
                       109.542k i/100ms
with bozos_buckets, limit quickly exceeded
                       111.998k i/100ms
Calculating -------------------------------------
without bozos_buckets
                         19.942M (± 1.6%) i/s -    100.138M in   5.022679s
with bozos_buckets, no limits
                          1.089M (± 3.2%) i/s -      5.477M in   5.034054s
with bozos_buckets, limit quickly exceeded
                          1.120M (± 0.7%) i/s -      5.600M in   5.001274s

Comparison:
without bozos_buckets: 19942390.0 i/s
with bozos_buckets, limit quickly exceeded:  1119744.2 i/s - 17.81x  (± 0.00) slower
with bozos_buckets, no limits:  1089430.5 i/s - 18.31x  (± 0.00) slower
```

TL;DR about 20x slower.

Memory footprint is 80 bytes for each bucket instance

```ruby
[1] pry(main)> require 'objspace'
=> true
[2] pry(main)> require_relative 'lib/bozos_buckets'
=> true
[3] pry(main)> b = BozosBuckets::Bucket.new
=> #<BozosBuckets::Bucket:0x000055bd62b45af8
 @current_token_count=100,
 @last_refilled=1632582094,
 @max_token_count=100,
 @refill_rate=1>
[4] pry(main)> ObjectSpace.memsize_of(b)
=> 80
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alexdglover/bozos_buckets.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
