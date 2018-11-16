require 'faraday'
require 'json'

class Sender
  BOT_KEY = ENV['BOT_TOKEN']
  CHAT_KEY = ENV['CHAT_ID']

  def self.send_sticker
    s = sticker
    return if s.nil?
    Faraday.get(
      "https://api.telegram.org/bot#{BOT_KEY}/sendSticker?chat_id=#{CHAT_KEY}&sticker=#{s}"
    )
  end

  def self.sticker
    stickers = stickers(packs.sample)
    stickers.sample unless stickers.nil?
  end

  def self.packs
    @packs ||= File.readlines('../packs').reject(&:empty?)
  end

  def self.stickers(pack)
    response = Faraday.get("https://api.telegram.org/bot#{BOT_KEY}/getStickerSet?name=#{pack}")
    return nil if response.status != 200
    response = JSON.parse(response.body)
    return nil unless response['ok']
    reponse['result']['stickers'].map do |sticker|
      sticker['file_id']
    end
  end
end
