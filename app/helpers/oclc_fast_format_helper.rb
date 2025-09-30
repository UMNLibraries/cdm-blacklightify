module OclcFastFormatHelper
  include Umedia

  # get the oclc uri and name. returns two capture groups
  def subject_loop
    array = @document[:subject_fast]
    array.map { |x| x.match('^(.*?)\|?\|(.*)')&.captures }
  end

  def subject_name
    @document[:subject_fast]
  end

  # creates array of full subject_fast items and individual captures
  def subject_zipped_arr
    subject_name.zip(subject_loop)
  end
end