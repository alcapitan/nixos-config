{ pkgs-unstable, ... }:

{
  # * cat ~/.config/zed/settings.json
  # ! TODO: zed ne pourra plus modifier ses paramètres après que le fichier de config actuel soit supprimé
  programs.zed-editor = {
    enable = true;
    package = pkgs-unstable.zed-editor;
    userSettings = {
      auto_install_extensions = {
        nix = true;
        html = true;
        dockerfile = true;
        comment = true;
        git-firefly = true;
        material-icon-theme = true;
      };
      diff_view_style = "split";
      cli_default_open_behavior = "existing_window";
      icon_theme = "Material Icon Theme";
      agent = {
        button = false;
      };
      collaboration_panel.button = false;
      outline_panel.button = false;
      git_panel = {
        group_by = "staging";
        collapse_untracked_diff = false;
        button = true;
        status_style = "label_color";
        dock = "left";
        tree_view = true;
      };
      project_panel = {
        hide_root = true;
        git_status_indicator = false;
        bold_folder_labels = false;
        git_status = true;
        folder_icons = true;
        file_icons = true;
        entry_spacing = "comfortable";
        dock = "left";
      };
      colorize_brackets = true;
      toolbar = {
        agent_review = true;
        quick_actions = true;
        breadcrumbs = true;
      };
      minimap.show = "always";
      gutter.line_numbers = true;
      autosave = "on_window_change";
      ui_font_size = 16;
      buffer_font_size = 15;
      theme = {
        mode = "system";
        light = "One Light";
        dark = "One Dark";
      };
    };
  };
}
