;;; init-dashboard.el --- dashboard configuration -*- lexical-binding: t -*-

;;; Commentary:
;; 使用 straight.el 管理 Dashboard 及其图标依赖

;;; Code:

(defvar my-use-dashboard t "是否启用启动面板。")

;; ==========================================
;; 1. 图标支持 (必须在 Dashboard 之前安装)
;; ==========================================
(use-package nerd-icons
  :straight t)

;; ==========================================
;; 2. Dashboard 主配置
;; ==========================================
(use-package dashboard
  :straight t
  :if my-use-dashboard
  :after nerd-icons
  :diminish dashboard-mode
  :bind
  (("<f2>" . open-dashboard)
   :map dashboard-mode-map
   ("q" . quit-dashboard)
   ("M-r" . restore-session))
  :hook (dashboard-mode . (lambda () (setq-local frame-title-format nil)))
  :init
  (defconst my-homepage-url "https://github.com/k4ngzy")
  
  ;; 设置导航栏按钮
  (setq dashboard-navigator-buttons
        `(((,(nerd-icons-octicon "nf-oct-mark_github")
            "GitHub" "Browse Github homepage"
            (lambda (&rest _) (browse-url my-homepage-url)))
           (,(nerd-icons-octicon "nf-oct-history")
            "Restore" "Restore previous session"
            (lambda (&rest _) (restore-session)))
           (,(nerd-icons-octicon "nf-oct-tools")
            "Settings" "Open custom file"
            (lambda (&rest _) (find-file custom-file)))
           (,(nerd-icons-octicon "nf-oct-download")
            "Update" "Update all packages via straight"
            (lambda (&rest _) 
              (message "Straight: Checking for updates...")
              (straight-pull-all))
            success))))
  
  (dashboard-setup-startup-hook)

  :config
  ;; --- 自定义功能函数 ---

  (defun restore-session ()
    "使用 perspective 恢复上一次的会话。"
    (interactive)
    (message "Restoring previous session...")
    (condition-case err
        (progn
          ;; 确保你已经安装并启用了 perspective 插件
          (if (fboundp 'persp-state-load)
              (progn
                (persp-state-load (expand-file-name "persp-confs" user-emacs-directory))
                (quit-window t)
                (message "Restoring previous session...done"))
            (user-error "Perspective 插件未加载，无法恢复会话")))
      (error 
       (message "Restore failed: %s" (error-message-string err)))))

  (defvar dashboard-recover-layout-p nil "是否需要恢复布局。")

  (defun open-dashboard ()
    "打开 *dashboard* 缓冲区并跳转至第一个组件。"
    (interactive)
    (if (length>
         (window-list-1)
         (if (and (fboundp 'treemacs-current-visibility)
                  (eq (treemacs-current-visibility) 'visible))
             2 1))
        (setq dashboard-recover-layout-p t))
    (delete-other-windows)
    (dashboard-refresh-buffer))

  (defun quit-dashboard ()
    "关闭 dashboard 窗口。"
    (interactive)
    (quit-window t)
    (when dashboard-recover-layout-p
      (cond
       ((bound-and-true-p tab-bar-history-mode) (tab-bar-history-back))
       ((bound-and-true-p winner-mode) (winner-undo)))
      (setq dashboard-recover-layout-p nil)))

  :custom-face
  (dashboard-heading ((t (:inherit (font-lock-string-face bold)))))
  (dashboard-items-face ((t (:weight normal))))
  (dashboard-no-items-face ((t (:weight normal))))

  :custom
  ;; 核心图标设置
  (dashboard-icon-type 'nerd-icons)
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t)
  
  ;; 布局设置
  (dashboard-page-separator "\f\n")
  (dashboard-center-content t)
  (dashboard-vertically-center-content t)
  (dashboard-path-style 'truncate-middle)
  (dashboard-path-max-length 60)
  
  ;; 项目后端
  (dashboard-projects-backend 'project-el)
  
  ;; 横幅设置 (请确保路径下有该图片)
  (dashboard-startup-banner (expand-file-name "assets/GNUEmacs.png" user-emacs-directory))
  (dashboard-image-banner-max-width 400)
  
  ;; 显示项
  (dashboard-items '((recents . 7) (bookmarks . 5) (projects . 5)))
  (dashboard-startupify-list
   '(dashboard-insert-banner
     dashboard-insert-newline
     dashboard-insert-banner-title
     dashboard-insert-newline
     dashboard-insert-navigator
     dashboard-insert-newline
     dashboard-insert-init-info
     dashboard-insert-items
     dashboard-insert-newline
     dashboard-insert-footer)))

;; ==========================================
;; 3. 辅助美化
;; ==========================================
(use-package page-break-lines
  :straight t
  :diminish
  :hook (after-init . global-page-break-lines-mode)
  :config
  (dolist (mode '(dashboard-mode emacs-news-mode))
    (add-to-list 'page-break-lines-modes mode)))

(provide 'init-dashboard)
;;; init-dashboard.el ends here
