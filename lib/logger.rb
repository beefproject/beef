module BeEF

#
# This class takes care of logging events in the db.
#
class Logger
  
  include Singleton
  
  def initialize
    @logs = BeEF::Models::Log
  end
  
  # Registers a new event in the logs
  def register(from, event, zombie = 0)
    @logs.new(:type => "#{from}", :event => "#{event}", :date => Time.now, :zombie_id => zombie).save
  end
  
  private
  @logs
  
end

end
