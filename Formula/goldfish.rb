class Goldfish < Formula
  desc "Practical Scheme interpreter based on S7"
  homepage "https://github.com/MoganLab/goldfish"
  # 顶层 url 直接是 arm64 macOS 预编译二进制包（Apple Silicon 是绝大多数用户）。
  # 这样 brew 探测版本/触发 brew upgrade 走的就是这条 url，不会被 on_system 覆盖层挡住。
  # Intel Mac 与 Linux 在下面 on_intel / on_linux block 里覆盖为源码包（从源码编译）。
  url "https://github.com/MoganLab/goldfish/releases/download/v18.11.11/goldfish-scheme-arm64-v18.11.11-darwin.tar.gz"
  sha256 "318b29c67d9db1cc30a9430a91666f03f2f71cf7ea99cf443f265bc674ee9a1e"
  license "Apache-2.0"

  # Apple Silicon 走预编译二进制，无需构建依赖；仅 Intel Mac / Linux 编译时才需要。
  on_intel do
    depends_on "cmake" => :build # 用于编译 cpr, json_schema_validator 等依赖
    depends_on "ninja" => :build
    depends_on "xmake" => :build
  end
  on_linux do
    depends_on "cmake" => :build
    depends_on "ninja" => :build
    depends_on "xmake" => :build
  end

  # Intel Mac：使用上游源码 tarball 从源码编译
  on_macos do
    on_intel do
      url "https://github.com/MoganLab/goldfish/archive/refs/tags/v18.11.11.tar.gz"
      sha256 "4552277a458f98865c184f1711ed80ab4f330a0b8de246741e02f60bdac2b5cc"
    end
  end

  # Linux：同样使用上游源码 tarball 从源码编译
  on_linux do
    url "https://github.com/MoganLab/goldfish/archive/refs/tags/v18.11.11.tar.gz"
    sha256 "4552277a458f98865c184f1711ed80ab4f330a0b8de246741e02f60bdac2b5cc"
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

  # 让 brew 用 GitHub 最新 release 来探测版本，配合顶层 arm64 url，
  # brew upgrade goldfish 能立刻识别到新版本。
  livecheck do
    url :stable
    strategy :github_latest
  end

  test do
    assert_match "Goldfish", shell_output("#{bin}/gf --version")
  end
end
