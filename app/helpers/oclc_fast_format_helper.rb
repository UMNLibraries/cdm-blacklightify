module OclcFastFormatHelper
  include Umedia

  # get the oclc uri and name. regex has two capture groups
  def subject_loop
    array = @document[:subject_fast]
    array.map { |x| x.match('^(.*?)\|?\|(.*)')&.captures }

    # capture group 1, suject name. removes trailing space
    # array.map { |x| x.match('^(.*?)\|?\|(.*)')&.captures[0].chop }
    # capture group 2, uri. removes leading space
    # array.map { |x| x.match('^(.*?)\|?\|(.*)')&.captures[1].trim }
  end

  def subject_name
    @document[:subject_fast]
  end

  # creates array of full subject_fast items and individual captures
  def subject_zipped_arr
    subject_name.zip(subject_loop)
  end
end