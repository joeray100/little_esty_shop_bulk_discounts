class Holiday
  def conn
    Faraday.new(url: "https://date.nager.at")
  end

  def upcoming_holidays
    resp = conn.get('/Api/v2/NextPublicHolidays/US')
    parsed = JSON.parse(resp.body, symbolize_names: true)

    next_3_holidays = parsed[0..2]
    next_3_holidays.map do |holiday|
      holiday
    end
  end
end
