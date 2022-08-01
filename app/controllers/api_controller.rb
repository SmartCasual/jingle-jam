class ApiController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authorised

  def fundraisers
    render json: Fundraiser.all
  end

  def curated_streamers
    render json: CuratedStreamer.all
  end

  def totals
    render json: {
      totals: Donation.group(:fundraiser_id).group(:amount_currency).sum(:amount_decimals),
      counts: Donation.group(:fundraiser_id).count
    }
  end

  def donations
    default_count = 1
    query = Donation.includes(:donator, :donated_by).where('aasm_state = ?', ['paid'])

    if params.has_key?(:before)
      begin
        query = query.where('paid_at < timestamp ? - interval \'1 ms\'', [ DateTime.strptime(params[:before], "%Q") ]).order('paid_at desc')
      rescue
        # Do nothing
      end
    elsif params.has_key?(:after)
      begin
        query = query.where('paid_at > timestamp ? + interval \'1 ms\'', [ DateTime.strptime(params[:after], "%Q") ]).order('paid_at asc')
      rescue
        # Nada
      end
    else
      query = query.order('paid_at asc')
    end

    count = (params[:count] || default_count).to_i

    puts query.to_sql

    collection = query.limit(count)

    cursor_after = 0
    cursor_before = 0

    if collection.length > 0
      cursor_after = collection.last.paid_at.to_datetime.strftime('%Q').to_i
      cursor_before = collection.first.paid_at.to_datetime.strftime('%Q').to_i
    end

    render json: {
      total:    query.count,
      data:     collection,
      cursor: {
        after: cursor_after,
        before: cursor_before,
      }
    }
  end

  private

  def authorised
    unless request.headers["Authorization"] == "Secret " + ENV.fetch("API_SECRET")
      render json: {
        error: "unauthorized"
      }, :status => :unauthorized
    end
  end
end