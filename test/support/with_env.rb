module WithEnv
  def with_env(environment_variables = {}, &)
    raise "Missing block" unless block_given?

    ClimateControl.modify(environment_variables, &)
  end
end
