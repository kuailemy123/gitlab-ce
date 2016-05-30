class EmojisController < ApplicationController
  layout false

  def index
    @emoji = {
      emoji: Gitlab::AwardEmoji.urls
    }

    respond_to do |format|
      format.html
      format.json { render json: @emoji }
    end
  end
end
