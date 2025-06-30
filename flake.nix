{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    neocord.url = "github:IogaMaster/neocord";
    prismlauncher.url = "github:PrismLauncher/PrismLauncher";
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, prismlauncher, ... } @ inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      system = "x86_64-linux";
      modules = [ ./configuration.nix
	(
	  {pkgs, ...}: {
	    environment.systemPackages = [prismlauncher.packages.${pkgs.system}.prismlauncher];
	  }
	)
      ];
    };
  }; 
}
