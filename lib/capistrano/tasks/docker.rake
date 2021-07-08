namespace :docker do
  desc "Build application images"
  task :build do
    on roles(:app) do
      within current_path do
        execute("docker-compose",
          "--project-name=#{fetch(:application)}_#{fetch(:stage)}",
          "-f", "docker-compose.#{fetch(:stage)}.yml",
          "build"
        )
      end
    end
  end

  desc "Take down compose application containers"
  task :down do
    on roles(:app) do
      within current_path do
        execute("docker-compose",
          "--project-name=#{fetch(:application)}_#{fetch(:stage)}",
          "-f", "docker-compose.#{fetch(:stage)}.yml",
          "down"
        )
      end
    end
  end

  namespace :restart do
    desc "Rebuild and restart web container"
    task :web do
      on roles(:app) do
        within current_path do
          execute("docker-compose",
            "--project-name=#{fetch(:application)}_#{fetch(:stage)}",
            "-f", "docker-compose.#{fetch(:stage)}.yml",
            "build", "base"
          )
          execute("docker-compose",
            "--project-name=#{fetch(:application)}_#{fetch(:stage)}",
            "-f", "docker-compose.#{fetch(:stage)}.yml",
            "build", "rails", "sidekiq"
          )
          execute("docker-compose",
            "--project-name=#{fetch(:application)}_#{fetch(:stage)}",
            "-f", "docker-compose.#{fetch(:stage)}.yml",
            "up", "-d", "--no-deps", "rails", "sidekiq"
          )
        end
      end
    end
  end

  namespace :redis do
    desc "Up redis and make sure it's ready"
    task :up do
      on roles(:app) do
        within current_path do
          execute("docker-compose",
            "--project-name=#{fetch(:application)}_#{fetch(:stage)}",
            "-f", "docker-compose.#{fetch(:stage)}.yml",
            "up", "-d", "--no-deps", "redis"
          )
        end
      end
      sleep 5
    end
  end

  namespace :database do
    desc "Up database and make sure it's ready"
    task :up do
      on roles(:app) do
        within current_path do
          execute("docker-compose",
            "--project-name=#{fetch(:application)}_#{fetch(:stage)}",
            "-f", "docker-compose.#{fetch(:stage)}.yml",
            "up", "-d", "--no-deps", "postgres"
          )
        end
      end
      sleep 5
    end

    desc "Create database"
    task :create do
      on roles(:app) do
        within current_path do
          execute("docker-compose",
            "--project-name=#{fetch(:application)}_#{fetch(:stage)}",
            "-f", "docker-compose.#{fetch(:stage)}.yml",
            "run", "--rm", "rails", "bundle", "exec", "rake", "db:create"
          )
        end
      end
    end

    desc "Migrate database"
    task :migrate do
      on roles(:app) do
        within current_path do
          execute("docker-compose",
            "--project-name=#{fetch(:application)}_#{fetch(:stage)}",
            "-f", "docker-compose.#{fetch(:stage)}.yml",
            "run", "--rm", "rails", "bundle", "exec", "rake", "db:migrate"
          )
        end
      end
    end
  end
end
