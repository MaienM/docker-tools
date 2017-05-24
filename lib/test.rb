class App
    command :ps do |c|
        c.syntax = 'docker-tools ps [options]'
        c.summary = ''
        c.description = ''
        c.example 'description', 'command example'
        c.option '--some-switch', 'Some switch that does something'
        c.action do |args, options|
            # Do something or c.when_called Docker-tools::Commands::Ps
        end
    end
end
