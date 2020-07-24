require 'json'
require 'open-uri'
require 'nokogiri'

class EventsController < ApplicationController
  def show
    @event = Event.find(params[:id])
    authorize @event
    @new_message = Message.new
    @new_question = Question.new
    @new_poll = Poll.new
    @new_poll.choices.build
    @tab = params[:tab] || "comment"
  end

  def new
    @event = Event.new
    authorize Event
    if current_or_guest_user.organization.present?
      url = "https://api.meetup.com/#{current_or_guest_user.organization}/events?&sign=true&photo-host=public&page=20"
      if url_valid?(url)
        events_serialized = open(url).read
        @events = JSON.parse(events_serialized)
      else
        @events = nil
      end
    end
  end

  def create
    @event = Event.new(event_params)
    @event.user = current_user
    authorize @event

    if @event.save
      redirect_to event_path(@event)
    else
      render :new
    end
  end

  def summary
    @event = Event.find(params[:event_id])
    authorize @event
    @audiences = Audience.where(event: current_user.events).joins(:user).where.not(users: {first_name: "guest", gender: nil, occupation: nil})
    @messages = Message.where(event: current_user.events)
    @questions = Question.where(event: current_user.events)
  end

  def edit
    @event = Event.find(params[:id])
    authorize @event
  end

  def update
    @event = Event.find(params[:id])
    @event.update(event_params)
    authorize @event
    @event.save
    redirect_to @event
  end

  private

  def event_params
    params.require(:event).permit(:title, :description, :start_time, :end_time, :photo, :location)
  end

  def url_valid?(url)
    url = URI.parse(url) rescue false
  end
end
