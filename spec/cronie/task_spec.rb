# encoding: UTF-8
require 'spec_helper'

module Cronie
  describe Task do
    describe "#do" do
      it "calls @proc.call" do
        t = Time.now
        called = false

        task = Task.new :name, "* * * * *" do |time|
          time.should == t
          called = true
        end
        task.do(t)
        called.should be_true
      end
      it "do not call if shedule does not match" do
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
