# 画像アップローダー: CarrierWaveを用いて記事の画像ファイルをローカルストレージに保存するアップローダー

class ImageUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
