require 'Kimurai/cli'

RSpec.describe Kimurai::CLI do
  describe "#generate" do
    context "when generator_type is 'project'" do
      it "generates a new project with the given name" do
        expect_any_instance_of(Kimurai::CLI::Generator).to receive(:generate_project).with("foo")
        subject.generate("project", "foo")
      end

      it "raises an error if no project name is provided" do
        expect { subject.generate("project") }.to raise_error("Provide project name to generate a new project")
      end
    end

    context "when generator_type is 'spider'" do
      it "generates a new spider with the given name" do
        expect_any_instance_of(Kimurai::CLI::Generator).to receive(:generate_spider).with("foo", in_project: false)
        subject.generate("spider", "foo")
      end

      it "raises an error if no spider name is provided" do
        expect { subject.generate("spider") }.to raise_error("Provide spider name to generate a spider")
      end
    end

    context "when generator_type is 'schedule'" do
      it "generates a new schedule" do
        expect_any_instance_of(Kimurai::CLI::Generator).to receive(:generate_schedule)
        subject.generate("schedule")
      end
    end

    context "when generator_type is unknown" do
      it "raises an error" do
        expect { subject.generate("unknown") }.to raise_error("Don't know this generator type: unknown")
      end
    end
  end

  describe "#setup" do
    it "sets up the server with the given options" do
      builder = instance_double(Kimurai::CLI::AnsibleCommandBuilder)
      expect(Kimurai::CLI::AnsibleCommandBuilder).to receive(:new).with("user_host", {}, playbook: "setup").and_return(builder)
      expect(builder).to receive(:get).and_return("ls")
      subject.setup("user_host")
    end
  end

  describe "#deploy" do
    pending
  end

  describe "#crawl" do
    pending
  end

  describe "#parse" do
    pending
  end
end
