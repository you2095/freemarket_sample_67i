class CreditsController < ApplicationController

  before_action :get_payjp_info, only: [:new_create, :create, :destroy, :show]
  before_action :set_credit, only: [:destroy]
  
  def new
  end

  def create
    if params['payjp-token'].blank?
      redirect_to action: "new"
    else
      customer = Payjp::Customer.create(
      card: params['payjp-token'],
      metadata: {user_id: current_user.id}
      )
      @card = Card.new(user_id: current_user.id, customer_id: customer.id, card_id: customer.default_card)
      if @card.save
        redirect_to action: "show"
      else
        redirect_to action: "edit", id: current_user.id
      end
    end
  end

  def confirmation
  end

  def show 
    if card.blank?
      redirect_to action: "confirmation" 
    else
      Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]
      customer = Payjp::Customer.retrieve(card.customer_id)
      @default_card_information = customer.cards.retrieve(card.card_id)
    end
  end

  def delete 
    if card.blank?
      Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]
      customer.delete
      card.delete
    end
      redirect_to action: "new"
  end


  private
  def get_payjp_info
    if Rails.env == 'development'
      Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]
    else
      Payjp.api_key = Rails.application.credentials.payjp[:PAYJP_PRIVATE_KEY]
    end
  end

  def set_credit
    card = Card.where(user_id: current_user.id).first
  end
end