{
  lib,
  stdenv,
  fetchFromSourcehut,
  SDL2,
  unstableGitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "uxn";
  version = "1.0-unstable-2025-01-31";

  src = fetchFromSourcehut {
    owner = "~rabbits";
    repo = "uxn";
    rev = "5829f7da504f77dbc44037250871befd64da79b3";
    hash = "sha256-7dXHcIFw3knxuib1BbdLyF+LNdBrFAQMNQkk+S5XmlY=";
  };

  outputs = [
    "out"
    "projects"
  ];

  nativeBuildInputs = [
    SDL2
  ];

  buildInputs = [
    SDL2
  ];

  strictDeps = true;

  postPatch = ''
    patchShebangs build.sh
    substituteInPlace build.sh \
      --replace "-L/usr/local/lib " ""
  '';

  buildPhase = ''
    runHook preBuild

    ./build.sh --no-run

    runHook postBuild
  '';

  # ./build.sh --install is meant to install in $HOME, therefore not useful for
  # package maintainers
  installPhase = ''
    runHook preInstall

    install -d $out/bin/
    cp bin/uxnasm bin/uxncli bin/uxnemu $out/bin/
    install -d $projects/share/uxn/
    cp -r projects $projects/share/uxn/

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    homepage = "https://wiki.xxiivv.com/site/uxn.html";
    description = "Assembler and emulator for the Uxn stack machine";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "uxnemu";
    inherit (SDL2.meta) platforms;
    broken = stdenv.hostPlatform.isDarwin;
  };
})
