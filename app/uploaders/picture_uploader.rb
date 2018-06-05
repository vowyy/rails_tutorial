# rails g uploader Pictureを実行でこのファイルが作成される。
# rails g ~　見たいのは仕組みを理解していれば誰でも作れる。(Railsエンジン) deviseとかもそう
class PictureUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  process resize_to_limit: [400, 400]
  #micropost投稿時に画像の加工をしてくれる。縦の最大値が400、横の最大値も400

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  #アップロード可能な拡張子のリスト。
  def extension_white_list
    %w(jpg jpeg gif png)
  end

end
