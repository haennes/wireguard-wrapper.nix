{ config, lib, ... }:
let
  hostname = config.networking.hostName;
  cfg = config.services.wireguard-wrapper;
  our_connections =
    builtins.filter (l: (builtins.elem hostname l)) cfg.connections;
in with lib;
with lib.types; {
  options.services.wireguard-wrapper = {
    enable = mkEnableOption "wireguard-wrapper";
    RestartOnFailure = {
      enable =
        mkEnableOption "restarts the systemd service if connection fails";
      RestartSec = mkOption {
        type = ints.u16;
        default = 10;
        description = ''
          Time to sleep inbetween restarts
        '';
      };
    };
    #should be a per peer option, but throws an infinite recursion error on my machine
    kind = mkOption {
      type = enum [ "wireguard" "wg-quick" ];
      default = "wireguard";
      description = mdDoc ''
        how to configure this peer.
        can be decided on a per peer basis
      '';
    };
    mtu = mkOption {
      type = int;
      default = 1300;
    };
    privateKeyFile = mkOption { type = path; };
    publicKey = mkOption { type = anything; };

    port = mkOption {
      type = types.port;
      default = 51820;
    };
    openPort = mkOption {
      type = bool;
      default = true;
    };
    connections = mkOption { type = listOf (listOf str); };
    nodes = mkOption {
      type = attrsOf (submodule ({
        options = {
          endpoint = mkOption {
            type = nullOr str;
            default = null;
            description = mdDoc ''
              set if this is an endpoint
            '';
            example = "wg.example.com:51820";
          };
          ips = mkOption {
            type = listOf str;
            description =
              mdDoc "  first: own ip, all: ips that this peer can forward\n";
          };
        };
      }));
    };
  };
  config = mkIf cfg.enable ({
    networking.firewall.allowedUDPPorts = mkIf cfg.openPort [ cfg.port ];

    networking."${cfg.kind}".interfaces =
      let ips_name = if cfg.kind == "wireguard" then "ips" else "address";
      in {
        "wg0" = {
          ${ips_name} = [ (builtins.head cfg.nodes."${hostname}".ips) ];
          mtu = cfg.mtu;
          privateKeyFile = cfg.privateKeyFile;
          listenPort = cfg.port;
          peers = (builtins.map (l:
            let
              other = (lib.head (lib.remove hostname l));
              other_node = cfg.nodes."${other}";
            in ({
              publicKey = ((cfg.publicKey) other);
              allowedIPs = (other_node.ips);
              persistentKeepalive = 25;
              endpoint = other_node.endpoint;
            } // (if cfg.kind == "wireguard" then { name = other; } else { })))
            our_connections);
        };
      };

    systemd.services = mkIf cfg.RestartOnFailure.enable (listToAttrs (map (n:

      let
        other = (lib.head (lib.remove hostname n));
        other_node = cfg.nodes."${other}";
      in {
        name = "wireguard-wg0-peer-${other}";
        value = {
          serviceConfig = {
            Restart = "on-failure";
            inherit (cfg.RestartOnFailure) RestartSec;
          };
          unitConfig.StartLimitIntervalSec = 0;
        };
      }

    ) our_connections));
  });
}
