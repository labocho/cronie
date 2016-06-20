# encoding: UTF-8
require "spec_helper"
module Cronie
  describe Cronie::Schedule do
    describe ".parse!" do
      it "should parse * * * * *" do
        Schedule.parse! "* * * * *"
      end
      it "should parse * 10 * 10 *" do
        Schedule.parse! "* 10 * 10 *"
      end
      it "should parse * */10 * */10 *" do
        Schedule.parse! "* */10 * */10 *"
      end
      it "should parse * 10 * */10 *" do
        Schedule.parse! "* 10 * */10 *"
      end
      it "should parse string include extra spaces" do
        Schedule.parse! " \t*  \t10    * \t */10 *  "
      end
      it "should raise parsing less elements" do
        expect {
          Schedule.parse! "* * * *"
        }.to raise_error(Schedule::ParseError)
      end
      it "should raise parsing extra elements" do
        expect {
          Schedule.parse! "* * * * * *"
        }.to raise_error(Schedule::ParseError)
      end
      it "should raise parsing invalid step" do
        expect {
          Schedule.parse! "* * * */1,2 *"
        }.to raise_error(Schedule::ParseError)
      end
      it "should raise parsing not a number" do
        expect {
          Schedule.parse! "* * * x *"
        }.to raise_error(Schedule::ParseError)
      end
    end

    describe "#to_s" do
      it "should return parsable string" do
        Schedule.parse("* 10 * */10 *").to_s.should == "* 10 * */10 *"
      end
      it "should remove spaces" do
        Schedule.parse(" \t*  \t10    * \t */10 *  ").to_s.should == "* 10 * */10 *"
      end
    end

    describe "=~" do
      def self.min(i)
        Time.new(2011, 11, 7, 0, i)
      end
      def self.hour(i)
        Time.new(2011, 11, 7, i, 12)
      end
      def self.day(i)
        Time.new(2011, 11, i, 14, 12)
      end
      def self.month(i)
        Time.new(2011, i, 7, 14, 12)
      end
      def self.wday(i)
        # 2011-11-06 is Sunday
        Time.new(2011, 11, 6 + i, 14, 12)
      end
      def self.it_should_match_only(options = {})
        case
        when options[:minutes]
          variations = (0..59).map{|i| min(i) }
          ok = options[:minutes].map{|i| min(i) }
        when options[:hours]
          variations = (0..23).map{|i| hour(i) }
          ok = options[:hours].map{|i| hour(i) }
        when options[:days]
          variations = (1..30).map{|i| day(i) }
          ok = options[:days].map{|i| day(i) }
        when options[:months]
          variations = (1..12).map{|i| month(i) }
          ok = options[:months].map{|i| month(i) }
        when options[:weekdays]
          variations = (0..6).map{|i| wday(i) }
          ok = options[:weekdays].map{|i| wday(i) }
        end
        ok.each do |time|
          it { should =~ time }
        end
        (variations - ok).each do |time|
          it { should_not =~ time }
        end
      end

      context "minutes" do
        context "asterisk: *" do
          subject { Schedule.parse("* * * * *") }
          it_should_match_only minutes: (0..59)
        end
        context "number: 13" do
          subject { Schedule.parse("13 * * * *") }
          it_should_match_only minutes: [13]
        end
        context "list: 13,17" do
          subject { Schedule.parse! "13,17 * * * *" }
          it_should_match_only minutes: [13, 17]
        end
        context "range: 13-17" do
          subject { Schedule.parse! "13-17 * * * *" }
          it_should_match_only minutes: (13..17)
        end
        context "list and range: 11,13-17,19" do
          subject { Schedule.parse! "7-9,11,13-17,19 * * * *" }
          it_should_match_only minutes: [7, 8, 9, 11, 13, 14, 15, 16, 17, 19]
        end
        context "asterisk with step: */13" do
          subject { Schedule.parse("*/13 * * * *") }
          it_should_match_only minutes: [0, 13, 26, 39, 52]
        end
        context "list with step: 1,2,3,5,7,11/2" do
          subject { Schedule.parse("1,2,3,5,7,11/2 * * * *") }
          it_should_match_only minutes: [1, 3, 7]
        end
        context "range with step: 1-15/3" do
          subject { Schedule.parse("1-15/3 * * * *") }
          it_should_match_only minutes: [1, 4, 7, 10, 13]
        end
        context "list and range with step: 1-3,5,7,11,13/2" do
          subject { Schedule.parse("1-3,5,7,11,13/2 * * * *") }
          it_should_match_only minutes: [1, 3, 7, 13]
        end
        context "invalid number: 60" do
          subject { Schedule.parse("60 * * * *") }
          it_should_match_only minutes: []
        end
      end
      context "hours" do
        context "asterisk: *" do
          subject { Schedule.parse("* * * * *") }
          it_should_match_only hours: (0..23)
        end
        context "number: 13" do
          subject { Schedule.parse("* 13 * * *") }
          it_should_match_only hours: [13]
        end
        context "asterisk with step: */4" do
          subject { Schedule.parse("* */4 * * *") }
          it_should_match_only hours: [0, 4, 8, 12, 16, 20]
        end
        context "invalid number: 24" do
          subject { Schedule.parse("* 24 * * *") }
          it_should_match_only hours: []
        end
      end
      context "day" do
        context "asterisk: *" do
          subject { Schedule.parse("* * * * *") }
          it_should_match_only days: (1..30)
        end
        context "number: 13" do
          subject { Schedule.parse("* * 13 * *") }
          it_should_match_only days: [13]
        end
        context "asterisk with step: */4" do
          subject { Schedule.parse("* * */4 * *") }
          it_should_match_only days: [1, 5, 9, 13, 17, 21, 25, 29]
        end
        context "invalid number: 32" do
          subject { Schedule.parse("* * 32 * *") }
          it_should_match_only days: []
        end
      end
      context "months" do
        context "asterisk: *" do
          subject { Schedule.parse("* * * * *") }
          it_should_match_only months: (1..12)
        end
        context "number: 7" do
          subject { Schedule.parse("* * * 7 *") }
          it_should_match_only months: [7]
        end
        context "asterisk with step: */4" do
          subject { Schedule.parse("* * * */4 *") }
          it_should_match_only months: [1, 5, 9]
        end
        context "invalid number: 13" do
          subject { Schedule.parse("* * * 13 *") }
          it_should_match_only months: []
        end
      end
      context "weekdays" do
        context "asterisk: *" do
          subject { Schedule.parse("* * * * *") }
          it_should_match_only weekdays: (0..6)
        end
        context "number: 3" do
          subject { Schedule.parse("* * * * 3") }
          it_should_match_only weekdays: [3]
        end
        context "asterisk with step: */3" do
          subject { Schedule.parse("* * * * */3") }
          it_should_match_only weekdays: [0, 3, 6]
        end
        context "invalid number: 7" do
          subject { Schedule.parse("* * * * 7") }
          it_should_match_only weekdays: []
        end
      end
      context "multiple constraints" do
        subject { Schedule.parse("0 3 * * *") }
        it { should_not =~ Time.new(2011, 11, 7, 2,  0) }
        it { should_not =~ Time.new(2011, 11, 7, 3, 10) }
        it { should     =~ Time.new(2011, 11, 7, 3,  0) }
      end
    end
  end
end
