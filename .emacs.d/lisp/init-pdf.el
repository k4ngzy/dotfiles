;;; init-pdf.el --- Better pdf read for Emacs -*- lexical-binding: t -*-

;;; Commentary:
;; 使用 straight.el 管理 pdf-tools

;;; Code:

(when (display-graphic-p)
  ;; 1. 安装 pdf-tools 主程序
  (use-package pdf-tools
    :straight t
    :mode ("\\.[pP][dD][fF]\\'" . pdf-view-mode)
    :magic ("%PDF" . pdf-view-mode)
    :init
    (setq pdf-view-use-scaling t
          pdf-view-use-imagemagick nil
          pdf-annot-activate-created-annotations t)
    :config
    ;; 核心：安装 pdf-tools 的后端程序
    ;; 第一个参数 t 表示自动安装，不再询问
    (pdf-tools-install t nil t nil)
    
    ;; 关联相关模式
    (add-hook 'pdf-tools-enabled-hook #'pdf-view-auto-slice-minor-mode)
    (add-hook 'pdf-tools-enabled-hook #'pdf-isearch-minor-mode))

  ;; 2. 配置 pdf-view (它是 pdf-tools 的一部分，无需再次下载)
  (use-package pdf-view
    :straight nil
    :after pdf-tools
    :diminish (pdf-view-themed-minor-mode
               pdf-view-midnight-minor-mode
               pdf-view-printer-minor-mode)
    :bind (:map pdf-view-mode-map
                ("C-s" . isearch-forward)
                ("j" . pdf-view-scroll-up-or-next-page)
                ("k" . pdf-view-scroll-down-or-previous-page)
                ("g" . pdf-view-goto-page)
                ("<f9>" . my/pdf-view-open-external-simple))
    :config
    ;; 外部程序打开 PDF 的函数
    (defun my/pdf-view-open-external-simple ()
      "用系统默认程序打开当前 PDF 文件。"
      (interactive)
      (let ((file (buffer-file-name)))
        (unless file
          (user-error "当前缓冲区没有关联文件"))
        (cond
         ((eq system-type 'windows-nt)
          (shell-command (format "start \"\" \"%s\"" (shell-quote-argument file))))
         ((eq system-type 'darwin)
          (shell-command (format "open %s" (shell-quote-argument file))))
         (t
          (shell-command (format "xdg-open %s" (shell-quote-argument file))))))))

  ;; 3. 记住 PDF 阅读位置的插件
  (use-package saveplace-pdf-view
    :straight t
    :after pdf-tools
    :init
    (advice-add 'save-place-find-file-hook :around #'saveplace-pdf-view-find-file-advice)
    (advice-add 'save-place-to-alist :around #'saveplace-pdf-view-to-alist-advice)))

(provide 'init-pdf)
;;; init-pdf.el ends here
