require 'digest'
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

      @tmp_dir = Dir.mktmpdir(@latex_hash)
    end

    def to_image
      IO.write(latex_file_path, document)

      result = system('pdflatex', '-halt-on-error', '-output-directory', @tmp_dir, latex_file_path)
      raise RuntimeError, "Error while creating pdf: #{ result }" unless result

      result = system('convert', '-density', '600', '-quality', '100', pdf_file_path, png_file_path)
      raise RuntimeError, "Error while converting PDF to PNG: #{ result }" unless result

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
