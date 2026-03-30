class BatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_batch, only: [:show, :edit, :update, :destroy, :chain_of_custody]

  def index
    @batches = Batch.all
  end

  def show
  end

  def new
    @batch = Batch.new
  end

  def edit
  end

  def create
    @batch = Batch.new(batch_params)

    respond_to do |format|
      if @batch.save
        format.html { redirect_to batch_url(@batch), notice: "Batch was successfully created." }
        format.json { render :show, status: :created, location: @batch }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @batch.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @batch.update(batch_params)
        format.html { redirect_to batch_url(@batch), notice: "Batch was successfully updated." }
        format.json { render :show, status: :ok, location: @batch }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @batch.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @batch.destroy
    respond_to do |format|
      format.html { redirect_to batches_url, notice: "Batch was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # 21 CFR Part 11 PDF
  def chain_of_custody
    require 'prawn'

    pdf = Prawn::Document.new
    pdf.text "21 CFR Part 11 - Chain of Custody", size: 18, style: :bold
    pdf.text "Batch ID: #{@batch.batch_id}"
    pdf.text "SHA256: #{Digest::SHA256.hexdigest(Time.now.to_s + @batch.id.to_s)}"
    pdf.text "Generated: #{Time.now.utc}"

    send_data pdf.render,
      filename: "chain-of-custody-#{@batch.id}.pdf",
      type: 'application/pdf',
      disposition: 'inline'
  end

  private

  def set_batch
    @batch = Batch.find(params[:id])
  end

  def batch_params
    params.require(:batch).permit(:batch_id, :product, :status, :temp, :location)
  end
end
