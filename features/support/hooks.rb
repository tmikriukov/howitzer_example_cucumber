Before do |scenario|
  Capybara.use_default_driver
  feature_name = \
    if Cucumber::VERSION.first.to_i > 3
      File.read(scenario.location.file)[/Feature:\s(.+)/, 1]
    else
      scenario.feature.name
    end
  Howitzer::Log.print_feature_name(feature_name)
  Howitzer::Log.print_scenario_name(scenario.name)
  @session_start = CapybaraHelpers.duration(Time.now.utc - Howitzer::Cache.extract(:cloud, :start_time))
end

After do |scenario|
  if CapybaraHelpers.cloud_driver?
    Howitzer::Cache.store(:cloud, :status, false) if scenario.failed?
    session_end = CapybaraHelpers.duration(Time.now.utc - Howitzer::Cache.extract(:cloud, :start_time))
    Howitzer::Log.info "CLOUD VIDEO #{@session_start} - #{session_end}" \
                       " URL: #{CapybaraHelpers.cloud_resource_path(:video)}"
  elsif CapybaraHelpers.ie_browser?
    Howitzer::Log.info 'IE reset session'
    Capybara.current_session.execute_script("void(document.execCommand('ClearAuthenticationCache', false));")
  end

  test_teardown = Howitzer::Cache.extract(:teardown)
  test_teardown.each_key do |key|
    instance_variable_get("@#{key}")&.destroy
  end

  Howitzer::Cache.clear_all_ns
  Capybara.reset_sessions!
end

at_exit do
  if CapybaraHelpers.cloud_driver?
    Howitzer::Log.info "CLOUD SERVER LOG URL: #{CapybaraHelpers.cloud_resource_path(:server_log)}"
    CapybaraHelpers.update_cloud_job_status(passed: Howitzer::Cache.extract(:cloud, :status))
  end
end

require 'capybara-screenshot/cucumber'
