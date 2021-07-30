class ConsumerChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
  end

  def unsubscribed
    # Limpiezas necesarias cuando se desuscribr del canal
  end
end
