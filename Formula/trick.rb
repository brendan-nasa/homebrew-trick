class Trick < Formula
  desc "Powerful simulation development framework"
  homepage "https://nasa.github.io/trick"
  license "NASA-1.3"
  head "https://github.com/nasa/trick.git", branch: "master"

  env :std

  depends_on "llvm" => :build
  depends_on "maven" => :build
  depends_on "swig" => :build
  depends_on "googletest" => :test
  depends_on "java"
  depends_on :macos
  depends_on "perl"
  depends_on "python@3.13"
  depends_on "udunits"
  depends_on "gsl" => :recommended
  depends_on "hdf5" => :recommended
  depends_on "openmotif" => :recommended

  def install
    # Set build environment
    ENV["TRICK_HOME"] = buildpath

    # Configure & build
    system "./configure", "--prefix=#{prefix}"
    system "make", "-j#{ENV.make_jobs}"
    system "make", "install"

    # Environment wrapper script
    (share/"trick_env.sh").write <<~EOS
      #!/bin/bash
      export TRICK_HOME=#{opt_prefix}
      export PATH=#{opt_bin}:$PATH
    EOS
    chmod 0755, share/"trick_env.sh"
  end

  def caveats
    <<~EOS
      Trick has been installed to:
        #{opt_prefix}

      To use Trick, set the environment variables:
        export TRICK_HOME=#{opt_prefix}
        export PATH=#{opt_bin}:$PATH

      Or source the provided script:
        source #{opt_share}/trick_env.sh
    EOS
  end

  test do
    # Test that trick-CP binary exists and runs
    assert_path_exists bin/"trick-CP"
    system bin/"trick-CP", "--help"
  end
end
