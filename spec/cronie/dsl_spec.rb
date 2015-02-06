# encoding: UTF-8
require "spec_helper"

describe Cronie::DSL do
  before(:all) do
    result = {}
    @result = result
    extend Cronie::DSL
    set_utc_offset "+09:00"
    task "Named task", "0 */2 * * *" do |time|
      result[:time] = time
    end
  end

  before(:each) do
    @result[:time] = nil
  end

  it "should register task" do
    task = Cronie.tasks.first
    task.name.should == "Named task"
    task.schedule.to_s.should == "0 */2 * * *"
  end

  it "should run registered task by Cronie.run" do
    Cronie.run(Time.new(2011, 11, 11, 1, 0, 0))
    @result[:time].should be_nil
    Cronie.run(Time.new(2011, 11, 11, 2, 0, 0))
    @result[:time].should == Time.new(2011, 11, 11, 2, 0, 0)
  end

  it "sets Cronie.utc_offset" do
    Cronie.utc_offset.should == "+09:00"
  end
end
