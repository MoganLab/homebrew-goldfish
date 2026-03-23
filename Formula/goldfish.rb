class Goldfish < Formula
  desc "A practical Scheme interpreter based on S7"
  homepage "https://github.com/MoganLab/goldfish"
  url "https://github.com/MoganLab/goldfish/archive/refs/tags/v17.11.32.tar.gz"
  sha256 "75cfea83f32ec35cfaf4cf6e22a87e04f7d11ae8e4eb83a4ce8363f214168c2c"
  license "Apache-2.0"

  depends_on "xmake" => :build
  depends_on "cmake" => :build # 用于编译 cpr, json_schema_validator 等依赖
  depends_on "ninja" => :build

  def install
    # 1. 注入编译器环境（解决 CMake 报错的关键）
    ENV["CC"] = ENV.cc
    ENV["CXX"] = ENV.cxx

    # 2. 配置 xmake
    # 这里的 --prefix=#{prefix} 会自动映射到你 xmake.lua 里的 prefixdir
    # 例如你的 share/goldfish 会自动变成 /opt/homebrew/Cellar/goldfish/版本号/share/goldfish
    # system "xmake", "config", "--yes", "--mode=release", "--prefix=#{prefix}"

    # 3. 编译
    system "xmake", "build", "goldfish"

    # 4. 执行安装逻辑
    # 这一步会根据你的 xmake.lua 自动安装 bin/gf 和所有的 .scm 文件
    # system "xmake", "install", "-y"
    
    # 5. 可选：建立软链接 (如果你希望用户输入 goldfish 也能运行)
    bin.install_symlink "gf" => "goldfish"
  end

  test do
    assert_match "Goldfish", shell_output("#{bin}/gf --version")
  end
end