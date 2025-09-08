module GettyFormatHelper
  include Umedia

  def id_split
    @document[:format][0].split(';')
  end

  # returns the getty aat definition id numbers
  def id_loop
    array = id_split
    array.map { |x| x.match('aat\/(.*)')&.captures[0] }
  end

  def f_name
    @document[:format_name]
  end

  # creates array of format name and associated getty aat id
  def zipped_arr
    f_name.zip(id_loop)
  end
end
