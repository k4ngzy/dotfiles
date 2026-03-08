(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status))

;; 集成 Magit (显示 Git 状态图标)
(use-package treemacs-magit
  :after (treemacs magit)
  :ensure t)

(provide 'init-git)
