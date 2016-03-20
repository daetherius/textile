module ApplicationHelper
  def back_link_to(target_url = :back, text = 'Back')
    link_to target_url, class: 'back-link' do
      content_tag('i', '', class: 'glyphicon glyphicon-chevron-left') + text
    end
  end
end
