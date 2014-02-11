# desc "Explaining what the task does"
# task :mystro-chef do
#   # Task goes here
# end

namespace :mystro do
  namespace :chef do
    task :compute => :environment do
      c = Compute.last
      puts "roles: #{c.roles}"
    end
    task :role => :environment do
      c = MystroChef::Role.last
      puts "computes: #{c.computes.entries}"
    end
  end
end