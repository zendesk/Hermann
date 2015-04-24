require 'rubygems'
require 'lib/hermann'
require 'lib/hermann/consumer'

c = Hermann::Consumer.new( "maxwell", "maxwell_consumer", "localhost:9092", offset: :start )
t1 = 0
c.consume() do
  |msg| puts("Received: #{msg}")
  if(t1 == 0)
    t1 = Time.now
  end
  t2 = Time.now
  elapsed = t2 - t1
  puts("Total elapsed time: #{elapsed} seconds")
end
