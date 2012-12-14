module Cronie
  class Schedule
    class ParseError < Cronie::Error; end
    # type は TYPES のいずれか
    # numbers は Fixnum, Range, :* の配列
    class Element
      TYPES = [:minute, :hour, :day_of_month, :month, :day_of_week]
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
          raise ParseError, "Unexpected step #{step.inspect} found in #{str.inspect}"
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
            parse_special_element(e) || raise(ParseError, "Unexpected schedule element #{e.inspect} found in #{str.inspect}")
          end
        end

        element
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

    attr_accessor :elements
    private :elements, :elements=

    # crontab 形式のスケジュール指定文字列から新しいインスタンスをつくる
    # 内部形式は list と step の 2 要素配列の、5 要素配列
    # 0 1,2-3,4 */10 * * なら
    # [ [[0], nil],
    #   [[1,2..3,4], nil],
    #   [[:*], 10],
    #   [[:*], nil],
    #   [[:*], nil]
    # ] になる
    # パースに失敗すると ParseError を投げる
    def self.parse!(str)
      return parse_special(str) if str =~ /\A@.+\z/
      raise ParseError, "Unexpected schedule string #{str.inspect}" unless str =~ /\A.+ .+ .+ .+ .+\z/

      elements = str.split(" ").zip(Element::TYPES).map do |text, type|
        Element.parse(text, type)
      end

      schedule = new
      schedule.send(:elements=, elements)
      schedule
    end

    # パースに失敗したとき例外を起こさず、 nil を返す
    def self.parse(*args)
      parse! *args
    rescue ParseError
    end

    # マッチしたら true
    # マッチしなければ false を返す
    def =~(t)
      numbers = [t.min, t.hour, t.day, t.month, t.wday]
      elements.zip(numbers).all?{|element, number|
        element =~ number
      }
    end

    # 内部形式を crontab 形式で返す (文字形式 (@weekly や sun など) で指定されたものは数値形式に展開されている)
    def to_s
      return super unless elements
      elements.map(&:to_s).join(" ")
    end

    def inspect
      "#<Cron::Schedule: #{to_s}>"
    end

    # 基底クラスに Schedule を持ち、to_s が同じなら true
    def ==(other)
      other.is_a?(Cron::Schedule) && to_s == other.to_s
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

    def self.parse_special_element(str)
      str = str.downcase[0..2]
      months = [nil] + %w(jan feb mar apr may jun jul aug sep oct nov dec) # index と月の数を合わせるため、最初に nil をいれておく
      weekdays = %w(sun mon tue wed thu fri sat)
      months.index(str) || weekdays.index(str)
    end
  end
end
