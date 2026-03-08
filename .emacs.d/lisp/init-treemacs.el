(use-package treemacs
  :ensure t
  :defer t
  :config
  (setq treemacs-no-png-images t) ; 如果你的系统图标渲染有问题，可以开启此项
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

;; 集成 Projectile (可选)
;; (use-package treemacs-projectile
;;   :after (treemacs projectile)
;;   :ensure t)



(provide 'init-treemacs)
