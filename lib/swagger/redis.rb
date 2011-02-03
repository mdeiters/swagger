require 'swagger/swallow'
require 'swagger/commands/helpers'
require 'swagger/commands/keys'
require 'swagger/commands/lists'
require 'swagger/commands/sets'
require 'swagger/commands/sorted_sets'
require 'swagger/commands/strings'

module Swagger
  class Redis

    extend Swallow

    swallow :namespace=
    swallow :namespace, 'not applicable'
    swallow :server, 'ActiveRecord'
    swallow :info, self.inspect

    include Commands::Keys
    include Commands::Lists
    include Commands::Sets
    include Commands::SortedSets
    include Commands::Strings

  end
end