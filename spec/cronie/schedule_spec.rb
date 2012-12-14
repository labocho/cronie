require "spec_helper"
module Cronie
  describe Cronie::Schedule do
    # RSpec::Matchers.define :match do |target|
    #   match do |receiver|
    #     receiver =~ target
    #   end
    # end

    context "parse 0 1,2-3,4 */10 * *" do
      subject { Schedule.parse! "0 1,2-3,4 */10 * *" }
      its(:to_s) { should == "0 1,2-3,4 */10 * *" }
    end
    context "exactly match" do
      subject { Schedule.parse! "* 10 * * *" }
      it { should     =~ Time.new(2011, 11, 11, 10, 12, 34) }
      it { should_not =~ Time.new(2011, 11, 11,  9, 12, 34) }
      it { should_not =~ Time.new(2011, 11, 11, 11, 12, 34) }
      it { should_not =~ Time.new(2011, 11, 11, 20, 12, 34) }
    end
    context "range include" do
      subject { Schedule.parse! "* 3-5 * * *" }
      it { should     =~ Time.new(2011, 11, 11,  3, 12, 34) }
      it { should     =~ Time.new(2011, 11, 11,  4, 12, 34) }
      it { should     =~ Time.new(2011, 11, 11,  5, 12, 34) }
      it { should_not =~ Time.new(2011, 11, 11,  2, 12, 34) }
      it { should_not =~ Time.new(2011, 11, 11,  6, 12, 34) }
    end
    context "list " do
      subject { Schedule.parse! "* 1,5 * * *" }
      it { should     =~ Time.new(2011, 11, 11,  1, 12, 34) }
      it { should     =~ Time.new(2011, 11, 11,  5, 12, 34) }
      it { should_not =~ Time.new(2011, 11, 11,  0, 12, 34) }
      it { should_not =~ Time.new(2011, 11, 11,  2, 12, 34) }
      it { should_not =~ Time.new(2011, 11, 11,  4, 12, 34) }
      it { should_not =~ Time.new(2011, 11, 11,  6, 12, 34) }
      it { should_not =~ Time.new(2011, 11, 11, 10, 12, 34) }
    end
    context "step" do
      context "with asterisk" do
        subject { Schedule.parse! "*/12 * * * *" }
        ok = [0, 12, 24, 36, 48]
        ng = (0..59).to_a - ok

        ok.each do |i|
          it { should =~ Time.new(2011, 11, 11, 11, i, 34) }
        end

        ng.each do |i|
          it {
            should_not =~ Time.new(2011, 11, 11, 11, i, 34)
          }
        end
      end
      context "with range" do
        subject { Schedule.parse! "1-15/3 * * * *" }
        ok = [1, 4, 7, 10, 13]
        ng = (0..59).to_a - ok

        ok.each do |i|
          it { should =~ Time.new(2011, 11, 11, 11, i, 34) }
        end

        ng.each do |i|
          it {
            should_not =~ Time.new(2011, 11, 11, 11, i, 34)
          }
        end
      end
    end
  end
end
