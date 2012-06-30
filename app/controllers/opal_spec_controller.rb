class OpalSpecController < ActionController::Base
  def run
    files = params[:files] || 'spec'
    render :nothing => true, :layout => 'spec', :locals => {
      :files => files.
    }
  end
end
