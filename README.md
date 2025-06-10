# Baby's First snowfall
I am writing this as a minimally useful example of a NixOS configuration (nay, a homelab configuration!) using Snowfall.

Snowfall has an interesting approach to its file structure and some well thought-out but rather opaque ways of doing things.

There are some great snowfall configurations out there, but the type of person who is interested in Snowfall very quickly fills up a set of dotfiles in ways that become confusing/overwhelming for some.

So I created this repo to give a starter for these configurations.

Here is a quick run down of everything:
```
├── flake.lock
├── flake.nix
├── homes
│   ├── john@server
│   │   └── default.nix
│   ├── user@client
│   │   └── default.nix
│   └── user@server
│       └── default.nix
├── modules
│   ├── home
│   └── nixos
│       ├── roles
│       │   └── desktop
│       │       └── pantheon
│       │           └── default.nix
│       └── users
│           └── default.nix
├── README.md
└── systems
    └── x86_64-linux
        ├── client
        │   ├── default.nix
        │   └── hardware.nix
        └── server
            ├── default.nix
            └── hardware.nix
```

## Some Snowfall concepts
### Workflow
Snowfall assumes you follow a pretty specific workflow. First you create a system in the directory corresponding to your architecture and platform. In this case I have created the systems `client` and `server` in the `x86_64-linux` directory. 

So in order to create a new system in a folder with the hostname of your choice you will create your `default.nix` in that directory and run from there.

Snowfall is also leaning pretty heavily on HomeManager (Which is great BTW.) 

After you create your system with a default.nix in the corresponding directory, you will create another default.nix in a directory that lives in homes yourname@hostname. In this case I have created a user named john for a home directory in server.

### Adding actual functionality
>"OK, John. That's great. Now how do I get actual work done?" - You (probably)

First of all, watch your tone. Secondo of all, we don't need to get any actual work done when there is literate programming and deterministic build processes to be done. But, should you want to add functionality you do it in the `modules` directory. 

But, let's say you want to add a desktop environment (because you never learned how to whistle at 2600Hz into payphones in order to launch nuclear missiles. *a la* Mr. Kevin Mitnick. You would create something in the nixos directory. For organization we are leaning on the fact that Snowfall turns these paths into strings we can access later. So a file in `modules/nixos/roles/desktop/pantheon` will export a value for `homelab.roles.desktop.pantheon`

```nix 
{ config, lib, pkgs, ... }:

with lib;
with lib.homelab;
let
  enabled = config.homelab.roles.desktop.pantheon or false;
in
{
  options.homelab.roles.desktop.pantheon = mkEnableOption "Pantheon desktop environment";

  config = mkIf enabled {
    #Actual things get done here.
    services.xserver.enable = true;
    services.xserver.displayManager.lightdm.enable = true;
    services.xserver.desktopManager.pantheon.enable = true;

    fonts.packages = with pkgs; [ dejavu_fonts ];
  };
}
```

One thing you might have noticed is the `with lib;` and `with lib.homelab;` options.

These are super fucking important. In our `flake.nix` (the main entrypoint for everything BTW) we have created a namespace called `homelab`. Homelab is the conduit between all of our objects. I am hardly a snowfall expert, but I have learned that if something doesn't work, just figure out a way to work `with lib.homelab` into it.

Think of the nix code surrounding the things in `#Actual things get done here` as a big ole composability hug. If you see some vanilla nix configuration and want to add it to your own homelab, just pop it in there.  

Anyway, now that we have created the basic skeleton of our role, we can go back to our system file and add it in like so:


`homelab.roles.desktop.pantheon = true;` and all of a sudden that son-of-a-gun can use pantheon. (Especially if you saved it in `systems/platform/that-son-of-a-gun/default.nix`)

>**ONE LAST THING:** This system assumes you have all of these fancy new `default.nix`es in version control. So frequently make some `git add .` calls to make sure you don't find yourself tracking down some missing functionality like a moron (ask me how I know...)

So there you have it:
1. how to create systems
2. how to create a user for that system 
3. how to give that system capabilities that will distract you from the important work of trying out new dotfiles frameworks.  

Now you just need to know how to build it. 

### Building the homelab

OK. So this next step is a little frustrating: If you are on a vanilla NixOS system you will need to make sure flakes are enabled, and get git. Only then can you enter the directory with the `flake.nix` and let out a mighty `sudo nixos-rebuild boot --flake .#myawesomemachine` and sprach into existence a kickass snowfall config.


