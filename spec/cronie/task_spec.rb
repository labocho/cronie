# encoding: UTF-8
require 'spec_helper'

module Cronie
  describe Task do
    describe "#do" do
      it "@proc.call が呼ばれる" do
        t = Time.now
        called = false

        task = Task.new :name, "* * * * *" do |time|
          time.should == t
          called = true
        end
        task.do(t)
        called.should be_true
      end
      it "shedule が一致しないときは呼ばれない" do
        t = Time.new(2011, 11, 7, 0, 0, 0)
        called = false

        task = Task.new :name, "1 * * * *" do |time|
          called = true
        end
        task.do(t)
        called.should be_false
      end
    end
  end
end
