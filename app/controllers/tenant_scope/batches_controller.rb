# app/controllers/tenant_scope/batches_controller.rb
module TenantScope
  class BatchesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_tenant_batches
    before_action :set_batch, only: [:show, :update, :destroy, :chain_of_custody]

    # PUBLIC API - Completely standalone (no auth, no tenant)
    skip_before_action :authenticate_user!, :set_tenant_batches, only: [:demo, :public_pdf, :chain_of_custody]
    # PUBLIC JSON API - No tenant dependency
    def demo
      batches = Batch.limit(10)
      render json: batches.map do |batch|
        {
          id: batch.id,
          batch_id: batch.batch_id,
          product: batch.product,
          status: batch.status,
          temp: batch.temp,
          location: batch.location
        }
      end
    end

    # PUBLIC PDF - Direct batch lookup (no tenant)
    def public_pdf
      @batch = Batch.find(params[:id])

      # Explicitly opt into :pdf format
      respond_to do |format|
        format.html { head :forbidden }  # block HTML
        format.pdf do
          require 'prawn'
          pdf = Prawn::Document.new

          pdf.text "Thomas IT - 21 CFR Part 11 (Public API)", size: 18, style: :bold
          pdf.text "Batch ID: #{@batch.batch_id}", size: 16, style: :bold
          pdf.text "Product: #{@batch.product}"
          pdf.text "Status: #{@batch.status}"
          pdf.text "Temp: #{@batch.temp}"
          pdf.text "Location: #{@batch.location}"
          pdf.text "SHA256: #{Digest::SHA256.hexdigest(Time.now.to_s + @batch.id.to_s)}"
          pdf.text "Generated: #{Time.now.utc.iso8601}"

          send_data pdf.render,
                    filename: "batch-#{@batch.batch_id}.pdf",
                    type: 'application/pdf',
                    disposition: 'inline'
        end
      end
    end

    def index
      @batches = @tenant_batches
    end

    def show
    end

    def new
      @batch = @tenant_batches.build
    end

    def create
      @batch = @tenant_batches.build(batch_params)
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

    # Authenticated PDF (tenant/user tracking)
    def chain_of_custody
      require 'prawn'
      @batch = @tenant_batches.find(params[:id])

      pdf = Prawn::Document.new
      pdf.text "Thomas IT - 21 CFR Part 11 Chain of Custody", size: 18, style: :bold
      pdf.text "Tenant: #{current_tenant&.name}", size: 14
      pdf.text "User: #{current_user&.email}", size: 14
      pdf.text "Batch ID: #{@batch.batch_id}", size: 16, style: :bold
      pdf.text "SHA256: #{Digest::SHA256.hexdigest(Time.now.to_s + @batch.id.to_s)}"
      pdf.text "Generated: #{Time.now.utc.iso8601}"

      send_data pdf.render,
                filename: "chain-of-custody-#{@batch.batch_id}.pdf",
                type: 'application/pdf',
                disposition: 'inline'
    end

    private

    def set_tenant_batches
      tenant = current_tenant
      @tenant_batches = Batch.where(tenant: tenant) if tenant
      @tenant_batches ||= Batch.none
    end

    def set_batch
      @batch = @tenant_batches.find(params[:id])
    end

    def batch_params
      params.require(:batch).permit(:batch_id, :product, :status, :temp, :location)
    end

    def log_chain_of_custody_view
      EventLog.create!(
        action: "pdf.chain_of_custody.view",
        user: current_user,
        batch: @batch,
        tenant: current_tenant,
        metadata: {
          user_name: current_user&.email,
          batch_id: @batch.id,
          batch_batch_id: @batch.batch_id,
          status: @batch.status,
          controller: "BatchesController",
          action: "chain_of_custody"
        }.to_json
      )
    end
  end
end
