# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, lib, ... }:
let
  master = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/master.tar.gz") {};
  # installs a vim plugin from git with a given tag / branch
  pluginGit = ref: repo: pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "${lib.strings.sanitizeDerivationName repo}";
    version = ref;
    src = builtins.fetchGit {
      url = "https://github.com/${repo}.git";
      ref = ref;
    };
  };
  # always installs latest version
  plugin = pluginGit "HEAD";
in 
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos")
    ];

  # Use the GRUB 2 boot loader.
  # boot.loader.grub.enable = true;
  # boot.loader.grub.version = 2;
  # boot.loader.grub.useOSProber = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  # boot.loader.grub.device = "nodev"; # or "nodev" for efi only
  boot.loader.systemd-boot.enable = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp5s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  services.dwm-status = {
    enable = true;
    order = [ "audio" "cpu_load" "time" ];
    extraConfig = ''
      separator = "    "
      [audio]
      mute = "ﱝ"
      template = "{ICO} {VOL}%"
      icons = ["奄", "奔", "墳"]
    '';
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    windowManager.dwm.enable = true;

    displayManager.sessionCommands = ''
      feh --no-fehbg --bg-scale /etc/nixos/mountain.jpg
    '';

    displayManager.lightdm.enable = true;
    displayManager.lightdm.greeters.mini = {
      enable = true;
      user = "akash";
    };

    videoDrivers = [ "nvidia" ];
  };

  # Configure keymap in X11
  services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  programs.zsh.enable = true;
  programs.zsh.ohMyZsh = {
    enable = true;
    plugins = [ "git" "sudo" ];
    theme = "nicoulaj";
  };
  programs.zsh.interactiveShellInit = ''
    ${pkgs.disfetch}/bin/disfetch
  '';

  users.extraUsers.akash = {
    shell = pkgs.zsh;
  };

  home-manager.users.root = {
    programs.git = {
      enable = true;
      userName = "JavaLich";
      userEmail = "amelachuri@gmail.com";
    };
    programs.neovim = {
      enable = true;
      package = pkgs.neovim-nightly;
      extraConfig = builtins.readFile ./nvim/init.vim + builtins.readFile ./nvim/mountain.vim;
      plugins = with pkgs.vimPlugins; [
        lualine-nvim
	    vimwiki
	    vim-floaterm
        vim-startify
	    vimtex
	    nerdtree
	    auto-pairs
	    vim-visual-multi
	    vim-clang-format
	    nvim-treesitter
	    nvim-lspconfig
	    completion-nvim
	    vim-glsl
	    (plugin "folke/lsp-colors.nvim")
	    (plugin "nvim-lua/popup.nvim")
	    (plugin "nvim-lua/plenary.nvim")
	    (plugin "nvim-telescope/telescope.nvim")
      ];
      extraPackages = with pkgs; [
      ];
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withPython3 = true;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.akash = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };
  

  #List packages installed in system profile. To search, run:
  #$ nix search wget
  nixpkgs = {
    overlays = 
      [
        (import (builtins.fetchTarball {
          url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
        }))

	(self: super: {
    	  dwm = super.dwm.overrideAttrs (oldAttrs: rec {
          patches = oldAttrs.patches ++ [
            ./dwm/patches/dwm-vanitygaps-6.2.diff
            ./dwm/patches/dwm-centeredmaster-6.1.diff
          ];
            configFile = super.writeText "config.h" (builtins.readFile ./dwm/dwm-config.h);
            postPatch = 
	      oldAttrs.postPatch or "" + "\necho 'Using own config file...'\n cp ${configFile} config.def.h";
          });
        })
      ];

    config = {
      allowUnfree = true;
    };
  };

  hardware.opengl.enable = true;
  hardware.pulseaudio.support32Bit = true;
  hardware.opengl.extraPackages = with pkgs; [
    linuxPackages.nvidia_x11
  ];

  environment.systemPackages = with pkgs; [
    wget git tmux 
    neovim
    dmenu
    ranger
    qutebrowser python39Packages.adblock
    firefox
    discord
    disfetch
    feh
    zathura
    gcc rustup rust-analyzer ccls

    (st.overrideAttrs (oldAttrs: rec {
      # ligatures dependency
      buildInputs = oldAttrs.buildInputs ++ [ harfbuzz ];
      patches = [
      ];
      # version controlled config file
      configFile = writeText "config.def.h" (builtins.readFile ./st/st-config.h);
      postPatch = "${oldAttrs.postPatch}\n cp ${configFile} config.def.h";
    }))
  ];

  environment.interactiveShellInit = ''
    export XDG_CONFIG_HOME="$HOME/.config"
    export EDITOR=nvim
    export VISUAL=nvim
    export BROWSER=qutebrowser
  '';

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}

