# Methods added to this helper will be available to all templates in the application.
module IllustrationsHelper
  def current_illustration
    @illustration || Illustration.first
  end

  def art_tag
    if current_illustration
      image_tag(current_illustration.art.url(:normal), :width => 550, :height => 500)
    else
      image_tag('default.png', :with => 550, :height => 500)
    end
  end

  def art_credits
    if current_illustration
      "Illustration by #{link_to(current_illustration.artist_name, current_illustration.artist_url)}. ##{current_illustration.id} of #{Illustration.count}."
    else
      nil
    end
  end
end
