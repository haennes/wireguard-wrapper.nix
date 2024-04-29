# A simpler way to configure wireguard on multiple NixOS machines 
## Key Features:
- declare ips and peers and connections in one file
- Peers are automagically configured
- [uses wg0 as a default interface](#Todos)
- easy organization of private  and public keys

## Who is this for?
This gets interesting if you have upwards of 3-4 peers as manually configuring each host becomes messy and hard to maintain

## Getting Started
You can take a look at my [dotfiles](https://github.com/haennes/dotfiles) or more specifically at my [base.nix](https://github.com/haennes/dotfiles/tree/main/modules/all/base.nix) 

## Todos
- Allow multiple Interfaces Syntax:
    ```"hostname%interface"```
- To be determined:
    - either throw a warning if wireguard is enabled without a connection
    - or autmatically enable the module if some config is present for the host

## Contributing
This Code is far from perfect... 

This flake arose because I wanted to share parts of my config to friends, as well as the world.

If you want to contribute just open a PR or Issue and make sure to run nixfmt before you submit your code.
