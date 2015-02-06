require "spec_helper"

describe Cronie do
  describe ".run" do
    let(:task) { double(:task) }
    let(:time) { Time.parse("2015-01-23T12:34:56+0900") }

    before do
      Cronie.tasks << task
    end

    after do
      Cronie.tasks.delete(task)
    end

    it "should receive Time" do
      task.should_receive(:do).with(time)
      Cronie.run(time)
    end

    it "should receive String" do
      task.should_receive(:do).with(time)
      Cronie.run(time.iso8601)
    end

    it "should receive timstamp" do
      task.should_receive(:do).with(time)
      Cronie.run(time.to_i)
    end
  end

  describe ".run_async" do
    let(:time) { Time.parse("2015-01-23T12:34:56+0900") }
    let(:utc_string) { "2015-01-23T03:34:56Z" }

    it "should receive Time" do
      Resque.should_receive(:enqueue).with(Cronie, utc_string)
      Cronie.run_async(time)
    end

    it "should receive String" do
      Resque.should_receive(:enqueue).with(Cronie, utc_string)
      Cronie.run_async(time.iso8601)
    end

    it "should receive timstamp" do
      Resque.should_receive(:enqueue).with(Cronie, utc_string)
      Cronie.run_async(time.to_i)
    end
  end
end
