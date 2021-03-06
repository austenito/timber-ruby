require "spec_helper"

describe Timber::Overrides::LoggerAdd, :rails_23 => true do
  describe "#add" do
    let(:io) { StringIO.new }
    let(:logger) do
      logger = ::Logger.new(io)
      logger.formatter = proc do |severity, datetime, progname, msg|
         "#{msg}\n"
      end
      logger
    end

    it "should display the message only when passed to a default logger" do
      event = Timber::Events::Custom.new(message: "Build version 1.0.0", type: :build, data: {version: "1.0.0"})
      logger.info(event)
      expect(io.string).to eq("Build version 1.0.0\n")
    end

    it "should work with blocks" do
      event = Timber::Events::Custom.new(message: "Build version 1.0.0", type: :build, data: {version: "1.0.0"})
      logger.info { event }
      expect(io.string).to eq("Build version 1.0.0\n")
    end
  end
end