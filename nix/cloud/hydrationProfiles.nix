{
  inputs,
  cell,
}: let
  inherit (inputs) cells;
  inherit (cell.library) sopsFiles vaultSecrets;
in {
  # Bitte Hydrate Module
  # -----------------------------------------------------------------------
  default = {bittelib, ...}: {
    imports = [
      (cells.cardano.hydrationProfiles.consul-workload-policy)
      (cells.cardano.hydrationProfiles.vault-workload-policy)
    ];
    # NixOS-level hydration
    # --------------
    cluster = {
      name = "cardano";
      adminNames = [
        "samuel.leathers"
        "david.arnold"
      ];
      developerGithubNames = [];
      developerGithubTeamNames = ["cardano-devs"];
      domain = "world.dev.cardano.org";
      extraAcmeSANs = [];
      kms = "arn:aws:kms:eu-central-1:052443713844:key/c1d7a205-5d3d-4ca7-8842-9f7fb2ccc847";
      s3Bucket = "iog-cardano-bitte";
    };
    services = {
      grafana.provision.dashboards = [
        {
          name = "provisioned-cardano";
          options.path = ./dashboards;
        }
      ];
      nomad.namespaces = {vasil-qa.description = "Cardano Vasil HF QA";};
    };

    # cluster level (terraform)
    # --------------
    tf.hydrate-cluster.configuration = {
      # ... operator role policies
      locals.policies = {
        consul.developer = {
          service_prefix."vasil-qa-" = {
            policy = "write";
            intentions = "write";
          };
        };

        nomad.admin = {
          namespace."*".policy = "write";
          host_volume."*".policy = "write";
        };

        nomad.developer = {
          namespace.vasil-qa = {
            policy = "write";
            capabilities = [
              "submit-job"
              "dispatch-job"
              "read-logs"
              "alloc-exec"
              "alloc-node-exec"
              "alloc-lifecycle"
            ];
          };
          host_volume."vasil-qa-*".policy = "write";
        };
      };
    };

    # application state (terraform)
    # --------------
    tf.hydrate-app.configuration = let
      vault' = {
        dir = ./. + "/kv/vault";
        prefix = "kv";
      };
      consul' = {
        dir = ./. + "/kv/consul";
        prefix = "config";
      };
      vault = bittelib.mkVaultResources {inherit (vault') dir prefix;};
      consul = bittelib.mkConsulResources {inherit (consul') dir prefix;};
    in {
      data = {inherit (vault) sops_file;};
      resource = {
        inherit (vault) vault_generic_secret;
        inherit (consul) consul_keys;
      };
    };
  };
}
