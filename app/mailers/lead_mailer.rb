class LeadMailer < ApplicationMailer
  def demo_request(email, company)
    @lead = {email: email, company: company}
    mail(to: 'leads@pharmatransport.com', subject: 'NEW PHARMA LEAD')
  end
end
