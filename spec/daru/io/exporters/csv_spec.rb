RSpec.describe Daru::IO::Exporters::CSV do
  include_context 'exporter setup'
  let(:filename) { 'test.csv' }
  subject        { File.open(tempfile.path, &:readline).chomp.split(',', -1) }

  before { described_class.new(df, tempfile.path, opts).call }

  context 'writes DataFrame to a CSV file' do
    let(:opts) { {} }
    let(:content) { CSV.read(tempfile.path) }
    subject { Daru::DataFrame.rows content[1..-1].map { |x| x.map { |y| convert(y) } }, order: content[0] }

    it_behaves_like 'daru dataframe'
    it { is_expected.to eq(df) }
  end

  context 'writes headers unless headers=false' do
    it { is_expected.to be_an(Array) }
    it { is_expected.to eq(df.vectors.to_a) }
  end

  context 'does not write headers when headers=false' do
    let(:headers) { false }
    let(:opts)    { {headers: headers} }

    it { is_expected.to be_an(Array) }
    it { is_expected.to eq(df.head(1).map { |v| (v.first || '').to_s }) }
  end

  context 'writes into .csv.gz format' do
    let(:opts)     { {compression: :gzip} }
    let(:filename) { 'test.csv.gz'        }

    subject        { Zlib::GzipReader.new(open(tempfile.path)).read.split("\n") }

    it { is_expected.to be_an(Array).and all be_a(String) }
    it { is_expected.to eq(['a,b,c,d', '1,11,a,', '2,22,g,23', '3,33,4,4', '4,44,5,a', '5,55,addadf,ff']) }
  end

  context 'writes into .csv.gz format with only order' do
    let(:df)       { Daru::DataFrame.new('a' => [], 'b' => [], 'c' => [], 'd' => []) }
    let(:opts)     { {compression: :gzip}                                            }
    let(:filename) { 'test.csv.gz'                                                   }

    subject        { Zlib::GzipReader.new(open(tempfile.path)).read.split("\n") }

    it { is_expected.to be_an(Array).and all be_a(String) }
    it { is_expected.to eq(%w[a,b,c,d]) }
  end
end
