json.issues @issues do |issue|
  json.id issue.id
  json.title issue.title
  json.description issue.description
  json.start_date issue.start_date
  json.finish_date issue.finish_date
  json.image issue.image_url
  json.participant_count issue.participant_count
  json.yes_votes issue.yes_votes
  json.no_votes issue.no_votes
  json.vote_count issue.vote_count
  json.abstain_count issue.abstain_count
  json.yes_percentage issue.yes_percentage
  json.no_percentage issue.no_percentage
  json.status issue.status
  json.time_remaining issue.time_remaining
end