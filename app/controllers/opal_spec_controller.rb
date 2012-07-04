class OpalSpecController < ActionController::Base
  def run
    files = (params[:files] || 'spec').split(':')
    render :nothing => true, :layout => 'opal_spec', 
           :locals => { :spec_files => files }
  end
end
