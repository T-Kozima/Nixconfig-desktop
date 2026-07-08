    { pkgs, ... }:

    {
      # Home Managerを通じて、chronotokeiユーザー向けにkanshiを設定
      home-manager.users.chronotokei = {
        services.kanshi = {
          enable = true;
          # Niriセッションの起動に同期してkanshiを自動起動する設定
          systemdTarget = "graphical-session.target";

          settings = [
            # DP-3単体時のプロファイル
            {
              profile = {
                name = "single-monitor";
                outputs = [
                  {
                    criteria = "DP-3";
                    status = "enable";
                    position = "0,0";
                  }
                ];
              };
            }
            # DP-3とHDMI-A-1接続時のデュアルモニタープロファイル（左側にHDMI-A-1を配置）
            {
              profile = {
                name = "dual-monitor";
                outputs = [
                  {
                    criteria = "DP-3";
                    status = "enable";
                    position = "0,0";
                  }
                  {
                    criteria = "HDMI-A-1";
                    status = "enable";
                    position = "-1920,0";
                  }
                ];
              };
            }
          ];
        };
      };
    }
