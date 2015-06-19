class User < ActiveRecord::Base
  attr_reader :vote_status

  def get_vote_status
    @vote_status = self.
  end

end
