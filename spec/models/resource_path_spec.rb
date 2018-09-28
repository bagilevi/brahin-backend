require 'mini_helper'

describe ResourcePath do
  let(:instance) { ResourcePath[input] }

  describe '#to_url_path' do
    subject { instance.to_url_path }

    context 'simple' do
      let(:input) { '/a/b/c' }
      it { is_expected.to eq '/a/b/c' }
    end

    context 'root' do
      let(:input) { '/' }
      it { is_expected.to eq '/' }
    end
  end

  describe '#to_key' do
    subject { instance.to_key }

    context 'simple' do
      let(:input) { '/a/b/c' }
      it { is_expected.to eq 'root/a/b/c' }
    end

    context 'root' do
      let(:input) { '/' }
      it { is_expected.to eq 'root' }
    end
  end

  describe '.[]' do
    context 'element with no valid characters' do
      let(:input) { '/a/@@@/b' }

      it 'raises error' do
        expect { described_class[input] }
          .to raise_error /invalid path element/i
      end
    end

    context 'contains unacceptable characters' do
      let(:input) { '/.%185na@' }

      it 'removes invalid characters' do
        expect(described_class[input].to_s).to eq '/185na'
      end
    end
  end
end
