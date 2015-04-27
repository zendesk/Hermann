# Hermann

[![Gitter chat](https://badges.gitter.im/lookout/Hermann.png)](https://gitter.im/lookout/Hermann) [![Build Status](https://travis-ci.org/lookout/Hermann.svg?branch=master)](https://travis-ci.org/lookout/Hermann)

A Ruby gem implementing a Kafka Publisher and Consumer

On MRI (C-based Ruby), this library wraps the [librdkafka
library](https://github.com/edenhill/librdkafka) which is implemented in C.

On JRuby this library [declares jar
dependencies](https://github.com/mkristian/jar-dependencies/wiki/declare-jars-inside-gemspec)
inside the `.gemspec` to express dependencies on the Java-based Kafka library
provided by the Kafka project. Tools like
[jbundler](https://github.com/mkristian/jbundler) will handle these
declarations correctly.

### Usage

Usage is modelled on the
[kafka-rb gem](https://github.com/acrosa/kafka-rb) and is fairly
straightforward.

- Kafka 0.8 is supported.
- Ruby 1.9.3, 2.1.1 and JRuby are tested against


### Producer

#### Zookeeper discovery (JRuby-only)

Discover Kafka brokers through zookeeper.  Looks at ```/brokers/ids``` in Zookeeper to find the list of brokers.

```ruby
require 'hermann/producer'
require 'hermann/discovery/zookeeper'

broker_ids_array = Hermann::Discovery::Zookeeper.new('localhost:2181').get_brokers
producer = Hermann::Producer.new('topic', broker_ids_array)

promise = producer.push('hello world') # send message to kafka
promise.value                          # forces the Concurrent::Promise to finish excuting (#value!)
promise.state                          # the state of the promise
```


#### MRI only

```ruby
require 'hermann/producer'

p = Hermann::Producer.new('topic', ['localhost:6667'])  # arguments topic, list of brokers
f = p.push('hello world from mri')                    
f.state                                               
p.tick_reactor                                        
f.state
```

### Consumer

Messages can be consumed by calling the consume method and passing a block to handle the yielded messages.  The consume method blocks, so take care to handle that functionality appropriately (i.e. use Concurrent::Promise, Thread, etc).

#### (JRuby)
```ruby
require 'hermann'
require 'hermann/consumer'
require 'hermann_jars'

topic     = 'topic'
new_topic = 'other_topic'

the_consumer = Hermann::Consumer.new(topic, zookeepers: "localhost:2181", group_id: "group1")

the_consumer.consume(new_topic) do |msg|   # can change topic with optional argument to .consume
  puts "Recv: #{msg}"
end
```


#### (MRI)

MRI currently has no zookeeper / client group support.

```ruby
require 'hermann'
require 'hermann/consumer'

topic     = 'topic'
new_topic = 'other_topic'

the_consumer = Hermann::Consumer.new(topic, brokers: "localhost:9092", partition: 1)

the_consumer.consume(new_topic) do |msg|   # can change topic with optional argument to .consume
  puts "Recv: #{msg}"
end
```






#### How to convert from using jruby-kafka

* Gemfile
  * remove jruby-kafka
  * add ```gem "hermann"```
  * ```bundle install```
* Jarfile
  * removed unecessary jars from your Jarfile (i.e. kafka, log4j)
  * jar dependencies are automatically included with Hermann
  * ```jbundle install```
* Test out one of the Producer/Consumer examples above





