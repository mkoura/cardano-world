{
  inputs,
  cell,
}: let
  inherit (inputs.nixpkgs) jq writeText runCommand lib;

  defaultLogConfig = import ./generic-log-config.nix;
  defaultExplorerLogConfig = import ./explorer-log-config.nix;
  mkExplorerConfig = name: nodeConfig:
    lib.filterAttrs (k: v: v != null) {
      NetworkName = name;
      inherit (nodeConfig) RequiresNetworkMagic;
      NodeConfigFile = "${__toFile "config-${toString name}.json" (__toJSON nodeConfig)}";
    };

  environments = {
    mainnet = rec {
      useByronWallet = true;
      relays = "relays.cardano-mainnet.iohk.io";
      relaysNew = "relays-new.cardano-mainnet.iohk.io";
      explorerUrl = "https://explorer.cardano.org";
      smashUrl = "https://smash.cardano-mainnet.iohk.io";
      metadataUrl = "https://tokens.cardano.org";
      edgeNodes = [
        "3.125.75.199"
        "18.177.103.105"
        "18.141.0.112"
        "52.14.58.121"
      ];
      edgePort = 3001;
      confKey = "mainnet_full";
      private = false;
      networkConfig = import ./mainnet-config.nix;
      nodeConfig = networkConfig // defaultLogConfig;
      consensusProtocol = networkConfig.Protocol;
      submitApiConfig =
        {
          GenesisHash = nodeConfig.ByronGenesisHash;
          inherit (networkConfig) RequiresNetworkMagic;
        }
        // defaultExplorerLogConfig;
      explorerConfig = mkExplorerConfig "mainnet" nodeConfig;
      usePeersFromLedgerAfterSlot = 29691317;
    };
    staging = rec {
      useByronWallet = true;
      relaysNew = "relays.staging.cardano.org";
      explorerUrl = "https://explorer.staging.cardano.org";
      smashUrl = "https://smash.staging.cardano.org";
      metadataUrl = "https://metadata.cardano-testnet.iohkdev.io";
      edgeNodes = [
        "3.125.10.61"
        "52.192.59.170"
        "18.136.145.112"
      ];
      edgePort = 3001;
      confKey = "mainnet_dryrun_full";
      private = false;
      networkConfig = import ./staging-config.nix;
      nodeConfig = networkConfig // defaultLogConfig;
      consensusProtocol = networkConfig.Protocol;
      submitApiConfig =
        {
          GenesisHash = nodeConfig.ByronGenesisHash;
          inherit (networkConfig) RequiresNetworkMagic;
        }
        // defaultExplorerLogConfig;
      explorerConfig = mkExplorerConfig "staging" nodeConfig;
      usePeersFromLedgerAfterSlot = 29444240;
    };
    testnet = rec {
      useByronWallet = true;
      relays = "relays.cardano-testnet.iohkdev.io";
      relaysNew = "relays-new.cardano-testnet.iohkdev.io";
      explorerUrl = "https://explorer.cardano-testnet.iohkdev.io";
      smashUrl = "https://smash.cardano-testnet.iohkdev.io";
      metadataUrl = "https://metadata.cardano-testnet.iohkdev.io";
      edgeNodes = [
        "3.125.94.58"
        "18.176.19.63"
        "13.251.186.36"
        "3.135.95.164"
      ];
      edgePort = 3001;
      confKey = "testnet_full";
      private = false;
      networkConfig = import ./testnet-config.nix;
      nodeConfig = networkConfig // defaultLogConfig;
      consensusProtocol = networkConfig.Protocol;
      submitApiConfig =
        {
          GenesisHash = nodeConfig.ByronGenesisHash;
          inherit (networkConfig) RequiresNetworkMagic;
        }
        // defaultExplorerLogConfig;
      explorerConfig = mkExplorerConfig "testnet" nodeConfig;
      usePeersFromLedgerAfterSlot = 26888469;
    };
    p2p = rec {
      useByronWallet = false;
      private = false;
      relaysNew = "relays.p2p.dev.cardano.org";
      explorerUrl = "https://explorer.p2p.dev.cardano.org";
      smashUrl = "https://smash.p2p.dev.cardano.org";
      metadataUrl = "https://metadata.cardano-testnet.iohkdev.io";
      networkConfig = import ./p2p-config.nix;
      consensusProtocol = networkConfig.Protocol;
      nodeConfig = defaultLogConfig // networkConfig;
      edgePort = 3001;
      explorerConfig = mkExplorerConfig "p2p" nodeConfig;
      usePeersFromLedgerAfterSlot = 14680;
    };
    alonzo-purple = rec {
      useByronWallet = false;
      private = false;
      relaysNew = "relays.alonzo-purple.dev.cardano.org";
      explorerUrl = "https://explorer.alonzo-purple.dev.cardano.org";
      smashUrl = "https://smash.alonzo-purple.dev.cardano.org";
      metadataUrl = "https://metadata.cardano-testnet.iohkdev.io";
      networkConfig = import ./alonzo-purple-config.nix;
      consensusProtocol = networkConfig.Protocol;
      nodeConfig = defaultLogConfig // networkConfig;
      edgePort = 3001;
      explorerConfig = mkExplorerConfig "alonzo-purple" nodeConfig;
    };
    marlowe-pioneers = rec {
      useByronWallet = false;
      private = false;
      relaysNew = "relays.marlowe-pioneers.dev.cardano.org";
      explorerUrl = "https://explorer.marlowe-pioneers.dev.cardano.org";
      smashUrl = "https://smash.marlowe-pioneers.dev.cardano.org";
      metadataUrl = "https://metadata.cardano-testnet.iohkdev.io";
      networkConfig = import ./marlowe-pioneers-config.nix;
      consensusProtocol = networkConfig.Protocol;
      nodeConfig = defaultLogConfig // networkConfig;
      edgePort = 3001;
      explorerConfig = mkExplorerConfig "marlowe-pioneers" nodeConfig;
      usePeersFromLedgerAfterSlot = 40000;
    };
    # used for daedalus/cardano-wallet for local development
    shelley_qa = rec {
      useByronWallet = false;
      private = false;
      relaysNew = "relays-new.shelley-qa.dev.cardano.org";
      explorerUrl = "https://explorer.shelley-qa.dev.cardano.org";
      smashUrl = "https://smash.shelley-qa.dev.cardano.org";
      metadataUrl = "https://metadata.cardano-testnet.iohkdev.io";
      networkConfig = import ./shelley_qa-config.nix;
      consensusProtocol = networkConfig.Protocol;
      nodeConfig = defaultLogConfig // networkConfig;
      edgePort = 3001;
      explorerConfig = mkExplorerConfig "shelley_qa" nodeConfig;
      usePeersFromLedgerAfterSlot = 23574838;
    };
    # used for SRE development
    sre = rec {
      useByronWallet = false;
      private = false;
      relaysNew = "relays.sre.dev.cardano.org";
      explorerUrl = "https://explorer.sre.dev.cardano.org";
      smashUrl = "https://smash.sre.dev.cardano.org";
      metadataUrl = "https://metadata.cardano-testnet.iohkdev.io";
      networkConfig = import ./shelley_qa-config.nix;
      consensusProtocol = networkConfig.Protocol;
      nodeConfig = defaultLogConfig // networkConfig;
      edgePort = 3001;
      explorerConfig = mkExplorerConfig "sre" nodeConfig;
      usePeersFromLedgerAfterSlot = 122760;
    };
  };
in
  environments
