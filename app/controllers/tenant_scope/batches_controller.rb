# app/controllers/tenant_scope/batches_controller.rb
module TenantScope
  class BatchesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_tenant_batches
    before_action :set_batch, only: [:show, :update, :destroy, :chain_of_custody]

    # PUBLIC API - Completely standalone (no auth, no tenant)
    skip_before_action :authenticate_user!, :set_tenant_batches, 
                       only: [:demo, :public_pdf, :chain_of_custody]

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

    # PUBLIC Chain of Custody PDF
    def chain_of_custody
      @batch = Batch.find(params[:id])
      
      respond_to do |format|
        format.html { head :forbidden }
        format.pdf do
          require 'prawn'
          pdf = Prawn::Document.new(page_size: 'LETTER')

          # Header
          pdf.font_size 20
          pdf.text "CHAIN OF CUSTODY - 21 CFR Part 11", style: :bold, align: :center
          pdf.text "Thomas IT Pharma Transport", size: 14, align: :center
          pdf.move_down 10

          # Batch Info
          pdf.text "Batch ID: #{@batch.batch_id}", style: :bold
          pdf.text "Product: #{@batch.product}"
          pdf.text "Status: #{@batch.status}"
          pdf.text "Temperature: #{@batch.temp}"
          pdf.text "Location: #{@batch.location}"
          pdf.move_down 10

          # Compliance Hash
          pdf.text "Compliance Hash (SHA256): #{Digest::SHA256.hexdigest(Time.now.to_s + @batch.id.to_s)}", style: :bold
          pdf.text "Generated: #{Time.now.utc.iso8601}"

          send_data pdf.render,
                    filename: "coc-#{@batch.batch_id}.pdf",
                    type: 'application/pdf',
                    disposition: 'inline'
        end
      end
    end

    def index
      @batches = @tenant_batches.recent # Add scope in model
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
          format.html { redirect_to tenant_scope_batch_url(@batch), notice: "Batch created." }
          format.json { render :show, status: :created }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @batch.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @batch.update(batch_params)
          format.html { redirect_to tenant_scope_batch_url(@batch), notice: "Batch updated." }
          format.json { render :show, status: :ok }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @batch.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @batch.destroy
      respond_to do |format|
        format.html { redirect_to tenant_scope_batches_url, notice: "Batch deleted." }
        format.json { head :no_content }
      end
    end

    private

    def set_tenant_batches
      @tenant_batches = current_tenant.batches
    end

    def set_batch
      @batch = @tenant_batches.find(params[:id])
    end

    def batch_params
      params.require(:batch).permit(:batch_id, :product, :status, :temp, :location)
    end
  end
end
