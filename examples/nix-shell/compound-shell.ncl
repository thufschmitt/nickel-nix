{
  inputs = {
    hello = { input = "nixpkgs" },
    python3 = { input = "nixpkgs" },
    perl = { input = "nixpkgs" },
  }

  , output = fun { pkgs, nix, system } =>
    let system_ = system in
    let
      myHello = {
        name = "hello-from-nickel",

        builder = nix.lib.nix_string_hack [ pkgs.python3, "/bin/python" ],

        args = [
          "-c",
          m%"
            import os
            import sys
            import stat

            outFile = os.getenv("out")

            with open(outFile, "w") as out:
                print(f"""#!/bin/sh

            echo "Welcome to my shell"
            """, file = out)

            os.chmod(outFile, stat.S_IEXEC)
          "%m,
        ],
        system = system_,
        type = "nickelPackage",
      } | nix.Derivation
    in
    {
       name = "hello"

       , packages = [
          pkgs.python3,
          pkgs.perl,
       ]

       # Need the string hack because `myHello` wouldn’t be in scope otherwise
       , shellHook = nix.lib.nix_string_hack [
          myHello
       ]
    } | nix.Shell,
}

