describe Moac::Key, type: :model do
  let(:priv) { nil }
  subject(:key) { Moac::Key.new priv: priv }

  describe "#initialize" do
    it "returns a key with a new private key" do
      key1 = Moac::Key.new
      key2 = Moac::Key.new

      expect(key1.private_hex).not_to eq(key2.private_hex)
      expect(key1.public_hex).not_to eq(key2.public_hex)
    end

    it "regenerates an old private key" do
      key1 = Moac::Key.new
      key2 = Moac::Key.new priv: key1.private_hex

      expect(key1.private_hex).to eq(key2.private_hex)
      expect(key1.public_hex).to eq(key2.public_hex)
    end
  end

  describe "#sign" do
    let(:message) { "Hi Mom!" }

    it "signs a message so that the public key is recoverable" do
      10.times do
        signature = key.sign message
        expect(key.verify_signature message, signature).to be_truthy
        s_value = Moac::Utils.v_r_s_for(signature).last
        expect(s_value).to be < (Moac::Secp256k1::N/2)
      end
    end

    context "when the network ID has been changed", chain_id: 42 do
      it "signs a message so that the public key is recoverable" do
        v_base = Moac.v_base
        expect(v_base).to eq(119)

        10.times do
          signature = key.sign message
          expect(key.verify_signature message, signature).to be_truthy
          v_val, r_val, s_val = Moac::Utils.v_r_s_for(signature)
          expect(s_val).to be < (Moac::Secp256k1::N/2)
          expect([v_base, v_base + 1]).to include(v_val)
        end
      end
    end
  end

  describe "#verify_signature" do
    let(:priv) { '5a37533acfa3ff9386aed01e16c0e7a79038ce05cc383e290d360b8ce9cd6fdf' }
    let(:signature) { hex_to_bin "1ce2f13b4123a23a4a280ac4adcba1ffa3f3848f494dc1de440af43f677e0e01260fb4667ed117d555659b249702c8215162b3f0ee09628813a4ef83616f99f180" }
    let(:message) { "Hi Mom!" }

    it "signs a message so that the public key is recoverable" do
      expect(key.verify_signature message, signature).to be_truthy
    end

    context "when the signature matches another public key" do
      let(:other_priv) { 'fd7f87d1f8c6cdfeb36caa491864519e89b405850c9e2e070839e74966d810cf' }
      let(:signature) { hex_to_bin "1b21a66b55af07a2b0981e3a0ba1768382c5bdbed3d16bcc58a8011425b3bbc090f881cc13d16792af55438637fbe9a2a81d85d6bb18b87b6c08aa9c20ce1341f4" }

      it "does not verify the signature" do
        expect(key.verify_signature message, signature).to be_falsy
      end
    end

    context "when the signature does not match any public key" do
      let(:signature) { hex_to_bin "1b21a66b" }

      it "signs a message so that the public key is recoverable" do
        expect(key.verify_signature message, signature).to be_falsy
      end
    end

    context "when the network ID has been changed", chain_id: 42 do
      let(:new_signature) { hex_to_bin '778bb9158ca2b1d64f97355839efef7564e8a960f2d8429c3001f3ecf6404fa0e83659a62ceb7f137d495d3f71dac967b6aab84ad3c06e50990df25c3caf202854' }

      it "can verify signatures from the new network" do
        v = Moac::Utils.v_r_s_for(new_signature).first
        expect([119, 120]).to include v
        expect(key.verify_signature message, new_signature).to be_truthy
      end

      it "can verify replayable signatures" do
        v = Moac::Utils.v_r_s_for(signature).first
        expect([27, 28]).to include v
        expect(key.verify_signature message, signature).to be_truthy
      end

      it "cannot verify signatures from other non replayable networks" do
        configure_chain_id 3

        expect(key.verify_signature message, new_signature).to be_falsey
      end
    end
  end

  describe "#address" do
    subject { key.address }
    let(:priv) { 'c3a4349f6e57cfd2cbba275e3b3d15a2e4cf00c89e067f6e05bfee25208f9cbb' }
    it { is_expected.to eq('0x759b427456623a33030bbC2195439C22A8a51d25') }
    it { is_expected.to eq(key.to_address) }
  end

  describe ".encrypt/.decrypt" do
    # see: https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition

    let(:password) { SecureRandom.base64 }
    let(:key) { Moac::Key.new }

    it "reads and writes keys in the Ethereum Secret Storage definition" do
      encrypted = Moac::Key.encrypt key, password
      decrypted = Moac::Key.decrypt encrypted, password

      expect(key.address).to eq(decrypted.address)
      expect(key.public_hex).to eq(decrypted.public_hex)
      expect(key.private_hex).to eq(decrypted.private_hex)
    end
  end
end
