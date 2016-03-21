module ApplicationHelper
  def back_link_to(target_url = :back, text = 'Back')
    link_to target_url, class: 'back-link' do
      content_tag('i', '', class: 'glyphicon glyphicon-chevron-left') + text
    end
  end

  def check_printer(checks, period)
    output_rows = {}
    grouped_by_day = checks.group_by{|chk| chk.created_at.strftime("%Y%m%d") }
    days_per_month_in_period = period.group_by{|day| day.strftime("%Y%m") }.map{|k,v| [k, v.count] }.to_h

    prev_month_key = ''

    period.each do |date|
      day_key = date.strftime("%Y%m%d")
      month_key = date.strftime("%Y%m")

      # Defaults
      row_defaults = {
        month: nil,
        day: { atts: {}, content: date.strftime("%a %d") },
        arrival: { atts: { class: 'missed' }, content: '–' },
        departure: { atts: { class: 'missed' }, content: '–' },
      }

      output_rows[day_key] = row_defaults

      if prev_month_key != month_key
        output_rows[day_key][:month] = {
          atts: { rowspan: days_per_month_in_period[month_key] },
          content: content_tag(:p, date.strftime("%B")) + content_tag(:p, date.strftime("%Y"))
        }
      end

      if grouped_by_day[day_key].to_a.any?
        arrival, departure = grouped_by_day[day_key]

        if arrival
          output_rows[day_key][:arrival] = {
            atts: { class: arrival.context },
            content: arrival.created_at.strftime("%T")
          }
        end

        if departure
          output_rows[day_key][:departure] = {
            atts: { class: departure.context },
            content: departure.created_at.strftime("%T")
          }
        end
      end

      prev_month_key = month_key
    end

    output_rows
  end
end
