class Trick < Formula
  desc "Trick Simulation Environment"
  homepage "https://nasa.github.io/trick"
  version "latest"
  license "NASA-1.3"
  head "https://github.com/nasa/trick.git", branch: "master"

  depends_on "maven" => :build
  depends_on "swig" => :build
  depends_on "python@3.13"
  depends_on "perl"
  depends_on "java"
  depends_on "udunits"
  depends_on "hdf5" => :recommended
  depends_on "gsl" => :recommended
  depends_on "googletest" => :test
  depends_on "xquartz"
  depends_on "openmotif" => :recommended

  uses_from_macos "gcc"
  uses_from_macos "clang"
  uses_from_macos "g++"
  uses_from_macos "clang++"

  def install
    # Set environment variables for build
    ENV["TRICK_HOME"] = buildpath

    # Configure the build
    system "./configure", "--prefix=#{prefix}"

    # Build Trick
    system "make"

    # Install to Homebrew prefix
    system "make", "install"

    # Ensure all required directories exist
    bin.mkpath
    include.mkpath
    lib.mkpath
    libexec.mkpath
    share.mkpath

    # Set up environment helper
    (buildpath/"trick_env.sh").write <<~EOS
      #!/bin/bash
      export TRICK_HOME=#{opt_prefix}
      export PATH=#{opt_bin}:$PATH
      export DYLD_LIBRARY_PATH=#{opt_lib}:$DYLD_LIBRARY_PATH
    EOS

    share.install "trick_env.sh"
  end

  def caveats
    <<~EOS
      Trick has been installed to:
        #{opt_prefix}

      To use Trick, you may need to set the following environment variables:
        export TRICK_HOME=#{opt_prefix}
        export PATH=#{opt_bin}:$PATH
        export DYLD_LIBRARY_PATH=#{opt_lib}:$DYLD_LIBRARY_PATH

      Or source the provided environment file:
        source #{opt_share}/trick_env.sh

      Add this to your shell profile (~/.zshrc or ~/.bash_profile) to make it permanent.
    EOS
  end

  test do
    # Test that trick-CP binary exists and runs
    assert_predicate bin/"trick-CP", :exist?
    system "#{bin}/trick-CP", "--help"
  end
end
