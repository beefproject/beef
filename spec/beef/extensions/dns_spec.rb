require 'resolv'
require 'extensions/dns/extension.rb'

RSpec.describe 'BeEF Extension DNS' do

  IN = Resolv::DNS::Resource::IN

  before(:all) do
    @config = BeEF::Core::Configuration.instance
    @config.load_extensions_config
    @dns = BeEF::Extension::Dns::Server.instance
  end

  it 'loaded configuration' do
    config = @config.get('beef.extension.dns')
    expect(config).to have_key('protocol')
    expect(config).to have_key('address')
    expect(config).to have_key('port')
    expect(config).to have_key('upstream')
  end

  it 'responds to interfaces' do
    expect(@dns).to respond_to(:add_rule)
    expect(@dns).to respond_to(:get_rule)
    expect(@dns).to respond_to(:remove_rule!)
    expect(@dns).to respond_to(:get_ruleset)
    expect(@dns).to respond_to(:remove_ruleset!)
  end

  context 'add good rule' do

    it '1.2.3.4' do
      id = nil
      response = '1.2.3.4'
      expect {
        id = @dns.add_rule(
          :pattern => 'foo.bar',
          :resource => IN::A,
          :response => [response] ) do |transaction|
            transaction.respond!(response)
        end
      }.to_not raise_error
      expect(id).to_not be_nil
    end

    it '9.9.9.9' do
      id = nil
      response = '9.9.9.9'
      expect {
        id = @dns.add_rule(
          :pattern => %r{i\.(love|hate)\.beef\.com?},
          :resource => IN::A,
          :response => [response] ) do |transaction|
            transaction.respond!(response)
        end
      }.to_not raise_error
      expect(id).to_not be_nil
    end

    it 'domains' do
      response = '9.9.9.9'
      domains = %w(
        i.hate.beef.com
        i.love.beef.com
        i.love.beef.co
        i.love.beef.co )
      domains.each do |d|
        id = nil
        expect {
          id = @dns.add_rule(
            :pattern => %r{i\.(love|hate)\.beef\.com?},
            :resource => IN::A,
            :response => [response] ) do |transaction|
              transaction.respond!(response)
          end
        }.to_not raise_error
        expect(id).to_not be_nil
      end

    end

    context 'add bad rule' do

      it '4.2.4.2' do
        id = nil
        same_id = nil
        pattern = 'j.random.hacker'
        response = '4.2.4.2'

        expect {
          id = @dns.add_rule(
            :pattern => pattern,
            :resource => IN::A,
            :response => [response] ) do |transaction|
              transaction.respond!(response)
          end
        }.to_not raise_error

        expect {
          same_id = @dns.add_rule(
            :pattern => pattern,
            :resource => IN::A,
            :response => [response] ) do |transaction|
              transaction.respond!(response)
          end
        }.to_not raise_error

        expect {
          same_id = @dns.add_rule(
            :pattern => pattern,
            :resource => IN::A,
            :response => [response] ) do |transaction|
              transaction.respond!(response)
          end
        }.to_not raise_error

        expect(id).to eql(same_id)
      end

    end

  end

  # it 'id format' do
  #   pattern = 'dead.beef'
  #   response = '2.2.2.2'
  #   id = nil

  #   expect {
  #     id = @dns.add_rule(
  #       :pattern => pattern,
  #       :resource => IN::A,
  #       :response => [response] ) do |transaction|
  #         transaction.respond!(response)
  #     end
  #   }.to_not raise_error

  #   expect(id.length).to eql(8)
  #   expect(id).to match(/^\h{8}$/)
  # end


  it 'get good rule' do
    pattern = 'be.ef'
    response = '1.1.1.1'
    id = nil

    expect {
      id = @dns.add_rule(
        :pattern => pattern,
        :resource => IN::A,
        :response => [response] ) do |transaction|
          transaction.respond!(response)
      end
    }.to_not raise_error

    expect(id).to_not be_nil
    rule = @dns.get_rule(id)

    expect(rule).to be_a(Hash)
    expect(rule.length).to be > 0
    expect(rule).to have_key(:id)
    expect(rule).to have_key(:pattern)
    expect(rule).to have_key(:resource)
    expect(rule).to have_key(:response)
    expect(rule[:id]).to eql(id)
    expect(rule[:pattern]).to eql(pattern)
    expect(rule[:resource]).to eql('A')
    expect(rule[:response]).to be_a(Array)
    expect(rule[:response].length).to be > 0
    expect(rule[:response].first).to eql(response)
  end

  it 'get bad rule' do
    expect(@dns.get_rule(42)).to be_nil
  end

  it 'remove good rule' do
    pattern = 'hack.the.gibson'
    response = '1.9.9.5'
    id = nil

    expect {
      id = @dns.add_rule(
        :pattern => pattern,
        :resource => IN::A,
        :response => [response] ) do |transaction|
          transaction.respond!(response)
      end
    }.to_not raise_error

    expect(@dns.remove_rule!(id)).to be(true)
  end

  it 'remove bad rule' do
    expect(@dns.remove_rule!(42)).to be_nil
  end

  it 'get ruleset' do
    rules = [
      { pattern: 'be.ef', resource: 'Resolv::DNS::Resource::IN::A', response: ['1.1.1.1'] },
      { pattern: 'dead.beef', resource: 'Resolv::DNS::Resource::IN::A', response: ['2.2.2.2'] },
      { pattern: 'foo.bar', resource: 'Resolv::DNS::Resource::IN::A', response: ['1.2.3.4'] },
      { pattern: 'i\.(love|hate)\.beef.com?', resource: 'Resolv::DNS::Resource::IN::A', response: ['9.9.9.9'] },
      { pattern: 'j.random.hacker', resource: 'Resolv::DNS::Resource::IN::A', response: ['4.2.4.2'] }
    ]

    @dns.remove_ruleset!
    expect(@dns.get_ruleset.length).to eql(0)

    rules.each do |r|
      @dns.add_rule(
        :pattern => r[:pattern],
        :resource => IN::A,
        :response => r[:response]
      )
    end

    ruleset = @dns.get_ruleset
    #ruleset.sort! { |a, b| a[:pattern] <=> b[:pattern] }
    expect(ruleset.length).to eql(5)

    rules.each_with_index do |v,i|
      expect(ruleset[i][:pattern]).to eql(v[:pattern])
      expect(ruleset[i][:resource]).to eql(v[:resource])
      expect(ruleset[i][:response]).to eql(v[:response])
    end
  end

  it 'remove ruleset' do
    expect(@dns.remove_ruleset!).to be(true)
    expect(@dns.get_ruleset.length).to eql(0)
  end

  it 'failure types' do

  end

end




  # Tests each supported type of query failure
#  def test_13_failure_types
#    begin
#      id = @@dns.add_rule(
#        :pattern => 'noerror.beef.com',
#        :resource => IN::A,
#        :response => ['1.2.3.4'] ) do |transaction|
#          transaction.failure!(:NoError)
#      end
#      #check_failure_status(id, :NoError)
#    end
#
#    begin
#      id = @@dns.add_rule(
#        :pattern => 'formerr.beef.com',
#        :resource => IN::A,
#        :response => ['1.2.3.4'] ) do |transaction|
#          transaction.failure!(:FormErr)
#      end
##      #check_failure_status(id, :FormErr)
#    end
#
#    begin
#      id = @@dns.add_rule(
#        :pattern => 'servfail.beef.com',
#        :resource => IN::A,
#        :response => ['1.2.3.4'] ) do |transaction|
#          transaction.failure!(:ServFail)
#      end
#      #check_failure_status(id, :ServFail)
#    end
#
#    begin
#      id = @@dns.add_rule(
#        :pattern => 'nxdomain.beef.com',
#        :resource => IN::A,
#        :response => ['1.2.3.4'] ) do |transaction|
#          transaction.failure!(:NXDomain)
#      end
#      #check_failure_status(id, :NXDomain)
#    end
#
#    begin
#      id = @@dns.add_rule(
#        :pattern => 'notimp.beef.com',
#        :resource => IN::A,
##        :response => ['1.2.3.4'] ) do |transaction|
#          transaction.failure!(:NotImp)
#      end
#      #check_failure_status(id, :NotImp)
#    end
#
#    begin
#      id = @@dns.add_rule(
#        :pattern => 'refused.beef.com',
#        :resource => IN::A,
#        :response => ['1.2.3.4'] ) do |transaction|
###          transaction.failure!(:Refused)
#      end
#      #check_failure_status(id, :Refused)
#    end
#
#    begin
#      id = @@dns.add_rule(
#        :pattern => 'notauth.beef.com',
#        :resource => IN::A,
#        :response => ['1.2.3.4'] ) do |transaction|
#          transaction.failure!(:NotAuth)
#      end
##      #check_failure_status(id, :NotAuth)
#    end
#  end
#
##  private
##
#  # Confirms that a query for the rule given in 'id' returns a 'resource' failure status
##  def check_failure_status(id, resource)
##    rule = @@dns.get_rule(id)
#    status = resource.to_s.force_encoding('UTF-8').upcase
#    assert_equal(status, rule[:response][0])
#
#    check_dns_response(/status: #{status}/, rule[:resource], rule[:pattern])
#  end
#
#  # Compares output of dig command against regex
#  def check_dns_response(regex, type, pattern)
#    address = @@config.get('beef.extension.dns.address')
#    port = @@config.get('beef.extension.dns.port')
###    dig_output = IO.popen(["dig", "@#{address}", "-p", "#{port}", "-t", "#{type}", "#{pattern}"], 'r+').read
#    assert_match(regex, dig_output)
#  end
##
##end
###
