module Isolate

  # A simple way to watch and extend the Isolate lifecycle.
  #
  #    Isolate::Events.watch Isolate::Sandbox, :initialized do |sandbox|
  #      puts "A sandbox just got initialized: #{sandbox}"
  #    end
  #
  # Read the source for Isolate::Sandbox and Isolate::Entry to see
  # what sort of events are fired.

  module Events

    # Watch for an event called +name+ from an instance of
    # +klass+. +block+ will be called when the event occurs. Block
    # args vary by event, but usually an instance of the relevant
    # class is passed.

    def self.watch klass, name, &block
      watchers[[klass, name]] << block
    end

    def self.fire klass, name, *args #:nodoc:
      watchers[[klass, name]].each do |block|
        block[*args]
      end
    end

    def self.watchers #:nodoc:
      @watchers ||= Hash.new { |h, k| h[k] = [] }
    end

    def fire name, after = nil, *args, &block #:nodoc:
      Isolate::Events.fire self.class, name, self, *args

      if after && block_given?
        yield self
        Isolate::Events.fire self.class, after, *args
      end
    end
  end
end
