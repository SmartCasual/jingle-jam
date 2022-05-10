module WithKeyAssignmentProcessor
  def with_key_assignment_processor
    raise "Missing block" unless block_given?

    thread = Thread.new do
      KeyAssignment::RequestProcessor.start
    end

    KeyAssignment::RequestProcessor.ping_processor!

    yield
  ensure
    thread.kill
    KeyAssignment::RequestProcessor.clear_all_queues
  end
end
