require "iroha_crypt/version"

module IrohaCrypt
  class Error < StandardError
    EMPTY_SRC = ':src required' # 必須
  end

  module Mode
    # 暗号化のモード
    RINTEGER = 1 # 数値を桁数で埋めて反転して使用
    INTEGER = 2 # 数値をそのまま使用
    STRING = 3 # 文字列を桁数で埋めてそのまま使用
  end

  module Keymap
    IROHA = 'いろはにほへとちりぬるをわかよたれそつねならむうゐのおくやまけふこえてあさきゆめみしゑひもせすん'
    BASE64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    BASE64URLSAFE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_'
  end

  module Separator
    DEFAULT = '-'
    IROHA = '・'
    BASE64 = '='
  end

  module ChunkBit
    # unpackのテンプレート指定
    INTEGER = 'I*' # 32bit int
    LONG = 'Q*' # 64bit long long
    ISIZE = 4
    LSIZE = 8
  end

  class Base
    @keymap = IrohaCrypt::Keymap::BASE64
    @keymap_size = 64
    @size = 16
    @chunk = IrohaCrypt::ChunkBit::LONG
    @mode = IrohaCrypt::Mode::RINTEGER
    @padding = '0'
    @sep = '='
    @src = nil

    def initialize(
      src: nil,
      keymap: IrohaCrypt::Keymap::IROHA,
      size: 16,
      chunk: IrohaCrypt::ChunkBit::LONG,
      mode: IrohaCrypt::Mode::RINTEGER,
      padding: '0',
      separator: nil
    )
      raise IrohaCrypt::Error.new(IrohaCrypt::Error::EMPTY_SRC) if src.nil?
      @src = src
      @keymap = keymap
      @size = size
      @chunk = chunk
      @mode = mode
      @padding = padding
      if separator.nil?
        case @keymap
        when IrohaCrypt::Keymap::IROHA then; @sep = IrohaCrypt::Separator::IROHA
        when IrohaCrypt::Keymap::BASE64 then; @sep = IrohaCrypt::Separator::BASE64
        when IrohaCrypt::Keymap::BASE64URLSAFE then; @sep = IrohaCrypt::Separator::BASE64
        else @sep = IrohaCrypt::Separator::DEFAULT
        end
      else
        @sep = separator
      end
      @keymap_size = @keymap.size
    end

    def encode
      case @mode
      when IrohaCrypt::Mode::RINTEGER then; reverse_int_encode
      when IrohaCrypt::Mode::INTEGER then; int_encode
      when IrohaCrypt::Mode::STRING then; str_encode
      end
    end

    def decode
      case @mode
      when IrohaCrypt::Mode::RINTEGER then; reverse_int_decode
      when IrohaCrypt::Mode::INTEGER then; int_decode
      when IrohaCrypt::Mode::STRING then; str_decode
      end
    end

    def test
      @src = encode
      puts @src
      @src = decode
      puts @src
    end

    private

    def reverse_int_encode
      crypt(@src.to_s.rjust(@size, '0').reverse.to_i)
    end

    def reverse_int_decode
      decrypt(@src).to_s.reverse.to_i
    end

    def int_encode
      crypt(@src)
    end

    def int_decode
      decrypt(@src)
    end

    def str_encode
      out = []
      bjust(@src.to_s.reverse).unpack(@chunk).map do |src|
        out << crypt(src)
      end
      out.join(@sep)
    end

    def str_decode
      out = []
      @src.split(@sep).map do |src|
        out << decrypt(src)
      end
      out.pack(@chunk).strip.reverse
    end

    def chunk(src)
      out = 0
      src.map.with_index do |s, i|
        out += (256 ** i) * s
      end
      out
    end

    def crypt(src)
      out = ""
      while src > 0
        out += @keymap[src % @keymap_size]
        src /= @keymap_size
      end
      out
    end

    def decrypt(src)
      out = 0
      src.reverse.chars.map do |s|
        out *= @keymap_size
        out += @keymap.index(s)
      end
      out
    end

    def bjust(src)
      byte = case @chunk
      when IrohaCrypt::ChunkBit::INTEGER then; IrohaCrypt::ChunkBit::ISIZE
      when IrohaCrypt::ChunkBit::LONG then; IrohaCrypt::ChunkBit::LSIZE
      end
      size = (@src.to_s.bytesize.to_f / byte).ceil * byte
      src += "".ljust(size - src.bytesize, "\0")
    end
  end

  def self.new(params)
    IrohaCrypt::Base.new(**params)
  end
end
