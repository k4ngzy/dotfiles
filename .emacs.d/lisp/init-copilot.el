;; init-copilot.el --- Copilot configuration -*- lexical-binding: t -*-
;;; Commentary:
;;; 
;;; Code:

(use-package copilot
  :straight (:host github :repo "copilot-emacs/copilot.el" :files ("*.el" "dist"))
  :hook ((prog-mode . copilot-mode)
         (text-mode . copilot-mode)
         (conf-mode . copilot-mode))
  :config
  (setq copilot-idle-delay 0.5)
  (setq copilot-max-char 1000000)
  ;; 1. 深度静音：拦截 copilot 内部的错误提示逻辑
  (defun my/copilot-quiet-error-h (orig-fun &rest args)
    "静音特定的取消请求错误"
    (let ((err-msg (format "%s" (nth 1 args))))
      (unless (and (stringp err-msg)
                   (string-match-p "-32800" err-msg))
        (apply orig-fun args))))
  
  (advice-add 'copilot--handle-error :around #'my/copilot-quiet-error-h)

  ;; 2. 优化已有的 message 拦截 (确保匹配更精准)
  (defun my/silence-copilot-cancel-error (orig-fun format-string &rest args)
    (let ((msg (condition-case nil (apply #'format format-string args) (error ""))))
      (unless (string-match-p "textDocument/inlineCompletion failed: (:code -32800" msg)
        (apply orig-fun format-string args))))
  (advice-add 'message :around #'my/silence-copilot-cancel-error)

  ;; 由于 `lisp-indent-offset' 的默认值是 nil，在编辑 elisp 时每敲一个字
  ;; 符都会跳出一个 warning，将其默认值设置为 t 以永不显示这个 warning
  (setq-default copilot--indent-warning-printed-p t
                copilot-indent-offset-warning-disable t)

  ;; 文件超出 `copilot-max-char' 的时候不要弹出一个 warning 的 window
  (defun my-copilot-get-source-suppress-warning (original-function &rest args)
    "Advice to suppress display-warning in copilot--get-source."
    (cl-letf (((symbol-function 'display-warning) (lambda (&rest args) nil)))
      (apply original-function args)))
  (advice-add 'copilot--get-source :around #'my-copilot-get-source-suppress-warning)

  (define-key copilot-mode-map (kbd "<tab>") 'copilot-accept-completion)
  (define-key copilot-mode-map (kbd "C-<right>") 'copilot-accept-completion-by-word))

(provide 'init-copilot)
;; init-copilot.el ends here
