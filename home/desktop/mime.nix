{ ... }:

{
  # Applications par défaut
  # * cat ~/.config/mimeapps.list
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/jpeg" = [ "org.kde.koko.desktop" ];
      "image/png" = [ "org.kde.koko.desktop" ];
      "image/webp" = [ "org.kde.koko.desktop" ];
      "image/gif" = [ "org.kde.koko.desktop" ];
      "image/bmp" = [ "org.kde.koko.desktop" ];
      "image/tiff" = [ "org.kde.koko.desktop" ];
      "image/avif" = [ "org.kde.koko.desktop" ];
      "image/heic" = [ "org.kde.koko.desktop" ];
      "image/heif" = [ "org.kde.koko.desktop" ];

      "video/mp4" = [ "vlc.desktop" ];
      "video/x-matroska" = [ "vlc.desktop" ];
      "video/webm" = [ "vlc.desktop" ];
      "video/vnd.avi" = [ "vlc.desktop" ]; # AVI
      "video/quicktime" = [ "vlc.desktop" ]; # MOV
      "video/mpeg" = [ "vlc.desktop" ];
      "video/ogg" = [ "vlc.desktop" ];

      "audio/mpeg" = [ "vlc.desktop" ]; # MP3
      "audio/mp3" = [ "vlc.desktop" ];
      "audio/mp4" = [ "vlc.desktop" ]; # M4A / AAC
      "audio/aac" = [ "vlc.desktop" ];
      "audio/flac" = [ "vlc.desktop" ];
      "audio/ogg" = [ "vlc.desktop" ];
      "audio/opus" = [ "vlc.desktop" ];
      "audio/wav" = [ "vlc.desktop" ];
      "audio/webm" = [ "vlc.desktop" ];

      "application/pdf" = [ "org.kde.okular.desktop" ];
      "application/vnd.oasis.opendocument.text" = [ "writer.desktop" ]; # ODT
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [ "writer.desktop" ]; # DOCX
      "application/msword" = [ "writer.desktop" ]; # DOC
      "application/rtf" = [ "writer.desktop" ];
      "application/vnd.oasis.opendocument.spreadsheet" = [ "calc.desktop" ]; # ODS
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [ "calc.desktop" ]; # XLSX
      "application/vnd.ms-excel" = [ "calc.desktop" ]; # XLS
      "text/csv" = [ "calc.desktop" ];
      "application/vnd.oasis.opendocument.presentation" = [ "impress.desktop" ]; # ODP
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [ "impress.desktop" ]; # PPTX
      "application/vnd.ms-powerpoint" = [ "impress.desktop" ]; # PPT

      "application/json" = [ "org.kde.kwrite.desktop" ];
      "application/xml" = [ "org.kde.kwrite.desktop" ];
      "application/yaml" = [ "org.kde.kwrite.desktop" ];
      "text/markdown" = [ "org.kde.kwrite.desktop" ];
      "text/plain" = [ "org.kde.kwrite.desktop" ];
      "text/html" = [ "librewolf.desktop" ];
      "application/vnd.ms-publisher" = [ "org.kde.kwrite.desktop" ]; # PUB ssh instead of ms publisher

      "application/zip" = [ "org.kde.ark.desktop" ];
      "application/x-tar" = [ "org.kde.ark.desktop" ];
      "application/x-compressed-tar" = [ "org.kde.ark.desktop" ];
      "application/gzip" = [ "org.kde.ark.desktop" ];
      "application/x-xz" = [ "org.kde.ark.desktop" ];
      "application/x-xz-compressed-tar" = [ "org.kde.ark.desktop" ];
      "application/x-7z-compressed" = [ "org.kde.ark.desktop" ];
      "application/vnd.rar" = [ "org.kde.ark.desktop" ];
      "application/x-rar" = [ "org.kde.ark.desktop" ];
      "application/zstd" = [ "org.kde.ark.desktop" ];
      "application/x-zstd" = [ "org.kde.ark.desktop" ];

      "x-scheme-handler/http" = [ "librewolf.desktop" ];
      "x-scheme-handler/https" = [ "librewolf.desktop" ];
      "x-scheme-handler/about" = [ "librewolf.desktop" ];
      "x-scheme-handler/unknown" = [ "librewolf.desktop" ];
      "x-scheme-handler/beeper" = [ "beepertexts.desktop" ];
      "x-scheme-handler/geo" = [ "openstreetmap-geo-handler.desktop" ];
      "inode/directory" = [ "org.kde.dolphin.desktop" ];
      "x-scheme-handler/mailto" = [ "userapp-Thunderbird-CMC7R3.desktop" ];
      "x-scheme-handler/mid" = [ "userapp-Thunderbird-CMC7R3.desktop" ];
      "message/rfc822" = [ "userapp-Thunderbird-CMC7R3.desktop" ];
    };
  };
  home.preferXdgDirectories = true;
  xdg.configFile."mimeapps.list".force = true; # ! destructif ; rm ~/.config/mimeapps.list
  xdg.dataFile."applications/mimeapps.list".force = true;
}
