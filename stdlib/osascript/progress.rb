# backtick_javascript: true

class Progress
  class << self
    def additionDescription=(str)
      `Progress.additionDescription = str`
    end

    def completedUnitCount=(i)
      `Progess.completedUnitCount = i`
    end

    def description=(str)
      `Progress.description = str`
    end

    def totalUnitCount=(i)
      `Progress.totalUnitCount = i`
    end
  end
end
