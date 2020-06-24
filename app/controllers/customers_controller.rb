class CustomersController < ApplicationController
  SORT_FIELDS = %w(name registered_at postal_code)

  before_action :parse_query_args

  def index
    if @sort
      data = Customer.all.order(@sort)
    else
      data = Customer.all
    end

    data = data.paginate(page: params[:p], per_page: params[:n])

    render json: data.as_json(
      only: [:id, :name, :registered_at, :address, :city, :state, :postal_code, :phone, :account_credit],
      methods: [:movies_checked_out_count]
    )
  end

  def show 
    @customer = Customer.find_by(id: params[:id])

    unless @customer
      render json: {
        errors: ['Customer Not Found'],  
      }, status: :bad_request 

      return 
    end

    rentals = @customer.rentals.map do |rental| 
      {
        id: rental.id,
        customer_id: rental.customer_id,
        movie_id: rental.movie_id,
        name: @customer.name,
        title: rental.movie.title,
        checkout_date: rental.checkout_date,
        due_date: rental.due_date,
        returned: rental.returned
      }
    end

    render json: rentals.as_json(), status: :ok
    return
  end

  private

  def parse_query_args
    errors = {}
    @sort = params[:sort]
    if @sort and not SORT_FIELDS.include? @sort
      errors[:sort] = ["Invalid sort field '#{@sort}'"]
    end

    unless errors.empty?
      render status: :bad_request, json: { errors: errors }
    end
  end
end
