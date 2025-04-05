# backtick_javascript: true

class Automation
  def self.getDisplayString(obj)
    if `typeof(obj.native_objective_c) !== "undefined"`
      `Automation.getDisplayString(obj.native_objective_c)`
    else
      `Automation.getDisplayString(obj)`
    end
  end
end
