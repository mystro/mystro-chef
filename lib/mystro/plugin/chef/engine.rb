module MystroChef
  class Engine < ::Rails::Engine
    isolate_namespace MystroChef

    config.to_prepare do
      ApplicationController.helper(ApplicationHelper)
    end

    initializer "chef.autoload.paths" do |app|
      app.config.autoload_paths += Dir[root.join('app','models','{**}')]
    end
  end
end