
  # PAYMENTS - Stripe Production
  get 'payments/checkout',          to: 'payments#checkout'
  get 'payments/success',           to: 'payments#success'
  get 'payments/cancel',            to: 'payments#cancel'
  post '/stripe/webhook',          to: 'payments#webhook'
