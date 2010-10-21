module Gigabitly
  module Settings
    set :logging, false
    configure :production do
      set :port, 80
    end
  end
end
