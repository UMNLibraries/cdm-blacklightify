module GettyFormatHelper
  include Umedia

  def id_getter
    string = @document[:format][0]
    definition = string.match('aat\/(.*)')&.captures[0]
  end

  def defining
  end
end