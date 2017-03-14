require File.expand_path('../support/test_helper', __FILE__)

class ReadmeTest < Minitest::Test
  README_PATH = File.expand_path('../../README.md', __FILE__)

  def test_code_blocks
    readme = File.read(README_PATH)
    code_blocks = readme.scan(/^(~~~|```)ruby(.*?)^\1/m)
    code_blocks.each do |(_, code)|
      begin
        eval(code)
      rescue Exception => e
        flunk("Could not evaluate code in the readme: #{e} in the code\n" + code.gsub(/^/m, '    '))
      end
    end
  end
end
