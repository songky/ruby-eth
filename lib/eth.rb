require 'digest/sha3'
require 'ffi'
require 'money-tree'
require 'rlp'

module Eth
  BYTE_ZERO = "\x00".freeze
  UINT_MAX = 2**256 - 1

  autoload :Address, 'eth/address'
  autoload :Gas, 'eth/gas'
  autoload :Key, 'eth/key'
  autoload :OpenSsl, 'eth/open_ssl'
  autoload :Secp256k1, 'eth/secp256k1'
  autoload :Sedes, 'eth/sedes'
  autoload :Tx, 'eth/tx'
  autoload :MoacTx, 'eth/moac_tx'
  autoload :Utils, 'eth/utils'

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
    end
  end

  class ValidationError < StandardError; end
  class InvalidTransaction < ValidationError; end
end
