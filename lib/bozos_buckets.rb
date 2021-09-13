# frozen_string_literal: true

require_relative './bozos_buckets/version'

module BozosBuckets
  class BucketExhausted < RuntimeError; end

  # Bucket class
  class Bucket
    attr_reader :current_token_count, :refill_rate, :max_token_count, :last_used

    # Constructor
    #
    # @param initial_token_count [Integer] the number of tokens the bucket
    #   starts with
    # @param refill_rate [Double] How many tokens per second should be added to
    #   the bucket. For example, 1 would be 1 token per second. 0.1 would be one
    #   token per 10 seconds
    # @param max_token_count [Integer] the maximum number of tokens the bucket
    #   can hold. Defaults to the initial_token_count if not provided
    # @return An instance of BozosBucket
    def initialize(initial_token_count: 100, refill_rate: 1, max_token_count: 100)
      @current_token_count = initial_token_count
      @refill_rate = refill_rate
      @max_token_count = max_token_count || initial_token_count
      reset_last_used
    end

    def use_tokens(count: 1)
      refill_bucket
      reset_last_used

      raise BozosBuckets::BucketExhausted unless (@current_token_count - count) >= 0

      @current_token_count -= count
    end

    def refill_bucket
      elapsed_seconds = Time.now.to_i - last_used
      tokens_to_add = (elapsed_seconds * refill_rate).floor
      @current_token_count = [@current_token_count + tokens_to_add, max_token_count].min
    end

    def reset_last_used
      @last_used = Time.now.to_i
    end
  end
end
