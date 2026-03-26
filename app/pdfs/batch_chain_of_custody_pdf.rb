class BatchChainOfCustodyPdf
  require 'prawn'

  def initialize(batch)
    @batch = batch
  end

  def render
    Prawn::Document.new do |pdf|
      pdf.text "Chain of Custody", size: 24, style: :bold
      pdf.move_down 20
      pdf.text "Batch ID: #{@batch.id}"
      pdf.text "Created at: #{@batch.created_at}"
      pdf.text "Status: #{@batch.status}" if @batch.respond_to?(:status)
    end.render
  end
end
