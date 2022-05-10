module RetryHelpers
  def wait_for(timeout: 10, step: 0.1, &block)
    time_waited = 0

    while block.call != true
      if time_waited >= timeout
        raise "#{block} didn't return true within #{timeout}s"
      end

      sleep step
      time_waited += step
    end
  end

  def retry_for(exception:, seconds: nil, attempts: nil, step: 1)
    attempts = (seconds / step).to_i if attempts.nil?

    yield
  rescue *Array(exception) => e
    if attempts.positive?
      attempts -= 1
      sleep(step)
      retry
    else
      raise e
    end
  end
end
