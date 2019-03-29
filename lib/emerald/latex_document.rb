require 'digest'
require 'open3'
require 'tmpdir'

module Emerald
  class LatexDocument
    DOCUMENT_SKELETON = %q{
\documentclass{standalone}

\usepackage{amsmath}

\begin{document}

\(
	%s
\)
\end{document}
}

    def initialize(latex:)
      @latex = latex
      @latex_hash = Digest::SHA2.hexdigest(@latex)

      @logger = Emerald.logger(program: 'latex')

      @tmp_dir = Dir.mktmpdir(@latex_hash)
    end

    def to_image
      @logger.debug({ path: ENV['PATH'] })
      @logger.info({ msg: 'Rendering LaTeX', latex: @latex })
      IO.write(latex_file_path, document)

      out, err, result = Open3.capture3(
        'pdflatex', '-halt-on-error', '-output-directory', @tmp_dir, latex_file_path
      )
      @logger.debug({ msg: 'PDF rendering complete', result: result, stdout: out, stderr: err })
      raise RuntimeError, "Error while creating pdf: #{ result.inspect }" unless result

      out, err, result = Open3.capture3(
        'convert', '-density', '600', '-quality', '100', pdf_file_path, png_file_path
      )
      @logger.debug({ msg: 'PNG conversion complete', result: result, stdout: out, stderr: err })
      raise RuntimeError, "Error while converting PDF to PNG: #{ result.inspect }" unless result

      png_file_path
    end

    def clear
      FileUtils.remove_dir(@tmp_dir)
    end

    private
    def document
      DOCUMENT_SKELETON % @latex
    end

    def latex_file_path
      File.join(@tmp_dir, "#{ @latex_hash }.tex")
    end

    def pdf_file_path
      File.join(@tmp_dir, "#{ @latex_hash }.pdf")
    end

    def png_file_path
      File.join(@tmp_dir, "#{ @latex_hash }.png")
    end
  end
end
