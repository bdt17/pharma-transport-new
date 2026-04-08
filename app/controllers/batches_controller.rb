def demo
  @batch = Batch.find_by(id: params[:id]) || Batch.find(123456)
  render json: {
    id: @batch.id,
    batch_id: @batch.batch_id,
    product: @batch.product,
    status: @batch.status,
    tenant: @batch.tenant.name
  }
end
