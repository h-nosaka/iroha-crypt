require "iroha_crypt"
RSpec.describe IrohaCrypt do
  let(:keymap) { '7jH2OExsmQ8rndfT9t1u5PWSvIoy0pGz6AbhZB/JlYekc3VCDi+M4LwXgUaNFRqK' }
  let(:size) { 16 }
  let(:chunk) { IrohaCrypt::ChunkBit::LONG }
  let(:mode) { IrohaCrypt::Mode::RINTEGER }
  let(:padding) { '0' }
  let(:separator) { '=' }

  it "has a version number" do
    expect(IrohaCrypt::VERSION).not_to be nil
  end

  describe "エンコード" do
    let(:src) { 12345 }

    describe 'iroha' do
      subject { IrohaCrypt.new(src: src).encode }
      let(:result) { 'いこつさきらもさいほ' }
      it { expect(subject).to eq(result) }
    end

    describe 'base64' do
      subject { IrohaCrypt.new(src: 56789, keymap: IrohaCrypt::Keymap::BASE64).encode }
      let(:result) { 'Ag8Ha/pFj' }
      it { expect(subject).to eq(result) }
    end

    describe 'base64 urlsafe' do
      subject { IrohaCrypt.new(src: 56789, keymap: IrohaCrypt::Keymap::BASE64URLSAFE).encode }
      let(:result) { 'Ag8Ha_pFj' }
      it { expect(subject).to eq(result) }
    end

    describe 'full paramater' do
      subject do
        IrohaCrypt.new(
          src: src,
          keymap: IrohaCrypt::Keymap::IROHA,
          size: size,
          chunk: chunk,
          mode: mode,
          padding: padding,
          separator: separator
        ).encode
      end
      let(:result) { 'いこつさきらもさいほ' }
      it { expect(subject).to eq(result) }
    end

    describe 'original' do
      subject { IrohaCrypt.new(src: src, keymap: keymap).encode }
      let(:result) { '76/gWpsuu' }
      it { expect(subject).to eq(result) }
    end

    describe 'string' do
      subject { IrohaCrypt.new(src: '12345678901234567890', mode: IrohaCrypt::Mode::STRING).encode }
      let(:result) { 'いえくわねむををゆめりろ・はえねみもいあゐさはをろ・ほろをうをに' }
      it { expect(subject).to eq(result) }
    end

  end

  describe "デコード" do
    let(:src) { 'いこつさきらもさいほ' }
    let(:keymap) { IrohaCrypt::Keymap::IROHA }
    let(:size) { 16 }
    let(:chunk) { IrohaCrypt::ChunkBit::LONG }
    let(:mode) { IrohaCrypt::Mode::RINTEGER }
    let(:padding) { '0' }
    let(:separator) { '=' }

    describe 'iroha' do
      subject { IrohaCrypt.new(src: src).decode }
      let(:result) { 12345 }
      it { expect(subject).to eq(result) }
    end

    describe 'base64' do
      subject { IrohaCrypt.new(src: 'Ag8Ha/pFj', keymap: IrohaCrypt::Keymap::BASE64).decode }
      let(:result) { 56789 }
      it { expect(subject).to eq(result) }
    end

    describe 'base64 urlsafe' do
      subject { IrohaCrypt.new(src: 'Ag8Ha_pFj', keymap: IrohaCrypt::Keymap::BASE64URLSAFE).decode }
      let(:result) { 56789 }
      it { expect(subject).to eq(result) }
    end

    describe 'full paramater' do
      subject do
        IrohaCrypt.new(
          src: src,
          keymap: IrohaCrypt::Keymap::IROHA,
          size: size,
          chunk: chunk,
          mode: mode,
          padding: padding,
          separator: separator
        ).decode
      end
      let(:result) { 12345 }
      it { expect(subject).to eq(result) }
    end

    describe 'original' do
      subject { IrohaCrypt.new(src: src, keymap: keymap).decode }
      let(:result) { 12345 }
      it { expect(subject).to eq(result) }
    end

    describe 'string' do
      subject { IrohaCrypt.new(src: 'いえくわねむををゆめりろ・はえねみもいあゐさはをろ・ほろをうをに', mode: IrohaCrypt::Mode::STRING).decode }
      let(:result) { '12345678901234567890' }
      it { expect(subject).to eq(result) }
    end

  end
end
