require 'hydra/file_characterization/exceptions'
require 'hydra/file_characterization/characterizer'
module Hydra::FileCharacterization::Characterizers
  class Jhove < Hydra::FileCharacterization::Characterizer

    protected
    def command
      "#{tool_path} -i \"#{filename}\" -h xml"
    end

  end
end
