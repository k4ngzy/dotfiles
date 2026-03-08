;;; init-base.el --- The necessary settings -*- lexical-binding: t -*-

;;; Commentary:
;;
;;; Code:

(setopt initial-major-mode 'fundamental-mode) ; default mode for the *scratch* buffer
(setopt display-time-default-load-average nil) ; this information is useless for most
;; Don't delete files diretly
(setq delete-by-moving-to-trash t)
;; Automatically reread from disk if the underlying file changes
(setopt auto-revert-avoid-polling t)
;; Some systems don't do file notifications well; see
;; https://todo.sr.ht/~ashton314/emacs-bedrock/11
(setopt auto-revert-interval 5)
(setopt auto-revert-check-vc-info t)
(global-auto-revert-mode)

;; undo limit
(setq undo-limit (* 64 1024 1024))
(setq undo-strong-limit (* 96 1024 1024))
(setq undo-outer-limit (* 128 1024 1024))

;; Save history of minibuffer
(savehist-mode)
;; Save cursor place
(save-place-mode)
;; Move through windows with Ctrl-<arrow keys>
(windmove-default-keybindings 'control)
;; Fix archaic defaults
(setq sentence-end-double-space nil)
;; close system bell
(setq ring-bell-function 'ignore)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Discovery aids
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun childframe-workable-p ()
  "Whether childframe is workable."
  (and (>= emacs-major-version 26)
       (not noninteractive)
       (not emacs-basic-display)
       (or (display-graphic-p)
           (featurep 'tty-child-frames))
       (eq (frame-parameter (selected-frame) 'minibuffer) 't)))

;; which-key: shows a popup of available keybindings when typing a long key
(use-package
  which-key
  :ensure t
  :defer 0.5
  :config
  (setq which-key-prefix-prefix ""              ; remove +
        which-key-separator " "
        which-key-sort-order 'which-key-local-then-key-order
        which-key-idle-delay 0.4
        which-key-add-column-padding 1)
  (which-key-mode))

;; Most completion settings are handled by Vertico/Corfu/Orderless in init-completion.el
(setopt enable-recursive-minibuffers t) ; Use the minibuffer whilst in the minibuffer

;; Mode line information
(setopt line-number-mode t) ; Show current line in modeline
(setopt column-number-mode t) ; Show column as well
(setq display-line-numbers-type 'relative)
;; (add-hook 'prog-mode-hook 'display-line-numbers-mode)
(global-display-line-numbers-mode t)
(setopt display-line-numbers-width 3)           ; Set a minimum width
(setopt x-underline-at-descent-line nil) ; Prettier underlines
(setopt switch-to-buffer-obey-display-actions t) ; Make switching buffers more consistent

(setopt show-trailing-whitespace nil) ; By default, don't underline trailing spaces
(setopt indicate-buffer-boundaries 'left) ; Show buffer top and bottom in the margin

(setopt indent-tabs-mode nil)

(blink-cursor-mode -1) ; Steady cursor

;; Nice line wrapping when working with text
(add-hook 'text-mode-hook 'visual-line-mode)

;; Modes to highlight the current line with
(let ((hl-line-hooks '(text-mode-hook prog-mode-hook)))
  (mapc (lambda (hook) (add-hook hook 'hl-line-mode)) hl-line-hooks))

;; Fonts
(defun font-available-p (font-name)
  "Check if font with FONT-NAME is available."
  (find-font (font-spec :name font-name)))

(defun setup-fonts ()
  "Setup fonts."
  (when (display-graphic-p)
    ;; Set default font
    (cl-loop for font in '("Jetbrains Mono" "Iosevka SS04" "MonoLisa" "FiraCode Nerd Font" 
                           "CaskaydiaCove Nerd Font" "Fira Code" "Cascadia Code" 
                           "SF Mono" "Menlo" "Hack" "Source Code Pro"
                           "Monaco" "DejaVu Sans Mono" "Consolas")
             when (font-available-p font)
             return (set-face-attribute 'default nil
                                        :family font
                                        :height 140))

    ;; Specify font for all unicode characters
    (cl-loop for font in '("Apple Symbols" "Segoe UI Symbol" "Symbola" "Symbol")
             when (font-available-p font)
             return (set-fontset-font t 'symbol (font-spec :family font) nil 'prepend))

    ;; Emoji
    (cl-loop for font in '("Noto Color Emoji" "Apple Color Emoji" "Segoe UI Emoji")
             when (font-available-p font)
             return (set-fontset-font t 'emoji (font-spec :family font) nil 'prepend))

    ;; Specify font for Chinese characters
    (cl-loop for font in '("Sarasa Mono SC" "LXGW WenKai Mono" "WenQuanYi Micro Hei Mono"
                           "PingFang SC" "Microsoft Yahei UI" "Simhei")
             when (font-available-p font)
             return (progn
                      (setq face-font-rescale-alist `((,font . 1.0)))
                      (set-fontset-font t 'han (font-spec :family font))))
    ))

(add-hook 'window-setup-hook #'setup-fonts)
(add-hook 'server-after-make-frame-hook #'setup-fonts)

;; Child frame
(use-package posframe
  :ensure t
  :custom-face
  (child-frame-border ((t (:inherit posframe-border))))
  :hook (after-load-theme . posframe-delete-all)
  :init
  (defface posframe-border
    `((t (:inherit region)))
    "Face used by the `posframe' border."
    :group 'posframe)
  (defvar posframe-border-width 2
    "Default posframe border width.")
  :config
  (with-no-warnings
    (defun my-posframe--prettify-frame (&rest _)
      (set-face-background 'fringe nil posframe--frame))
    (advice-add #'posframe--create-posframe :after #'my-posframe--prettify-frame)

    (defun posframe-poshandler-frame-center-near-bottom (info)
      (cons (/ (- (plist-get info :parent-frame-width)
                  (plist-get info :posframe-width))
               2)
            (/ (+ (plist-get info :parent-frame-height)
                  (* 2 (plist-get info :font-height)))
               2)))))

(provide 'init-base)
;;; init-base.el ends here
