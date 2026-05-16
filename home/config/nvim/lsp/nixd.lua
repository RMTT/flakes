return {
    settings = {
        nixd = {
            nixpkgs = {
                expr = 'import (builtins.getFlake ("git+file://" + toString ./.)).inputs.nixpkgs { }',
            },
            formatting = {
                command = { "nixfmt" },
            },
            options = {
                nixos = {
                    expr = '(builtins.getFlake (builtins.toString ./.)).nixosConfigurations.mtspc.options',
                },
                home_manager = {
                    expr = '(builtins.getFlake (builtins.toString ./.)).homeConfigurations.mt.options'
                }
            }
        },
    },
}
