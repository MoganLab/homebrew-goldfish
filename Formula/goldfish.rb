class Goldfish < Formula
  desc "Practical Scheme interpreter based on S7"
  homepage "https://github.com/MoganLab/goldfish"
  # 顶层源码包：作为 Intel Mac 与 Linux 的默认（从源码编译）。
  # arm64 macOS 在下面的 on_macos > on_arm 中覆盖为预编译二进制。
  # 注：Homebrew 规则下只有 on_macos/on_arm 能覆盖 url，on_intel/on_linux 不能，
  # 故顶层必须用跨平台成立的源码包，arm64 二进制走覆盖。
  url "https://github.com/MoganLab/goldfish/archive/refs/tags/v18.11.15.tar.gz"
  sha256 "d1e133aa50431e0297682157f934f9af8b6bbb2df5799435024e5eff23096bea"
  license "Apache-2.0"

  # 让 brew 用 GitHub 最新 release 来探测版本。
  # 顶层 url 是 archive 源码包，brew 默认无法可靠从中探测版本，导致
  # brew upgrade goldfish 误判为已是最新（no-op）。livecheck 指向 release 后，
  # brew 能正确识别新版本，配合 on_arm 覆盖的 arm64 二进制 url 完成升级。
  livecheck do
    url :stable
    strategy :github_latest
  end

  # Apple Silicon：使用上游发布的预编译二进制包（秒装，无需编译依赖）。
  # Intel Mac 在同一 block 的 on_intel 里声明从源码编译所需的构建依赖。
  on_macos do
    on_arm do
      url "https://github.com/MoganLab/goldfish/releases/download/v18.11.15/goldfish-scheme-arm64-v18.11.15-darwin.tar.gz"
      sha256 "a9d68deae14e96effd5f58cd6ab953a4f492c0ce6c95a67f34b33b369e6849ea"
    end
    on_intel do
      depends_on "cmake" => :build # 用于编译 cpr, json_schema_validator 等依赖
      depends_on "ninja" => :build
      depends_on "xmake" => :build
    end
  end

  on_linux do
    depends_on "cmake" => :build
    depends_on "ninja" => :build
    depends_on "xmake" => :build
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
