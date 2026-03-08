;;; init-python.el --- Python IDE

;; 使用 tree-sitter python
(add-to-list 'major-mode-remap-alist '(python-mode . python-ts-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LSP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package eglot
  :ensure t
  :hook (python-ts-mode . eglot-ensure)
  :config
  (add-to-list 'eglot-server-programs
               '(python-ts-mode . ("pyright-langserver" "--stdio"))))

(use-package conda
  :ensure t
  :config
  (setq conda-anaconda-home (expand-file-name "~/miniconda3"))
  (setq conda-env-home-directory (expand-file-name "~/miniconda3"))

  (conda-mode-line-setup)
  (add-hook 'conda-postactivate-hook (lambda () (call-interactively #'eglot-reconnect)))

  (conda-env-initialize-interactive-shells)
  (conda-env-initialize-eshell))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Ruff (lint + format)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package apheleia
  :ensure t
  :config
  ;; 定义 ruff 的具体命令，确保它能被找到
  (setf (alist-get 'ruff apheleia-formatters)
        '("ruff" "format" "--stdin-filename" filepath "-"))
  (setf (alist-get 'ruff-isort apheleia-formatters)
        '("ruff" "check" "--select" "I" "--fix" "--stdin-filename" filepath "-"))

  ;; 确保 python-mode 和 python-ts-mode 都生效
  (setf (alist-get 'python-mode apheleia-mode-alist) '(ruff-isort ruff))
  (setf (alist-get 'python-ts-mode apheleia-mode-alist) '(ruff-isort ruff))

  (apheleia-global-mode +1))

(provide 'init-python)
