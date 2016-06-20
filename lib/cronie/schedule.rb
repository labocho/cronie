module Cronie
  class Schedule
    class ParseError < Cronie::Error; end

    class Element
      TYPES = [:minute, :hour, :day_of_month, :month, :day_of_week]
      # type is in TYPES
      # numbers is Array of Fixnum, Range, or :*
      attr_accessor :type, :numbers, :step

      def self.parse(text, type)
        element = new(type: type)
        numbers, step = text.split("/")
        numbers = numbers.split(",")

        element.step = case step
        when nil
          1
        when /\A\d+\z/
          step.to_i
        else
          raise ParseError, "Unexpected step #{step.inspect} found in #{text.inspect}"
        end

        element.numbers = numbers.map do |e|
          case e
          when "*"
            :*
          when /\A\d+\z/
            e.to_i
          when /\A(\d+)-(\d+)\z/
            ($1.to_i..$2.to_i)
          else
            parse_special_element(e) || raise(ParseError, "Unexpected schedule element #{e.inspect} found in #{text.inspect}")
          end
        end

        element
      end

      def self.parse_special_element(str)
        str = str.downcase[0..2]
        # prepend nil to make index of "jan" to 1 (instead of 0)
        months = [nil] + %w(jan feb mar apr may jun jul aug sep oct nov dec)
        weekdays = %w(sun mon tue wed thu fri sat)
        months.index(str) || weekdays.index(str)
      end

      def initialize(attributes = {})
        attributes.each do |k, v|
          send("#{k}=", v)
        end
      end

      def to_a
        expanded = numbers.map{|n|
          case n
          when :*
            expand_asterisk
          when Range
            n.to_a
          else
            n
          end
        }.flatten

        expanded.select.with_index do |n, i|
          i % step == 0
        end
      end

      def =~(number)
        to_a.include?(number)
      end

      def to_s
        suffix = step == 1 ? "" : "/#{step}"
        numbers.map{|i|
          case i
          when Range
            "#{i.first}-#{i.last}"
          else
            i.to_s
          end
        }.join(",") + suffix
      end

      private
      def expand_asterisk
        case type
        when :minute
          (0..59).to_a
        when :hour
          (0..23).to_a
        when :day_of_month
          (1..31).to_a
        when :month
          (1..12).to_a
        when :day_of_week
          (0..6).to_a
        else
          raise ::Cronie::Error "Undefined type: #{type.inspect}"
        end
      end
    end

    # elements is array of 5 Element
    attr_accessor :elements
    private :elements, :elements=

    # Create instance from crontab format schedule string.
    # Raises `ParseError` if argument cannot be parsed.
    def self.parse!(str)
      return parse_special(str) if str =~ /\A@.+\z/
      unless str =~ %r(\A\s*\S+\s+\S+\s+\S+\s+\S+\s+\S+\s*\z)
        raise ParseError, "Unexpected schedule string #{str.inspect}"
      end

      elements = str.split(" ").zip(Element::TYPES).map do |text, type|
        Element.parse(text, type)
      end

      schedule = new
      schedule.send(:elements=, elements)
      schedule
    end

    # Create instance from crontab format schedule string.
    # Returns `nil` if argument cannot be parsed.
    def self.parse(*args)
      parse! *args
    rescue ParseError
    end

    # Returns whether schedule matches Time
    def =~(t)
      numbers = [t.min, t.hour, t.day, t.month, t.wday]
      elements.zip(numbers).all?{|element, number|
        element =~ number
      }
    end

    # Returns as crontab format
    # If not a number (@weekly, sun, ...) passed, it shows as number
    def to_s
      return super unless elements
      elements.map(&:to_s).join(" ")
    end

    def inspect
      "#<Cronie::Schedule: #{to_s}>"
    end

    def ==(other)
      other.is_a?(Cronie::Schedule) && to_s == other.to_s
    end

    private
    def self.parse_special(str)
      case str
      when "@reboot"
        raise ParseError, "Sorry, cronie cannot run at @reboot"
      when "@year", "@annually"
        parse "0 0 1 1 *"
      when "@monthly"
        parse "0 0 1 * *"
      when "@weekly"
        parse "0 0 * * 0"
      when "@daily", "@midnight"
        parse "0 0 * * *"
      when "@hourly"
        parse "0 * * * *"
      else
        raise ParseError, "Unexpected schedule string: #{str}"
      end
    end
  end
end
