;;; init-completion.el --- Initialize completion configurations.	-*- lexical-binding: t -*-
;;; Commentary:
;;
;; Modern completion configuration.
;;

;;; Code:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Motion aids
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package
  avy
  :ensure t
  :bind
  (("M-g l" . avy-goto-line)
   ("M-g s" . avy-goto-char-timer)
   ;; avy Original Life Order, suitable for operation line
   ("M-g k" . avy-kill-whole-line)   ; 远程删除行（Kill）
   ("M-g M-k" . avy-kill-region)     ; 远程删除区域
   ("M-g w" . avy-copy-line)         ; 远程拷贝行 (Work-around for copy)
   ("M-g M-w" . avy-copy-region)     ; 远程拷贝区域
   ("M-g m" . avy-move-line))        ; 远程移动行 (Move)
  :config
  (setq avy-all-windows t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Power-ups: Embark and Consult
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Consult: Misc. enhanced commands
(use-package
  consult
  :ensure t
  :bind
  (
   ;; Drop-in replacements
   ("C-x b" . consult-buffer) ; orig. switch-to-buffer
   ("M-y" . consult-yank-pop) ; orig. yank-pop
   ;; Searching
   ("M-s r" . consult-ripgrep)
   ("M-s l" . consult-line) ; Alternative: rebind C-s to use
   ("M-s s" . consult-line) ; consult-line instead of isearch, bind
   ("M-s L" . consult-line-multi) ; isearch to M-s s
   ("M-s o" . consult-outline)
   ;; Isearch integration
   :map isearch-mode-map
   ("M-e" . consult-isearch-history) ; orig. isearch-edit-string
   ("M-s e" . consult-isearch-history) ; orig. isearch-edit-string
   ("M-s l" . consult-line) ; needed by consult-line to detect isearch
   ("M-s L" . consult-line-multi) ; needed by consult-line to detect isearch
   )
  :config
  ;; Narrowing lets you restrict results to certain groups of candidates
  (setq consult-narrow-key "<"))

(use-package
  embark
  :ensure t
  :after avy
  :bind (("C-c a" . embark-act)) ; bind this to an easy key to hit
  :init
  ;; Add the option to run embark when using avy
  ;; suitable for operation word
  (defun my/avy-action-embark (pt)
    (unwind-protect
        (save-excursion
          (goto-char pt)
          (embark-act))
      (select-window (cdr (ring-ref avy-ring 0))))
    t)

  ;; After invoking avy-goto-char-timer, hit "." to run embark at the next
  ;; candidate you select
  (setf (alist-get ?. avy-dispatch-alist) 'my/avy-action-embark))

(use-package embark-consult :ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Minibuffer and completion
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Vertico: better vertical completion for minibuffer commands
(use-package vertico
  :straight (:files (:defaults "extensions/*.el"))
  :init
  (vertico-mode 1))

(use-package vertico-directory
  :straight nil
  :after vertico
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package vertico-prescient
  :after (vertico prescient)
  :ensure t
  :config
  (vertico-prescient-mode 1)
  (prescient-persist-mode 1))

;; Marginalia: annotations for minibuffer
(use-package marginalia :ensure t :config (marginalia-mode))

;; Popup completion-at-point
(use-package
  corfu
  :straight (:files (:defaults "extensions/*.el"))
  :ensure t
  :init (global-corfu-mode)
  :custom
  (corfu-auto t)
  (corfu-cycle t)
  (corfu-auto-delay 0.1)
  (corfu-auto-prefix 2)
  (corfu-preselect 'prompt)
  (corfu-auto-trigger ".") ;; Custom trigger characters
  (corfu-quit-no-match 'separator) ;; or t
  :bind
  (:map corfu-map
        ("TAB" . corfu-insert)
        ([tab] . corfu-insert)
        ("C-n" . corfu-next)
        ("C-p" . corfu-previous)
        ("SPC" . corfu-insert-separator)))

;; Part of corfu
(use-package
  corfu-popupinfo
  :straight nil
  :after corfu
  :hook (corfu-mode . corfu-popupinfo-mode)
  :custom
  (corfu-popupinfo-delay '(0.25 . 0.1))
  (corfu-popupinfo-hide nil)
  :bind (:map corfu-map
              ("M-p" . corfu-popupinfo-scroll-down) ; 往回滚文档
              ("M-n" . corfu-popupinfo-scroll-up))   ; 往下滚文档
  :config (corfu-popupinfo-mode))

;; Fancy completion-at-point functions; there's too much in the cape package to
;; configure here; dive in when you're comfortable!
(use-package
  cape
  :ensure t
  :defer t
  :init
  (add-to-list
   'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file))

(defun my/setup-elisp-completion ()
  (setq-local completion-at-point-functions
              (list (cape-capf-super
                     #'elisp-completion-at-point
                     #'cape-dabbrev))))

(add-hook 'emacs-lisp-mode-hook #'my/setup-elisp-completion)

;; Pretty icons for corfu
(use-package
  nerd-icons-corfu
  :ensure t
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;; Pretty icons for files
(use-package nerd-icons-completion
  :ensure t
  :after marginalia
  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(use-package
  eshell
  :init
  (defun my/setup-eshell ()
    ;; Something funny is going on with how Eshell sets up its keymaps; this is
    ;; a work-around to make C-r bound in the keymap
    (keymap-set eshell-mode-map "C-r" 'consult-history))
  :hook ((eshell-mode . my/setup-eshell)))

;; Orderless: powerful completion style
(use-package
  orderless
  :ensure t
  :config
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles basic partial-completion)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Misc. editing enhancements
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Modify search results en masse
(use-package
  wgrep
  :ensure t
  :defer t
  :config (setq wgrep-auto-save-buffer t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   UI optimization
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package vertico-posframe
  :ensure t
  :after vertico
  :config
  (vertico-posframe-mode 1)
  (setq vertico-posframe-poshandler #'posframe-poshandler-frame-center-near-bottom)
  (setq vertico-posframe-border-width 1))

(provide 'init-completion)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; init-completion.el ends here
