module Api
  # Controller that handles authorization and user data fetching
  class UsersController < ApplicationController
    include Devise::Controllers::Helpers

    def login
      user = User.find_by('lower(email) = ?', params[:email])

      if user.blank? || !user.valid_password?(params[:password])
        render json: {
          errors: [
            'Invalid email/password combination'
          ]
        }, status: :unauthorized
        return
      end

      sign_in(:user, user)

      render json: {
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          token: current_token
        }
      }.to_json
    end

    def index
      users = User.all
      serialized_users = users.map(&:serialize)

      response = {
        users: serialized_users,
      }

      render json: response.to_json
    end

    def show
      # user = User.find_by(id: params[:id])

      # response = {
      #   user: user,
      # }

      # render json: response.to_json
      scores = Score.where(user_id: params[:id]).includes(:user).order(played_at: :desc, id: :desc)
      serialized_scores = scores.map(&:serialize)

      response = {
        scores: serialized_scores,
      }

      render json: response.to_json
    end
  end
end
