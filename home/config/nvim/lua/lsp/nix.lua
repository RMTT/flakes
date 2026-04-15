return {
    settings = {
        nixd = {
            nixpkgs = {
                expr = 'import (builtins.getFlake ("git+file://" + toString ./.)).inputs.nixpkgs { }',
            },
            formatting = {
                command = { "nixfmt" },
            }
        },
    },
}
