{ ... }:
{
  programs.git = {
    enable = true;
    ignores = [
      ".direnv"
      "compile_commands.json"
      ".cache"
    ];
    signing = {
      signByDefault = true;
      key = "d.rong@outlook.com";
    };
    settings = {
      init.defaultBranch = "main";
      credential."https://github.com".helper = "!/usr/bin/env gh auth git-credential";
      credential."https://gist.github.com".helper = "!/usr/bin/env gh auth git-credential";
      user.name = "RMT";
      user.email = "d.rong@outlook.com";
    };
  };
}
