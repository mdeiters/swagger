require 'resque'

require 'swagger/redis_impersonator'
require 'swagger/resque_extension'
require 'swagger/version'

module Swagger
  class << self
    attr_accessor :impersonator_klass
  end
end
