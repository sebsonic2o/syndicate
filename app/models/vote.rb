class Vote < ActiveRecord::Base
  has_ancestry
  belongs_to :issue
  belongs_to :user

  def count_votes(issue_id, user)
    if user == self
      p "wtf"
    else
     p self.subtree.count
     return self.subtree.count
    end
  end


end
