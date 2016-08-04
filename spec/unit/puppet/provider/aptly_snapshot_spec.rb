require 'spec_helper'
require 'puppet/type/aptly_snapshot'

describe Puppet::Type.type(:aptly_snapshot).provider(:cli) do
  let(:resource) do
    Puppet::Type.type(:aptly_snapshot).new(
      :name         => '2016-07-30-daily',
      :ensure       => 'present',
      :source_type  => 'repository',
      :source_name  => 'test',
    )
  end

  let(:provider) do
    described_class.new(resource)
  end

  [:create, :destroy, :exists? ].each do |method|
    it "should have a(n) #{method}" do
      expect(provider).to respond_to(method)
    end
  end

  describe '#create' do
    it 'should create the snapshot' do
      Puppet_X::Aptly::Cli.expects(:execute).with(
        object: :snapshot,
        action: 'create',
        arguments: [ '2016-07-30-daily', 'from repo', 'test' ],
      )
      provider.create
    end
  end

  describe '#destroy' do
    it 'should drop the snapshot' do
      Puppet_X::Aptly::Cli.expects(:execute).with(
        object: :snapshot,
        action: 'drop',
        arguments: ['2016-07-30-daily'],
      )
      provider.destroy
    end
  end

  describe '#exists?' do
    it 'should check the snapshots list' do
      Puppet_X::Aptly::Cli.stubs(:execute).with(
        object: :snapshot,
        action: 'show',
        arguments: ['2016-07-30-daily'],
        exceptions: false,
      ).returns 'ERROR Unable to ...'
      expect(provider.exists?).to eq(false)
    end
  end

end