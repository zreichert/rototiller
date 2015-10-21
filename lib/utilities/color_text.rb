module ColorText

  def colorize(text, color)
    "\e[#{color}m#{text}\e[0m"
  end

  def yellow_text(text)
    colorize(text, 33)
  end

  def green_text(text)
    colorize(text, 32)
  end

  def red_text(text)
    colorize(text, 31)
  end

end
