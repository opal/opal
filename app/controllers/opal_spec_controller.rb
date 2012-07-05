class OpalSpecController < ActionController::Base
  def run
  end
  
  
  private
  
  def spec_files
    @spec_files ||= (params[:files] || 'spec').split(':')
  end
  
  helper_method :spec_files
end
