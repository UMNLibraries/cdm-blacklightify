module OclcFastFormatHelper
  include Umedia

  # get the oclc uri
  def subject_loop
    array = @document[:subject_fast]
  end
end