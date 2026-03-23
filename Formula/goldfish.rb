# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://docs.brew.sh/rubydoc/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Goldfish < Formula
  desc "Goldfish Scheme / 金鱼Scheme"
  homepage "https://github.com/MoganLab/goldfish"
  url "https://github.com/MoganLab/goldfish/archive/refs/tags/v17.11.32.tar.gz"
  sha256 "75cfea83f32ec35cfaf4cf6e22a87e04f7d11ae8e4eb83a4ce8363f214168c2c"
  license "Apache-2.0"
  head "https://github.com/MoganLab/goldfish.git", branch: "main"

  depends_on "xmake" => :build
  depends_on "cmake" => :build
  depends_on "ninja" => :build

  def install
    # Use Homebrew's build environment
    ENV.deparallelize
    
    # Set compiler environment variables for both xmake and cmake
    ENV["CC"] = ENV.cc
    ENV["CXX"] = ENV.cxx
    ENV["CMAKE_C_COMPILER"] = ENV.cc
    ENV["CMAKE_CXX_COMPILER"] = ENV.cxx
    
    # Configure xmake with explicit compiler settings
    system "xmake", "config", 
           "--mode=release",
           "--cc=#{ENV.cc}",
           "--cxx=#{ENV.cxx}",
           "--buildir=build"
    
    system "xmake", "build", "goldfish"
    
    bin.install "bin/gf"
    bin.install_symlink "gf" => "goldfish"
    
    # Install standard library
    (share/"goldfish").install Dir["goldfish/*.scm"]
    (share/"goldfish").install Dir["goldfish/**/*"]
    
    # Install SRFI libraries
    (share/"goldfish").install Dir["srfi/*.scm"]
    (share/"goldfish").install Dir["srfi/**/*"]
    
    # Install liii libraries
    (share/"goldfish").install Dir["liii/*.scm"]
    (share/"goldfish").install Dir["liii/**/*"]
  end

  test do
    # Test basic functionality
    assert_match(/Goldfish Scheme/, shell_output("#{bin}/gf --version"))
    
    # Test basic Scheme evaluation
    assert_equal "3", shell_output("#{bin}/gf eval '(+ 1 2)'").strip
    
    # Test loading a simple Scheme file
    (testpath/"test.scm").write "(display \"Hello from Goldfish Scheme\")"
    assert_match(/Hello from Goldfish Scheme/, shell_output("#{bin}/gf load #{testpath}/test.scm"))
  end
end
