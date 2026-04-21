class Goldfish < Formula
  desc "A practical Scheme interpreter based on S7"
  homepage "https://github.com/MoganLab/goldfish"
  url "https://github.com/MoganLab/goldfish/archive/refs/tags/v17.11.55.tar.gz"
  sha256 "04ba823dc44674666296bdaf86af2a78d5f57ed57d584a508f4b7d002263ebd8"
  license "Apache-2.0"

  depends_on "xmake" => :build
  depends_on "cmake" => :build # 用于编译 cpr, json_schema_validator 等依赖
  depends_on "ninja" => :build

  def install
    # 1. 注入编译器环境（解决 CMake 报错的关键）
    ENV["CC"] = ENV.cc
    ENV["CXX"] = ENV.cxx

    # 2. 编译
    system "xmake", "config", "--yes", "--mode=release"
    system "xmake", "build", "goldfish"

    # 3. 安装
    # bin.install "bin/gf"
    # (share/"goldfish").mkpath
    # (share/"goldfish").install "goldfish"
    system "xmake", "install", "-y", "-o", prefix

    # 4. 创建符号链接，方便用户使用 `gf` 命令
    bin.install_symlink "gf" => "goldfish"
  end

  test do
    assert_match "Goldfish", shell_output("#{bin}/gf --version")
  end
end