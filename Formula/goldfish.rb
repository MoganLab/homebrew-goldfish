class Goldfish < Formula
  desc "Practical Scheme interpreter based on S7"
  homepage "https://github.com/MoganLab/goldfish"
  # 顶层源码包：作为 Intel Mac 与 Linux 的默认（从源码编译）。
  # arm64 macOS 在下面的 on_arm block 中覆盖为预编译二进制。
  url "https://github.com/MoganLab/goldfish/archive/refs/tags/v18.11.11.tar.gz"
  sha256 "4552277a458f98865c184f1711ed80ab4f330a0b8de246741e02f60bdac2b5cc"
  license "Apache-2.0"

  depends_on "cmake" => :build # 用于编译 cpr, json_schema_validator 等依赖
  depends_on "ninja" => :build
  depends_on "xmake" => :build

  # Apple Silicon：使用上游发布的预编译二进制包（秒装，无需编译依赖）
  on_macos do
    on_arm do
      url "https://github.com/MoganLab/goldfish/releases/download/v18.11.11/goldfish-scheme-arm64-v18.11.11-darwin.tar.gz"
      sha256 "318b29c67d9db1cc30a9430a91666f03f2f71cf7ea99cf443f265bc674ee9a1e"
    end
  end

  def install
    # arm64 macOS 下走预编译二进制：tar 包内布局为 bin/gf + share/goldfish/...，
    # 直接落到 prefix；其余平台（Intel Mac / Linux）从源码编译。
    if OS.mac? && Hardware::CPU.arm?
      prefix.install Dir["*"]
    else
      # 1. 注入编译器环境（解决 CMake 报错的关键）
      ENV["CC"] = ENV.cc
      ENV["CXX"] = ENV.cxx

      # 2. 编译
      system "xmake", "config", "--yes", "--mode=release"
      system "xmake", "build", "goldfish"

      # 3. 安装
      system "xmake", "install", "-y", "-o", prefix
    end

    # 创建符号链接，方便用户使用 `goldfish` 命令
    bin.install_symlink "gf" => "goldfish"
  end

  test do
    assert_match "Goldfish", shell_output("#{bin}/gf --version")
  end
end
