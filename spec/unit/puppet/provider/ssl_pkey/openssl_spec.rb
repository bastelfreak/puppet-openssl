# frozen_string_literal: true

require 'puppet'
require 'pathname'
require 'puppet/type/ssl_pkey'

describe 'The openssl provider for the ssl_pkey type' do
  let(:path) { '/tmp/foo.key' }
  let(:pathname) { Pathname.new(path) }
  let(:resource) { Puppet::Type::Ssl_pkey.new(path: path) }
  let(:key) { OpenSSL::PKey::RSA.new }

  it 'exists? should return true if key exists' do
    expect(Pathname).to receive(:new).twice.with(path).and_return(pathname)
    expect(pathname).to receive(:exist?).and_return(true)
    expect(resource.provider.exists?).to be(true)
  end

  it 'exists? should return false if certificate does not exist' do
    expect(Pathname).to receive(:new).twice.with(path).and_return(pathname)
    expect(pathname).to receive(:exist?).and_return(false)
    expect(resource.provider.exists?).to be(false)
  end

  context 'when creating a key with defaults' do
    it 'creates an rsa key' do
      allow(OpenSSL::PKey::RSA).to receive(:new).with(2048).and_return(key)
      expect(File).to receive(:write).with('/tmp/foo.key', kind_of(String))
      resource.provider.create
    end

    context 'when setting size' do
      it 'creates with given size' do
        resource[:size] = 1024
        allow(OpenSSL::PKey::RSA).to receive(:new).with(1024).and_return(key)
        expect(File).to receive(:write).with('/tmp/foo.key', kind_of(String))
        resource.provider.create
      end
    end

    context 'when setting password' do
      it 'creates with given password' do
        resource[:password] = '2x$5{'
        allow(OpenSSL::PKey::RSA).to receive(:new).with(2048).and_return(key)
        expect(OpenSSL::Cipher).to receive(:new).with('aes-256-cbc')
        expect(File).to receive(:write).with('/tmp/foo.key', kind_of(String))
        resource.provider.create
      end
    end
  end

  context 'when setting authentication to rsa' do
    it 'creates an rsa key' do
      resource[:authentication] = :rsa
      allow(OpenSSL::PKey::RSA).to receive(:new).with(2048).and_return(key)
      expect(File).to receive(:write).with('/tmp/foo.key', kind_of(String))
      resource.provider.create
    end

    context 'when setting size' do
      it 'creates with given size' do
        resource[:authentication] = :rsa
        resource[:size] = 1024
        allow(OpenSSL::PKey::RSA).to receive(:new).with(1024).and_return(key)
        expect(File).to receive(:write).with('/tmp/foo.key', kind_of(String))
        resource.provider.create
      end
    end

    context 'when setting password' do
      it 'creates with given password' do
        resource[:authentication] = :rsa
        resource[:password] = '2x$5{'
        allow(OpenSSL::PKey::RSA).to receive(:new).with(2048).and_return(key)
        expect(OpenSSL::Cipher).to receive(:new).with('aes-256-cbc')
        expect(File).to receive(:write).with('/tmp/foo.key', kind_of(String))
        resource.provider.create
      end
    end
  end

  context 'when setting authentication to ec' do
    key = OpenSSL::PKey::EC.new('secp384r1').generate_key # For mocking

    it 'creates an ec key' do
      resource[:authentication] = :ec
      allow(OpenSSL::PKey::EC).to receive(:new).with('secp384r1').and_return(key)
      expect(File).to receive(:write).with('/tmp/foo.key', kind_of(String))
      resource.provider.create
    end

    context 'when setting curve' do
      it 'creates with given curve' do
        resource[:authentication] = :ec
        resource[:curve] = 'prime239v1'
        allow(OpenSSL::PKey::EC).to receive(:new).with('prime239v1').and_return(key)
        expect(File).to receive(:write).with('/tmp/foo.key', kind_of(String))
        resource.provider.create
      end
    end

    context 'when setting password' do
      it 'creates with given password' do
        resource[:authentication] = :ec
        resource[:password] = '2x$5{'
        allow(OpenSSL::PKey::EC).to receive(:new).with('secp384r1').and_return(key)
        expect(OpenSSL::Cipher).to receive(:new).with('aes-256-cbc')
        expect(File).to receive(:write).with('/tmp/foo.key', kind_of(String))
        resource.provider.create
      end
    end
  end

  it 'deletes files' do
    expect(Pathname).to receive(:new).twice.with(path).and_return(pathname)
    expect(pathname).to receive(:delete)
    resource.provider.destroy
  end
end
