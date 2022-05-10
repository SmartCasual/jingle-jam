class KeyAssignment::RequestProcessor # rubocop:disable Metrics/ClassLength
  QUEUES = [
    COMMAND_QUEUE = "key_assignment:command_queue".freeze,
    FULFILLMENT_QUEUE = "key_assignment:fulfillment_queue".freeze,
    RESPONSE_QUEUE = "key_assignment:response_queue".freeze,
  ].freeze

  PAUSE_COMMAND = "pause".freeze
  PING_COMMAND = "ping".freeze
  RECHECK_DATABASE_COMMAND = "recheck_database".freeze
  STATUS_REPORT_COMMAND = "status_report".freeze
  STOP_COMMAND = "stop".freeze
  UNPAUSE_COMMAND = "unpause".freeze

  class << self
    delegate :start, to: :new

    def queue_fulfillment(donator_bundle_tier)
      case donator_bundle_tier
      when DonatorBundleTier
        redis.lpush(FULFILLMENT_QUEUE, donator_bundle_tier.id)
      else
        raise ArgumentError, "Expected DonatorBundleTier, got #{donator_bundle_tier.class}"
      end
    end

    def recheck_database
      send_command(RECHECK_DATABASE_COMMAND)
    end

    def ping_processor!
      Rails.logger.debug("Pinging key assignment processor")
      nonce = SecureRandom.hex

      response = send_command(PING_COMMAND, nonce, await_response: true)
      response == nonce or raise PingMismatchError, "Response `#{response}` != `#{nonce}`"
    rescue Redis::TimeoutError => e
      raise PingTimeoutError, e
    end

    def status_report
      send_command(STATUS_REPORT_COMMAND, await_response: true, json: true)
    end

    def send_command(command, *args, await_response: false, json: false, **kwargs) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      await_response = 10 if await_response == true

      args = [JSON.dump(kwargs)] if json

      redis.lpush(COMMAND_QUEUE, args.unshift(client_id).unshift(command).join(" "))

      if await_response
        redis.subscribe_with_timeout(await_response, client_id) do |on|
          on.message do |channel, response|
            match = response.match(/\A(\w+) (.*)\z/)
            response_command, response_body = match[1, 2]

            response_args = if json
              JSON.parse(response_body, symbolize_names: true)
            elsif response_body.include?(" ")
              response_body.split
            else
              response_body
            end

            if response_command == command
              redis.unsubscribe(channel)

              response_args = response_args.first if response_args.length == 1
              return response_args
            end
          end
        end
      end
    end

    def clear_all_queues
      QUEUES.each do |queue|
        redis.del(queue)
      end
    end

  private

    def redis
      @redis ||= Redis.new
    end

    def client_id
      @client_id ||= SecureRandom.hex
    end
  end

  class PingTimeoutError < StandardError; end
  class PingMismatchError < StandardError; end

  def initialize
    @key_assigner = KeyAssignment::KeyAssigner.new
  end

  def start
    process_backlog_from_database
    begin_reading_from_redis_queue
  end

private

  attr_reader :key_assigner

  def process_backlog_from_database
    @processing_backlog = true
    Rails.logger.debug("Processing backlog from database...")
    Fundraiser.active.open.each do |fundraiser|
      tiers = DonatorBundleTier
        .unlocked
        .unfulfilled
        .oldest_first
        .for_fundraiser(fundraiser)

      tiers.each do |donator_bundle_tier|
        key_assigner.assign(donator_bundle_tier, fundraiser:)
      end
    end
    @processing_backlog = false
  end

  def begin_reading_from_redis_queue
    Rails.logger.debug("Beginning to read from redis queue...")

    loop do
      process_next_tier unless paused?
      process_command_queue
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.debug { "Could not find donator bundle tier with ID `#{donator_bundle_id}`" }
    Rollbar.error(e)
  end

  def process_next_tier
    _, donator_bundle_id = redis.blpop(FULFILLMENT_QUEUE, timeout: 1)

    if donator_bundle_id
      key_assigner.assign(DonatorBundleTier.find(donator_bundle_id))
    end
  end

  def process_command_queue
    if (command = redis.lpop(COMMAND_QUEUE))
      execute(*command.split)
    elsif paused?
      # Without the backpressure from tier processing, we need to
      # slow down polling the command queue.
      sleep 1
    end
  end

  def execute(command, client_id, *args)
    case command
    when RECHECK_DATABASE_COMMAND
      process_backlog_from_database
    when PAUSE_COMMAND
      Rails.logger.debug("Pausing...")
      @paused = true
    when UNPAUSE_COMMAND
      Rails.logger.debug("Unpausing...")
      @paused = false
    when PING_COMMAND
      Rails.logger.debug("Received PING")
      respond_with(command, client_id, args)
    when STOP_COMMAND
      Rails.logger.debug("Stopping key assignment...")
      exit # rubocop:disable Rails/Exit
    when STATUS_REPORT_COMMAND
      Rails.logger.debug("Status report requested")
      respond_with(command, client_id, **status_report, json: true)
    end
  end

  def respond_with(response, client_id, args = [], json: false, **kwargs)
    args = [JSON.dump(kwargs)] if json
    redis.publish(client_id, args.unshift(response).join(" "))
  end

  def status_report
    {
      paused: paused?,
      processing_backlog: @processing_backlog,
      queue_size: redis.llen(FULFILLMENT_QUEUE),
    }
  end

  def redis
    @redis ||= Redis.new
  end

  def paused?
    !!@paused
  end
end
