require_relative './channel'

module Concurrency
  # Actor thread, runs a loop and processes messages.
  #
  # Example:
  #
  #     class MyActor < Concurrency::Actor
  #       def on_messages(messages)
  #         puts "Received message: #{messages.inspect}"
  #       end
  #     end
  #
  #     my_actor = MyActor.new
  #
  #     other_thread = Thread.new do
  #       loop do
  #         sleep 1
  #         my_actor.send_message('yo')
  #       end
  #     end
  #
  #     my_actor.join
  #     other_thread.join
  #
  class Actor
    def initialize(name = nil)
      name ||= "actor#{object_id}"

      @channel = Concurrency::Channel.new

      @thread = Thread.new do
        loop do
          loop do
            messages = @channel.receive_all
            break if messages.empty?
            on_messages(messages)
          end

          Thread.stop
        end
      end
      @thread.abort_on_exception = true
    end

    def <<(*messages)
      send_messages(messages)
    end

    def send_messages(messages)
      @channel.<<(*messages)
      @thread.wakeup if @thread.status == 'sleep'
    end

    def join
      @thread.join
    end

    def on_messages(messages)
      raise "on_messages must be implemented on subclass of Actor"
    end
  end
end
