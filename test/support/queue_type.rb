module QueueType
  def self.apply_to(config)
    config.around(:example) do |example|
      queue_type = ActiveJob::Base.queue_adapter
      ActiveJob::Base.queue_adapter = example.metadata[:queue_type] || queue_type

      example.run

      ActiveJob::Base.queue_adapter = queue_type
    end
  end
end
