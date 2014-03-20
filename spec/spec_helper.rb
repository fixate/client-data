$:.unshift(File.join(File.dirname(__FILE__), "../lib"))
$:.unshift(File.dirname(__FILE__))

require 'client_data'

require 'support/client_data'

RSpec.configure do |config|
   # Run specs in random order to surface order dependencies. If you find an
   # order dependency and want to debug it, you can fix the order by providing
   # the seed, which is printed after each run.
   #     --seed 1234
   config.order = "random"
   # Allow for more brief test tags (:test instead of :test => true)
   config.treat_symbols_as_metadata_keys_with_true_values = true
end
