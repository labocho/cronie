require "spec_helper"

describe Cronie do
  describe ".run" do
    let(:task) { double(:task) }
    let(:time) { Time.parse("2015-01-23T12:34:56+09:00") }

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

    context 'Cronie.utc_offset exists' do
      before do
        Cronie.utc_offset = "-08:00"
      end

      after do
        Cronie.utc_offset = nil
      end

      it "should pass time as in time zone" do
        task.should_receive(:do) do |t|
          t.year.should == 2015
          t.month.should == 1
          t.day.should == 22
          t.hour.should == 19
          t.min.should == 34
          t.sec.should == 56
          t.utc_offset.should == -8 * 60 * 60
        end
        Cronie.run(time.to_i)
      end
    end
  end

  describe ".run_async" do
    before do
      Cronie.utc_offset = "-08:00"
    end

    after do
      Cronie.utc_offset = nil
    end

    let(:time) { Time.parse("2015-01-23T12:34:56+09:00") }
    let(:pst_string) { "2015-01-22T19:34:56-08:00" }

    it "should receive Time" do
      Resque.should_receive(:enqueue).with(Cronie, pst_string)
      Cronie.run_async(time)
    end

    it "should receive String" do
      Resque.should_receive(:enqueue).with(Cronie, pst_string)
      Cronie.run_async(time.iso8601)
    end

    it "should receive timstamp" do
      Resque.should_receive(:enqueue).with(Cronie, pst_string)
      Cronie.run_async(time.to_i)
    end
  end
end
