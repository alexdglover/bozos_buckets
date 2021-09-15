# frozen_string_literal: true

require_relative './bozos_buckets/version'

module BozosBuckets

  # Class representing a token bucket
  class Bucket
    attr_reader :current_token_count, :refill_rate, :max_token_count, :last_refilled

    # Constructs a Bucket instance
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
      reset_last_refilled
    end

    # Attempt to use tokens from the bucket. If there are sufficient 
    # tokens, @current_token_count is decremented by the `count` and method
    # returns `true`. If there are not sufficient tokens, method returns
    # false without changing the @current_token_count
    #
    # @param count [Integer] Number of tokens that should be used
    # @return [Boolean] Whether there were sufficient tokens when called
    def use_tokens(count: 1)
      refill_bucket

      if (@current_token_count - count) >= 0
        @current_token_count -= count
        return true
      else
        return false
      end
    end

    # Determines how many seconds have passed since the last time the bucket
    # was used, calculates how many tokens should be added to the bucket, and
    # adds them by updating @current_token_count
    #
    # @return [Integer] the current_token_count after refilling the bucket
    def refill_bucket
      elapsed_seconds = Time.now.to_i - last_refilled
      tokens_to_add = (elapsed_seconds * refill_rate).floor

      reset_last_refilled

      @current_token_count = [@current_token_count + tokens_to_add, max_token_count].min
    end

    private

    # Resets the last_refilled timestamp to the current time. Called by 
    # {#refill_bucket} after calculating elapsed time
    #
    # @return [Integer] last used timestamp in Unix epoch format. Should
    #   always be the current time
    def reset_last_refilled
      @last_refilled = Time.now.to_i
    end
  end
end
