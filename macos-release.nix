let
  pkgs = import <nixpkgs> {};
  echidna = import ./.;
in
  with pkgs; runCommand "echidna-${echidna.version}-bundled-dylibs" {
    buildInputs = [
      macdylibbundler
      darwin.sigtool
      darwin.cctools
    ];
  } ''
    mkdir -p $out/bin
    cp ${echidna}/bin/echidna-test $out/bin/echidna-test
    chmod 755 $out/bin/echidna-test
    dylibbundler -b \
      -x $out/bin/echidna-test \
      -d $out/bin \
      -p '@executable_path'
    # re-sign the binaries since the load paths were modified
    codesign -s - -f $out/bin/*
    tar -czvf $out/echidna-${echidna.version}-${stdenv.system}.tar.gz -C $out/bin .
  ''
