# frozen_string_literal: true
# == Schema Information
#
# Table name: subscriptions
#
#  id             :integer          not null, primary key
#  user_id        :integer          not null
#  competition_id :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  status         :integer          default("pending"), not null
#
# Indexes
#
#  index_subscriptions_on_competition_id  (competition_id)
#  index_subscriptions_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (competition_id => competitions.id)
#  fk_rails_...  (user_id => users.id)
#

class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: [:edit, :update, :destroy]
  before_action :find_competition, only: [:new, :edit, :create, :update]

  # POST
  def new
    authorize Subscription

    @form = Subscription::Contract::Create.new(Subscription.new)
    @form.prepopulate_user!(user: current_user)
  end

  def edit
    authorize @subscription, :update?

    @form = Subscription::Contract::Update.new(@subscription)
  end

  def create
    operation = Subscription::Create.call(params.merge(current_user: current_user))

    @form = operation.form

    if @form.valid?
      respond_to do |format|
        format.html { redirect_to operation.model.competition, notice: t("subscriptions.create.notice") }
        format.js
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.js
      end
    end
  end

  def update
    operation = Subscription::Update.call(params.merge(current_user: current_user))

    @form = operation.form

    if @form.valid?
      respond_to do |format|
        format.html { redirect_to root_path }
        format.js
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.js
      end
    end
  end

  def destroy
    authorize @subscription

    competition = @subscription.competition

    if competition.author.notification_setting.as_author_cancelation
      UserMailer.as_author_cancelation(@subscription.user.id,
                                       competition.id,
                                       competition.author.id).deliver_later
    end

    @subscription.destroy

    redirect_to competition, notice: t("subscriptions.destroy.notice")
  end

  private

    def set_subscription
      @subscription = Subscription.find(params[:id])
    end

    def find_competition
      @competition = Competition.find(params[:competition_id])
    end

    def subscription_params
      params.require(:subscription).permit(:status, :rules, :phone_number, :whatsapp, :telegram, :signal)
    end
end
