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
      key = "iamrmttt@gmail.com";
    };
    settings = {
      init.defaultBranch = "main";
      credential."https://github.com".helper = "!/usr/bin/env gh auth git-credential";
      credential."https://gist.github.com".helper = "!/usr/bin/env gh auth git-credential";
      user.name = "RMT";
      user.email = "iamrmttt@gmail.com";
    };
  };
}
