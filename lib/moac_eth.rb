require 'digest/sha3'
require 'ffi'
require 'money-tree'
require 'rlp'

module MoacEth
  BYTE_ZERO = "\x00".freeze
  UINT_MAX = 2**256 - 1

  autoload :Address, 'moac_eth/address'
  autoload :Gas, 'moac_eth/gas'
  autoload :Key, 'moac_eth/key'
  autoload :OpenSsl, 'moac_eth/open_ssl'
  autoload :Secp256k1, 'moac_eth/secp256k1'
  autoload :Sedes, 'moac_eth/sedes'
  autoload :Tx, 'moac_eth/tx'
  autoload :Utils, 'moac_eth/utils'

  class << self
    def configure
      yield(configuration)
    end

    def replayable_chain_id
      27
    end

    def chain_id
      configuration.chain_id
    end

    def v_base
      if chain_id
        (chain_id * 2) + 35
      else
        replayable_chain_id
      end
    end

    def prevent_replays?
      !chain_id.nil?
    end

    def replayable_v?(v)
      [replayable_chain_id, replayable_chain_id + 1].include? v
    end

    def tx_data_hex?
      !!configuration.tx_data_hex
    end


    private

    def configuration
      @configuration ||= Configuration.new
    end
  end

  class Configuration
    attr_accessor :chain_id, :tx_data_hex

    def initialize
      self.tx_data_hex = true

      # Moac chain
      # Network ID for Testnet is 101
      # Network ID for Mainnet is 99
      self.chain_id    = 101
    end
  end

  class ValidationError < StandardError; end
  class InvalidTransaction < ValidationError; end
end
