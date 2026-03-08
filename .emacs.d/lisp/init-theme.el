(use-package doom-themes
  :ensure t
  :config
  ;; 设置默认主题
  (load-theme 'doom-one t)
  ;; 如果你想要在 Org-mode 中有更漂亮的效果
  (doom-themes-org-config))

;; ==========================================
;; 5. 安装并配置 Doom Modeline (状态栏)
;; ==========================================
(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom
  (doom-modeline-icon-set 'nerd-icons)
  (doom-modeline-height 25)     ; 状态栏高度
  (doom-modeline-bar-width 3)   ; 左侧修饰条宽度
  (doom-modeline-icon t)        ; 显示图标
  (doom-modeline-major-mode-icon t) ; 显示主模式图标
  (doom-modeline-buffer-encoding t)) ; 显示文件编码

(provide 'init-theme)
