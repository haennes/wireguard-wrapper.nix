{secrets, config, lib, ...}:{
    services.wireguard-wrapper = {
      #port = 51821;
      connections = [
        [ "tabula" "welt" ]
        [ "porta" "welt" ]
        [ "hermes" "welt" ]
        [ "syncschlawiner" "welt" ]
        [ "syncschlawiner_mkhh" "welt" ]
        [ "handy_hannses" "welt" ]
        [ "thinkpad" "welt" ]
        [ "thinknew" "welt" ]
        [ "yoga" "welt" ]
        [ "mainpc" "welt" ]
      ];
      nodes = {
        welt = {
          ips = [ "192.168.1.1/32" "192.168.1.5/24" ];
          endpoint = "hannses.de:51821";
        };
        thinknew.ips = ["192.168.1.4/32" ]; 
      }; 
      publicKey = name:
        ((secrets.obtain_wireguard_pub { hostname = name; }).key);
      privateKeyFile = lib.mkIf (config.services.wireguard-wrapper.enable)
        config.age.secrets."wireguard_${config.networking.hostName}_wg0_private".path;
      port = 51821;
    };
}
