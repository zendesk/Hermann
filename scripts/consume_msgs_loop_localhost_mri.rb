require 'bundler/setup'
require 'rubygems'

$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
$LOAD_PATH << File.dirname(__FILE__) + "/../ext"
require 'hermann'
require 'hermann/consumer'

i = 0

#c = Hermann::Consumer.new( "maxwell", brokers: "localhost:9092", partition: i, offset: -1)
c = Hermann::Consumer.new( "maxwell", brokers: "localhost:9092", partition: i, offset: -1)

c.consume() do |msg, key, offset|
  puts "%s %s %d" % [msg, key, offset]
  break
end

c.offset = :start

c.consume() do |msg, key, offset|
  puts "%s %s %d" % [msg, key, offset]
  break
end

exit

while true
  max_offset = 0
  c.consume() do |msg, key, offset|
    max_offset = offset
    puts "%s %s %d" % [msg, key, offset]
    break
  end

  o = rand(max_offset)
  puts "dipping in at #{o}"
  c.offset = o
end

exit
t1 = 0
threads = []
100.times do |i|
  threads << Thread.new do
    puts "booting #{i}"
    c = Hermann::Consumer.new( "maxwell", brokers: "localhost:9092", partition: i, offset: :start)
    c.consume() do |msg, key, offset|
      puts("Received: #{msg} on #{i}")
      if(t1 == 0)
        t1 = Time.now
      end
      t2 = Time.now
      elapsed = t2 - t1
      puts("Total elapsed time: #{elapsed} seconds")
    end
  end
end
threads.each(&:join)
