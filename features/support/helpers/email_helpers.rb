module EmailHelpers
  def last_email
    expect(ActionMailer::Base.deliveries).not_to be_empty
    ActionMailer::Base.deliveries.last
  end

  def email_with_subject(subject)
    expect(ActionMailer::Base.deliveries).not_to be_empty
    ActionMailer::Base.deliveries.find do |email|
      email.subject == subject
    end
  end

  def extract_links_from_email(email)
    email.html_part.body.to_s.scan(/href="(.*?)"/).flatten
  end
end

World(EmailHelpers)
