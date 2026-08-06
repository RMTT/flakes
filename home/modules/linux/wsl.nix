{ config, pkgs, ... }:
{
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
  ];
  home.file = {
    ".local/bin/gpg" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        exec gpg.exe "$@"
      '';
    };

    ".local/bin/ssh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        exec ssh.exe "$@"
      '';
    };

    ".local/bin/ssh-add" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        exec ssh-add.exe "$@"
      '';
    };
  };
}
