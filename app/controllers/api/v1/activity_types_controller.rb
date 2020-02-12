# frozen_string_literal: true

class Api::V1::ActivityTypesController < ApplicationController
  include ActivityCreator

  def create
    activity_type = create_activity_type
    activity_visits = set_activity_visits
    search_keyword = params[:keyword]

    activities = create_activities(activity_type, activity_visits, search_keyword)

    if activities && activities.length == activity_visits.to_i
      render json: activities, status: 200
    else
      activity_type.destroy
      render json: { error: 'Failed to create activity.' }, status: 422
    end
  end

  def index
    activity_types = ActivityType.where(trip_id: params[:trip])
    activities = {}
    activity_types.each do |type|
      activities[type.activity_type] = Activity.where(activity_type_id: type)
    end
    render json: activities, status: 200
  end

  def destroy
    activity_type_to_destroy = ActivityType.find_by(trip_id: params[:trip])
    activities_to_destroy = Activity.where(activity_type_id: activity_type_to_destroy)
    ActivityType.destroy(activity_type_to_destroy.id)
    Activity.destroy(activities_to_destroy.ids)
    render head: :ok
  end

  private

  def set_activity_visits
    if params[:activity_type] == 'restaurant'
      Trip.find(params[:trip]).days
    else
      params[:activity_visits]
    end
  end

  def create_activity_type
    activity_type = ActivityType.create(activity_type: params.require(:activity_type),
                                        trip_id: params.require(:trip),
                                        max_price: params[:max_price])

    if activity_type.persisted?
      activity_type
    else
      render json: { error: activity_type.errors.full_messages }, status: 422
    end
  end

  def update_activity_type(activity_type_to_update)
    activity_type_to_update = ActivityType.update(activity_type_to_update.id,
                                                  activity_type: params.require(:activity_type),
                                                  trip_id: params.require(:trip),
                                                  max_price: params[:max_price])

    if ActivityType.find_by(trip_id: params[:trip])[:created_at] != ActivityType.find_by(trip_id: params[:trip])[:updated_at]
      activity_type_to_update
    else
      render json: { error: activity_type_to_update.errors.full_messages }, status: 422
    end
  end
end
