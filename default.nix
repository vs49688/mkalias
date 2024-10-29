{ stdenv
, lib
, version
, cmake
, darwin
}:

stdenv.mkDerivation(finalAttrs: {
  inherit version;

  pname = "mkalias";

  src = ./.;

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    darwin.apple_sdk.frameworks.Foundation
  ];

  cmakeFlags = [
    "-DMKALIAS_VERSION=${finalAttrs.version}"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 mkalias $out/bin/mkalias

    runHook postInstall
  '';


  meta = {
    description = "Quick'n'dirty tool to make APFS aliases";
    homepage = "https://github.com/vs49688/mkalias";
    license = lib.licenses.gpl2Only;
    mainProgram = "mkalias";
    maintainers = with lib.maintainers; [ zane ];
    platforms = lib.platforms.darwin;
  };
})
