class OpalSpecController < ActionController::Base
  helper_method :spec_files

  def run
  end


  private

  def spec_files
    @spec_files ||= some_spec_files || all_spec_files
  end

  def specs_param
    params[:pattern]
  end

  def some_spec_files
    return if specs_param.blank?
    specs_param.split(':').map { |path| spec_files_for_glob(path) }.flatten
  end

  def all_spec_files
    spec_files_for_glob '**'
  end

  def spec_files_for_glob glob = '**'
    Dir[Rails.root.join("{app,lib}/assets/javascripts/spec/#{glob}{,_spec.js.{rb,opal}}")].map do |path|
      path.split('assets/javascripts/spec/').last
    end.uniq
  end
end
